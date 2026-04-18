import * as functions from "firebase-functions";
import * as admin from "firebase-admin";

export const onUserCreated = functions.auth.user().onCreate(async (user) => {
  const db = admin.firestore();
  const userRef = db.collection("users").doc(user.uid);

  // 중복 실행 방어 — 문서가 이미 존재하면 덮어쓰지 않음
  const snapshot = await userRef.get();
  if (snapshot.exists) {
    functions.logger.info(`users/${user.uid} already exists, skipping.`);
    return;
  }

  const provider = (user.customClaims as Record<string, string> | undefined)
    ?.provider ?? "apple";

  await userRef.set({
    uid: user.uid,
    provider,
    isVerified: false,
    createdAt: admin.firestore.FieldValue.serverTimestamp(),
    updatedAt: admin.firestore.FieldValue.serverTimestamp(),
  });

  functions.logger.info(`users/${user.uid} created. provider: ${provider}`);
});
