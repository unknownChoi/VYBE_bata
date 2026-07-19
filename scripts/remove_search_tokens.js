// clubs/{id} 문서에서 searchTokens 필드 일괄 삭제.
//
// Algolia 전환으로 Firestore 토큰 검색을 폐기하면서 실행하는 1회성 정리 스크립트.
// 사전 조건: onClubWritten 트리거가 먼저 삭제돼 있어야 함 (아니면 수정 시 재생성됨).
//
// 실행: gcloud 로그인 상태에서  node scripts/remove_search_tokens.js
//   --dry : 삭제하지 않고 대상만 출력

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

// 모든 클럽 id + searchTokens 보유 여부 수집
async function listClubs(token) {
  const clubs = [];
  let pageToken = '';
  do {
    const qs = `pageSize=300&mask.fieldPaths=searchTokens${
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
      const id = doc.name.split('/').pop();
      const hasTokens = !!doc.fields?.searchTokens;
      clubs.push({ id, hasTokens });
    }
    pageToken = json.nextPageToken || '';
  } while (pageToken);
  return clubs;
}

// updateMask에 searchTokens만 지정 + 본문에서 생략 → 해당 필드 삭제
function removeTokens(token, clubId) {
  return fsReq(
    token,
    'PATCH',
    `/v1/projects/${PROJECT}/databases/(default)/documents/clubs/${clubId}` +
      `?updateMask.fieldPaths=searchTokens`,
    JSON.stringify({ fields: {} })
  );
}

(async () => {
  const token = execSync('gcloud auth print-access-token').toString().trim();
  const clubs = await listClubs(token);
  const targets = clubs.filter((c) => c.hasTokens);
  console.log(`클럽 ${clubs.length}개 중 searchTokens 보유 ${targets.length}개`);

  if (DRY) {
    for (const c of targets) console.log(`  [dry] ${c.id}`);
    return;
  }

  let ok = 0;
  for (const c of targets) {
    const res = await removeTokens(token, c.id);
    if (res.status === 200) {
      ok++;
      console.log(`  삭제됨: ${c.id}`);
    } else {
      console.error(`  실패: ${c.id} → ${res.status} ${res.body}`);
    }
  }
  console.log(`완료: ${ok}/${targets.length}`);
})().catch((e) => {
  console.error(e);
  process.exit(1);
});
