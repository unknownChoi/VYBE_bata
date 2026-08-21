// clubs/{id} 전체를 "touch"해서 Algolia Extension 재색인을 유발한다.
//
// Extension(firestore-algolia-search)은 문서 write 이벤트에만 반응하므로,
// Indexable Fields를 바꿔도 기존 문서는 인덱스에 반영되지 않는다.
// 같은 값을 그대로 다시 써서(데이터 무변경) onWrite만 발생시킨다.
//
// 사전 조건: Extension 설정의 Indexable Fields에 아래 19개가 모두 포함돼 있어야 함
//   name, area, genre, genreStyles, tags, address, rating, reviewCount,
//   thumbnailUrl, entryFeeMin, entryFeeMax, operatingHours, isActive,
//   isVybeRecommended, isNonSmoking, favoriteCount, location,
//   freeEntry, isFreeEntry
// (하나라도 빠지면 앱이 complete=false로 판단해 Firestore 조인으로 폴백 —
//  화면은 멀쩡하고 read 비용만 조용히 되살아나므로 눈으로는 못 잡는다.
//  돌리기 전에 배포된 설정을 실물로 확인할 것. CLAUDE.md '클럽 검색(Algolia)' 참고)
//
// 실행: gcloud 로그인 상태에서  node scripts/reindex_clubs.js
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

// 모든 클럽 id + 기존 updatedAt 수집 (updatedAt만 마스크 조회)
async function listClubs(token) {
  const clubs = [];
  let pageToken = '';
  do {
    const qs = `pageSize=300&mask.fieldPaths=updatedAt${
      pageToken ? `&pageToken=${encodeURIComponent(pageToken)}` : ''
    }`;
    const res = await fsReq(
      token,
      'GET',
      `/v1/projects/${PROJECT}/databases/(default)/documents/clubs?${qs}`
    );
    if (res.status !== 200) throw new Error(`list 실패: ${res.status} ${res.body}`);
    const json = JSON.parse(res.body);
    for (const doc of json.documents || []) {
      clubs.push({
        id: doc.name.split('/').pop(),
        updatedAt: doc.fields?.updatedAt?.timestampValue || null,
      });
    }
    pageToken = json.nextPageToken || '';
  } while (pageToken);
  return clubs;
}

// updatedAt을 원래 값 그대로 다시 write → 데이터는 그대로, onWrite만 발생.
// 값이 없던 문서는 현재 시각으로 채운다.
function touch(token, club) {
  const ts = club.updatedAt || new Date().toISOString();
  return fsReq(
    token,
    'PATCH',
    `/v1/projects/${PROJECT}/databases/(default)/documents/clubs/${club.id}` +
      `?updateMask.fieldPaths=updatedAt`,
    JSON.stringify({ fields: { updatedAt: { timestampValue: ts } } })
  );
}

(async () => {
  const token = execSync('gcloud auth print-access-token').toString().trim();
  const clubs = await listClubs(token);
  console.log(`클럽 ${clubs.length}개 재색인 대상`);

  if (DRY) {
    for (const c of clubs) console.log(`  [dry] ${c.id} (updatedAt=${c.updatedAt})`);
    return;
  }

  let ok = 0;
  for (const c of clubs) {
    const res = await touch(token, c);
    if (res.status === 200) {
      ok++;
      console.log(`  touch: ${c.id}`);
    } else {
      console.error(`  실패: ${c.id} → ${res.status} ${res.body}`);
    }
    // Extension 함수 동시 실행 폭주 방지 — 문서당 약간의 간격.
    await new Promise((r) => setTimeout(r, 50));
  }
  console.log(`완료: ${ok}/${clubs.length} — Algolia 반영까지 수십 초 소요`);
})().catch((e) => {
  console.error(e);
  process.exit(1);
});
