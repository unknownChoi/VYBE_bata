"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.onReviewUpdated = void 0;
const v1_1 = require("firebase-functions/v1");
const admin = require("firebase-admin");
exports.onReviewUpdated = v1_1.firestore
    .document("clubs/{clubId}/reviews/{reviewId}")
    .onUpdate(async (change, context) => {
    var _a, _b;
    const { clubId } = context.params;
    const oldRating = (_a = change.before.data()) === null || _a === void 0 ? void 0 : _a.rating;
    const newRating = (_b = change.after.data()) === null || _b === void 0 ? void 0 : _b.rating;
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