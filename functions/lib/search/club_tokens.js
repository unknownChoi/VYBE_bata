"use strict";
// 클럽 검색 토큰 생성 (Firestore 내 검색 — B안).
//
// name/area/genre/tags를 소문자화하여 "접두사(prefix) 토큰" 집합으로 만든다.
// 예) "테크노" → 테, 테크, 테크노   "어썸레드" → 어, 어썸, 어썸레, 어썸레드
// → 앱에서 arrayContainsAny 로 부분 일치(as-you-type)까지 후보 필터 가능.
//
// 동일 알고리즘이 scripts/seed_search_tokens.js(백필)에도 복제돼 있으니
// 수정 시 양쪽을 함께 맞출 것.
Object.defineProperty(exports, "__esModule", { value: true });
exports.buildSearchTokens = buildSearchTokens;
exports.sameTokens = sameTokens;
const MAX_PREFIX = 12; // 토큰 1개당 접두사 최대 길이
const MAX_TOKENS = 300; // 문서당 토큰 배열 상한
function buildSearchTokens(data) {
    var _a;
    const out = new Set();
    // 한 단어를 접두사들로 분해해 추가.
    const addPrefixes = (raw) => {
        const s = raw.toLowerCase().trim();
        if (!s)
            return;
        const max = Math.min(s.length, MAX_PREFIX);
        for (let i = 1; i <= max; i++)
            out.add(s.slice(0, i));
    };
    // 구(phrase): 공백제거 통째 + 단어별로 접두사 추가.
    const addPhrase = (raw) => {
        if (!raw)
            return;
        const p = raw.toLowerCase().trim();
        if (!p)
            return;
        addPrefixes(p.replace(/\s+/g, ""));
        for (const w of p.split(/\s+/))
            addPrefixes(w);
    };
    addPhrase(data.name);
    addPhrase(data.area);
    addPhrase(data.genre);
    for (const t of (_a = data.tags) !== null && _a !== void 0 ? _a : [])
        addPhrase(t);
    return Array.from(out).slice(0, MAX_TOKENS);
}
// 배열 동등 비교(순서 무관) — 트리거 무한루프 방지용.
function sameTokens(a = [], b = []) {
    if (a.length !== b.length)
        return false;
    const sa = [...a].sort();
    const sb = [...b].sort();
    for (let i = 0; i < sa.length; i++)
        if (sa[i] !== sb[i])
            return false;
    return true;
}
//# sourceMappingURL=club_tokens.js.map