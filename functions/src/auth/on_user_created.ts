import * as functions from "firebase-functions";
import * as admin from "firebase-admin";

export const onUserCreated = functions.auth.user().onCreate(async (user) => {
  // 익명 로그인(본인인증 직접 경로) — OTP 완료 전이므로 문서 생성 스킵
  // 문서는 saveUserProfile에서 직접 생성됨
  const isAnonymous = !user.providerData || user.providerData.length === 0;
  if (isAnonymous) {
    functions.logger.info(`users/${user.uid}: anonymous user, skipping document creation`);
    return;
  }

  const db = admin.firestore();
  const userRef = db.collection("users").doc(user.uid);

  const provider = user.uid.startsWith("kakao:") ? "kakao"
    : user.uid.startsWith("naver:") ? "naver"
    : "apple";

  // merge: true — setUserProfile이 먼저 실행돼 문서가 존재해도 누락 필드만 채움
  await userRef.set({
    uid: user.uid,
    provider,
    createdAt: admin.firestore.FieldValue.serverTimestamp(),
    updatedAt: admin.firestore.FieldValue.serverTimestamp(),
  }, {merge: true});

  functions.logger.info(`users/${user.uid} created. provider: ${provider}`);
});
