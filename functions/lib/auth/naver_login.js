"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.naverLogin = void 0;
const functions = require("firebase-functions");
const admin = require("firebase-admin");
const axios_1 = require("axios");
exports.naverLogin = functions.https.onCall(async (data) => {
    var _a, _b, _c;
    const accessToken = data === null || data === void 0 ? void 0 : data.accessToken;
    if (!accessToken) {
        throw new functions.https.HttpsError("invalid-argument", "accessToken이 필요합니다.");
    }
    // 네이버 유저 정보 조회
    let naverId;
    try {
        const response = await axios_1.default.get("https://openapi.naver.com/v1/nid/me", {
            headers: { Authorization: `Bearer ${accessToken}` },
        });
        naverId = (_b = (_a = response.data) === null || _a === void 0 ? void 0 : _a.response) === null || _b === void 0 ? void 0 : _b.id;
    }
    catch (e) {
        if (axios_1.default.isAxiosError(e) && ((_c = e.response) === null || _c === void 0 ? void 0 : _c.status) === 401) {
            throw new functions.https.HttpsError("unauthenticated", "토큰 만료: 다시 로그인해주세요.");
        }
        throw new functions.https.HttpsError("internal", "네이버 API 호출에 실패했습니다.");
    }
    if (!naverId) {
        throw new functions.https.HttpsError("internal", "네이버 ID를 가져올 수 없습니다.");
    }
    const uid = `naver:${naverId}`;
    // 신규/기존 유저 판단
    const userSnap = await admin.firestore().collection("users").doc(uid).get();
    const isNewUser = !userSnap.exists;
    // Custom Token 발급 (provider 정보를 customClaims로 전달)
    const customToken = await admin.auth().createCustomToken(uid, {
        provider: "naver",
    });
    functions.logger.info(`naverLogin: uid=${uid}, isNewUser=${isNewUser}`);
    return { customToken, isNewUser };
});
//# sourceMappingURL=naver_login.js.map