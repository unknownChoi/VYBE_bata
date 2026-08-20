"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.STATUS_PENDING_DELETION = exports.STATUS_ACTIVE = exports.RETENTION_DAYS = void 0;
exports.isPendingDeletion = isPendingDeletion;
exports.pendingDeletionError = pendingDeletionError;
exports.commitInChunks = commitInChunks;
exports.deleteStorageFolder = deleteStorageFolder;
exports.applyRatingDelta = applyRatingDelta;
exports.applyFavoriteDelta = applyFavoriteDelta;
const v1_1 = require("firebase-functions/v1");
const admin = require("firebase-admin");
/** 탈퇴 요청 후 데이터를 보관하는 기간. 이 기간이 지나면 완전 파기. */
exports.RETENTION_DAYS = 30;
/** users/{uid}.status 값 */
exports.STATUS_ACTIVE = "active";
exports.STATUS_PENDING_DELETION = "pendingDeletion";
/**
 * 탈퇴 대기 상태인지. `status` 필드가 없는 기존 문서는 active로 본다.
 */
function isPendingDeletion(data) {
    return (data === null || data === void 0 ? void 0 : data.status) === exports.STATUS_PENDING_DELETION;
}
/**
 * 탈퇴 대기 계정의 로그인을 거부할 때 던지는 에러.
 *
 * `details.purgeAt` 을 실어 앱이 "언제부터 다시 가입할 수 있는지"를 보여줄 수
 * 있게 한다 (앱: `AccountPendingDeletionException`).
 *
 * 보관 기간이 **남아 있으면** 거부가 아니라 복구다 —
 * `restorePendingDeletionOnLogin` 참고. 이 에러는 파기 시점이 이미 지나
 * 되살릴 수 없는 경우에만 쓴다.
 */
function pendingDeletionError(purgeAtMillis) {
    return new v1_1.https.HttpsError("failed-precondition", "탈퇴 처리 중인 계정입니다.", { purgeAt: purgeAtMillis });
}
/**
 * 문서를 Firestore 배치 한도(500)에 맞춰 나눠 쓴다.
 *
 * `apply` 는 배치에 쓰기를 하나만 거는 것을 전제로 한다 — 문서당 쓰기가
 * 둘 이상이면 chunk 크기를 줄여 호출할 것.
 */
async function commitInChunks(items, apply, chunkSize = 500) {
    const db = admin.firestore();
    for (let i = 0; i < items.length; i += chunkSize) {
        const batch = db.batch();
        items.slice(i, i + chunkSize).forEach((item) => apply(batch, item));
        await batch.commit();
    }
}
/**
 * Storage 경로 prefix 아래 파일을 전부 지운다. 실패해도 던지지 않는다 —
 * 파기 배치가 파일 하나 때문에 멈추면 안 된다(다음 회차에 다시 시도된다).
 */
async function deleteStorageFolder(prefix) {
    try {
        await admin.storage().bucket().deleteFiles({ prefix });
    }
    catch (e) {
        // 파일이 없거나 권한 문제 — 로그만 남기고 진행
        console.warn(`deleteStorageFolder failed: ${prefix}`, e);
    }
}
/**
 * clubs/{clubId} 의 ratingSum·reviewCount 를 델타만큼 옮기고 rating 재계산.
 *
 * 탈퇴 숨김(감산)과 복구(가산)가 같은 함수를 부호만 바꿔 쓴다 —
 * 두 경로가 어긋나면 평점이 영구히 틀어진다.
 */
async function applyRatingDelta(clubId, sumDelta, countDelta) {
    const clubRef = admin.firestore().collection("clubs").doc(clubId);
    await admin.firestore().runTransaction(async (tx) => {
        var _a, _b, _c;
        const snap = await tx.get(clubRef);
        if (!snap.exists)
            return;
        const club = (_a = snap.data()) !== null && _a !== void 0 ? _a : {};
        const newSum = Math.max(0, ((_b = club.ratingSum) !== null && _b !== void 0 ? _b : 0) + sumDelta);
        const newCount = Math.max(0, ((_c = club.reviewCount) !== null && _c !== void 0 ? _c : 0) + countDelta);
        tx.update(clubRef, {
            ratingSum: newSum,
            reviewCount: newCount,
            rating: newCount > 0 ? Math.round((newSum / newCount) * 10) / 10 : 0,
        });
    });
}
/** clubs/{clubId} 의 favoriteCount 를 델타만큼 옮긴다 (0 미만 방지). */
async function applyFavoriteDelta(clubId, delta) {
    const clubRef = admin.firestore().collection("clubs").doc(clubId);
    await admin.firestore().runTransaction(async (tx) => {
        var _a, _b;
        const snap = await tx.get(clubRef);
        if (!snap.exists)
            return;
        const current = (_b = (_a = snap.data()) === null || _a === void 0 ? void 0 : _a.favoriteCount) !== null && _b !== void 0 ? _b : 0;
        tx.update(clubRef, { favoriteCount: Math.max(0, current + delta) });
    });
}
//# sourceMappingURL=account_common.js.map