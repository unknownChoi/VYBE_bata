"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.onUserCreated = void 0;
const v1_1 = require("firebase-functions/v1");
const admin = require("firebase-admin");
exports.onUserCreated = v1_1.auth.user().onCreate(async (user) => {
    const provider = user.uid.startsWith("kakao:") ? "kakao"
        : user.uid.startsWith("naver:") ? "naver"
            : user.uid.startsWith("phone:") ? "identity"
                : "apple";
    const db = admin.firestore();
    await db.collection("users").doc(user.uid).set({
        uid: user.uid,
        provider,
        createdAt: admin.firestore.FieldValue.serverTimestamp(),
        updatedAt: admin.firestore.FieldValue.serverTimestamp(),
    }, { merge: true });
    v1_1.logger.info(`users/${user.uid} created. provider: ${provider}`);
});
//# sourceMappingURL=on_user_created.js.map