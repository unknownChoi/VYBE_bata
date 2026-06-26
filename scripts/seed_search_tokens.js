// clubs/{id} 문서에 searchTokens(검색 토큰 배열) 백필.
//
// Cloud Function(onClubWritten)이 앞으로의 생성/수정은 자동 처리하지만,
// 이미 존재하는 클럽들엔 토큰이 없으므로 이 스크립트로 1회 채운다.
//
// 토큰 알고리즘은 functions/src/search/club_tokens.ts 와 동일해야 함 (복제본).
//
// 실행: gcloud 로그인 상태에서  node scripts/seed_search_tokens.js
//   --dry   : 쓰지 않고 대상/토큰 개수만 출력
//   --force : 이미 searchTokens 있는 클럽도 다시 계산 (기본은 skip)

const { execSync } = require('child_process');
const https = require('https');

const PROJECT = 'vybe-bata-c07aa';
const DRY = process.argv.includes('--dry');
const FORCE = process.argv.includes('--force');

const MAX_PREFIX = 12;
const MAX_TOKENS = 300;

// ── 토큰 생성 (club_tokens.ts 복제) ──
function buildSearchTokens({ name, area, genre, tags }) {
  const out = new Set();
  const addPrefixes = (raw) => {
    const s = String(raw || '').toLowerCase().trim();
    if (!s) return;
    const max = Math.min(s.length, MAX_PREFIX);
    for (let i = 1; i <= max; i++) out.add(s.slice(0, i));
  };
  const addPhrase = (raw) => {
    const p = String(raw || '').toLowerCase().trim();
    if (!p) return;
    addPrefixes(p.replace(/\s+/g, ''));
    for (const w of p.split(/\s+/)) addPrefixes(w);
  };
  addPhrase(name);
  addPhrase(area);
  addPhrase(genre);
  for (const t of tags || []) addPhrase(t);
  return Array.from(out).slice(0, MAX_TOKENS);
}

function request(options, body) {
  return new Promise((resolve, reject) => {
    const req = https.request(options, (res) => {
      let data = '';
      res.on('data', (c) => (data += c));
      res.on('end', () => resolve({ status: res.statusCode, body: data }));
    });
    req.on('error', reject);
    if (body) req.write(body);
    req.end();
  });
}

function fsReq(token, method, path, body) {
  return request(
    {
      hostname: 'firestore.googleapis.com',
      path,
      method,
      headers: {
        Authorization: `Bearer ${token}`,
        'Content-Type': 'application/json',
        ...(body ? { 'Content-Length': Buffer.byteLength(body) } : {}),
      },
    },
    body
  );
}

function strArr(v) {
  return (v?.arrayValue?.values || []).map((e) => e.stringValue || '');
}

// 모든 클럽 수집 (id + name/area/genre/tags + searchTokens 존재 여부)
async function listClubs(token) {
  const clubs = [];
  let pageToken = '';
  do {
    const qs = `pageSize=300${pageToken ? `&pageToken=${encodeURIComponent(pageToken)}` : ''}`;
    const res = await fsReq(
      token,
      'GET',
      `/v1/projects/${PROJECT}/databases/(default)/documents/clubs?${qs}`
    );
    if (res.status !== 200) throw new Error(`list clubs failed: ${res.status} ${res.body}`);
    const json = JSON.parse(res.body);
    for (const doc of json.documents || []) {
      const f = doc.fields || {};
      clubs.push({
        id: doc.name.split('/').pop(),
        name: f.name?.stringValue || '',
        area: f.area?.stringValue || '',
        genre: f.genre?.stringValue || '',
        tags: strArr(f.tags),
        has: f.searchTokens !== undefined,
      });
    }
    pageToken = json.nextPageToken || '';
  } while (pageToken);
  return clubs;
}

async function setTokens(token, clubId, tokens) {
  const body = JSON.stringify({
    fields: {
      searchTokens: {
        arrayValue: { values: tokens.map((t) => ({ stringValue: t })) },
      },
    },
  });
  const res = await fsReq(
    token,
    'PATCH',
    `/v1/projects/${PROJECT}/databases/(default)/documents/clubs/${clubId}?updateMask.fieldPaths=searchTokens`,
    body
  );
  if (res.status !== 200) throw new Error(`patch failed: ${res.status} ${res.body}`);
}

async function run() {
  const token = execSync('gcloud auth print-access-token').toString().trim();
  const clubs = await listClubs(token);
  const targets = FORCE ? clubs : clubs.filter((c) => !c.has);
  console.log(
    `클럽 ${clubs.length}개 / 대상 ${targets.length}개 (skip ${clubs.length - targets.length})\n`
  );

  for (let i = 0; i < targets.length; i++) {
    const c = targets[i];
    const tokens = buildSearchTokens(c);
    if (DRY) {
      console.log(`  ${c.id.slice(0, 8)}… tokens=${tokens.length}  ${c.name}`);
      continue;
    }
    await setTokens(token, c.id, tokens);
    console.log(`[${i + 1}/${targets.length}] ${c.id.slice(0, 8)}… tokens=${tokens.length}  ${c.name}`);
  }
  console.log(`\n완료 — ${targets.length}개 처리${DRY ? ' (dry run)' : ''}`);
}

run().catch((e) => {
  console.error(e);
  process.exit(1);
});
