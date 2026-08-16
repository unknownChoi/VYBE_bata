import { https } from "firebase-functions/v1";
import * as admin from "firebase-admin";

/** 탈퇴 요청 후 데이터를 보관하는 기간. 이 기간이 지나면 완전 파기. */
export const RETENTION_DAYS = 30;

/** users/{uid}.status 값 */
export const STATUS_ACTIVE = "active";
export const STATUS_PENDING_DELETION = "pendingDeletion";

/**
 * 탈퇴 대기 상태인지. `status` 필드가 없는 기존 문서는 active로 본다.
 */
export function isPendingDeletion(
  data: FirebaseFirestore.DocumentData | undefined
): boolean {
  return data?.status === STATUS_PENDING_DELETION;
}

/**
 * users/{uid} 를 읽어 탈퇴 대기 상태면 `failed-precondition` 으로 막는다.
 *
 * 로그인 함수(kakao/naver/phone)가 Custom Token을 발급하기 **전에** 호출한다.
 * Auth 계정이 disabled 라 어차피 signInWithCustomToken 이 거부되지만,
 * 여기서 막아야 앱이 "왜 안 되는지"(재가입 가능일)를 사용자에게 보여줄 수 있다.
 */
export async function assertNotPendingDeletion(uid: string): Promise<void> {
  const snap = await admin.firestore().collection("users").doc(uid).get();
  if (!snap.exists) return;

  const data = snap.data();
  if (!isPendingDeletion(data)) return;

  const purgeAt = data?.purgeAt as admin.firestore.Timestamp | undefined;

  // details 에 purgeAt 을 실어 앱이 "언제부터 재가입 가능한지"를 보여줄 수 있게 한다.
  throw new https.HttpsError(
    "failed-precondition",
    "탈퇴 처리 중인 계정입니다.",
    {purgeAt: purgeAt?.toMillis() ?? null}
  );
}

/**
 * 문서를 Firestore 배치 한도(500)에 맞춰 나눠 쓴다.
 *
 * `apply` 는 배치에 쓰기를 하나만 거는 것을 전제로 한다 — 문서당 쓰기가
 * 둘 이상이면 chunk 크기를 줄여 호출할 것.
 */
export async function commitInChunks<T>(
  items: T[],
  apply: (batch: FirebaseFirestore.WriteBatch, item: T) => void,
  chunkSize = 500
): Promise<void> {
  const db = admin.firestore();
  for (let i = 0; i < items.length; i += chunkSize) {
    const batch = db.batch();
    items.slice(i, i + chunkSize).forEach((item) => apply(batch, item));
    await batch.commit();
  }
}

/**
 * Storage 경로 prefix 아래 파일을 전부 지운다. 실패해도 던지지 않는다 —
 * 파기 배치가 파일 하나 때문에 멈추면 안 된다(다음 회차에 다시 시도된다).
 */
export async function deleteStorageFolder(prefix: string): Promise<void> {
  try {
    await admin.storage().bucket().deleteFiles({prefix});
  } catch (e) {
    // 파일이 없거나 권한 문제 — 로그만 남기고 진행
    console.warn(`deleteStorageFolder failed: ${prefix}`, e);
  }
}
