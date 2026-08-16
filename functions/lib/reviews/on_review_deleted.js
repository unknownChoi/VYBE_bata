"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.onReviewDeleted = void 0;
const v1_1 = require("firebase-functions/v1");
const admin = require("firebase-admin");
exports.onReviewDeleted = v1_1.firestore
    .document("clubs/{clubId}/reviews/{reviewId}")
    .onDelete(async (snapshot, context) => {
    const { clubId } = context.params;
    const data = snapshot.data();
    // 탈퇴로 숨겨진 리뷰는 requestAccountDeletion 이 이미 집계에서 뺐다.
    // 30일 뒤 purgeDeletedUsers 가 지울 때 또 빼면 두 번 깎여 음수가 된다.
    if ((data === null || data === void 0 ? void 0 : data.isHidden) === true)
        return;
    const rating = data === null || data === void 0 ? void 0 : data.rating;
    if (!rating || typeof rating !== "number") {
        v1_1.logger.error("onReviewDeleted: rating missing or invalid", data);
        return;
    }
    const clubRef = admin.firestore().collection("clubs").doc(clubId);
    await admin.firestore().runTransaction(async (tx) => {
        var _a, _b, _c;
        const clubSnap = await tx.get(clubRef);
        const clubData = (_a = clubSnap.data()) !== null && _a !== void 0 ? _a : {};
        const prevSum = (_b = clubData.ratingSum) !== null && _b !== void 0 ? _b : 0;
        const prevCount = (_c = clubData.reviewCount) !== null && _c !== void 0 ? _c : 0;
        const newSum = Math.max(0, prevSum - rating);
        const newCount = Math.max(0, prevCount - 1);
        tx.update(clubRef, {
            ratingSum: newSum,
            reviewCount: newCount,
            rating: newCount > 0 ? Math.round((newSum / newCount) * 10) / 10 : 0,
        });
    });
    v1_1.logger.info(`onReviewDeleted: club=${clubId}, rating=${rating}`);
});
//# sourceMappingURL=on_review_deleted.js.map