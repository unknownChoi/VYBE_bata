// vybeRecommendations 컬렉션 시드 — vybe 추천 페이지용 큐레이션.
//
// 평점(rating) 상위 활성 클럽 N개를 골라 추천 문서를 생성한다.
// 문서 ID = clubId (주간 1클럽 1추천, 재실행 시 upsert).
// 기존 추천 중 이번 세트에 없는 건 isActive=false 로 비활성(주간 교체).
//
// 스키마: { recId, clubId, rank, match, reason, tags, weekOf, isActive, createdAt }
//   rank 1 = featured(NO.1 PICK). match = 매치 %. reason = 큐레이터 노트.
//
// 실행: gcloud 로그인 상태에서  node scripts/seed_vybe_recommendations.js
//   --count=5 : 추천 개수 (기본 5)
//   --dry     : 쓰지 않고 대상만 출력

const { execSync } = require('child_process');
const https = require('https');

const PROJECT = 'vybe-bata-c07aa';
const DRY = process.argv.includes('--dry');
const countArg = process.argv.find((a) => a.startsWith('--count='));
const COUNT = countArg ? parseInt(countArg.split('=')[1], 10) : 5;

// rank별 매치 % (featured부터 내림차순). COUNT 초과 시 마지막 값 재사용.
const MATCH = [98, 95, 93, 91, 88, 86, 84, 82];

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

// 활성 클럽 전체 수집 (id, name, genre, rating).
async function listActiveClubs(token) {
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
      if (f.isActive?.booleanValue !== true) continue;
      clubs.push({
        id: doc.name.split('/').pop(),
        name: f.name?.stringValue || '',
        genre: f.genre?.stringValue || '클럽',
        rating: f.rating?.doubleValue ?? f.rating?.integerValue ?? 0,
      });
    }
    pageToken = json.nextPageToken || '';
  } while (pageToken);
  return clubs;
}

// 기존 추천 문서 ID 목록.
async function listRecIds(token) {
  const ids = [];
  const res = await fsReq(
    token,
    'GET',
    `/v1/projects/${PROJECT}/databases/(default)/documents/vybeRecommendations?pageSize=300`
  );
  if (res.status === 200) {
    const json = JSON.parse(res.body);
    for (const doc of json.documents || []) ids.push(doc.name.split('/').pop());
  }
  return ids;
}

function reasonFor(club, rank) {
  if (rank === 1) {
    return `압도적인 사운드와 ${club.genre} 라인업. 오늘 밤 가장 먼저 추천하는 곳이에요.`;
  }
  return `${club.genre}의 무드를 제대로 즐길 수 있는 곳. 최근 방문자 만족도가 높아요.`;
}

// 이번 주 화요일 00:00 (KST 무시, UTC 기준 근사).
function tuesdayOfWeek() {
  const now = new Date();
  const day = now.getUTCDay(); // 0=일
  const diff = (day + 5) % 7; // 화요일(2)까지 거슬러
  const tue = new Date(Date.UTC(now.getUTCFullYear(), now.getUTCMonth(), now.getUTCDate() - diff));
  return tue.toISOString();
}

async function upsertRec(token, club, rank, weekOf) {
  const match = MATCH[Math.min(rank - 1, MATCH.length - 1)];
  const body = JSON.stringify({
    fields: {
      recId: { stringValue: club.id },
      clubId: { stringValue: club.id },
      rank: { integerValue: String(rank) },
      match: { integerValue: String(match) },
      reason: { stringValue: reasonFor(club, rank) },
      tags: { arrayValue: { values: [] } },
      weekOf: { timestampValue: weekOf },
      isActive: { booleanValue: true },
      createdAt: { timestampValue: new Date().toISOString() },
    },
  });
  const res = await fsReq(
    token,
    'PATCH',
    `/v1/projects/${PROJECT}/databases/(default)/documents/vybeRecommendations/${club.id}`,
    body
  );
  if (res.status !== 200) throw new Error(`upsert failed: ${res.status} ${res.body}`);
}

async function deactivate(token, recId) {
  const body = JSON.stringify({ fields: { isActive: { booleanValue: false } } });
  const res = await fsReq(
    token,
    'PATCH',
    `/v1/projects/${PROJECT}/databases/(default)/documents/vybeRecommendations/${recId}?updateMask.fieldPaths=isActive`,
    body
  );
  if (res.status !== 200) throw new Error(`deactivate failed: ${res.status} ${res.body}`);
}

async function run() {
  const token = execSync('gcloud auth print-access-token').toString().trim();
  const clubs = await listActiveClubs(token);
  clubs.sort((a, b) => Number(b.rating) - Number(a.rating));
  const picks = clubs.slice(0, COUNT);
  const weekOf = tuesdayOfWeek();

  console.log(`활성 클럽 ${clubs.length}개 / 추천 ${picks.length}개 (weekOf ${weekOf.slice(0, 10)})\n`);
  picks.forEach((c, i) => {
    const match = MATCH[Math.min(i, MATCH.length - 1)];
    console.log(`  ${i + 1}위  매치 ${match}%  ★${Number(c.rating).toFixed(2)}  ${c.name}`);
  });

  if (DRY) {
    console.log('\n(dry run — 쓰지 않음)');
    return;
  }

  const pickIds = new Set(picks.map((c) => c.id));
  for (let i = 0; i < picks.length; i++) {
    await upsertRec(token, picks[i], i + 1, weekOf);
  }

  // 이번 세트에 없는 기존 추천 비활성화.
  const existing = await listRecIds(token);
  const stale = existing.filter((id) => !pickIds.has(id));
  for (const id of stale) await deactivate(token, id);

  console.log(`\n완료 — 추천 ${picks.length}개 활성, 기존 ${stale.length}개 비활성화`);
}

run().catch((e) => {
  console.error(e);
  process.exit(1);
});
