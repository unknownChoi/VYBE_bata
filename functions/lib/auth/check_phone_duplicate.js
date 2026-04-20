"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.checkPhoneDuplicate = void 0;
const functions = require("firebase-functions");
const admin = require("firebase-admin");
exports.checkPhoneDuplicate = functions.https.onCall(async (data) => {
    const phone = data === null || data === void 0 ? void 0 : data.phone;
    if (!phone) {
        throw new functions.https.HttpsError("invalid-argument", "phone이 필요합니다.");
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