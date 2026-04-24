"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.phoneLogin = void 0;
const v1_1 = require("firebase-functions/v1");
const admin = require("firebase-admin");
exports.phoneLogin = v1_1.https.onCall(async (data) => {
    const phone = data === null || data === void 0 ? void 0 : data.phone;
    if (!phone) {
        throw new v1_1.https.HttpsError("invalid-argument", "phone이 필요합니다.");
    }
    const uid = `phone:${phone}`;
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