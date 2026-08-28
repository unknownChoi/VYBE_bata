// clubs.genreStyles 배정 — EDM 장르 페이지 세부 장르 칩·포스터 #태그 데이터.
//
// 왜 필요한가: seed_performances_sep.js 는 공연(performances)만 만들고 클럽의
// genreStyles 는 안 건드린다. 힙합 클럽만 seed_performances.js 에서 배정받았고
// EDM 클럽은 비어 있어, EDM 페이지의 'DJ 타임테이블' 세부 장르 칩이 통째로 안 뜬다
// (칩은 실제 데이터에 있는 장르만 만든다 — 눌러도 늘 0건인 칩을 만들지 않으려고).
//
// 동작: genre==="EDM" 활성 클럽에 STYLE_SETS 중 하나를 배정.
//   ⚠ 첫 항목이 그 클럽의 대표 장르가 된다 — 타임테이블 칩이 이 값으로 묶인다.
//
// 멱등성: clubId 해시로 고르므로 재실행해도 같은 결과.
//
// 실행: gcloud 로그인 상태에서  node scripts/seed_edm_genre_styles.js
//   --dry   : 쓰지 않고 배정 결과만 출력
//   --force : 이미 genreStyles 가 있는 클럽도 덮어씀 (기본은 비어 있는 클럽만)

const { execSync } = require('child_process');
const https = require('https');

const PROJECT = 'vybe-bata-c07aa';
const DRY = process.argv.includes('--dry');
const FORCE = process.argv.includes('--force');
const GENRE = 'EDM';

// 세부 장르 풀 — 디자인(edm_renew.jsx GENRES/CLUBS.styles) 문구 그대로.
// 첫 항목이 대표 장르(타임테이블 칩 기준)라 5종이 고르게 퍼지도록 배열했다.
const STYLE_SETS = [
  ['빅룸', '프로그레시브'],
  ['테크노', '미니멀'],
  ['하우스', '퓨처하우스'],
  ['트랜스'],
  ['프로그레시브'],
  ['빅룸'],
  ['테크노'],
  ['하우스', '테크하우스'],
  ['트랜스', '프로그레시브'],
  ['하우스'],
];

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

async function listClubs(token) {
  const clubs = [];
  let pageToken = '';
  do {
    const qs = `pageSize=300${pageToken ? `&pageToken=${encodeURIComponent(pageToken)}` : ''}`;
    const res = await fsReq(
      token, 'GET',
      `/v1/projects/${PROJECT}/databases/(default)/documents/clubs?${qs}`
    );
    if (res.status !== 200) throw new Error(`list clubs failed: ${res.status} ${res.body}`);
    const json = JSON.parse(res.body);
    for (const doc of json.documents || []) {
      const f = doc.fields || {};
      if ((f.genre?.stringValue || '') !== GENRE) continue;
      if (f.isActive?.booleanValue === false) continue;
      clubs.push({
        id: doc.name.split('/').pop(),
        name: f.name?.stringValue || '',
        area: f.area?.stringValue || '',
        styles: (f.genreStyles?.arrayValue?.values || []).map((v) => v.stringValue),
      });
    }
    pageToken = json.nextPageToken || '';
  } while (pageToken);
  return clubs;
}

// clubId 해시 — 같은 클럽은 항상 같은 조합.
function hash(s) {
  let h = 0;
  for (let i = 0; i < s.length; i++) h = (h * 31 + s.charCodeAt(i)) >>> 0;
  return h;
}

async function setGenreStyles(token, clubId, styles) {
  const body = JSON.stringify({
    fields: { genreStyles: { arrayValue: { values: styles.map((s) => ({ stringValue: s })) } } },
  });
  const res = await fsReq(
    token, 'PATCH',
    `/v1/projects/${PROJECT}/databases/(default)/documents/clubs/${clubId}?updateMask.fieldPaths=genreStyles`,
    body
  );
  if (res.status !== 200) throw new Error(`patch genreStyles failed: ${res.status} ${res.body}`);
}

async function run() {
  const token = execSync('gcloud auth print-access-token').toString().trim();
  const clubs = await listClubs(token);

  const plan = clubs
    .filter((c) => FORCE || c.styles.length === 0)
    .map((c) => ({ ...c, next: STYLE_SETS[hash(c.id) % STYLE_SETS.length] }));

  const skipped = clubs.length - plan.length;
  console.log(`EDM 활성 클럽 ${clubs.length}곳 / 배정 대상 ${plan.length}곳${skipped ? ` (이미 있음 ${skipped}곳 건너뜀)` : ''}`);

  const byLead = {};
  for (const p of plan) (byLead[p.next[0]] ||= []).push(p.name);
  for (const k of Object.keys(byLead)) console.log(`  ${k}: ${byLead[k].length}곳`);

  if (DRY) {
    for (const p of plan) console.log(`  ${p.area}/${p.name}  →  ${p.next.join(', ')}`);
    console.log('\n(dry run — 쓰기 없음)');
    return;
  }

  for (let i = 0; i < plan.length; i++) {
    await setGenreStyles(token, plan[i].id, plan[i].next);
    console.log(`[${i + 1}/${plan.length}] ${plan[i].name} → ${plan[i].next.join(', ')}`);
  }
  console.log(`\n완료 — genreStyles ${plan.length}곳 배정`);
}

run().catch((e) => {
  console.error(e);
  process.exit(1);
});
