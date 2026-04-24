"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.checkPhoneDuplicate = void 0;
const v1_1 = require("firebase-functions/v1");
const admin = require("firebase-admin");
exports.checkPhoneDuplicate = v1_1.https.onCall(async (data) => {
    const phone = data === null || data === void 0 ? void 0 : data.phone;
    if (!phone) {
        throw new v1_1.https.HttpsError("invalid-argument", "phone이 필요합니다.");
    }
    const db = admin.firestore();
    const snap = await db
        .collection("users")
        .where("phone", "==", phone)
        .limit(1)
        .get();
    return { isDuplicate: !snap.empty };
});
//# sourceMappingURL=check_phone_duplicate.js.map