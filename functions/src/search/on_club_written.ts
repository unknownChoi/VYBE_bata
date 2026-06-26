import { firestore, logger } from "firebase-functions/v1";
import * as admin from "firebase-admin";
import { buildSearchTokens, sameTokens } from "./club_tokens";

// clubs/{clubId} 생성·수정 시 searchTokens 자동 갱신.
//
// - 삭제: 문서가 사라지므로 처리 불필요.
// - 생성/수정: name/area/genre/tags 로 토큰 재계산 → 기존과 다르면 update.
//   (update 가 다시 트리거를 호출하므로 sameTokens 로 동일하면 즉시 종료 → 무한루프 방지)
export const onClubWritten = firestore
  .document("clubs/{clubId}")
  .onWrite(async (change, context) => {
    const after = change.after;
    if (!after.exists) return; // 삭제

    const data = after.data() ?? {};
    const next = buildSearchTokens({
      name: data.name,
      area: data.area,
      genre: data.genre,
      tags: data.tags,
    });

    const current: string[] = Array.isArray(data.searchTokens)
      ? data.searchTokens
      : [];

    if (sameTokens(current, next)) return; // 변화 없음 → 루프 차단

    await admin
      .firestore()
      .collection("clubs")
      .doc(context.params.clubId)
      .update({ searchTokens: next });

    logger.info(
      `searchTokens updated (${next.length}) for club: ${context.params.clubId}`
    );
  });
