// clubs/{id} 문서에 freeEntryCondition(string) 필드 추가 — 입장비 무료 페이지 데이터.
//
// freeEntryCondition : 입장비 무료(entryFeeMin=0) 클럽마다 서로 다른 무료입장 조건 코멘트.
//   (COMMENTS 풀에서 중복 없이 순차 배정, 부족하면 번호 suffix)
//
// 대상: entryFeeMin === 0 인 클럽만 (입장비 유료 클럽은 건너뜀).
// PATCH + updateMask=freeEntryCondition 로 기존 필드 보존하며 머지.
//
// 실행: gcloud 로그인 상태에서  node scripts/seed_free_entry.js
//   --force : 이미 freeEntryCondition 있는 클럽도 다시 배정(기본은 skip)
//   --dry   : 쓰지 않고 대상/배정 결과만 출력

const { execSync } = require('child_process');
const https = require('https');

const PROJECT = 'vybe-bata-c07aa';
const FORCE = process.argv.includes('--force');
const DRY = process.argv.includes('--dry');

// 클럽마다 다른 무료입장 조건 코멘트 풀 (중복 없이 순차 배정, 부족하면 번호 suffix).
const COMMENTS = [
  '여성 무료입장',
  '남녀 전원 무료입장',
  '새벽 2시까지 무료',
  '오픈~23시 무료입장',
  '자정 이전 입장 무료',
  '게스트리스트 등록 시 무료',
  '평일 상시 무료입장',
  '대학생 인증 시 무료',
  '단체 4인 이상 무료',
  '생일자 무료입장',
  '얼리버드 입장 무료',
  '커플 동반 무료입장',
  '주중(월~목) 무료',
  '오픈런 1시간 무료',
  '여성 자정 전 무료',
  'SNS 팔로우 인증 시 무료',
  '첫 방문 인증 시 무료',
  '예약 방문 시 무료입장',
  '심야 입장 무료',
  '단골 도장 적립 무료',
  '학생증 소지 시 무료',
  '20대 전용 무료입장',
  '오픈 직후 30분 무료',
  '평일 여성 무료',
  '게스트 동반 1인 무료',
  '주말 자정 전 무료',
  '코스튬 착용 시 무료',
  '생일 주간 무료입장',
  '온라인 예약 시 무료',
  '오픈 시간대 전원 무료',
  '커뮤니티 회원 무료',
  '첫째·셋째 주 무료',
  '단체석 예약 시 무료',
  '평일 야간 무료입장',
  '인플루언서 인증 무료',
  '주중 게스트 무료',
  '오픈 1시간 한정 무료',
  '여성 단체 무료입장',
  '얼리 입장객 무료',
  '재방문 고객 무료',
  '졸업·신입생 무료',
  'VIP 등록 시 무료',
  '평일 커플 무료',
  '오픈런 전원 무료',
  '심야 여성 무료',
  'DJ 게스트 동반 무료',
  '주말 오픈 직후 무료',
  '회원 추천 시 무료',
  '평일 학생 무료입장',
  '첫 방문 단체 무료',
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

// 모든 클럽 문서 페이지네이션 수집 (id + name + entryFeeMin + freeEntryCondition 존재 여부)
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
      const entryFeeMin = parseInt(doc.fields?.entryFeeMin?.integerValue ?? '0', 10);
      const has = doc.fields?.freeEntryCondition !== undefined;
      clubs.push({ id, name, entryFeeMin, has });
    }
    pageToken = json.nextPageToken || '';
  } while (pageToken);
  return clubs;
}

async function setFreeEntryCondition(token, clubId, comment) {
  const body = JSON.stringify({
    fields: {
      freeEntryCondition: { stringValue: comment },
    },
  });
  const res = await fsReq(
    token,
    'PATCH',
    `/v1/projects/${PROJECT}/databases/(default)/documents/clubs/${clubId}?updateMask.fieldPaths=freeEntryCondition`,
    body
  );
  if (res.status !== 200) throw new Error(`patch failed: ${res.status} ${res.body}`);
}

// 코멘트 풀 셔플 (클럽 간 중복 최소화).
function shuffledComments() {
  const pool = [...COMMENTS];
  for (let i = pool.length - 1; i > 0; i--) {
    const j = Math.floor(Math.random() * (i + 1));
    [pool[i], pool[j]] = [pool[j], pool[i]];
  }
  return pool;
}

async function run() {
  const token = execSync('gcloud auth print-access-token').toString().trim();
  const clubs = await listClubs(token);
  // 입장비 무료(entryFeeMin=0) 클럽만 대상. --force 아니면 이미 있는 건 skip.
  const free = clubs.filter((c) => c.entryFeeMin === 0);
  const targets = FORCE ? free : free.filter((c) => !c.has);
  console.log(
    `클럽 ${clubs.length}개 / 입장비 무료 ${free.length}개 / 대상 ${targets.length}개 (skip ${free.length - targets.length})\n`
  );

  const comments = shuffledComments();

  for (let i = 0; i < targets.length; i++) {
    const { id, name } = targets[i];
    // 코멘트 풀 소진 시 번호 suffix로 유일성 유지.
    const base = comments[i % comments.length];
    const comment =
      i < comments.length ? base : `${base} (${Math.floor(i / comments.length) + 1})`;

    if (DRY) {
      console.log(`  ${id.slice(0, 8)}… "${comment}"  ${name}`);
      continue;
    }
    await setFreeEntryCondition(token, id, comment);
    console.log(`[${i + 1}/${targets.length}] ${id.slice(0, 8)}… "${comment}"  ${name}`);
  }
  console.log(`\n완료 — ${targets.length}개 배정${DRY ? ' (dry run)' : ''}`);
}

run().catch((e) => {
  console.error(e);
  process.exit(1);
});
