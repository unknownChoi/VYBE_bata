"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.checkPhoneDuplicate = void 0;
const v1_1 = require("firebase-functions/v1");
const admin = require("firebase-admin");
const account_common_1 = require("../account/account_common");
exports.checkPhoneDuplicate = v1_1.https.onCall(async (data) => {
    var _a;
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
    if (snap.empty) {
        return { isDuplicate: false, pendingDeletion: false, purgeAt: null };
    }
    // 탈퇴 대기 계정도 중복이다 — 문서가 30일 남아 있어 여기 걸린다.
    // 통과시키면 같은 번호로 계정이 둘 생겨 phone 유니크 전제가 깨진다.
    // 앱이 "재가입 불가"와 "이미 가입됨"을 구분해 안내하도록 사유를 실어 보낸다.
    const user = snap.docs[0].data();
    const pending = (0, account_common_1.isPendingDeletion)(user);
    const purgeAt = user === null || user === void 0 ? void 0 : user.purgeAt;
    return {
        isDuplicate: true,
        pendingDeletion: pending,
        purgeAt: pending ? (_a = purgeAt === null || purgeAt === void 0 ? void 0 : purgeAt.toMillis()) !== null && _a !== void 0 ? _a : null : null,
    };
});
//# sourceMappingURL=check_phone_duplicate.js.map