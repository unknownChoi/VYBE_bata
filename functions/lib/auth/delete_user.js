"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.deleteUser = void 0;
const v1_1 = require("firebase-functions/v1");
const admin = require("firebase-admin");
exports.deleteUser = v1_1.https.onCall(async (_data, context) => {
    if (!context.auth) {
        throw new v1_1.https.HttpsError("unauthenticated", "로그인이 필요합니다.");
    }
    const uid = context.auth.uid;
    const db = admin.firestore();
    const bucket = admin.storage().bucket();
    try {
        await bucket.deleteFiles({ prefix: `users/${uid}/` });
        v1_1.logger.info(`deleteUser: Storage deleted for uid=${uid}`);
    }
    catch (e) {
        v1_1.logger.warn(`deleteUser: Storage delete skipped for uid=${uid}`, e);
    }
    await db.collection("users").doc(uid).delete();
    v1_1.logger.info(`deleteUser: Firestore deleted for uid=${uid}`);
    await admin.auth().deleteUser(uid);
    v1_1.logger.info(`deleteUser: Auth deleted for uid=${uid}`);
    return { success: true };
});
//# sourceMappingURL=delete_user.js.map