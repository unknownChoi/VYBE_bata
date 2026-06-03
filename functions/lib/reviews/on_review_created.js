"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.onReviewCreated = void 0;
const v1_1 = require("firebase-functions/v1");
const admin = require("firebase-admin");
exports.onReviewCreated = v1_1.firestore
    .document("clubs/{clubId}/reviews/{reviewId}")
    .onCreate(async (snapshot, context) => {
    const { clubId } = context.params;
    const data = snapshot.data();
    const rating = data === null || data === void 0 ? void 0 : data.rating;
    if (!rating || typeof rating !== "number") {
        v1_1.logger.error("onReviewCreated: rating missing or invalid", data);
        return;
    }
    const clubRef = admin.firestore().collection("clubs").doc(clubId);
    await admin.firestore().runTransaction(async (tx) => {
        var _a, _b, _c;
        const clubSnap = await tx.get(clubRef);
        const clubData = (_a = clubSnap.data()) !== null && _a !== void 0 ? _a : {};
        const prevSum = (_b = clubData.ratingSum) !== null && _b !== void 0 ? _b : 0;
        const prevCount = (_c = clubData.reviewCount) !== null && _c !== void 0 ? _c : 0;
        const newSum = prevSum + rating;
        const newCount = prevCount + 1;
        tx.update(clubRef, {
            ratingSum: newSum,
            reviewCount: newCount,
            rating: Math.round((newSum / newCount) * 10) / 10,
        });
    });
    v1_1.logger.info(`onReviewCreated: club=${clubId}, rating=${rating}`);
});
//# sourceMappingURL=on_review_created.js.map