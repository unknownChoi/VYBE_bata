import * as functions from "firebase-functions";
import * as admin from "firebase-admin";

export const onFavoriteCreated = functions.firestore
  .document("favorites/{favoriteId}")
  .onCreate(async (snapshot) => {
    const data = snapshot.data();
    const clubId: string = data?.clubId;

    if (!clubId) {
      functions.logger.error("onFavoriteCreated: clubId missing", data);
      return;
    }

    await admin.firestore().collection("clubs").doc(clubId).update({
      favoriteCount: admin.firestore.FieldValue.increment(1),
    });

    functions.logger.info(`favoriteCount +1 for club: ${clubId}`);
  });
