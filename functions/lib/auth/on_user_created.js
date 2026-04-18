"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.onUserCreated = void 0;
const functions = require("firebase-functions");
const admin = require("firebase-admin");
exports.onUserCreated = functions.auth.user().onCreate(async (user) => {
    var _a, _b;
    const db = admin.firestore();
    const userRef = db.collection("users").doc(user.uid);
    // 중복 실행 방어 — 문서가 이미 존재하면 덮어쓰지 않음
    const snapshot = await userRef.get();
    if (snapshot.exists) {
        functions.logger.info(`users/${user.uid} already exists, skipping.`);
        return;
    }
    const provider = (_b = (_a = user.customClaims) === null || _a === void 0 ? void 0 : _a.provider) !== null && _b !== void 0 ? _b : "apple";
    await userRef.set({
        uid: user.uid,
        provider,
        isVerified: false,
        createdAt: admin.firestore.FieldValue.serverTimestamp(),
        updatedAt: admin.firestore.FieldValue.serverTimestamp(),
    });
    functions.logger.info(`users/${user.uid} created. provider: ${provider}`);
});
//# sourceMappingURL=on_user_created.js.map