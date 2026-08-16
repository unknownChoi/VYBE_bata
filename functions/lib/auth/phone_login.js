"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.phoneLogin = void 0;
const v1_1 = require("firebase-functions/v1");
const admin = require("firebase-admin");
const account_common_1 = require("../account/account_common");
exports.phoneLogin = v1_1.https.onCall(async (data) => {
    const phone = data === null || data === void 0 ? void 0 : data.phone;
    if (!phone) {
        throw new v1_1.https.HttpsError("invalid-argument", "phone이 필요합니다.");
    }
    const uid = `phone:${phone}`;
    // 탈퇴 대기 계정이면 여기서 막는다 (앱에 재가입 가능일을 알려주기 위해).
    await (0, account_common_1.assertNotPendingDeletion)(uid);
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
    v1_1.logger.info(`phoneLogin: uid=${uid}, isNewUser=${isNewUser}`);
    return { customToken, isNewUser };
});
//# sourceMappingURL=phone_login.js.map