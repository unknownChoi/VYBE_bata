import * as functions from "firebase-functions";
import * as admin from "firebase-admin";

export const phoneLogin = functions.https.onCall(async (data) => {
  const phone: string | undefined = data?.phone;

  if (!phone) {
    throw new functions.https.HttpsError(
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

  functions.logger.info(`phoneLogin: uid=${uid}, isNewUser=${isNewUser}`);

  return {customToken, isNewUser};
});
