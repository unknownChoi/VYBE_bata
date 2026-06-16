// 리뷰에 사진 추가 + 클럽당 리뷰 12개로 확장.
// - 기존 5개 리뷰: imageUrls 채움(rating 미변경 → onReviewUpdated delta 0, ratingSum 무영향)
// - 신규 7개 리뷰 추가: content/userName/rating/imageUrls
//   → onReviewCreated 트리거가 reviewCount/ratingSum/rating 자동 갱신 (수동 세팅 금지)
// 사진 소스: 각 클럽 gallery URL(clubs/{id}.imageUrls) 재활용.
//
// 실행: gcloud 로그인 상태에서  node scripts/add_review_photos.js
//   --dry : 계획만

const { execSync } = require('child_process');
const https = require('https');

const PROJECT = 'vybe-bata-c07aa';
const BASE = '62VaHypRMWcCySNQZEaa';
const TARGET_TOTAL = 12; // 클럽당 최종 리뷰 수
const CONC = 5;
const DRY = process.argv.includes('--dry');
const enc = encodeURIComponent;

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
  '사진 찍기 좋은 스팟이 많아요. 인생샷 건졌습니다.',
  '단체로 가도 자리 넉넉해서 좋았어요.',
  '재방문 의사 100%. 분위기 깡패.',
  '여기 시그니처 칵테일 꼭 드셔보세요. 미쳤어요.',
];
const NICKNAMES = [
  '밤의제왕', '클러버J', '홍대토박이', '디제이러버', '주말전사', '네온키드',
  '베이스헤드', '칵테일러', '댄싱퀸', '나이트아울', '비트메이커', '플로어킬러',
  '서울나이트', '뮤직중독', '리듬타기', '글로우스틱', '미드나잇', '바이브체커',
  '테크노매니아', '힙합러버', '강남러너', '파티피플', '사운드체이서', '문라이트',
  '클럽요정', '새벽감성', '디스코볼', '하우스키드', '펑크소울', '리버브',
];
const RATINGS = [4, 4.5, 5, 5, 4.5, 5];

function request(o, b) {
  return new Promise((res, rej) => {
    const r = https.request(o, (x) => { let d = ''; x.on('data', (c) => (d += c)); x.on('end', () => res({ status: x.statusCode, body: d })); });
    r.on('error', rej); if (b) r.write(b); r.end();
  });
}
const fs_ = (t, m, p, b) =>
  request({ hostname: 'firestore.googleapis.com', path: p, method: m, headers: { Authorization: `Bearer ${t}`, 'Content-Type': 'application/json', ...(b ? { 'Content-Length': Buffer.byteLength(b) } : {}) } }, b);
const ROOT = `/v1/projects/${PROJECT}/databases/(default)/documents`;

const rnd = (a) => a[Math.floor(Math.random() * a.length)];
function shuffle(a) { a = a.slice(); for (let i = a.length - 1; i > 0; i--) { const j = Math.floor(Math.random() * (i + 1)); [a[i], a[j]] = [a[j], a[i]]; } return a; }
const arrVal = (urls) => ({ arrayValue: { values: urls.map((u) => ({ stringValue: u })) } });
const pickPhotos = (gallery) => shuffle(gallery).slice(0, 1 + Math.floor(Math.random() * 4)); // 1~4장

async function listClubIds(t) {
  const o = []; let pt = '';
  do { const r = await fs_(t, 'GET', `${ROOT}/clubs?pageSize=300&mask.fieldPaths=name${pt ? `&pageToken=${enc(pt)}` : ''}`); const j = JSON.parse(r.body); (j.documents || []).forEach((d) => o.push(d.name.split('/').pop())); pt = j.nextPageToken || ''; } while (pt);
  return o;
}
async function getImageUrls(t, id) {
  const r = await fs_(t, 'GET', `${ROOT}/clubs/${id}?mask.fieldPaths=imageUrls`);
  const f = JSON.parse(r.body).fields || {};
  return (f.imageUrls?.arrayValue?.values || []).map((v) => v.stringValue);
}
async function listReviewIds(t, id) {
  const o = []; let pt = '';
  do { const r = await fs_(t, 'GET', `${ROOT}/clubs/${id}/reviews?pageSize=300&fields=documents(name),nextPageToken${pt ? `&pageToken=${enc(pt)}` : ''}`); const j = JSON.parse(r.body); (j.documents || []).forEach((d) => o.push(d.name.split('/').pop())); pt = j.nextPageToken || ''; } while (pt);
  return o;
}
async function patchReviewImages(t, id, rid, urls) {
  const body = JSON.stringify({ fields: { imageUrls: arrVal(urls) } });
  const r = await fs_(t, 'PATCH', `${ROOT}/clubs/${id}/reviews/${rid}?updateMask.fieldPaths=imageUrls`, body);
  if (r.status !== 200) throw new Error(`patch ${rid}: ${r.status} ${r.body.slice(0, 80)}`);
}
async function addReview(t, id, fields) {
  const r = await fs_(t, 'POST', `${ROOT}/clubs/${id}/reviews`, JSON.stringify({ fields }));
  if (r.status !== 200) throw new Error(`add review: ${r.status} ${r.body.slice(0, 80)}`);
}
async function pool(ts, n, onDone) {
  let i = 0, ok = 0, f = 0;
  async function w() { while (i < ts.length) { const m = i++; try { await ts[m](); ok++; } catch (e) { f++; console.error('  ✗', e.message.slice(0, 90)); } if (onDone) onDone(ok + f, ts.length); } }
  await Promise.all(Array.from({ length: n }, w)); return { ok, f };
}

async function run() {
  const t = execSync('gcloud auth print-access-token').toString().trim();
  const clubs = (await listClubIds(t)).filter((id) => id !== BASE);
  console.log(`타깃 ${clubs.length} 클럽, 목표 리뷰 ${TARGET_TOTAL}개/클럽` + (DRY ? '  (dry run)' : ''));
  if (DRY) return;

  const tasks = clubs.map((id) => async () => {
    const gallery = await getImageUrls(t, id);
    if (gallery.length === 0) throw new Error(`${id} gallery 비어있음`);

    // 기존 리뷰에 사진 추가
    const existing = await listReviewIds(t, id);
    for (const rid of existing) await patchReviewImages(t, id, rid, pickPhotos(gallery));

    // 부족분 신규 추가
    const need = Math.max(0, TARGET_TOTAL - existing.length);
    const texts = shuffle(REVIEW_TEXTS).slice(0, need);
    const names = shuffle(NICKNAMES).slice(0, need);
    const now = Date.now();
    for (let k = 0; k < need; k++) {
      await addReview(t, id, {
        clubId: { stringValue: id },
        userId: { stringValue: 'seed' },
        userName: { stringValue: names[k] },
        rating: { doubleValue: rnd(RATINGS) },
        content: { stringValue: texts[k] },
        imageUrls: arrVal(pickPhotos(gallery)),
        createdAt: { timestampValue: new Date(now - k * 3600000).toISOString() },
        updatedAt: { timestampValue: new Date(now - k * 3600000).toISOString() },
      });
    }
  });

  let last = -1;
  const { ok, f } = await pool(tasks, CONC, (d, total) => {
    const pct = Math.floor((d / total) * 100);
    if (pct !== last && pct % 10 === 0) { last = pct; console.log(`  ${pct}% (${d}/${total} 클럽)`); }
  });
  console.log(`\n완료! 성공 ${ok} 클럽, 실패 ${f}`);
  console.log('※ reviewCount/ratingSum/rating 은 onReviewCreated 트리거가 비동기 갱신 — 잠시 후 반영됨.');
}

run();
