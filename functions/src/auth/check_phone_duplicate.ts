import { https } from "firebase-functions/v1";
import * as admin from "firebase-admin";

export const checkPhoneDuplicate = https.onCall(async (data) => {
  const phone: string | undefined = data?.phone;

  if (!phone) {
    throw new https.HttpsError(
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
