// clubs.genreStyles 필드 일괄 삭제 — 세부 장르 기능 폐기(2026.09.01).
//
// 왜 지우나: 세부 장르는 실제 조사 데이터가 아니라 clubId 해시로 만든 샘플이었고,
// 화면에서 쓰던 곳(힙합 라인업 장르 칩 · EDM 타임테이블 장르 필터 · 포스터 #태그)을
// 전부 걷어냈다. 남겨 두면 앱이 안 읽는 값을 Algolia가 계속 실어 나른다.
//
// 동작: 전 클럽을 훑어 genreStyles 가 있는 문서만 PATCH(updateMask=genreStyles, 빈 fields)
//   → Firestore REST 규약상 마스크에 있는데 본문에 없는 필드는 **삭제**된다.
//
// 멱등성: 이미 없는 문서는 건너뛴다. 재실행해도 무해.
//
// ⚠ 되돌릴 수 없다. 값을 남겨 두려면 --dry 로 먼저 목록을 받아 보관할 것.
//
// 실행: gcloud 로그인 상태에서  node scripts/delete_genre_styles.js
//   --dry : 쓰지 않고 대상만 출력

const { execSync } = require('child_process');
const https = require('https');

const PROJECT = 'vybe-bata-c07aa';
const DRY = process.argv.includes('--dry');

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
      clubs.push({
        id: doc.name.split('/').pop(),
        name: f.name?.stringValue || '',
        genre: f.genre?.stringValue || '',
        has: Object.prototype.hasOwnProperty.call(f, 'genreStyles'),
        styles: (f.genreStyles?.arrayValue?.values || []).map((v) => v.stringValue),
      });
    }
    pageToken = json.nextPageToken || '';
  } while (pageToken);
  return clubs;
}

// updateMask 에 필드를 넣고 body 에서 빼면 그 필드가 삭제된다.
// 다른 필드는 마스크 밖이라 그대로 남는다(문서 전체 교체가 아니다).
async function deleteGenreStyles(token, clubId) {
  const body = JSON.stringify({ fields: {} });
  const res = await fsReq(
    token, 'PATCH',
    `/v1/projects/${PROJECT}/databases/(default)/documents/clubs/${clubId}?updateMask.fieldPaths=genreStyles`,
    body
  );
  if (res.status !== 200) throw new Error(`delete genreStyles failed: ${res.status} ${res.body}`);
}

async function run() {
  const token = execSync('gcloud auth print-access-token').toString().trim();
  const clubs = await listClubs(token);
  const targets = clubs.filter((c) => c.has);

  console.log(`클럽 ${clubs.length}개 / genreStyles 있는 문서 ${targets.length}개`);
  for (const c of targets) {
    console.log(`  ${c.id}  ${c.genre.padEnd(4)} ${c.name}  [${c.styles.join(', ')}]`);
  }

  if (DRY) {
    console.log('\n(dry run — 쓰기 없음)');
    return;
  }
  if (targets.length === 0) {
    console.log('\n삭제할 문서 없음');
    return;
  }

  for (let i = 0; i < targets.length; i++) {
    await deleteGenreStyles(token, targets[i].id);
    console.log(`[${i + 1}/${targets.length}] ${targets[i].name} 삭제`);
  }
  console.log(`\n완료 — genreStyles ${targets.length}개 문서에서 삭제`);
}

run().catch((e) => {
  console.error(e);
  process.exit(1);
});
