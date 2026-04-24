import { https, logger } from "firebase-functions/v1";
import * as admin from "firebase-admin";

export const deleteUser = https.onCall(async (_data, context) => {
  if (!context.auth) {
    throw new https.HttpsError(
      "unauthenticated",
      "로그인이 필요합니다."
    );
  }

  const uid = context.auth.uid;
  const db = admin.firestore();
  const bucket = admin.storage().bucket();

  try {
    await bucket.deleteFiles({prefix: `users/${uid}/`});
    logger.info(`deleteUser: Storage deleted for uid=${uid}`);
  } catch (e) {
    logger.warn(`deleteUser: Storage delete skipped for uid=${uid}`, e);
  }

  await db.collection("users").doc(uid).delete();
  logger.info(`deleteUser: Firestore deleted for uid=${uid}`);

  await admin.auth().deleteUser(uid);
  logger.info(`deleteUser: Auth deleted for uid=${uid}`);

  return {success: true};
});
