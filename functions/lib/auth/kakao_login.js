"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.kakaoLogin = void 0;
const functions = require("firebase-functions");
const admin = require("firebase-admin");
const axios_1 = require("axios");
exports.kakaoLogin = functions.https.onCall(async (data) => {
    var _a, _b;
    const accessToken = data === null || data === void 0 ? void 0 : data.accessToken;
    if (!accessToken) {
        throw new functions.https.HttpsError("invalid-argument", "accessToken이 필요합니다.");
    }
    // 카카오 유저 정보 조회
    let kakaoId;
    try {
        const response = await axios_1.default.get("https://kapi.kakao.com/v2/user/me", {
            headers: { Authorization: `Bearer ${accessToken}` },
        });
        kakaoId = String((_a = response.data) === null || _a === void 0 ? void 0 : _a.id);
    }
    catch (e) {
        if (axios_1.default.isAxiosError(e) && ((_b = e.response) === null || _b === void 0 ? void 0 : _b.status) === 401) {
            throw new functions.https.HttpsError("unauthenticated", "토큰 만료: 다시 로그인해주세요.");
        }
        throw new functions.https.HttpsError("internal", "카카오 API 호출에 실패했습니다.");
    }
    if (!kakaoId || kakaoId === "undefined") {
        throw new functions.https.HttpsError("internal", "카카오 ID를 가져올 수 없습니다.");
    }
    const uid = `kakao:${kakaoId}`;
    // 신규/기존 유저 판단 — Firebase Auth 기준
    let isNewUser = false;
    try {
        await admin.auth().getUser(uid);
    }
    catch (_c) {
        isNewUser = true;
    }
    // Custom Token 발급
    const customToken = await admin.auth().createCustomToken(uid, {
        provider: "kakao",
    });
    functions.logger.info(`kakaoLogin: uid=${uid}, isNewUser=${isNewUser}`);
    return { customToken, isNewUser };
});
//# sourceMappingURL=kakao_login.js.map