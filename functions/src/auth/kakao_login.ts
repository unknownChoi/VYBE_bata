import { https, logger } from "firebase-functions/v1";
import * as admin from "firebase-admin";
import axios from "axios";
import { restorePendingDeletionOnLogin } from "../account/restore_account";

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

  // 탈퇴 대기 계정이면 보관 기간 안에 한해 여기서 되살린다. Auth 가 disabled
  // 인 채로 토큰을 주면 앱의 signInWithCustomToken 이 거부되므로 발급 전에
  // 풀어야 한다. 파기 시점이 지났으면 failed-precondition 으로 막힌다.
  const restored = await restorePendingDeletionOnLogin(uid);

  let isNewUser = false;
  try {
    await admin.auth().getUser(uid);
  } catch {
    isNewUser = true;
  }

  const customToken = await admin.auth().createCustomToken(uid, {
    provider: "kakao",
  });

  logger.info(
    `kakaoLogin: uid=${uid}, isNewUser=${isNewUser}, restored=${restored}`
  );

  return {customToken, isNewUser, restored};
});
