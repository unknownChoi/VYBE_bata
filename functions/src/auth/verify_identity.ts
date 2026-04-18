import * as functions from "firebase-functions";
import * as admin from "firebase-admin";
import axios from "axios";

const PORTONE_API_URL = "https://api.iamport.kr";

async function getPortoneToken(): Promise<string> {
  const config = functions.config();
  const impKey: string = config.portone?.imp_key;
  const impSecret: string = config.portone?.imp_secret;

  if (!impKey || !impSecret) {
    throw new functions.https.HttpsError(
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
    throw new functions.https.HttpsError(
      "internal",
      "포트원 토큰 발급에 실패했습니다."
    );
  }
  return token;
}

export const verifyIdentity = functions.https.onCall(async (data, context) => {
  if (!context.auth) {
    throw new functions.https.HttpsError(
      "unauthenticated",
      "로그인이 필요합니다."
    );
  }

  const impUid: string | undefined = data?.impUid;
  if (!impUid) {
    throw new functions.https.HttpsError(
      "invalid-argument",
      "impUid가 필요합니다."
    );
  }

  const uid = context.auth.uid;

  // 포트원 본인인증 결과 조회
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
      throw new functions.https.HttpsError(
        "failed-precondition",
        "본인인증에 실패했습니다."
      );
    }

    // phone: 010-1234-5678 → 01012345678
    phone = (cert.phone as string).replace(/-/g, "");
    // birth: YYYY-MM-DD → YYYYMMDD
    birthDate = (cert.birthday as string).replace(/-/g, "");
  } catch (e) {
    if (e instanceof functions.https.HttpsError) throw e;
    throw new functions.https.HttpsError(
      "internal",
      "포트원 API 호출에 실패했습니다."
    );
  }

  // phone 중복 체크
  const db = admin.firestore();
  const duplicateSnap = await db
    .collection("users")
    .where("phone", "==", phone)
    .limit(1)
    .get();

  if (!duplicateSnap.empty && duplicateSnap.docs[0].id !== uid) {
    throw new functions.https.HttpsError(
      "already-exists",
      "이미 가입된 전화번호입니다."
    );
  }

  // Firestore 업데이트
  await db.collection("users").doc(uid).update({
    phone,
    birthDate,
    isVerified: true,
    updatedAt: admin.firestore.FieldValue.serverTimestamp(),
  });

  functions.logger.info(`verifyIdentity: uid=${uid}, phone=${phone}`);

  return {verified: true};
});
