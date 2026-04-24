import { https, logger } from "firebase-functions/v1";
import * as admin from "firebase-admin";
import axios from "axios";

const PORTONE_API_URL = "https://api.iamport.kr";

async function getPortoneToken(): Promise<string> {
  const impKey = process.env.PORTONE_IMP_KEY;
  const impSecret = process.env.PORTONE_IMP_SECRET;

  if (!impKey || !impSecret) {
    throw new https.HttpsError(
      "internal",
      "포트원 API 키가 설정되지 않았습니다."
    );
  }

  const res = await axios.post(`${PORTONE_API_URL}/users/getToken`, {
    imp_key: impKey,
    imp_secret: impSecret,
  });

  const token: string = res.data?.response?.access_token;
  if (!token) {
    throw new https.HttpsError(
      "internal",
      "포트원 토큰 발급에 실패했습니다."
    );
  }
  return token;
}

export const verifyIdentity = https.onCall(async (data, context) => {
  if (!context.auth) {
    throw new https.HttpsError(
      "unauthenticated",
      "로그인이 필요합니다."
    );
  }

  const impUid: string | undefined = data?.impUid;
  if (!impUid) {
    throw new https.HttpsError(
      "invalid-argument",
      "impUid가 필요합니다."
    );
  }

  const uid = context.auth.uid;

  let phone: string;
  let birthDate: string;
  try {
    const portoneToken = await getPortoneToken();
    const res = await axios.get(
      `${PORTONE_API_URL}/certifications/${impUid}`,
      {headers: {Authorization: portoneToken}}
    );

    const cert = res.data?.response;
    if (!cert || !cert.certified) {
      throw new https.HttpsError(
        "failed-precondition",
        "본인인증에 실패했습니다."
      );
    }

    phone = (cert.phone as string).replace(/-/g, "");
    birthDate = (cert.birthday as string).replace(/-/g, "");
  } catch (e) {
    if (e instanceof https.HttpsError) throw e;
    throw new https.HttpsError(
      "internal",
      "포트원 API 호출에 실패했습니다."
    );
  }

  const db = admin.firestore();
  const duplicateSnap = await db
    .collection("users")
    .where("phone", "==", phone)
    .limit(1)
    .get();

  if (!duplicateSnap.empty && duplicateSnap.docs[0].id !== uid) {
    throw new https.HttpsError(
      "already-exists",
      "이미 가입된 전화번호입니다."
    );
  }

  await db.collection("users").doc(uid).update({
    phone,
    birthDate,
    isVerified: true,
    updatedAt: admin.firestore.FieldValue.serverTimestamp(),
  });

  logger.info(`verifyIdentity: uid=${uid}, phone=${phone}`);

  return {verified: true};
});
