import { firestore, logger } from "firebase-functions/v1";
import * as admin from "firebase-admin";

export const onReviewUpdated = firestore
  .document("clubs/{clubId}/reviews/{reviewId}")
  .onUpdate(async (change, context) => {
    const { clubId } = context.params;

    // 탈퇴 숨김/복구로 isHidden 이 바뀐 update 는 여기서 처리하지 않는다.
    // 집계 감산은 requestAccountDeletion 이 직접 하므로 여기서 또 하면
    // 이중 감산이 된다.
    const wasHidden = change.before.data()?.isHidden === true;
    const isHidden = change.after.data()?.isHidden === true;
    if (wasHidden !== isHidden) return;

    // 이미 숨겨진 리뷰는 집계에서 빠져 있다 — 별점을 고쳐도 반영할 게 없다.
    if (isHidden) return;

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
