import { https, logger } from "firebase-functions/v1";
import * as admin from "firebase-admin";
import axios from "axios";
import { assertNotPendingDeletion } from "../account/account_common";

export const kakaoLogin = https.onCall(async (data) => {
  const accessToken: string | undefined = data?.accessToken;

  if (!accessToken) {
    throw new https.HttpsError(
      "invalid-argument",
      "accessToken이 필요합니다."
    );
  }

  let kakaoId: string;
  try {
    const response = await axios.get("https://kapi.kakao.com/v2/user/me", {
      headers: {Authorization: `Bearer ${accessToken}`},
    });
    kakaoId = String(response.data?.id);
  } catch (e: unknown) {
    if (axios.isAxiosError(e) && e.response?.status === 401) {
      throw new https.HttpsError(
        "unauthenticated",
        "토큰 만료: 다시 로그인해주세요."
      );
    }
    throw new https.HttpsError(
      "internal",
      "카카오 API 호출에 실패했습니다."
    );
  }

  if (!kakaoId || kakaoId === "undefined") {
    throw new https.HttpsError(
      "internal",
      "카카오 ID를 가져올 수 없습니다."
    );
  }

  const uid = `kakao:${kakaoId}`;

  // 탈퇴 대기 계정이면 여기서 막는다. Auth 가 disabled 라 토큰을 줘도 어차피
  // 로그인이 안 되지만, 그러면 앱이 이유(재가입 가능일)를 알 수 없다.
  await assertNotPendingDeletion(uid);

  let isNewUser = false;
  try {
    await admin.auth().getUser(uid);
  } catch {
    isNewUser = true;
  }

  const customToken = await admin.auth().createCustomToken(uid, {
    provider: "kakao",
  });

  logger.info(`kakaoLogin: uid=${uid}, isNewUser=${isNewUser}`);

  return {customToken, isNewUser};
});
