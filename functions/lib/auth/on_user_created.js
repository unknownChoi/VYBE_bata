"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.onUserCreated = void 0;
const functions = require("firebase-functions");
const admin = require("firebase-admin");
exports.onUserCreated = functions.auth.user().onCreate(async (user) => {
    const db = admin.firestore();
    const userRef = db.collection("users").doc(user.uid);
    const provider = user.uid.startsWith("kakao:") ? "kakao"
        : user.uid.startsWith("naver:") ? "naver"
            : "apple";
    // merge: true — setUserProfile이 먼저 실행돼 문서가 존재해도 누락 필드만 채움
    // isVerified는 이미 true로 저장됐을 수 있으므로 포함하지 않음
    await userRef.set({
        uid: user.uid,
        provider,
        createdAt: admin.firestore.FieldValue.serverTimestamp(),
        updatedAt: admin.firestore.FieldValue.serverTimestamp(),
    }, { merge: true });
    functions.logger.info(`users/${user.uid} created. provider: ${provider}`);
});
//# sourceMappingURL=on_user_created.js.map