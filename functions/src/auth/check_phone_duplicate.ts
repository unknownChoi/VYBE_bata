import { https } from "firebase-functions/v1";
import * as admin from "firebase-admin";
import { isPendingDeletion } from "../account/account_common";

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

  if (snap.empty) {
    return {isDuplicate: false, pendingDeletion: false, purgeAt: null};
  }

  // 탈퇴 대기 계정도 중복이다 — 문서가 30일 남아 있어 여기 걸린다.
  // 통과시키면 같은 번호로 계정이 둘 생겨 phone 유니크 전제가 깨진다.
  // 앱이 "재가입 불가"와 "이미 가입됨"을 구분해 안내하도록 사유를 실어 보낸다.
  const user = snap.docs[0].data();
  const pending = isPendingDeletion(user);
  const purgeAt = user?.purgeAt as admin.firestore.Timestamp | undefined;

  return {
    isDuplicate: true,
    pendingDeletion: pending,
    purgeAt: pending ? purgeAt?.toMillis() ?? null : null,
  };
});
