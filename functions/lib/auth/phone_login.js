"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.phoneLogin = void 0;
const v1_1 = require("firebase-functions/v1");
const admin = require("firebase-admin");
const restore_account_1 = require("../account/restore_account");
exports.phoneLogin = v1_1.https.onCall(async (data) => {
    const phone = data === null || data === void 0 ? void 0 : data.phone;
    if (!phone) {
        throw new v1_1.https.HttpsError("invalid-argument", "phone이 필요합니다.");
    }
    const uid = `phone:${phone}`;
    // 탈퇴 대기 계정이면 보관 기간 안에 한해 여기서 되살린다
    // (파기 시점이 지났으면 failed-precondition + 재가입 가능일).
    const restored = await (0, restore_account_1.restorePendingDeletionOnLogin)(uid);
    let isNewUser = false;
    try {
        await admin.auth().getUser(uid);
    }
    catch (_a) {
        isNewUser = true;
    }
    const customToken = await admin.auth().createCustomToken(uid, {
        provider: "identity",
    });
    v1_1.logger.info(`phoneLogin: uid=${uid}, isNewUser=${isNewUser}, restored=${restored}`);
    return { customToken, isNewUser, restored };
});
//# sourceMappingURL=phone_login.js.map