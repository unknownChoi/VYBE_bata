import { https, logger } from "firebase-functions/v1";
import * as admin from "firebase-admin";

export const phoneLogin = https.onCall(async (data) => {
  const phone: string | undefined = data?.phone;

  if (!phone) {
    throw new https.HttpsError(
      "invalid-argument",
      "phone이 필요합니다."
    );
  }

  const uid = `phone:${phone}`;

  let isNewUser = false;
  try {
    await admin.auth().getUser(uid);
  } catch {
    isNewUser = true;
  }

  const customToken = await admin.auth().createCustomToken(uid, {
    provider: "identity",
  });

  logger.info(`phoneLogin: uid=${uid}, isNewUser=${isNewUser}`);

  return {customToken, isNewUser};
});
