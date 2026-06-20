// clubs/{id} 문서에 isNonSmoking(boolean) 필드 추가.
//
// 값은 데모용 랜덤 배정: 약 25% 클럽만 금연(true), 나머지 false.
// PATCH + updateMask=isNonSmoking 으로 기존 필드 보존하며 머지.
//
// 실행: gcloud 로그인 상태에서  node scripts/seed_non_smoking.js
//   --force : 이미 isNonSmoking 있는 클럽도 다시 배정(기본은 skip)
//   --dry   : 쓰지 않고 대상/배정 결과만 출력
//   --rate=0.25 : 금연(true) 비율 (기본 0.25)

const { execSync } = require('child_process');
const https = require('https');

const PROJECT = 'vybe-bata-c07aa';
const FORCE = process.argv.includes('--force');
const DRY = process.argv.includes('--dry');
const rateArg = process.argv.find((a) => a.startsWith('--rate='));
const RATE = rateArg ? parseFloat(rateArg.split('=')[1]) : 0.25;

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

// 모든 클럽 문서 페이지네이션 수집 (id + name + isNonSmoking 존재 여부)
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
      const id = doc.name.split('/').pop();
      const name = doc.fields?.name?.stringValue || '';
      const has = doc.fields?.isNonSmoking !== undefined;
      clubs.push({ id, name, has });
    }
    pageToken = json.nextPageToken || '';
  } while (pageToken);
  return clubs;
}

async function setNonSmoking(token, clubId, value) {
  const body = JSON.stringify({
    fields: { isNonSmoking: { booleanValue: value } },
  });
  const res = await fsReq(
    token,
    'PATCH',
    `/v1/projects/${PROJECT}/databases/(default)/documents/clubs/${clubId}?updateMask.fieldPaths=isNonSmoking`,
    body
  );
  if (res.status !== 200) throw new Error(`patch failed: ${res.status} ${res.body}`);
}

async function run() {
  const token = execSync('gcloud auth print-access-token').toString().trim();
  const clubs = await listClubs(token);
  const targets = FORCE ? clubs : clubs.filter((c) => !c.has);
  console.log(
    `클럽 ${clubs.length}개 / 대상 ${targets.length}개 / 금연 비율 ${RATE} (skip ${clubs.length - targets.length})\n`
  );

  let trueCount = 0;
  for (let i = 0; i < targets.length; i++) {
    const { id, name } = targets[i];
    const value = Math.random() < RATE;
    if (value) trueCount++;
    if (DRY) {
      console.log(`  ${id.slice(0, 8)}… ${value ? '금연' : '흡연가능'}  ${name}`);
      continue;
    }
    await setNonSmoking(token, id, value);
    console.log(
      `[${i + 1}/${targets.length}] ${id.slice(0, 8)}… ${value ? '금연(true)' : '흡연가능(false)'}  ${name}`
    );
  }
  console.log(`\n완료 — 금연 ${trueCount}개 / 흡연가능 ${targets.length - trueCount}개${DRY ? ' (dry run)' : ''}`);
}

run().catch((e) => {
  console.error(e);
  process.exit(1);
});
