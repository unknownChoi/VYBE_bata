"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.verifyIdentity = void 0;
const functions = require("firebase-functions");
const admin = require("firebase-admin");
const axios_1 = require("axios");
const PORTONE_API_URL = "https://api.iamport.kr";
async function getPortoneToken() {
    var _a, _b, _c, _d;
    const config = functions.config();
    const impKey = (_a = config.portone) === null || _a === void 0 ? void 0 : _a.imp_key;
    const impSecret = (_b = config.portone) === null || _b === void 0 ? void 0 : _b.imp_secret;
    if (!impKey || !impSecret) {
        throw new functions.https.HttpsError("internal", "포트원 API 키가 설정되지 않았습니다.");
    }
    const res = await axios_1.default.post(`${PORTONE_API_URL}/users/getToken`, {
        imp_key: impKey,
        imp_secret: impSecret,
    });
    const token = (_d = (_c = res.data) === null || _c === void 0 ? void 0 : _c.response) === null || _d === void 0 ? void 0 : _d.access_token;
    if (!token) {
        throw new functions.https.HttpsError("internal", "포트원 토큰 발급에 실패했습니다.");
    }
    return token;
}
exports.verifyIdentity = functions.https.onCall(async (data, context) => {
    var _a;
    if (!context.auth) {
        throw new functions.https.HttpsError("unauthenticated", "로그인이 필요합니다.");
    }
    const impUid = data === null || data === void 0 ? void 0 : data.impUid;
    if (!impUid) {
        throw new functions.https.HttpsError("invalid-argument", "impUid가 필요합니다.");
    }
    const uid = context.auth.uid;
    // 포트원 본인인증 결과 조회
    let phone;
    let birthDate;
    try {
        const portoneToken = await getPortoneToken();
        const res = await axios_1.default.get(`${PORTONE_API_URL}/certifications/${impUid}`, { headers: { Authorization: portoneToken } });
        const cert = (_a = res.data) === null || _a === void 0 ? void 0 : _a.response;
        if (!cert || !cert.certified) {
            throw new functions.https.HttpsError("failed-precondition", "본인인증에 실패했습니다.");
        }
        // phone: 010-1234-5678 → 01012345678
        phone = cert.phone.replace(/-/g, "");
        // birth: YYYY-MM-DD → YYYYMMDD
        birthDate = cert.birthday.replace(/-/g, "");
    }
    catch (e) {
        if (e instanceof functions.https.HttpsError)
            throw e;
        throw new functions.https.HttpsError("internal", "포트원 API 호출에 실패했습니다.");
    }
    // phone 중복 체크
    const db = admin.firestore();
    const duplicateSnap = await db
        .collection("users")
        .where("phone", "==", phone)
        .limit(1)
        .get();
    if (!duplicateSnap.empty && duplicateSnap.docs[0].id !== uid) {
        throw new functions.https.HttpsError("already-exists", "이미 가입된 전화번호입니다.");
    }
    // Firestore 업데이트
    await db.collection("users").doc(uid).update({
        phone,
        birthDate,
        isVerified: true,
        updatedAt: admin.firestore.FieldValue.serverTimestamp(),
    });
    functions.logger.info(`verifyIdentity: uid=${uid}, phone=${phone}`);
    return { verified: true };
});
//# sourceMappingURL=verify_identity.js.map