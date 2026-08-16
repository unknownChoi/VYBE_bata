import { firestore, logger } from "firebase-functions/v1";
import * as admin from "firebase-admin";

export const onFavoriteDeleted = firestore
  .document("favorites/{favoriteId}")
  .onDelete(async (snapshot) => {
    const data = snapshot.data();

    // 탈퇴로 숨겨진 찜은 requestAccountDeletion 이 이미 favoriteCount 에서 뺐다.
    // 30일 뒤 파기 때 또 빼면 두 번 깎인다.
    if (data?.isHidden === true) return;

    const clubId: string = data?.clubId;

    if (!clubId) {
      logger.error("onFavoriteDeleted: clubId missing", data);
      return;
    }

    const clubRef = admin.firestore().collection("clubs").doc(clubId);

    await admin.firestore().runTransaction(async (tx) => {
      const clubSnap = await tx.get(clubRef);
      if (!clubSnap.exists) return;

      const current: number = clubSnap.data()?.favoriteCount ?? 0;
      tx.update(clubRef, {
        favoriteCount: Math.max(0, current - 1),
      });
    });

    logger.info(`favoriteCount -1 for club: ${clubId}`);
  });
