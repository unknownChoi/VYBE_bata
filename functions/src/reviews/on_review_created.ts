import { firestore, logger } from "firebase-functions/v1";
import * as admin from "firebase-admin";

export const onReviewCreated = firestore
  .document("clubs/{clubId}/reviews/{reviewId}")
  .onCreate(async (snapshot, context) => {
    const { clubId } = context.params;
    const data = snapshot.data();
    const rating: number = data?.rating;

    if (!rating || typeof rating !== "number") {
      logger.error("onReviewCreated: rating missing or invalid", data);
      return;
    }

    const clubRef = admin.firestore().collection("clubs").doc(clubId);

    await admin.firestore().runTransaction(async (tx) => {
      const clubSnap = await tx.get(clubRef);
      const clubData = clubSnap.data() ?? {};
      const prevSum: number = clubData.ratingSum ?? 0;
      const prevCount: number = clubData.reviewCount ?? 0;

      const newSum = prevSum + rating;
      const newCount = prevCount + 1;

      tx.update(clubRef, {
        ratingSum: newSum,
        reviewCount: newCount,
        rating: Math.round((newSum / newCount) * 10) / 10,
      });
    });

    logger.info(`onReviewCreated: club=${clubId}, rating=${rating}`);
  });
