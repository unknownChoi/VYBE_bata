import { auth, logger } from "firebase-functions/v1";
import * as admin from "firebase-admin";

export const onUserCreated = auth.user().onCreate(async (user) => {
  const provider = user.uid.startsWith("kakao:") ? "kakao"
    : user.uid.startsWith("naver:") ? "naver"
    : user.uid.startsWith("phone:") ? "identity"
    : "apple";

  const db = admin.firestore();
  await db.collection("users").doc(user.uid).set({
    uid: user.uid,
    provider,
    createdAt: admin.firestore.FieldValue.serverTimestamp(),
    updatedAt: admin.firestore.FieldValue.serverTimestamp(),
  }, {merge: true});

  logger.info(`users/${user.uid} created. provider: ${provider}`);
});
