import { https } from "firebase-functions/v1";
import * as admin from "firebase-admin";
import { isPendingDeletion } from "../account/account_common";

/**
 * 이 번호를 쓰는 계정이 있는지, 있다면 **지금 시도 중인 그 계정인지** 알려준다.
 *
 * 번호가 이미 쓰인다고 무조건 막으면 안 된다 — 같은 계정이 같은 방식으로
 * 다시 로그인하는 것까지 막혀 재로그인이 불가능해진다. 그래서 "중복"이 아니라
 * "주인이 누구인지"를 판정한다.
 *
 * 시도 중인 uid 판정 (클라 값을 그대로 믿지 않는다):
 * - 이미 로그인된 세션이 있으면 → `context.auth.uid` (서버가 검증한 값)
 * - 아니고 본인인증 경로면    → `phone:{phone}` (phone 하나로 결정된다)
 * - 아니면(소셜 신규)          → 없음. 아직 세션이 없으니 users 문서도 없다
 *
 * ⚠ 주인의 uid·provider는 **응답에 싣지 않는다** — 번호만 알면 남의
 * 카카오/네이버 식별자를 캐낼 수 있게 된다. 비교는 서버에서 끝낸다.
 */
export const checkPhoneDuplicate = https.onCall(async (data, context) => {
  const phone: string | undefined = data?.phone;
  // 'identity' | 'kakao' | 'naver' | 'apple' — 지금 진행 중인 가입/로그인 방식
  const method: string = data?.method ?? "identity";

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

  if (snap.empty) {
    return {
      isDuplicate: false,
      sameAccount: false,
      pendingDeletion: false,
      purgeAt: null,
      restorable: false,
    };
  }

  const doc = snap.docs[0];
  const user = doc.data();

  // 탈퇴 대기 계정도 중복이다 — 문서가 30일 남아 있어 여기 걸린다.
  // 통과시키면 같은 번호로 계정이 둘 생겨 phone 유니크 전제가 깨진다.
  // 앱이 "재가입 불가"와 "이미 가입됨"을 구분해 안내하도록 사유를 실어 보낸다.
  const pending = isPendingDeletion(user);
  const purgeAt = user?.purgeAt as admin.firestore.Timestamp | undefined;

  const attemptedUid = context.auth?.uid ??
    (method === "identity" ? `phone:${phone}` : null);
  const isOwner = attemptedUid !== null && attemptedUid === doc.id;

  // 탈퇴 대기라도 **본인이 파기 전에** 돌아온 것이면 막지 않는다 —
  // 이어지는 로그인(phoneLogin 등)이 계정을 되살린다
  // (restorePendingDeletionOnLogin). 파기 시각이 지났으면 되살려도 다음
  // 배치가 지우므로 그대로 차단한다.
  const restorable = pending && isOwner &&
    purgeAt !== undefined && purgeAt.toMillis() > Date.now();
  const blocked = pending && !restorable;

  return {
    isDuplicate: true,
    // 같은 계정이 같은 방식으로 다시 들어온 경우 = 재로그인. 앱이 통과시킨다.
    sameAccount: isOwner && !blocked,
    // 앱이 차단 안내를 띄울 조건 — 되살릴 수 있는 계정은 여기 안 걸린다.
    pendingDeletion: blocked,
    purgeAt: blocked ? purgeAt?.toMillis() ?? null : null,
    // 로그인하면 복구된다는 걸 앱이 미리 알 수 있게(안내 문구용).
    restorable,
  };
});
