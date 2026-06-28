// clubs/{id} 문서에 serviceDrink(map) 필드 추가 — 서비스 음료(무료 제공) 페이지 데이터.
//
// serviceDrink = { isOffered: bool, comment: string, drinks: string[] }
//   - drinks  : 서비스 음료 페이지 음료 선택 칩 종류에서 랜덤 subset
//               (양주 / 샴페인 / 칵테일 / 맥주 / 와인)
//   - comment : 클럽마다 서로 다른 코멘트 (COMMENTS 풀에서 중복 없이 배정)
//   - isOffered: 제공 비율(RATE)만큼 true, 나머지 false(빈 음료/코멘트)
//
// PATCH + updateMask=serviceDrink 로 기존 필드 보존하며 머지.
//
// 실행: gcloud 로그인 상태에서  node scripts/seed_service_drinks.js
//   --force : 이미 serviceDrink 있는 클럽도 다시 배정(기본은 skip)
//   --dry   : 쓰지 않고 대상/배정 결과만 출력
//   --rate=0.5 : 서비스 음료 제공(true) 비율 (기본 0.5)

const { execSync } = require('child_process');
const https = require('https');

const PROJECT = 'vybe-bata-c07aa';
const FORCE = process.argv.includes('--force');
const DRY = process.argv.includes('--dry');
const rateArg = process.argv.find((a) => a.startsWith('--rate='));
const RATE = rateArg ? parseFloat(rateArg.split('=')[1]) : 0.5;

// 서비스 음료 페이지 음료 선택 칩 종류 ('전체' 제외).
const DRINK_TYPES = ['양주', '샴페인', '칵테일', '맥주', '와인'];

// 클럽마다 다른 코멘트 풀 (중복 없이 순차 배정, 부족하면 번호 suffix).
const COMMENTS = [
  '1인 음료 무제한',
  '테이블당 맥주 6병 서비스',
  '양주 1병 + 웰컴드링크',
  '입장 시 웰컴 샷 제공',
  '테이블 예약 시 샴페인 1병 증정',
  '1인 칵테일 2잔 무료',
  '입장객 전원 웰컴 드링크 1잔',
  '테이블당 양주 1병 서비스',
  '여성 입장객 칵테일 1잔 무료',
  '심야 입장 시 맥주 2병 제공',
  '단체(4인 이상) 샴페인 1병 증정',
  '게스트 등록 시 음료 1잔 무료',
  '주중 방문 시 칵테일 무료',
  '테이블석 음료 무제한',
  '얼리버드 입장 웰컴 와인 1잔',
  '예약 테이블 양주 + 음료 세트',
  '첫 방문 인증 시 칵테일 1잔',
  '생일 고객 샴페인 1병 서비스',
  '커플 입장 시 와인 2잔 무료',
  '입장 시 수제 칵테일 1잔',
  'VIP 테이블 양주 2병 제공',
  '주말 한정 웰컴 맥주 1병',
  '단체 예약 시 음료 무제한',
  '오픈런 입장객 샷 + 음료',
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

// 모든 클럽 문서 페이지네이션 수집 (id + name + serviceDrink 존재 여부)
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
      const has = doc.fields?.serviceDrink !== undefined;
      clubs.push({ id, name, has });
    }
    pageToken = json.nextPageToken || '';
  } while (pageToken);
  return clubs;
}

// 1~3종 랜덤 음료 subset (중복 없이).
function pickDrinks() {
  const pool = [...DRINK_TYPES];
  // Fisher-Yates 셔플 후 앞에서 n개.
  for (let i = pool.length - 1; i > 0; i--) {
    const j = Math.floor(Math.random() * (i + 1));
    [pool[i], pool[j]] = [pool[j], pool[i]];
  }
  const n = 1 + Math.floor(Math.random() * 3); // 1..3
  return pool.slice(0, n).sort((a, b) => DRINK_TYPES.indexOf(a) - DRINK_TYPES.indexOf(b));
}

async function setServiceDrink(token, clubId, sd) {
  const body = JSON.stringify({
    fields: {
      serviceDrink: {
        mapValue: {
          fields: {
            isOffered: { booleanValue: sd.isOffered },
            comment: { stringValue: sd.comment },
            drinks: {
              arrayValue: {
                values: sd.drinks.map((d) => ({ stringValue: d })),
              },
            },
          },
        },
      },
    },
  });
  const res = await fsReq(
    token,
    'PATCH',
    `/v1/projects/${PROJECT}/databases/(default)/documents/clubs/${clubId}?updateMask.fieldPaths=serviceDrink`,
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
  const targets = FORCE ? clubs : clubs.filter((c) => !c.has);
  console.log(
    `클럽 ${clubs.length}개 / 대상 ${targets.length}개 / 제공 비율 ${RATE} (skip ${clubs.length - targets.length})\n`
  );

  const comments = shuffledComments();
  let offerCount = 0; // 제공(true) 클럽 카운터 = 코멘트 인덱스

  for (let i = 0; i < targets.length; i++) {
    const { id, name } = targets[i];
    const isOffered = Math.random() < RATE;

    let sd;
    if (isOffered) {
      // 코멘트 풀 소진 시 번호 suffix로 유일성 유지.
      const base = comments[offerCount % comments.length];
      const comment =
        offerCount < comments.length ? base : `${base} (${Math.floor(offerCount / comments.length) + 1})`;
      sd = { isOffered: true, comment, drinks: pickDrinks() };
      offerCount++;
    } else {
      sd = { isOffered: false, comment: '', drinks: [] };
    }

    if (DRY) {
      console.log(
        `  ${id.slice(0, 8)}… ${sd.isOffered ? `제공 [${sd.drinks.join(',')}] "${sd.comment}"` : '미제공'}  ${name}`
      );
      continue;
    }
    await setServiceDrink(token, id, sd);
    console.log(
      `[${i + 1}/${targets.length}] ${id.slice(0, 8)}… ${sd.isOffered ? `제공 [${sd.drinks.join(',')}] "${sd.comment}"` : '미제공'}  ${name}`
    );
  }
  console.log(
    `\n완료 — 제공 ${offerCount}개 / 미제공 ${targets.length - offerCount}개${DRY ? ' (dry run)' : ''}`
  );
}

run().catch((e) => {
  console.error(e);
  process.exit(1);
});
