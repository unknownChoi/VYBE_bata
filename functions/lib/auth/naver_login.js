"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.naverLogin = void 0;
const v1_1 = require("firebase-functions/v1");
const admin = require("firebase-admin");
const axios_1 = require("axios");
const restore_account_1 = require("../account/restore_account");
exports.naverLogin = v1_1.https.onCall(async (data) => {
    var _a, _b, _c;
    const accessToken = data === null || data === void 0 ? void 0 : data.accessToken;
    if (!accessToken) {
        throw new v1_1.https.HttpsError("invalid-argument", "accessToken이 필요합니다.");
    }
    let naverId;
    try {
        const response = await axios_1.default.get("https://openapi.naver.com/v1/nid/me", {
            headers: { Authorization: `Bearer ${accessToken}` },
        });
        naverId = (_b = (_a = response.data) === null || _a === void 0 ? void 0 : _a.response) === null || _b === void 0 ? void 0 : _b.id;
    }
    catch (e) {
        if (axios_1.default.isAxiosError(e) && ((_c = e.response) === null || _c === void 0 ? void 0 : _c.status) === 401) {
            throw new v1_1.https.HttpsError("unauthenticated", "토큰 만료: 다시 로그인해주세요.");
        }
        throw new v1_1.https.HttpsError("internal", "네이버 API 호출에 실패했습니다.");
    }
    if (!naverId) {
        throw new v1_1.https.HttpsError("internal", "네이버 ID를 가져올 수 없습니다.");
    }
    const uid = `naver:${naverId}`;
    // 탈퇴 대기 계정이면 보관 기간 안에 한해 여기서 되살린다
    // (파기 시점이 지났으면 failed-precondition + 재가입 가능일).
    const restored = await (0, restore_account_1.restorePendingDeletionOnLogin)(uid);
    let isNewUser = false;
    try {
        await admin.auth().getUser(uid);
    }
    catch (_d) {
        isNewUser = true;
    }
    const customToken = await admin.auth().createCustomToken(uid, {
        provider: "naver",
    });
    v1_1.logger.info(`naverLogin: uid=${uid}, isNewUser=${isNewUser}, restored=${restored}`);
    return { customToken, isNewUser, restored };
});
//# sourceMappingURL=naver_login.js.map