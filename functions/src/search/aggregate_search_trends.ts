import {pubsub, logger} from "firebase-functions/v1";
import * as admin from "firebase-admin";
import {
  SearchLogEntry,
  aggregateLogs,
  normalizeKey,
  rankHashtags,
  rankTrends,
  scheduleDecision,
} from "./compute_trends";

// 집계 윈도우. 클럽 검색은 밤에 몰리므로 24h를 잡아도 최근 몇 시간이
// 표본의 상당 비중을 차지한다 → 야간 매시 갱신에도 순위가 실제로 움직인다.
const WINDOW_HOURS = 24;

// 이 인원 미만이 검색한 키워드는 노출하지 않음 (1인 검색어가 1위 되는 사고 방지).
const MIN_USERS = 2;

// 노출 개수 (검색 화면 2열 × 5행).
const TREND_LIMIT = 10;

// 랭킹에 반영할 유입 경로. 트렌드/해시태그 칩 탭(source: trend/hashtag)을
// 제외하지 않으면 1위가 계속 1위가 되는 되먹임이 생긴다.
const RANKED_SOURCES = ["input", "suggestion"];

// 한 번에 읽을 로그 상한 (폭주 방어).
const MAX_LOGS = 20000;

// 시드 스크립트가 넣은 합성 로그(isSynthetic: true) 제외 여부.
// 실사용자 트래픽이 확보되면 true로 바꾼다.
const EXCLUDE_SYNTHETIC = false;

const BLOCKLIST: string[] = [];

// 갱신 주기·중복 실행 가드를 무시하고 즉시 집계 (검증용).
// functions:shell 에서만 켠다 — 배포 환경엔 이 환경변수가 없다.
//   FORCE_TREND_AGGREGATION=1 firebase functions:shell
const FORCE = process.env.FORCE_TREND_AGGREGATION === "1";

const TRENDS_COLLECTION = "searchTrends";
const CURRENT_DOC = "current";
const FALLBACK_DOC = "fallback";
const HASHTAGS_COLLECTION = "searchHashtags";

/** UTC Date → KST 기준 시각 구성요소 */
function kstParts(now: Date): { hour: number; runKey: string } {
  const kst = new Date(now.getTime() + 9 * 60 * 60 * 1000);
  const y = kst.getUTCFullYear();
  const m = `${kst.getUTCMonth() + 1}`.padStart(2, "0");
  const d = `${kst.getUTCDate()}`.padStart(2, "0");
  const h = `${kst.getUTCHours()}`.padStart(2, "0");
  return {hour: kst.getUTCHours(), runKey: `${y}${m}${d}${h}`};
}

// 검색 트렌드 집계 (매시 정각 KST 실행 → 내부에서 갱신 여부 판단)
//
// 갱신 주기
//   실시간 인기 검색어 : 2시간 / 20:00~09:00은 1시간
//   인기 해시태그      : 4시간 / 20:00~09:00은 1시간
//
// 갱신 대상이 없는 시각엔 Firestore 접근 없이 즉시 종료한다.
export const aggregateSearchTrends = pubsub
  .schedule("0 * * * *")
  .timeZone("Asia/Seoul")
  .onRun(async () => {
    const db = admin.firestore();
    const now = new Date();
    const {hour, runKey} = kstParts(now);
    const scheduled = scheduleDecision(hour);
    const due = FORCE ?
      {trend: true, hashtag: true, night: scheduled.night} :
      scheduled;

    if (!due.trend) {
      logger.info(
        `aggregateSearchTrends: skip (KST ${hour}시 — 갱신 대상 아님) ` +
          `[force=${FORCE}]`
      );
      return;
    }

    const currentRef = db.collection(TRENDS_COLLECTION).doc(CURRENT_DOC);
    const [currentSnap, fallbackSnap] = await Promise.all([
      currentRef.get(),
      db.collection(TRENDS_COLLECTION).doc(FALLBACK_DOC).get(),
    ]);

    // 같은 시각에 두 번 실행되면(재시도 등) 증감이 직전 결과와 비교되어
    // 전부 same으로 뭉개진다 → runKey로 중복 실행 차단.
    const currentData = currentSnap.data();
    if (!FORCE && currentData?.runKey === runKey) {
      logger.info(
        `aggregateSearchTrends: skip (runKey ${runKey} 이미 처리) ` +
          `[force=${FORCE}] — 재실행하려면 FORCE_TREND_AGGREGATION=1`
      );
      return;
    }

    // ── 1. 로그 수집 ──
    const since = admin.firestore.Timestamp.fromMillis(
      now.getTime() - WINDOW_HOURS * 60 * 60 * 1000
    );
    const logsSnap = await db
      .collection("searchLogs")
      .where("createdAt", ">=", since)
      .orderBy("createdAt", "desc")
      .limit(MAX_LOGS)
      .get();

    const entries: SearchLogEntry[] = [];
    logsSnap.forEach((doc) => {
      const data = doc.data();
      if (EXCLUDE_SYNTHETIC && data.isSynthetic === true) return;
      const createdAt = data.createdAt as admin.firestore.Timestamp | undefined;
      if (!createdAt) return;
      entries.push({
        keyword: (data.keyword as string) ?? "",
        userId: (data.userId as string) ?? "",
        source: (data.source as string) ?? "",
        createdAtMs: createdAt.toMillis(),
      });
    });

    const stats = aggregateLogs(entries, {
      rankedSources: RANKED_SOURCES,
      blocklist: BLOCKLIST,
    });

    // ── 2. 실시간 인기 검색어 ──
    const prevRanks: Record<string, number> = {};
    const prevItems = (currentData?.items ?? []) as Array<{
      keyword?: string;
      rank?: number;
      uniqueUsers?: number;
    }>;
    for (const item of prevItems) {
      // fallback으로 채웠던 자리는 실제 순위가 아니므로 증감 기준에서 제외.
      if (!item.keyword || !item.rank) continue;
      if ((item.uniqueUsers ?? 0) <= 0) continue;
      prevRanks[normalizeKey(item.keyword)] = item.rank;
    }

    const fallback = ((fallbackSnap.data()?.items ?? []) as Array<{
      keyword?: string;
    }>)
      .map((it) => it.keyword ?? "")
      .filter((k) => k.length > 0);

    const items = rankTrends(stats, prevRanks, {
      minUsers: MIN_USERS,
      limit: TREND_LIMIT,
      fallback,
    });
    const realCount = items.filter((it) => it.uniqueUsers > 0).length;

    await currentRef.set({
      items,
      realCount,
      sampleSize: entries.length,
      windowHours: WINDOW_HOURS,
      runKey,
      updatedAt: admin.firestore.FieldValue.serverTimestamp(),
    });

    // ── 3. 인기 해시태그 순위 (4시간 / 야간 매시) ──
    let hashtagUpdated = 0;
    if (due.hashtag) {
      const tagsSnap = await db
        .collection(HASHTAGS_COLLECTION)
        .where("isActive", "==", true)
        .get();

      const labels = tagsSnap.docs.map(
        (doc) => (doc.data().label as string) ?? ""
      );
      const ranks = rankHashtags(labels, stats);

      const batch = db.batch();
      tagsSnap.docs.forEach((doc) => {
        const label = (doc.data().label as string) ?? "";
        const next = ranks[label] ?? null;
        const prev = (doc.data().popularityRank as number | null) ?? null;
        if (next === prev) return; // 변화 없으면 쓰지 않음
        batch.update(doc.ref, {popularityRank: next});
        hashtagUpdated += 1;
      });
      if (hashtagUpdated > 0) await batch.commit();
    }

    logger.info(
      `aggregateSearchTrends: KST ${hour}시 (야간=${due.night}) ` +
        `로그 ${entries.length}건 → 키워드 ${stats.length}종 / ` +
        `트렌드 ${items.length}개(실데이터 ${realCount}) / ` +
        `해시태그 ${due.hashtag ? `${hashtagUpdated}건 갱신` : "미갱신"}`
    );
  });
