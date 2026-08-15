// clubs/{id}/info/{id} 문서에 facilities(string[]) 필드 추가 — 클럽 상세 '편의시설' 섹션 데이터.
//
// facilities : 앱의 ClubFacility 키 목록.
//   parking(주차 가능) · restroom(화장실 분리) · smoking(흡연실)
//   locker(물품보관함) · card(카드 결제) · groupSeat(단체석)
//   ⚠ 앱은 모르는 키를 조용히 버린다 → 여기 목록 밖의 값을 넣으면 화면에 안 나온다.
//     시설을 늘리려면 lib/presentation/clubs/renew/widgets/renew_facilities.dart 의
//     ClubFacility enum에 먼저 추가할 것.
//
// 배정: card·restroom은 전 클럽 공통, 나머지는 clubId 해시로 결정(같은 클럽은 항상 같은 결과).
//   실제 시설 조사 데이터가 아니라 화면 확인용 샘플 — 어드민 페이지가 생기면 그쪽에서 편집한다.
//
// PATCH + updateMask=facilities 로 기존 필드(nearbySubways·cautions·openChatUrl) 보존하며 머지.
// info 문서가 없는 클럽은 PATCH가 문서를 새로 만든다.
//
// 실행: gcloud 로그인 상태에서  node scripts/seed_facilities.js
//   --force : 이미 facilities 있는 클럽도 다시 배정(기본은 skip)
//   --dry   : 쓰지 않고 대상/배정 결과만 출력

const { execSync } = require('child_process');
const https = require('https');

const PROJECT = 'vybe-bata-c07aa';
const FORCE = process.argv.includes('--force');
const DRY = process.argv.includes('--dry');

// 전 클럽 공통 — 카드 결제·화장실 분리는 사실상 기본.
const ALWAYS = ['restroom', 'card'];
// clubId 해시로 켜고 끄는 항목.
const OPTIONAL = ['parking', 'smoking', 'locker', 'groupSeat'];

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

// 모든 클럽 문서 페이지네이션 수집 (id + name)
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
      clubs.push({ id, name: doc.fields?.name?.stringValue || '' });
    }
    pageToken = json.nextPageToken || '';
  } while (pageToken);
  return clubs;
}

// info 문서에 facilities가 이미 있는지 (404 = 문서 없음 → 없는 것으로 취급)
async function hasFacilities(token, clubId) {
  const res = await fsReq(
    token,
    'GET',
    `/v1/projects/${PROJECT}/databases/(default)/documents/clubs/${clubId}/info/${clubId}`
  );
  if (res.status === 404) return false;
  if (res.status !== 200) throw new Error(`get info failed: ${res.status} ${res.body}`);
  const json = JSON.parse(res.body);
  const arr = json.fields?.facilities?.arrayValue?.values;
  return Array.isArray(arr) && arr.length > 0;
}

async function setFacilities(token, clubId, keys) {
  const body = JSON.stringify({
    fields: {
      facilities: { arrayValue: { values: keys.map((k) => ({ stringValue: k })) } },
    },
  });
  const res = await fsReq(
    token,
    'PATCH',
    `/v1/projects/${PROJECT}/databases/(default)/documents/clubs/${clubId}/info/${clubId}?updateMask.fieldPaths=facilities`,
    body
  );
  if (res.status !== 200) throw new Error(`patch failed: ${res.status} ${res.body}`);
}

// clubId 문자열 해시 — 같은 클럽은 몇 번을 돌려도 같은 조합이 나온다.
function hash(s) {
  let h = 0;
  for (let i = 0; i < s.length; i++) h = (h * 31 + s.charCodeAt(i)) >>> 0;
  return h;
}

function pickFacilities(clubId) {
  const h = hash(clubId);
  const picked = OPTIONAL.filter((_, i) => (h >> i) & 1);
  // 전부 꺼지면 너무 빈약해 보이니 최소 하나는 켠다.
  if (picked.length === 0) picked.push(OPTIONAL[h % OPTIONAL.length]);
  return [...ALWAYS, ...picked];
}

async function run() {
  const token = execSync('gcloud auth print-access-token').toString().trim();
  const clubs = await listClubs(token);

  const targets = [];
  for (const c of clubs) {
    if (!FORCE && (await hasFacilities(token, c.id))) continue;
    targets.push(c);
  }
  console.log(`클럽 ${clubs.length}개 / 대상 ${targets.length}개 (skip ${clubs.length - targets.length})\n`);

  for (let i = 0; i < targets.length; i++) {
    const { id, name } = targets[i];
    const keys = pickFacilities(id);

    if (DRY) {
      console.log(`  ${id.slice(0, 8)}… [${keys.join(', ')}]  ${name}`);
      continue;
    }
    await setFacilities(token, id, keys);
    console.log(`[${i + 1}/${targets.length}] ${id.slice(0, 8)}… [${keys.join(', ')}]  ${name}`);
  }
  console.log(`\n완료 — ${targets.length}개 배정${DRY ? ' (dry run)' : ''}`);
}

run().catch((e) => {
  console.error(e);
  process.exit(1);
});
