import * as functions from "firebase-functions";
import * as admin from "firebase-admin";
import axios from "axios";

export const naverLogin = functions.https.onCall(async (data) => {
  const accessToken: string | undefined = data?.accessToken;

  if (!accessToken) {
    throw new functions.https.HttpsError(
      "invalid-argument",
      "accessToken이 필요합니다."
    );
  }

  // 네이버 유저 정보 조회
  let naverId: string;
  try {
    const response = await axios.get("https://openapi.naver.com/v1/nid/me", {
      headers: {Authorization: `Bearer ${accessToken}`},
    });
    naverId = response.data?.response?.id;
  } catch (e: unknown) {
    if (axios.isAxiosError(e) && e.response?.status === 401) {
      throw new functions.https.HttpsError(
        "unauthenticated",
        "토큰 만료: 다시 로그인해주세요."
      );
    }
    throw new functions.https.HttpsError(
      "internal",
      "네이버 API 호출에 실패했습니다."
    );
  }

  if (!naverId) {
    throw new functions.https.HttpsError(
      "internal",
      "네이버 ID를 가져올 수 없습니다."
    );
  }

  const uid = `naver:${naverId}`;

  // 신규/기존 유저 판단 — Firebase Auth 기준
  let isNewUser = false;
  try {
    await admin.auth().getUser(uid);
  } catch {
    isNewUser = true;
  }

  // Custom Token 발급 (provider 정보를 customClaims로 전달)
  const customToken = await admin.auth().createCustomToken(uid, {
    provider: "naver",
  });

  functions.logger.info(`naverLogin: uid=${uid}, isNewUser=${isNewUser}`);

  return {customToken, isNewUser};
});
