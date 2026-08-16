"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.STATUS_PENDING_DELETION = exports.STATUS_ACTIVE = exports.RETENTION_DAYS = void 0;
exports.isPendingDeletion = isPendingDeletion;
exports.assertNotPendingDeletion = assertNotPendingDeletion;
exports.commitInChunks = commitInChunks;
exports.deleteStorageFolder = deleteStorageFolder;
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
 * users/{uid} 를 읽어 탈퇴 대기 상태면 `failed-precondition` 으로 막는다.
 *
 * 로그인 함수(kakao/naver/phone)가 Custom Token을 발급하기 **전에** 호출한다.
 * Auth 계정이 disabled 라 어차피 signInWithCustomToken 이 거부되지만,
 * 여기서 막아야 앱이 "왜 안 되는지"(재가입 가능일)를 사용자에게 보여줄 수 있다.
 */
async function assertNotPendingDeletion(uid) {
    var _a;
    const snap = await admin.firestore().collection("users").doc(uid).get();
    if (!snap.exists)
        return;
    const data = snap.data();
    if (!isPendingDeletion(data))
        return;
    const purgeAt = data === null || data === void 0 ? void 0 : data.purgeAt;
    // details 에 purgeAt 을 실어 앱이 "언제부터 재가입 가능한지"를 보여줄 수 있게 한다.
    throw new v1_1.https.HttpsError("failed-precondition", "탈퇴 처리 중인 계정입니다.", { purgeAt: (_a = purgeAt === null || purgeAt === void 0 ? void 0 : purgeAt.toMillis()) !== null && _a !== void 0 ? _a : null });
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
//# sourceMappingURL=account_common.js.map