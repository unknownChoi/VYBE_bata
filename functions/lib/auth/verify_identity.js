"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.verifyIdentity = void 0;
const v1_1 = require("firebase-functions/v1");
const admin = require("firebase-admin");
const axios_1 = require("axios");
const PORTONE_API_URL = "https://api.iamport.kr";
async function getPortoneToken() {
    var _a, _b;
    const impKey = process.env.PORTONE_IMP_KEY;
    const impSecret = process.env.PORTONE_IMP_SECRET;
    if (!impKey || !impSecret) {
        throw new v1_1.https.HttpsError("internal", "포트원 API 키가 설정되지 않았습니다.");
    }
    const res = await axios_1.default.post(`${PORTONE_API_URL}/users/getToken`, {
        imp_key: impKey,
        imp_secret: impSecret,
    });
    const token = (_b = (_a = res.data) === null || _a === void 0 ? void 0 : _a.response) === null || _b === void 0 ? void 0 : _b.access_token;
    if (!token) {
        throw new v1_1.https.HttpsError("internal", "포트원 토큰 발급에 실패했습니다.");
    }
    return token;
}
exports.verifyIdentity = v1_1.https.onCall(async (data, context) => {
    var _a;
    if (!context.auth) {
        throw new v1_1.https.HttpsError("unauthenticated", "로그인이 필요합니다.");
    }
    const impUid = data === null || data === void 0 ? void 0 : data.impUid;
    if (!impUid) {
        throw new v1_1.https.HttpsError("invalid-argument", "impUid가 필요합니다.");
    }
    const uid = context.auth.uid;
    let phone;
    let birthDate;
    try {
        const portoneToken = await getPortoneToken();
        const res = await axios_1.default.get(`${PORTONE_API_URL}/certifications/${impUid}`, { headers: { Authorization: portoneToken } });
        const cert = (_a = res.data) === null || _a === void 0 ? void 0 : _a.response;
        if (!cert || !cert.certified) {
            throw new v1_1.https.HttpsError("failed-precondition", "본인인증에 실패했습니다.");
        }
        phone = cert.phone.replace(/-/g, "");
        birthDate = cert.birthday.replace(/-/g, "");
    }
    catch (e) {
        if (e instanceof v1_1.https.HttpsError)
            throw e;
        throw new v1_1.https.HttpsError("internal", "포트원 API 호출에 실패했습니다.");
    }
    const db = admin.firestore();
    const duplicateSnap = await db
        .collection("users")
        .where("phone", "==", phone)
        .limit(1)
        .get();
    if (!duplicateSnap.empty && duplicateSnap.docs[0].id !== uid) {
        throw new v1_1.https.HttpsError("already-exists", "이미 가입된 전화번호입니다.");
    }
    await db.collection("users").doc(uid).update({
        phone,
        birthDate,
        isVerified: true,
        updatedAt: admin.firestore.FieldValue.serverTimestamp(),
    });
    v1_1.logger.info(`verifyIdentity: uid=${uid}, phone=${phone}`);
    return { verified: true };
});
//# sourceMappingURL=verify_identity.js.map