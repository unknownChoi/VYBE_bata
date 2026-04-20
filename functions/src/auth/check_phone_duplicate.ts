import * as functions from "firebase-functions";
import * as admin from "firebase-admin";

export const checkPhoneDuplicate = functions.https.onCall(async (data) => {
  const phone: string | undefined = data?.phone;

  if (!phone) {
    throw new functions.https.HttpsError(
      "invalid-argument",
      "phone이 필요합니다."
    );
  }

  const db = admin.firestore();
  const snap = await db
    .collection("users")
    .where("phone", "==", phone)
    .limit(1)
    .get();

  return {isDuplicate: !snap.empty};
});
