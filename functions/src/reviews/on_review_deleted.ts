import { firestore, logger } from "firebase-functions/v1";
import * as admin from "firebase-admin";

export const onReviewDeleted = firestore
  .document("clubs/{clubId}/reviews/{reviewId}")
  .onDelete(async (snapshot, context) => {
    const { clubId } = context.params;
    const data = snapshot.data();

    // 탈퇴로 숨겨진 리뷰는 requestAccountDeletion 이 이미 집계에서 뺐다.
    // 30일 뒤 purgeDeletedUsers 가 지울 때 또 빼면 두 번 깎여 음수가 된다.
    if (data?.isHidden === true) return;

    const rating: number = data?.rating;

    if (!rating || typeof rating !== "number") {
      logger.error("onReviewDeleted: rating missing or invalid", data);
      return;
    }

    const clubRef = admin.firestore().collection("clubs").doc(clubId);

    await admin.firestore().runTransaction(async (tx) => {
      const clubSnap = await tx.get(clubRef);
      const clubData = clubSnap.data() ?? {};
      const prevSum: number = clubData.ratingSum ?? 0;
      const prevCount: number = clubData.reviewCount ?? 0;

      const newSum = Math.max(0, prevSum - rating);
      const newCount = Math.max(0, prevCount - 1);

      tx.update(clubRef, {
        ratingSum: newSum,
        reviewCount: newCount,
        rating: newCount > 0 ? Math.round((newSum / newCount) * 10) / 10 : 0,
      });
    });

    logger.info(`onReviewDeleted: club=${clubId}, rating=${rating}`);
  });
