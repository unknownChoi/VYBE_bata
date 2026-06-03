import { firestore, logger } from "firebase-functions/v1";
import * as admin from "firebase-admin";

export const onReviewUpdated = firestore
  .document("clubs/{clubId}/reviews/{reviewId}")
  .onUpdate(async (change, context) => {
    const { clubId } = context.params;
    const oldRating: number = change.before.data()?.rating;
    const newRating: number = change.after.data()?.rating;

    if (oldRating === newRating) return;

    if (!oldRating || !newRating || typeof oldRating !== "number" || typeof newRating !== "number") {
      logger.error("onReviewUpdated: rating missing or invalid", { oldRating, newRating });
      return;
    }

    const clubRef = admin.firestore().collection("clubs").doc(clubId);

    await admin.firestore().runTransaction(async (tx) => {
      const clubSnap = await tx.get(clubRef);
      const clubData = clubSnap.data() ?? {};
      const prevSum: number = clubData.ratingSum ?? 0;
      const count: number = clubData.reviewCount ?? 1;

      const newSum = prevSum - oldRating + newRating;

      tx.update(clubRef, {
        ratingSum: newSum,
        rating: count > 0 ? Math.round((newSum / count) * 10) / 10 : 0,
      });
    });

    logger.info(`onReviewUpdated: club=${clubId}, ${oldRating} → ${newRating}`);
  });
