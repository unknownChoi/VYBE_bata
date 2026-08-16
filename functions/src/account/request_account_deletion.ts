import { https, logger } from "firebase-functions/v1";
import * as admin from "firebase-admin";
import {
  RETENTION_DAYS,
  STATUS_PENDING_DELETION,
  commitInChunks,
  isPendingDeletion,
} from "./account_common";

/**
 * 회원 탈퇴 요청.
 *
 * 데이터를 **지우지 않는다**. 30일 보관 요구와 "즉시 비노출" 요구를 분리해서,
 * 문서는 남기되 `isHidden` 으로 노출 경로에서만 빼고 집계를 감산한다.
 * 실제 파기는 30일 뒤 `purgeDeletedUsers` 스케줄이 한다.
 *
 * **멱등**하게 만들어 뒀다 — 중간에 실패해서 앱이 다시 호출해도
 * 상태 필드만 유지되고 아직 안 숨겨진 문서만 이어서 처리한다.
 * (집계는 `isHidden !== true` 인 문서만 세므로 두 번 깎이지 않는다)
 */
export const requestAccountDeletion = https.onCall(async (data, context) => {
  const uid = context.auth?.uid;
  if (!uid) {
    throw new https.HttpsError(
      "unauthenticated",
      "로그인이 필요합니다."
    );
  }

  const reason: string = typeof data?.reason === "string" ? data.reason : "";

  const db = admin.firestore();
  const userRef = db.collection("users").doc(uid);
  const userSnap = await userRef.get();

  // 1) 상태 기록 — 이미 대기 중이면 deletedAt/purgeAt 을 덮어쓰지 않는다.
  //    (재호출로 파기 시점이 계속 뒤로 밀리면 안 된다)
  let purgeAt: admin.firestore.Timestamp;
  if (userSnap.exists && isPendingDeletion(userSnap.data())) {
    purgeAt = userSnap.data()?.purgeAt as admin.firestore.Timestamp;
  } else {
    const now = Date.now();
    purgeAt = admin.firestore.Timestamp.fromMillis(
      now + RETENTION_DAYS * 24 * 60 * 60 * 1000
    );
    await userRef.set({
      status: STATUS_PENDING_DELETION,
      deletedAt: admin.firestore.Timestamp.fromMillis(now),
      purgeAt,
      deletionReason: reason,
      updatedAt: admin.firestore.FieldValue.serverTimestamp(),
    }, {merge: true});
  }

  // 2) 리뷰 숨김 + 클럽 평점 집계 감산
  const hiddenReviews = await hideReviews(uid);

  // 3) 사진 숨김 (집계 없음)
  const hiddenPhotos = await hidePhotos(uid);

  // 4) 찜 숨김 + favoriteCount 감산
  const hiddenFavorites = await hideFavorites(uid);

  // 5) Auth 계정 비활성.
  //    삭제가 아니라 disabled 인 이유 — 소셜 uid(`kakao:{id}`)는 고정이라
  //    Auth에서 지우면 재로그인 시 같은 uid가 다시 만들어져 보관 중인
  //    데이터에 그대로 붙는다. disabled 면 로그인이 거부되고, 앱의
  //    isSessionRevokedCode 가 'user-disabled' 를 이미 처리해 다른 기기
  //    세션도 다음 실행 때 자동 정리된다.
  try {
    await admin.auth().updateUser(uid, {disabled: true});
  } catch (e) {
    logger.error(`requestAccountDeletion: disable 실패 uid=${uid}`, e);
    throw new https.HttpsError(
      "internal",
      "탈퇴 처리에 실패했습니다. 잠시 후 다시 시도해주세요."
    );
  }

  logger.info(
    `requestAccountDeletion: uid=${uid} ` +
      `reviews=${hiddenReviews} photos=${hiddenPhotos} ` +
      `favorites=${hiddenFavorites} purgeAt=${purgeAt.toDate().toISOString()}`
  );

  return {purgeAt: purgeAt.toMillis()};
});

/**
 * 유저가 쓴 리뷰를 전부 숨기고, 클럽별 평점 집계를 감산한다.
 *
 * ⚠ 집계를 여기서 직접 하는 이유 — `isHidden` 세팅은 문서 update라
 * `onReviewUpdated` 가 발화한다. 거기서도 재계산하면 이중 감산이 나므로
 * 트리거는 `isHidden` 전이를 무시하고(가드), 감산 주체를 이 함수 하나로 못 박는다.
 */
async function hideReviews(uid: string): Promise<number> {
  const db = admin.firestore();
  const snap = await db
    .collectionGroup("reviews")
    .where("userId", "==", uid)
    .get();

  // 이미 숨긴 문서는 집계에서 제외 — 재호출 시 두 번 깎이지 않게
  const targets = snap.docs.filter((d) => d.data()?.isHidden !== true);
  if (targets.length === 0) return 0;

  // 클럽별 (평점 합, 개수) 델타 집계
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
    batch.update(doc.ref, {isHidden: true});
  });

  for (const [clubId, delta] of deltas) {
    await applyRatingDelta(clubId, -delta.sum, -delta.count);
  }

  return targets.length;
}

/** 유저가 올린 사진을 전부 숨긴다. 사진은 클럽 집계에 안 들어가 감산 없음. */
async function hidePhotos(uid: string): Promise<number> {
  const db = admin.firestore();
  const snap = await db
    .collectionGroup("photos")
    .where("userId", "==", uid)
    .get();

  const targets = snap.docs.filter((d) => d.data()?.isHidden !== true);
  if (targets.length === 0) return 0;

  await commitInChunks(targets, (batch, doc) => {
    batch.update(doc.ref, {isHidden: true});
  });

  return targets.length;
}

/**
 * 찜을 숨기고 `favoriteCount` 를 감산한다.
 *
 * 찜은 본인만 읽으므로 '노출' 이슈는 없지만, `favoriteCount` 는 공개 지표라
 * 빼야 한다. 문서를 지우지 않는 이유는 30일 보관 요구 때문 —
 * `isHidden` 은 "집계에서 이미 뺐다"는 표시도 겸해 파기 때 이중 감산을 막는다.
 */
async function hideFavorites(uid: string): Promise<number> {
  const db = admin.firestore();
  const snap = await db
    .collection("favorites")
    .where("userId", "==", uid)
    .get();

  const targets = snap.docs.filter((d) => d.data()?.isHidden !== true);
  if (targets.length === 0) return 0;

  const perClub = new Map<string, number>();
  for (const doc of targets) {
    const clubId = doc.data()?.clubId;
    if (typeof clubId !== "string" || !clubId) continue;
    perClub.set(clubId, (perClub.get(clubId) ?? 0) + 1);
  }

  await commitInChunks(targets, (batch, doc) => {
    batch.update(doc.ref, {isHidden: true});
  });

  for (const [clubId, count] of perClub) {
    await applyFavoriteDelta(clubId, -count);
  }

  return targets.length;
}

/** clubs/{clubId} 의 ratingSum·reviewCount 를 델타만큼 옮기고 rating 재계산. */
export async function applyRatingDelta(
  clubId: string,
  sumDelta: number,
  countDelta: number
): Promise<void> {
  const clubRef = admin.firestore().collection("clubs").doc(clubId);

  await admin.firestore().runTransaction(async (tx) => {
    const snap = await tx.get(clubRef);
    if (!snap.exists) return;

    const club = snap.data() ?? {};
    const newSum = Math.max(0, (club.ratingSum ?? 0) + sumDelta);
    const newCount = Math.max(0, (club.reviewCount ?? 0) + countDelta);

    tx.update(clubRef, {
      ratingSum: newSum,
      reviewCount: newCount,
      rating: newCount > 0 ? Math.round((newSum / newCount) * 10) / 10 : 0,
    });
  });
}

/** clubs/{clubId} 의 favoriteCount 를 델타만큼 옮긴다 (0 미만 방지). */
export async function applyFavoriteDelta(
  clubId: string,
  delta: number
): Promise<void> {
  const clubRef = admin.firestore().collection("clubs").doc(clubId);

  await admin.firestore().runTransaction(async (tx) => {
    const snap = await tx.get(clubRef);
    if (!snap.exists) return;

    const current: number = snap.data()?.favoriteCount ?? 0;
    tx.update(clubRef, {favoriteCount: Math.max(0, current + delta)});
  });
}
