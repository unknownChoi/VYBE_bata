import * as functions from "firebase-functions";
import * as admin from "firebase-admin";
import axios from "axios";

export const kakaoLogin = functions.https.onCall(async (data) => {
  const accessToken: string | undefined = data?.accessToken;

  if (!accessToken) {
    throw new functions.https.HttpsError(
      "invalid-argument",
      "accessToken이 필요합니다."
    );
  }

  // 카카오 유저 정보 조회
  let kakaoId: string;
  try {
    const response = await axios.get("https://kapi.kakao.com/v2/user/me", {
      headers: {Authorization: `Bearer ${accessToken}`},
    });
    kakaoId = String(response.data?.id);
  } catch (e: unknown) {
    if (axios.isAxiosError(e) && e.response?.status === 401) {
      throw new functions.https.HttpsError(
        "unauthenticated",
        "토큰 만료: 다시 로그인해주세요."
      );
    }
    throw new functions.https.HttpsError(
      "internal",
      "카카오 API 호출에 실패했습니다."
    );
  }

  if (!kakaoId || kakaoId === "undefined") {
    throw new functions.https.HttpsError(
      "internal",
      "카카오 ID를 가져올 수 없습니다."
    );
  }

  const uid = `kakao:${kakaoId}`;

  // 신규/기존 유저 판단 — Firebase Auth 기준
  let isNewUser = false;
  try {
    await admin.auth().getUser(uid);
  } catch {
    isNewUser = true;
  }

  // Custom Token 발급
  const customToken = await admin.auth().createCustomToken(uid, {
    provider: "kakao",
  });

  functions.logger.info(`kakaoLogin: uid=${uid}, isNewUser=${isNewUser}`);

  return {customToken, isNewUser};
});
