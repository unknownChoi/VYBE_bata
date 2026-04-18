import * as functions from "firebase-functions";
import * as admin from "firebase-admin";

export const deleteUser = functions.https.onCall(async (_data, context) => {
  if (!context.auth) {
    throw new functions.https.HttpsError(
      "unauthenticated",
      "로그인이 필요합니다."
    );
  }

  const uid = context.auth.uid;
  const db = admin.firestore();
  const bucket = admin.storage().bucket();

  // 1) Storage users/{uid}/** 전체 삭제
  try {
    await bucket.deleteFiles({prefix: `users/${uid}/`});
    functions.logger.info(`deleteUser: Storage deleted for uid=${uid}`);
  } catch (e) {
    // 파일이 없어도 계속 진행
    functions.logger.warn(`deleteUser: Storage delete skipped for uid=${uid}`, e);
  }

  // 2) Firestore users/{uid} 문서 삭제
  await db.collection("users").doc(uid).delete();
  functions.logger.info(`deleteUser: Firestore deleted for uid=${uid}`);

  // 3) Firebase Auth 계정 삭제
  await admin.auth().deleteUser(uid);
  functions.logger.info(`deleteUser: Auth deleted for uid=${uid}`);

  return {success: true};
});
