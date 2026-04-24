import { firestore, logger } from "firebase-functions/v1";
import * as admin from "firebase-admin";

export const onFavoriteCreated = firestore
  .document("favorites/{favoriteId}")
  .onCreate(async (snapshot) => {
    const data = snapshot.data();
    const clubId: string = data?.clubId;

    if (!clubId) {
      logger.error("onFavoriteCreated: clubId missing", data);
      return;
    }

    await admin.firestore().collection("clubs").doc(clubId).update({
      favoriteCount: admin.firestore.FieldValue.increment(1),
    });

    logger.info(`favoriteCount +1 for club: ${clubId}`);
  });
