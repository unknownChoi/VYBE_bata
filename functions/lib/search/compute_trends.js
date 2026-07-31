"use strict";
// 검색 트렌드 집계 순수 로직 — Firestore/Admin SDK 의존 없음.
//
// 이 파일에 로직을 몰아넣는 이유: 실사용자 없이도 배열 리터럴만으로 전 케이스를
// 검증할 수 있게 하기 위함. aggregate_search_trends.ts는 읽기/쓰기만 담당한다.
// 검증 스크립트: node scripts/test_compute_trends.js
Object.defineProperty(exports, "__esModule", { value: true });
exports.displayForm = displayForm;
exports.normalizeKey = normalizeKey;
exports.isValidKeyword = isValidKeyword;
exports.aggregateLogs = aggregateLogs;
exports.rankTrends = rankTrends;
exports.rankHashtags = rankHashtags;
exports.scheduleDecision = scheduleDecision;
const MIN_KEYWORD_LENGTH = 2;
const MAX_KEYWORD_LENGTH = 30;
// 한글(음절·자모) 또는 라틴 문자가 최소 1자는 있어야 유효한 검색어로 본다.
// 숫자·기호만으로 이루어진 입력("123", "!!!")을 걸러낸다.
const HAS_LETTER = /[a-zA-Z가-힣ㄱ-ㆎ]/;
/**
 * 표시용 정리 — 앞뒤 공백 제거, 선행 '#' 제거, 연속 공백 1칸.
 * 대소문자는 보존한다 ('EDM'을 'edm'으로 보여주지 않기 위해).
 */
function displayForm(raw) {
    return raw.replace(/^#+/, "").replace(/\s+/g, " ").trim();
}
/**
 * 그룹핑 키 — displayForm에 소문자화만 추가.
 * 'EDM' / 'edm' / '#EDM '을 한 키워드로 합친다.
 */
function normalizeKey(raw) {
    return displayForm(raw).toLowerCase();
}
/** 집계 대상으로 삼을 수 있는 검색어인지 */
function isValidKeyword(key) {
    if (key.length < MIN_KEYWORD_LENGTH)
        return false;
    if (key.length > MAX_KEYWORD_LENGTH)
        return false;
    return HAS_LETTER.test(key);
}
/**
 * 로그 목록 → 키워드별 통계.
 * minUsers 필터는 여기서 하지 않는다 (해시태그 순위는 임계값이 다르므로).
 */
function aggregateLogs(logs, opts) {
    var _a, _b;
    const ranked = new Set(opts.rankedSources);
    const blocked = new Set(((_a = opts.blocklist) !== null && _a !== void 0 ? _a : []).map(normalizeKey));
    const buckets = new Map();
    for (const log of logs) {
        if (!ranked.has(log.source))
            continue;
        const key = normalizeKey(log.keyword);
        if (!isValidKeyword(key))
            continue;
        if (blocked.has(key))
            continue;
        let bucket = buckets.get(key);
        if (!bucket) {
            bucket = { users: new Set(), count: 0, lastAtMs: 0, displays: new Map() };
            buckets.set(key, bucket);
        }
        bucket.users.add(log.userId);
        bucket.count += 1;
        if (log.createdAtMs > bucket.lastAtMs)
            bucket.lastAtMs = log.createdAtMs;
        const display = displayForm(log.keyword);
        bucket.displays.set(display, ((_b = bucket.displays.get(display)) !== null && _b !== void 0 ? _b : 0) + 1);
    }
    const stats = [];
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
function sortStats(stats) {
    return stats.sort((a, b) => {
        if (b.uniqueUsers !== a.uniqueUsers)
            return b.uniqueUsers - a.uniqueUsers;
        if (b.count !== a.count)
            return b.count - a.count;
        if (b.lastAtMs !== a.lastAtMs)
            return b.lastAtMs - a.lastAtMs;
        return a.key.localeCompare(b.key);
    });
}
/**
 * 키워드 통계 + 직전 순위 → 노출용 트렌드 목록.
 *
 * @param prevRanks 직전 스냅샷의 { 정규화키: 순위 }. 증감 계산에만 쓰인다.
 */
function rankTrends(stats, prevRanks, opts) {
    const items = [];
    for (const stat of stats) {
        if (items.length >= opts.limit)
            break;
        if (stat.uniqueUsers < opts.minUsers)
            continue;
        const rank = items.length + 1;
        const prev = prevRanks[stat.key];
        let status = "same";
        let change = null;
        if (prev === undefined) {
            status = "newEntry";
        }
        else if (prev > rank) {
            status = "up";
            change = prev - rank;
        }
        else if (prev < rank) {
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
        if (items.length >= opts.limit)
            break;
        const key = normalizeKey(keyword);
        if (!isValidKeyword(key) || used.has(key))
            continue;
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
function rankHashtags(labels, stats) {
    const volume = new Map();
    for (const stat of stats)
        volume.set(stat.key, stat.uniqueUsers);
    const scored = labels
        .map((label) => { var _a; return ({ label, users: (_a = volume.get(normalizeKey(label))) !== null && _a !== void 0 ? _a : 0 }); })
        .filter((entry) => entry.users > 0)
        .sort((a, b) => {
        if (b.users !== a.users)
            return b.users - a.users;
        return a.label.localeCompare(b.label);
    });
    const result = {};
    for (const label of labels)
        result[label] = null;
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
function scheduleDecision(hourKst) {
    const night = hourKst >= 20 || hourKst <= 9;
    return {
        night,
        trend: night || hourKst % 2 === 0,
        hashtag: night || hourKst % 4 === 0,
    };
}
//# sourceMappingURL=compute_trends.js.map