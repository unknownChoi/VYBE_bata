import * as functions from "firebase-functions";
import * as admin from "firebase-admin";

export const onFavoriteDeleted = functions.firestore
  .document("favorites/{favoriteId}")
  .onDelete(async (snapshot) => {
    const data = snapshot.data();
    const clubId: string = data?.clubId;

    if (!clubId) {
      functions.logger.error("onFavoriteDeleted: clubId missing", data);
      return;
    }

    const clubRef = admin.firestore().collection("clubs").doc(clubId);

    // 0 미만으로 내려가지 않도록 트랜잭션으로 처리
    await admin.firestore().runTransaction(async (tx) => {
      const clubSnap = await tx.get(clubRef);
      if (!clubSnap.exists) return;

      const current: number = clubSnap.data()?.favoriteCount ?? 0;
      tx.update(clubRef, {
        favoriteCount: Math.max(0, current - 1),
      });
    });

    functions.logger.info(`favoriteCount -1 for club: ${clubId}`);
  });
