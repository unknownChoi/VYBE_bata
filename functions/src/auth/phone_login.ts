import { https, logger } from "firebase-functions/v1";
import * as admin from "firebase-admin";
import { restorePendingDeletionOnLogin } from "../account/restore_account";

export const phoneLogin = https.onCall(async (data) => {
  const phone: string | undefined = data?.phone;

  if (!phone) {
    throw new https.HttpsError(
      "invalid-argument",
      "phone이 필요합니다."
    );
  }

  const uid = `phone:${phone}`;

  // 탈퇴 대기 계정이면 보관 기간 안에 한해 여기서 되살린다
  // (파기 시점이 지났으면 failed-precondition + 재가입 가능일).
  const restored = await restorePendingDeletionOnLogin(uid);

  let isNewUser = false;
  try {
    await admin.auth().getUser(uid);
  } catch {
    isNewUser = true;
  }

  const customToken = await admin.auth().createCustomToken(uid, {
    provider: "identity",
  });

  logger.info(
    `phoneLogin: uid=${uid}, isNewUser=${isNewUser}, restored=${restored}`
  );

  return {customToken, isNewUser, restored};
});
