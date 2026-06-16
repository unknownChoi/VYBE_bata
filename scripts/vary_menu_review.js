// 클럽마다 메뉴명 / 리뷰(내용·작성자)를 다르게 변경.
// 이미지·가격·카테고리·평점은 그대로. (평점 미변경 → onReviewUpdated 트리거 무영향)
//
// 실행: gcloud 로그인 상태에서  node scripts/vary_menu_review.js
//   --dry : 변경 없이 계획만

const { execSync } = require('child_process');
const https = require('https');

const PROJECT = 'vybe-bata-c07aa';
const BASE = '62VaHypRMWcCySNQZEaa';
const CONC = 6;
const DRY = process.argv.includes('--dry');
const enc = encodeURIComponent;

// ── 메뉴명 풀 (칵테일/주류/안주 혼합) ──
const MENU_NAMES = [
  'NEGRONI', 'OLD FASHIONED', 'MOJITO', 'MARGARITA', 'COSMOPOLITAN', 'MANHATTAN',
  'WHISKEY SOUR', 'DAIQUIRI', 'GIN TONIC', 'APEROL SPRITZ', 'PINA COLADA',
  'LONG ISLAND', 'MAI TAI', 'TEQUILA SUNRISE', 'BLOODY MARY', 'ESPRESSO MARTINI',
  'MOSCOW MULE', 'WHITE RUSSIAN', 'BLACK RUSSIAN', 'GIMLET', 'SIDECAR',
  'BELLINI', 'KIR ROYALE', 'SEX ON THE BEACH', 'BLUE HAWAII', 'CAIPIRINHA',
  'MOËT & CHANDON', 'DOM PÉRIGNON', 'VEUVE CLICQUOT', 'JÄGERBOMB', 'B-52',
  '하이볼', '얼그레이 하이볼', '청포도 하이볼', '레몬 하이볼', '자몽 하이볼',
  '생맥주 500', '수제 맥주', 'IPA 드래프트', '버드와이저', '하이네켄',
  '나초 플래터', '감바스 알 아히요', '치즈 플래터', '트러플 감자튀김', '치킨윙',
  '먹태 구이', '소시지 모둠', '하몽 플래터', '과일 안주', '오징어 튀김',
  '불도그 칵테일', '미드나잇 블루', '네온 펀치', '바이브 시그니처', '퍼플 헤이즈',
  '선셋 마티니', '럼 펀치', '베이스 드롭', '애프터 글로우', '스칼렛 키스',
];

// ── 리뷰 내용 풀 ──
const REVIEW_TEXTS = [
  '분위기 진짜 미쳤어요. 사운드도 빵빵하고 또 올 듯!',
  '주말에 갔는데 사람 많아서 신났어요. DJ 선곡 취향저격.',
  '입장료 대비 만족도 최고. 칵테일도 맛있음.',
  '친구들이랑 갔는데 다들 만족했어요. 다음에 또 갈게요.',
  '음악이 너무 좋아서 시간 가는 줄 몰랐어요.',
  '내부 인테리어가 감각적이에요. 사진 맛집.',
  '직원분들 친절하고 화장실도 깨끗했어요.',
  '테크노 좋아하면 무조건 가야 하는 곳.',
  '좀 시끄럽긴 한데 클럽이니까 당연하죠 ㅋㅋ 즐거웠음.',
  '웨이팅이 좀 있었지만 들어가니까 다 잊혀짐.',
  '분위기는 좋은데 사람이 너무 많아서 정신없었어요.',
  '칵테일 종류가 다양해서 골라먹는 재미가 있어요.',
  '처음 와봤는데 단골 될 것 같아요. 강추!',
  '조명이랑 사운드 시스템 퀄리티가 다르네요.',
  '생일파티로 갔는데 분위기 띄우기 딱 좋았어요.',
  '가성비 좋은 클럽 찾으면 여기 추천합니다.',
  '플로어 넓어서 춤추기 좋았어요. 에어컨도 빵빵.',
  '음료 좀 비싼 편이지만 분위기 값이라 생각하면 OK.',
  'DJ 라인업 보고 갔는데 기대 이상이었어요.',
  '늦게까지 영업해서 좋아요. 새벽까지 놀았네요.',
];

const NICKNAMES = [
  '밤의제왕', '클러버J', '홍대토박이', '디제이러버', '주말전사', '네온키드',
  '베이스헤드', '칵테일러', '댄싱퀸', '나이트아울', '비트메이커', '플로어킬러',
  '서울나이트', '뮤직중독', '리듬타기', '글로우스틱', '미드나잇', '바이브체커',
  '테크노매니아', '힙합러버', '강남러너', '파티피플', '사운드체이서', '문라이트',
];

function request(o, b) {
  return new Promise((res, rej) => {
    const r = https.request(o, (x) => { let d = ''; x.on('data', (c) => (d += c)); x.on('end', () => res({ status: x.statusCode, body: d })); });
    r.on('error', rej); if (b) r.write(b); r.end();
  });
}
const fs_ = (t, m, p, b) =>
  request({ hostname: 'firestore.googleapis.com', path: p, method: m, headers: { Authorization: `Bearer ${t}`, 'Content-Type': 'application/json', ...(b ? { 'Content-Length': Buffer.byteLength(b) } : {}) } }, b);
const ROOT = `/v1/projects/${PROJECT}/databases/(default)/documents`;

function shuffle(a) { a = a.slice(); for (let i = a.length - 1; i > 0; i--) { const j = Math.floor(Math.random() * (i + 1)); [a[i], a[j]] = [a[j], a[i]]; } return a; }

async function listIds(t, coll) {
  const o = []; let pt = '';
  do {
    const r = await fs_(t, 'GET', `${ROOT}/${coll}?pageSize=300&fields=documents(name),nextPageToken${pt ? `&pageToken=${enc(pt)}` : ''}`);
    const j = JSON.parse(r.body); (j.documents || []).forEach((d) => o.push(d.name.split('/').pop())); pt = j.nextPageToken || '';
  } while (pt);
  return o;
}
async function patch(t, path, fields) {
  const mask = Object.keys(fields).map((k) => `updateMask.fieldPaths=${enc(k)}`).join('&');
  const r = await fs_(t, 'PATCH', `${ROOT}/${path}?${mask}`, JSON.stringify({ fields }));
  if (r.status !== 200) throw new Error(`${path}: ${r.status} ${r.body.slice(0, 80)}`);
}
async function pool(ts, n, onDone) {
  let i = 0, ok = 0, f = 0;
  async function w() { while (i < ts.length) { const m = i++; try { await ts[m](); ok++; } catch (e) { f++; console.error('  ✗', e.message.slice(0, 90)); } if (onDone) onDone(ok + f, ts.length); } }
  await Promise.all(Array.from({ length: n }, w)); return { ok, f };
}

async function run() {
  const t = execSync('gcloud auth print-access-token').toString().trim();
  const clubs = (await listIds(t, 'clubs')).filter((id) => id !== BASE);
  console.log(`타깃 ${clubs.length} 클럽` + (DRY ? '  (dry run)' : ''));
  if (DRY) return;

  const tasks = clubs.map((id) => async () => {
    // 메뉴명 변경
    const menuIds = await listIds(t, `clubs/${id}/menus`);
    const names = shuffle(MENU_NAMES).slice(0, menuIds.length);
    for (let k = 0; k < menuIds.length; k++) {
      await patch(t, `clubs/${id}/menus/${menuIds[k]}`, { name: { stringValue: names[k] } });
    }
    // 리뷰 내용/작성자 변경
    const reviewIds = await listIds(t, `clubs/${id}/reviews`);
    const texts = shuffle(REVIEW_TEXTS).slice(0, reviewIds.length);
    const names2 = shuffle(NICKNAMES).slice(0, reviewIds.length);
    for (let k = 0; k < reviewIds.length; k++) {
      await patch(t, `clubs/${id}/reviews/${reviewIds[k]}`, {
        content: { stringValue: texts[k] },
        userName: { stringValue: names2[k] },
      });
    }
  });

  let last = -1;
  const { ok, f } = await pool(tasks, CONC, (d, total) => {
    const pct = Math.floor((d / total) * 100);
    if (pct !== last && pct % 10 === 0) { last = pct; console.log(`  ${pct}% (${d}/${total} 클럽)`); }
  });
  console.log(`\n완료! 성공 ${ok} 클럽, 실패 ${f}`);
}

run();
