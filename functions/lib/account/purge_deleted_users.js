"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.purgeDeletedUsers = void 0;
const v1_1 = require("firebase-functions/v1");
const admin = require("firebase-admin");
const account_common_1 = require("./account_common");
/** 한 회차에 처리할 최대 유저 수. 함수 실행 시간(기본 60s)을 넘기지 않게. */
const MAX_USERS_PER_RUN = 50;
/**
 * 보관 기간(30일)이 지난 탈퇴 계정을 완전 파기한다. 매일 KST 04:30.
 *
 * `requestAccountDeletion` 이 이미 노출을 막고 집계를 감산해 뒀으므로,
 * 여기서는 **집계를 다시 건드리지 않는다**. 문서 삭제로 발화하는
 * `onReviewDeleted`·`onFavoriteDeleted` 는 `isHidden === true` 가드로
 * 스스로 빠진다 — 없으면 rating·favoriteCount 가 두 번 깎여 음수가 된다.
 */
exports.purgeDeletedUsers = v1_1.pubsub
    .schedule("every day 04:30")
    .timeZone("Asia/Seoul")
    .onRun(async () => {
    const db = admin.firestore();
    const now = admin.firestore.Timestamp.now();
    const snap = await db
        .collection("users")
        .where("status", "==", account_common_1.STATUS_PENDING_DELETION)
        .where("purgeAt", "<=", now)
        .limit(MAX_USERS_PER_RUN)
        .get();
    if (snap.empty) {
        v1_1.logger.info("purgeDeletedUsers: 파기 대상 없음");
        return;
    }
    let purged = 0;
    for (const doc of snap.docs) {
        try {
            await purgeUser(doc.id);
            purged++;
        }
        catch (e) {
            // 한 명 때문에 배치 전체가 죽으면 안 된다. 다음 회차에 다시 잡힌다.
            v1_1.logger.error(`purgeDeletedUsers: uid=${doc.id} 파기 실패`, e);
        }
    }
    v1_1.logger.info(`purgeDeletedUsers: ${purged}/${snap.size} 파기 완료`);
});
/**
 * uid 하나에 딸린 모든 데이터를 지운다.
 *
 * Auth 유저 삭제를 **맨 마지막**에 두는 이유 — 앞 단계가 실패해도
 * `users/{uid}` 문서가 남아 다음 회차 쿼리에 다시 잡힌다. Auth를 먼저 지우면
 * 다시 잡히긴 해도 계정 없이 데이터만 떠도는 구간이 생긴다.
 */
async function purgeUser(uid) {
    var _a;
    const db = admin.firestore();
    // 1) 리뷰 — Storage 첨부 이미지 먼저, 그다음 문서
    const reviews = await db
        .collectionGroup("reviews")
        .where("userId", "==", uid)
        .get();
    for (const doc of reviews.docs) {
        const clubId = (_a = doc.ref.parent.parent) === null || _a === void 0 ? void 0 : _a.id;
        if (clubId) {
            await (0, account_common_1.deleteStorageFolder)(`reviews/${clubId}/${doc.id}/`);
        }
    }
    await (0, account_common_1.commitInChunks)(reviews.docs, (batch, doc) => batch.delete(doc.ref));
    // 2) 사진
    const photos = await db
        .collectionGroup("photos")
        .where("userId", "==", uid)
        .get();
    await (0, account_common_1.commitInChunks)(photos.docs, (batch, doc) => batch.delete(doc.ref));
    // 3) 찜
    const favorites = await db
        .collection("favorites")
        .where("userId", "==", uid)
        .get();
    await (0, account_common_1.commitInChunks)(favorites.docs, (batch, doc) => batch.delete(doc.ref));
    // 4) 검색 기록 (users/{uid} 하위 컬렉션 — 문서를 지워도 자동으로 안 사라진다)
    const history = await db
        .collection("users")
        .doc(uid)
        .collection("searchHistory")
        .get();
    await (0, account_common_1.commitInChunks)(history.docs, (batch, doc) => batch.delete(doc.ref));
    // 5) 프로필 이미지
    await (0, account_common_1.deleteStorageFolder)(`users/${uid}/`);
    // 6) 유저 문서
    await db.collection("users").doc(uid).delete();
    // 7) Auth 계정 — 이미 없으면 무시
    try {
        await admin.auth().deleteUser(uid);
    }
    catch (e) {
        v1_1.logger.warn(`purgeUser: Auth 삭제 건너뜀 uid=${uid}`, e);
    }
    v1_1.logger.info(`purgeUser: uid=${uid} reviews=${reviews.size} photos=${photos.size} ` +
        `favorites=${favorites.size} history=${history.size}`);
}
//# sourceMappingURL=purge_deleted_users.js.map