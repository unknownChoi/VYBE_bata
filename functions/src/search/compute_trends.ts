// 검색 트렌드 집계 순수 로직 — Firestore/Admin SDK 의존 없음.
//
// 이 파일에 로직을 몰아넣는 이유: 실사용자 없이도 배열 리터럴만으로 전 케이스를
// 검증할 수 있게 하기 위함. aggregate_search_trends.ts는 읽기/쓰기만 담당한다.
// 검증 스크립트: node scripts/test_compute_trends.js

export type TrendStatus = "up" | "down" | "newEntry" | "same";

/** 집계 입력 — searchLogs 문서 1건을 평면화한 형태 */
export interface SearchLogEntry {
  keyword: string;
  userId: string;
  source: string;
  createdAtMs: number;
}

/** 키워드 단위 집계 결과 */
export interface KeywordStat {
  /** 정규화 키 (소문자) — 그룹핑 기준 */
  key: string;
  /** 표시용 원문 (가장 많이 쓰인 표기를 채택) */
  display: string;
  /** 고유 userId 수 — 랭킹 기준 */
  uniqueUsers: number;
  /** 로그 건수 — 동점 tie-break */
  count: number;
  /** 마지막 검색 시각 — 2차 tie-break */
  lastAtMs: number;
}

export interface TrendItem {
  rank: number;
  keyword: string;
  status: TrendStatus;
  change: number | null;
  /** 0이면 fallback으로 채운 자리 (실데이터 아님) */
  uniqueUsers: number;
}

export interface AggregateOptions {
  /** 랭킹에 반영할 source 목록. 트렌드/해시태그 탭 유입은 제외해 되먹임을 막는다. */
  rankedSources: string[];
  /** 금칙어 (정규화 키 기준 완전 일치) */
  blocklist?: string[];
}

export interface RankOptions {
  /** 이 인원 미만이 검색한 키워드는 노출하지 않음 */
  minUsers: number;
  /** 노출 개수 */
  limit: number;
  /** 실데이터가 모자랄 때 뒷자리를 채울 큐레이션 키워드 */
  fallback: string[];
}

const MIN_KEYWORD_LENGTH = 2;
const MAX_KEYWORD_LENGTH = 30;

// 한글(음절·자모) 또는 라틴 문자가 최소 1자는 있어야 유효한 검색어로 본다.
// 숫자·기호만으로 이루어진 입력("123", "!!!")을 걸러낸다.
const HAS_LETTER = /[a-zA-Z가-힣ㄱ-ㆎ]/;

/**
 * 표시용 정리 — 앞뒤 공백 제거, 선행 '#' 제거, 연속 공백 1칸.
 * 대소문자는 보존한다 ('EDM'을 'edm'으로 보여주지 않기 위해).
 */
export function displayForm(raw: string): string {
  return raw.replace(/^#+/, "").replace(/\s+/g, " ").trim();
}

/**
 * 그룹핑 키 — displayForm에 소문자화만 추가.
 * 'EDM' / 'edm' / '#EDM '을 한 키워드로 합친다.
 */
export function normalizeKey(raw: string): string {
  return displayForm(raw).toLowerCase();
}

/** 집계 대상으로 삼을 수 있는 검색어인지 */
export function isValidKeyword(key: string): boolean {
  if (key.length < MIN_KEYWORD_LENGTH) return false;
  if (key.length > MAX_KEYWORD_LENGTH) return false;
  return HAS_LETTER.test(key);
}

/**
 * 로그 목록 → 키워드별 통계.
 * minUsers 필터는 여기서 하지 않는다 (해시태그 순위는 임계값이 다르므로).
 */
export function aggregateLogs(
  logs: SearchLogEntry[],
  opts: AggregateOptions
): KeywordStat[] {
  const ranked = new Set(opts.rankedSources);
  const blocked = new Set((opts.blocklist ?? []).map(normalizeKey));

  const buckets = new Map<
    string,
    {
      users: Set<string>;
      count: number;
      lastAtMs: number;
      displays: Map<string, number>;
    }
  >();

  for (const log of logs) {
    if (!ranked.has(log.source)) continue;

    const key = normalizeKey(log.keyword);
    if (!isValidKeyword(key)) continue;
    if (blocked.has(key)) continue;

    let bucket = buckets.get(key);
    if (!bucket) {
      bucket = {users: new Set(), count: 0, lastAtMs: 0, displays: new Map()};
      buckets.set(key, bucket);
    }

    bucket.users.add(log.userId);
    bucket.count += 1;
    if (log.createdAtMs > bucket.lastAtMs) bucket.lastAtMs = log.createdAtMs;

    const display = displayForm(log.keyword);
    bucket.displays.set(display, (bucket.displays.get(display) ?? 0) + 1);
  }

  const stats: KeywordStat[] = [];
  buckets.forEach((bucket, key) => {
    // 같은 키워드의 여러 표기 중 가장 많이 쓰인 것을 대표로.
    let display = key;
    let best = -1;
    bucket.displays.forEach((n, form) => {
      if (n > best) {
        best = n;
        display = form;
      }
    });

    stats.push({
      key,
      display,
      uniqueUsers: bucket.users.size,
      count: bucket.count,
      lastAtMs: bucket.lastAtMs,
    });
  });

  return sortStats(stats);
}

/** 고유 유저 → 건수 → 최근 → 키 순. 완전 결정적(입력 순서 무관). */
function sortStats(stats: KeywordStat[]): KeywordStat[] {
  return stats.sort((a, b) => {
    if (b.uniqueUsers !== a.uniqueUsers) return b.uniqueUsers - a.uniqueUsers;
    if (b.count !== a.count) return b.count - a.count;
    if (b.lastAtMs !== a.lastAtMs) return b.lastAtMs - a.lastAtMs;
    return a.key.localeCompare(b.key);
  });
}

/**
 * 키워드 통계 + 직전 순위 → 노출용 트렌드 목록.
 *
 * @param prevRanks 직전 스냅샷의 { 정규화키: 순위 }. 증감 계산에만 쓰인다.
 */
export function rankTrends(
  stats: KeywordStat[],
  prevRanks: Record<string, number>,
  opts: RankOptions
): TrendItem[] {
  const items: TrendItem[] = [];

  for (const stat of stats) {
    if (items.length >= opts.limit) break;
    if (stat.uniqueUsers < opts.minUsers) continue;

    const rank = items.length + 1;
    const prev = prevRanks[stat.key];

    let status: TrendStatus = "same";
    let change: number | null = null;

    if (prev === undefined) {
      status = "newEntry";
    } else if (prev > rank) {
      status = "up";
      change = prev - rank;
    } else if (prev < rank) {
      status = "down";
      change = rank - prev;
    }

    items.push({
      rank,
      keyword: stat.display,
      status,
      change,
      uniqueUsers: stat.uniqueUsers,
    });
  }

  // 실데이터가 모자라면 큐레이션 목록으로 뒷자리를 채운다.
  // uniqueUsers: 0 → 앱에서 증감 아이콘을 숨기는 근거가 된다 (가짜 순위변동 금지).
  const used = new Set(items.map((it) => normalizeKey(it.keyword)));
  for (const keyword of opts.fallback) {
    if (items.length >= opts.limit) break;
    const key = normalizeKey(keyword);
    if (!isValidKeyword(key) || used.has(key)) continue;
    used.add(key);
    items.push({
      rank: items.length + 1,
      keyword: displayForm(keyword),
      status: "same",
      change: null,
      uniqueUsers: 0,
    });
  }

  return items;
}

/**
 * 해시태그 label 목록 → { label: popularityRank }.
 * 검색량이 있는 해시태그만 1부터 순위를 받고, 나머지는 null (앱에서 order로 폴백).
 */
export function rankHashtags(
  labels: string[],
  stats: KeywordStat[]
): Record<string, number | null> {
  const volume = new Map<string, number>();
  for (const stat of stats) volume.set(stat.key, stat.uniqueUsers);

  const scored = labels
    .map((label) => ({label, users: volume.get(normalizeKey(label)) ?? 0}))
    .filter((entry) => entry.users > 0)
    .sort((a, b) => {
      if (b.users !== a.users) return b.users - a.users;
      return a.label.localeCompare(b.label);
    });

  const result: Record<string, number | null> = {};
  for (const label of labels) result[label] = null;
  scored.forEach((entry, i) => {
    result[entry.label] = i + 1;
  });
  return result;
}

/**
 * KST 시각(0~23) → 이번 시간에 무엇을 갱신할지.
 *
 * - 야간(20:00~09:00): 검색어·해시태그 모두 매시
 * - 주간(10:00~19:00): 검색어 2시간(10·12·14·16·18) / 해시태그 4시간(12·16)
 *
 * 주간 간격은 자정 기준 앵커(hour % N)라 해시태그 갱신 시각은 항상
 * 검색어 갱신 시각의 부분집합이다 → 로그 스캔 1회로 둘 다 처리 가능.
 */
export function scheduleDecision(hourKst: number): {
  trend: boolean;
  hashtag: boolean;
  night: boolean;
} {
  const night = hourKst >= 20 || hourKst <= 9;
  return {
    night,
    trend: night || hourKst % 2 === 0,
    hashtag: night || hourKst % 4 === 0,
  };
}
