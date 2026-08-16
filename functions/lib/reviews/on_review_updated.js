"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.onReviewUpdated = void 0;
const v1_1 = require("firebase-functions/v1");
const admin = require("firebase-admin");
exports.onReviewUpdated = v1_1.firestore
    .document("clubs/{clubId}/reviews/{reviewId}")
    .onUpdate(async (change, context) => {
    var _a, _b, _c, _d;
    const { clubId } = context.params;
    // 탈퇴 숨김/복구로 isHidden 이 바뀐 update 는 여기서 처리하지 않는다.
    // 집계 감산은 requestAccountDeletion 이 직접 하므로 여기서 또 하면
    // 이중 감산이 된다.
    const wasHidden = ((_a = change.before.data()) === null || _a === void 0 ? void 0 : _a.isHidden) === true;
    const isHidden = ((_b = change.after.data()) === null || _b === void 0 ? void 0 : _b.isHidden) === true;
    if (wasHidden !== isHidden)
        return;
    // 이미 숨겨진 리뷰는 집계에서 빠져 있다 — 별점을 고쳐도 반영할 게 없다.
    if (isHidden)
        return;
    const oldRating = (_c = change.before.data()) === null || _c === void 0 ? void 0 : _c.rating;
    const newRating = (_d = change.after.data()) === null || _d === void 0 ? void 0 : _d.rating;
    if (oldRating === newRating)
        return;
    if (!oldRating || !newRating || typeof oldRating !== "number" || typeof newRating !== "number") {
        v1_1.logger.error("onReviewUpdated: rating missing or invalid", { oldRating, newRating });
        return;
    }
    const clubRef = admin.firestore().collection("clubs").doc(clubId);
    await admin.firestore().runTransaction(async (tx) => {
        var _a, _b, _c;
        const clubSnap = await tx.get(clubRef);
        const clubData = (_a = clubSnap.data()) !== null && _a !== void 0 ? _a : {};
        const prevSum = (_b = clubData.ratingSum) !== null && _b !== void 0 ? _b : 0;
        const count = (_c = clubData.reviewCount) !== null && _c !== void 0 ? _c : 1;
        const newSum = prevSum - oldRating + newRating;
        tx.update(clubRef, {
            ratingSum: newSum,
            rating: count > 0 ? Math.round((newSum / count) * 10) / 10 : 0,
        });
    });
    v1_1.logger.info(`onReviewUpdated: club=${clubId}, ${oldRating} → ${newRating}`);
});
//# sourceMappingURL=on_review_updated.js.map