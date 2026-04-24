"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.kakaoLogin = void 0;
const v1_1 = require("firebase-functions/v1");
const admin = require("firebase-admin");
const axios_1 = require("axios");
exports.kakaoLogin = v1_1.https.onCall(async (data) => {
    var _a, _b;
    const accessToken = data === null || data === void 0 ? void 0 : data.accessToken;
    if (!accessToken) {
        throw new v1_1.https.HttpsError("invalid-argument", "accessToken이 필요합니다.");
    }
    let kakaoId;
    try {
        const response = await axios_1.default.get("https://kapi.kakao.com/v2/user/me", {
            headers: { Authorization: `Bearer ${accessToken}` },
        });
        kakaoId = String((_a = response.data) === null || _a === void 0 ? void 0 : _a.id);
    }
    catch (e) {
        if (axios_1.default.isAxiosError(e) && ((_b = e.response) === null || _b === void 0 ? void 0 : _b.status) === 401) {
            throw new v1_1.https.HttpsError("unauthenticated", "토큰 만료: 다시 로그인해주세요.");
        }
        throw new v1_1.https.HttpsError("internal", "카카오 API 호출에 실패했습니다.");
    }
    if (!kakaoId || kakaoId === "undefined") {
        throw new v1_1.https.HttpsError("internal", "카카오 ID를 가져올 수 없습니다.");
    }
    const uid = `kakao:${kakaoId}`;
    let isNewUser = false;
    try {
        await admin.auth().getUser(uid);
    }
    catch (_c) {
        isNewUser = true;
    }
    const customToken = await admin.auth().createCustomToken(uid, {
        provider: "kakao",
    });
    v1_1.logger.info(`kakaoLogin: uid=${uid}, isNewUser=${isNewUser}`);
    return { customToken, isNewUser };
});
//# sourceMappingURL=kakao_login.js.map