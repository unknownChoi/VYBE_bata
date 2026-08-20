import { logger } from "firebase-functions/v1";
import * as admin from "firebase-admin";
import {
  STATUS_ACTIVE,
  applyFavoriteDelta,
  applyRatingDelta,
  commitInChunks,
  isPendingDeletion,
  pendingDeletionError,
} from "./account_common";

/**
 * 보관 기간(30일) 안에 다시 로그인한 탈퇴 대기 계정을 되살린다.
 *
 * 로그인 3종(`kakaoLogin`·`naverLogin`·`phoneLogin`)이 Custom Token 을 발급하기
 * **전에** 부른다. Auth 계정이 `disabled` 인 채로 토큰을 주면 앱의
 * `signInWithCustomToken` 이 거부되므로, 여기서 먼저 풀어야 한다.
 *
 * `requestAccountDeletion` 의 정확한 역연산이다 —
 * 리뷰·사진·찜 `isHidden=false` + 집계 가산 + Auth 활성 + 상태 필드 제거.
 *
 * @returns 실제로 복구했으면 true. 원래 정상 계정이었으면 false.
 * @throws  파기 시점이 이미 지났으면 `failed-precondition`
 *          (되살려도 다음 파기 배치가 다시 지운다 — 살리지 않는다).
 */
export async function restorePendingDeletionOnLogin(
  uid: string
): Promise<boolean> {
  const db = admin.firestore();
  const userRef = db.collection("users").doc(uid);
  const snap = await userRef.get();
  if (!snap.exists) return false;

  const data = snap.data();
  if (!isPendingDeletion(data)) return false;

  const purgeAt = data?.purgeAt as admin.firestore.Timestamp | undefined;

  // 파기 예정 시각이 지났으면 되살리지 않는다. purgeDeletedUsers 가 아직
  // 안 돌았을 뿐이고, 살려 놔도 다음 새벽 배치가 데이터를 지워 버린다.
  // purgeAt 이 아예 없는 문서도 같은 이유로 막는다(언제 지워질지 모른다).
  if (!purgeAt || purgeAt.toMillis() <= Date.now()) {
    // purgeAt 을 실어 보내지 않는다 — 이미 지난 날짜를 "그 날부터 가입 가능"
    // 이라고 안내하면 거짓말이 된다. 앱은 "잠시 후 다시 시도" 문구로 폴백한다.
    throw pendingDeletionError(null);
  }

  // 상태 필드는 **맨 마지막에** 지운다. 중간에 실패하면 status 가
  // pendingDeletion 으로 남아 다음 로그인 때 처음부터 다시 시도된다
  // (각 단계는 isHidden===true 인 것만 손대므로 재실행해도 이중 가산 없음).
  const shownReviews = await unhideReviews(uid);
  const shownPhotos = await unhidePhotos(uid);
  const shownFavorites = await unhideFavorites(uid);

  await admin.auth().updateUser(uid, {disabled: false});

  await userRef.update({
    status: STATUS_ACTIVE,
    deletedAt: admin.firestore.FieldValue.delete(),
    purgeAt: admin.firestore.FieldValue.delete(),
    deletionReason: admin.firestore.FieldValue.delete(),
    updatedAt: admin.firestore.FieldValue.serverTimestamp(),
  });

  logger.info(
    `restoreAccount: uid=${uid} reviews=${shownReviews} ` +
      `photos=${shownPhotos} favorites=${shownFavorites}`
  );
  return true;
}

/**
 * 숨겨 둔 리뷰를 되살리고 클럽 평점 집계를 가산한다.
 *
 * ⚠ 가산 주체는 여기 하나 — `isHidden` 을 false 로 되돌리는 update 는
 * `onReviewUpdated` 를 발화시키지만, 그 트리거는 `isHidden` 전이를 통째로
 * 건너뛴다(가드). 없으면 두 번 더해진다.
 */
async function unhideReviews(uid: string): Promise<number> {
  const db = admin.firestore();
  const snap = await db
    .collectionGroup("reviews")
    .where("userId", "==", uid)
    .get();

  const targets = snap.docs.filter((d) => d.data()?.isHidden === true);
  if (targets.length === 0) return 0;

  const deltas = new Map<string, {sum: number; count: number}>();
  for (const doc of targets) {
    const clubId = doc.ref.parent.parent?.id;
    if (!clubId) continue;
    const rating = doc.data()?.rating;
    if (typeof rating !== "number") continue;

    const prev = deltas.get(clubId) ?? {sum: 0, count: 0};
    deltas.set(clubId, {sum: prev.sum + rating, count: prev.count + 1});
  }

  await commitInChunks(targets, (batch, doc) => {
    batch.update(doc.ref, {isHidden: false});
  });

  for (const [clubId, delta] of deltas) {
    await applyRatingDelta(clubId, delta.sum, delta.count);
  }

  return targets.length;
}

/** 숨겨 둔 사진을 되살린다. 사진은 클럽 집계에 안 들어가 가산 없음. */
async function unhidePhotos(uid: string): Promise<number> {
  const db = admin.firestore();
  const snap = await db
    .collectionGroup("photos")
    .where("userId", "==", uid)
    .get();

  const targets = snap.docs.filter((d) => d.data()?.isHidden === true);
  if (targets.length === 0) return 0;

  await commitInChunks(targets, (batch, doc) => {
    batch.update(doc.ref, {isHidden: false});
  });

  return targets.length;
}

/** 숨겨 둔 찜을 되살리고 `favoriteCount` 를 가산한다. */
async function unhideFavorites(uid: string): Promise<number> {
  const db = admin.firestore();
  const snap = await db
    .collection("favorites")
    .where("userId", "==", uid)
    .get();

  const targets = snap.docs.filter((d) => d.data()?.isHidden === true);
  if (targets.length === 0) return 0;

  const perClub = new Map<string, number>();
  for (const doc of targets) {
    const clubId = doc.data()?.clubId;
    if (typeof clubId !== "string" || !clubId) continue;
    perClub.set(clubId, (perClub.get(clubId) ?? 0) + 1);
  }

  await commitInChunks(targets, (batch, doc) => {
    batch.update(doc.ref, {isHidden: false});
  });

  for (const [clubId, count] of perClub) {
    await applyFavoriteDelta(clubId, count);
  }

  return targets.length;
}
