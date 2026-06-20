// 장르 "하이브리드" 클럽 50개 신규 생성. 5개 지역 균등 분포(각 10개).
// 클럽마다 이름/설명/메뉴명/리뷰/평점/입장료/위치 전부 다르게.
//
// 이미지는 더 베이스(62Va...) Storage 자산 재사용 (gallery/menus/boards/thumbnail).
//   - clubs/** 는 공개 읽기라 URL 그대로 참조 가능.
// 각 신규 클럽: clubs/{auto} 문서 + info/{id} + menus/* + reviews/* + photos/*.
// 평점은 생성된 리뷰로 계산해 rating/ratingSum/reviewCount 세팅
//   (문서를 먼저 만들고 reviews 를 addDoc 하면 onReviewCreated 트리거가 또 더해 중복됨
//    → 그래서 reviews 는 setDoc(고정 id)로 만들되, 집계 필드는 트리거에 맡기지 않고
//      직접 계산값을 넣는다. 트리거 중복을 피하려 reviews 의 createdAt 만 세팅, 집계는
//      스크립트가 최종 PATCH 로 덮어쓴다.)
//
// ⚠️ onReviewCreated 트리거가 활성화돼 있으면 reviewCount/ratingSum 이 두 배가 될 수 있음.
//    --no-reviews 로 리뷰 없이 만들거나, 생성 후 집계 필드를 재보정하려면 --fix-rating 재실행.
//
// 실행: gcloud 로그인 상태에서  node scripts/seed_hybrid_clubs.js
//   --count=50 : 생성 개수 (기본 50)
//   --dry      : 쓰지 않고 계획만 출력
//   --no-photos: photos 서브컬렉션 생략

const { execSync } = require('child_process');
const https = require('https');

const PROJECT = 'vybe-bata-c07aa';
const BUCKET = 'vybe-bata-c07aa.firebasestorage.app';
const BASE = '62VaHypRMWcCySNQZEaa';
const CONC = 6;
const enc = encodeURIComponent;
const DRY = process.argv.includes('--dry');
const NO_PHOTOS = process.argv.includes('--no-photos');
const countArg = process.argv.find((a) => a.startsWith('--count='));
const COUNT = countArg ? parseInt(countArg.split('=')[1]) : 50;

// ── 지역 정의 (중심 좌표 + 행정구 + 도로명 풀) ──
const REGIONS = [
  { area: '홍대', gu: '마포구', lat: 37.5547, lng: 126.9230, roads: ['양화로', '와우산로', '동교로', '홍익로', '잔다리로'] },
  { area: '강남', gu: '강남구', lat: 37.4979, lng: 127.0276, roads: ['강남대로', '테헤란로', '논현로', '도산대로', '봉은사로'] },
  { area: '이태원', gu: '용산구', lat: 37.5345, lng: 126.9946, roads: ['이태원로', '녹사평대로', '우사단로', '보광로', '한남대로'] },
  { area: '건대', gu: '광진구', lat: 37.5403, lng: 127.0698, roads: ['아차산로', '능동로', '광나루로', '자양로', '동일로'] },
  { area: '신촌', gu: '서대문구', lat: 37.5559, lng: 126.9368, roads: ['연세로', '신촌로', '명물길', '백범로', '대현로'] },
];

// ── 고유 클럽명 풀 (60개, 하이브리드 무드) ──
const NAMES = [
  '클럽 퓨전', '하이브리드 라운지', '클럽 크로스오버', '믹스드 시그널', '클럽 듀얼',
  '제네시스 클럽', '클럽 모자이크', '폴리곤', '클럽 스펙트라', '클럽 프리퀀시',
  '클럽 패럴렐', '하이퍼 믹스', '클럽 오버랩', '클럽 컨버전스', '클럽 시너지',
  '클럽 카멜레온', '클럽 옴니', '클럽 플럭스', '클럽 케미스트리', '클럽 하이라인',
  '클럽 노바디', '클럽 미라주', '클럽 에테르', '클럽 퀀텀', '클럽 패러독스',
  '클럽 인터레이스', '클럽 보더리스', '클럽 어셈블', '클럽 리믹스', '클럽 듀오톤',
  '클럽 하모닉', '클럽 그라데이션', '클럽 트랜지트', '클럽 코드네임', '클럽 바이너리',
  '클럽 프리즘 하우스', '클럽 멜팅팟', '클럽 하프타임', '클럽 셀시우스', '클럽 노이즈게이트',
  '클럽 언폴드', '클럽 더블에지', '클럽 리버브', '클럽 스플라이스', '클럽 오토튠',
  '클럽 미드웨이', '클럽 디센트', '클럽 어센션', '클럽 노스탤지어', '클럽 페이즈',
  '클럽 시그니처', '클럽 모멘텀', '클럽 비전', '클럽 에코시스템', '클럽 패브릭',
  '클럽 라티튜드', '클럽 옥타브', '클럽 인덱스', '클럽 보야지', '클럽 하이브',
];

// ── 하이브리드 장르 설명 풀 ──
const DESCRIPTIONS = [
  '하우스부터 힙합까지 장르 경계 없이 즐기는 하이브리드 클럽.',
  '테크노와 R&B가 한 공간에서 교차하는 멀티 장르 플레이그라운드.',
  'EDM·힙합·팝을 넘나드는 셋으로 누구나 즐길 수 있는 하이브리드 사운드.',
  '두 개의 플로어, 서로 다른 장르가 흐르는 크로스오버 클럽.',
  '디제이가 그날의 분위기에 맞춰 장르를 섞는 하이브리드 나이트.',
  '하우스 베이스에 힙합 비트를 얹은 독자적인 하이브리드 셋.',
  '장르에 갇히지 않는 자유로운 선곡, 매일 다른 바이브.',
  '일렉트로닉과 어반 뮤직이 공존하는 서울의 하이브리드 핫스팟.',
  '팝부터 테크노까지, 경계를 허문 사운드 디자인.',
  '여러 장르를 한 무대에서 경험하는 멀티 장르 클럽.',
];

// ── 메뉴명 풀 ──
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
  '장르가 계속 바뀌어서 지루할 틈이 없어요. 하이브리드 최고!',
  '힙합 좋아하는 친구랑 하우스 좋아하는 나랑 둘 다 만족했어요.',
  '분위기 진짜 미쳤어요. 사운드도 빵빵하고 또 올 듯!',
  '주말에 갔는데 사람 많아서 신났어요. DJ 선곡 취향저격.',
  '입장료 대비 만족도 최고. 칵테일도 맛있음.',
  '음악이 너무 좋아서 시간 가는 줄 몰랐어요.',
  '내부 인테리어가 감각적이에요. 사진 맛집.',
  '직원분들 친절하고 화장실도 깨끗했어요.',
  '두 플로어 왔다갔다 하는 재미가 있어요.',
  '좀 시끄럽긴 한데 클럽이니까 당연하죠 ㅋㅋ 즐거웠음.',
  '웨이팅이 좀 있었지만 들어가니까 다 잊혀짐.',
  '칵테일 종류가 다양해서 골라먹는 재미가 있어요.',
  '처음 와봤는데 단골 될 것 같아요. 강추!',
  '조명이랑 사운드 시스템 퀄리티가 다르네요.',
  '생일파티로 갔는데 분위기 띄우기 딱 좋았어요.',
  '플로어 넓어서 춤추기 좋았어요. 에어컨도 빵빵.',
  'DJ 라인업 보고 갔는데 기대 이상이었어요.',
  '늦게까지 영업해서 좋아요. 새벽까지 놀았네요.',
  '장르 안 가리고 다 트는 게 이 집 매력인 듯.',
  '가성비 좋은 하이브리드 클럽 찾으면 여기 추천.',
];

const NICKNAMES = [
  '밤의제왕', '클러버J', '홍대토박이', '디제이러버', '주말전사', '네온키드',
  '베이스헤드', '칵테일러', '댄싱퀸', '나이트아울', '비트메이커', '플로어킬러',
  '서울나이트', '뮤직중독', '리듬타기', '글로우스틱', '미드나잇', '바이브체커',
  '테크노매니아', '힙합러버', '강남러너', '파티피플', '사운드체이서', '문라이트',
  '크로스페이더', '장르파괴자', '하이브리드킹', '멀티장르', '플로어호퍼', '셋리스트',
];

const TAG_POOL = ['하이브리드', '멀티장르', '크로스오버', '힙합', '하우스', 'EDM', '루프탑', '라운지', '대형클럽', '감성'];

// ── geohash 인코딩 (base32, precision 9) ──
const B32 = '0123456789bcdefghjkmnpqrstuvwxyz';
function geohashEncode(lat, lng, precision = 9) {
  let idx = 0, bit = 0, evenBit = true, hash = '';
  let latMin = -90, latMax = 90, lngMin = -180, lngMax = 180;
  while (hash.length < precision) {
    if (evenBit) {
      const mid = (lngMin + lngMax) / 2;
      if (lng >= mid) { idx = idx * 2 + 1; lngMin = mid; } else { idx = idx * 2; lngMax = mid; }
    } else {
      const mid = (latMin + latMax) / 2;
      if (lat >= mid) { idx = idx * 2 + 1; latMin = mid; } else { idx = idx * 2; latMax = mid; }
    }
    evenBit = !evenBit;
    if (++bit === 5) { hash += B32[idx]; bit = 0; idx = 0; }
  }
  return hash;
}

// ── HTTP helpers ──
function request(o, b) {
  return new Promise((res, rej) => {
    const r = https.request(o, (x) => { let d = ''; x.on('data', (c) => (d += c)); x.on('end', () => res({ status: x.statusCode, body: d })); });
    r.on('error', rej); if (b) r.write(b); r.end();
  });
}
const fsReq = (t, m, p, b) =>
  request({ hostname: 'firestore.googleapis.com', path: p, method: m, headers: { Authorization: `Bearer ${t}`, 'Content-Type': 'application/json', ...(b ? { 'Content-Length': Buffer.byteLength(b) } : {}) } }, b);
const ROOT = `/v1/projects/${PROJECT}/databases/(default)/documents`;

async function getDoc(t, path) {
  const r = await fsReq(t, 'GET', `${ROOT}/${path}`);
  if (r.status !== 200) throw new Error(`get ${path}: ${r.status}`);
  return JSON.parse(r.body).fields;
}
async function listDocs(t, coll) {
  const out = []; let pt = '';
  do {
    const r = await fsReq(t, 'GET', `${ROOT}/${coll}?pageSize=300${pt ? `&pageToken=${enc(pt)}` : ''}`);
    const j = JSON.parse(r.body); (j.documents || []).forEach((d) => out.push({ id: d.name.split('/').pop(), fields: d.fields })); pt = j.nextPageToken || '';
  } while (pt);
  return out;
}
async function createDoc(t, coll, fields, docId) {
  const path = docId ? `${ROOT}/${coll}/${docId}` : `${ROOT}/${coll}`;
  const method = docId ? 'PATCH' : 'POST';
  const r = await fsReq(t, method, path, JSON.stringify({ fields }));
  if (r.status !== 200) throw new Error(`create ${coll}: ${r.status} ${r.body.slice(0, 140)}`);
  return JSON.parse(r.body);
}

// ── value helpers ──
const S = (v) => ({ stringValue: v });
const I = (v) => ({ integerValue: String(v) });
const D = (v) => ({ doubleValue: v });
const B = (v) => ({ booleanValue: v });
const TS = (v) => ({ timestampValue: v });
const arr = (vals) => ({ arrayValue: { values: vals } });
const strArr = (xs) => arr(xs.map(S));

function rand(min, max) { return Math.random() * (max - min) + min; }
function randInt(min, max) { return Math.floor(rand(min, max + 1)); }
function pick(a) { return a[Math.floor(Math.random() * a.length)]; }
function shuffle(a) { a = a.slice(); for (let i = a.length - 1; i > 0; i--) { const j = Math.floor(Math.random() * (i + 1)); [a[i], a[j]] = [a[j], a[i]]; } return a; }

async function pool(ts, n, onDone) {
  let i = 0, ok = 0, f = 0;
  async function w() { while (i < ts.length) { const m = i++; try { await ts[m](); ok++; } catch (e) { f++; console.error('  ✗', String(e.message).slice(0, 140)); } if (onDone) onDone(ok + f, ts.length); } }
  await Promise.all(Array.from({ length: n }, w)); return { ok, f };
}

async function run() {
  const t = execSync('gcloud auth print-access-token').toString().trim();

  // 베이스 템플릿 (이미지/메뉴 자산/info/operatingHours 재사용)
  const baseClub = await getDoc(t, `clubs/${BASE}`);
  const baseInfo = await getDoc(t, `clubs/${BASE}/info/${BASE}`);
  const baseMenus = await listDocs(t, `clubs/${BASE}/menus`);
  const heroUrls = baseClub.heroImageUrls;
  const imageUrls = baseClub.imageUrls;
  const boardUrls = baseClub.menuBoardUrls;
  const thumbUrl = baseClub.thumbnailUrl;
  const operatingHours = baseClub.operatingHours;
  console.log(`베이스 자산 로드: menus ${baseMenus.length}, gallery ${imageUrls.arrayValue.values.length}장`);

  // 이름 고유 보장
  const names = shuffle(NAMES).slice(0, COUNT);
  if (names.length < COUNT) throw new Error(`이름 풀 부족: ${names.length} < ${COUNT}`);

  const nowIso = new Date().toISOString();
  const plan = [];
  for (let k = 0; k < COUNT; k++) {
    const region = REGIONS[k % REGIONS.length];   // 균등 분포
    const lat = +(region.lat + rand(-0.012, 0.012)).toFixed(6);
    const lng = +(region.lng + rand(-0.012, 0.012)).toFixed(6);
    const geohash = geohashEncode(lat, lng, 9);
    const road = pick(region.roads);
    const feeMin = pick([0, 0, 10000, 15000, 20000]);
    const feeMax = feeMin === 0 ? pick([0, 10000, 15000]) : feeMin + pick([5000, 10000, 15000]);
    plan.push({
      name: names[k], region, lat, lng, geohash, road,
      desc: pick(DESCRIPTIONS), feeMin, feeMax,
      menuCount: randInt(8, 14), reviewCount: randInt(4, 7),
      recommended: Math.random() < 0.2, nonSmoking: Math.random() < 0.25,
      addrNo: randInt(1, 200),
    });
  }

  console.log(`\n생성 계획 ${COUNT}개 (지역별 ${COUNT / REGIONS.length}개씩):`);
  const byArea = {};
  plan.forEach((p) => { byArea[p.region.area] = (byArea[p.region.area] || 0) + 1; });
  console.log('  ' + Object.entries(byArea).map(([a, n]) => `${a} ${n}`).join(' / '));
  if (DRY) {
    plan.forEach((p, i) => console.log(`  ${i + 1}. [${p.region.area}] ${p.name} (geohash ${p.geohash}, 메뉴 ${p.menuCount}, 리뷰 ${p.reviewCount})`));
    console.log('\n(dry run — 쓰지 않음)');
    return;
  }

  const tasks = plan.map((p) => async () => {
    // 리뷰 데이터 준비. 집계(rating/ratingSum/reviewCount)는 onReviewCreated 트리거가
    // 자동 누적하므로 클럽 문서엔 0으로 두고 트리거에 위임(중복 가산 방지).
    const reviewTexts = shuffle(REVIEW_TEXTS).slice(0, p.reviewCount);
    const reviewNames = shuffle(NICKNAMES).slice(0, p.reviewCount);
    const ratings = Array.from({ length: p.reviewCount }, () => randInt(3, 5));

    // 1) 클럽 문서 생성 (auto id)
    const created = await createDoc(t, 'clubs', {
      name: S(p.name),
      description: S(p.desc),
      address: S(`서울 ${p.region.gu} ${p.road} ${p.addrNo}`),
      area: S(p.region.area),
      phone: S(`02-${randInt(300, 999)}-${randInt(1000, 9999)}`),
      instagramUrl: S(`https://instagram.com/${p.name.replace(/[^가-힣a-zA-Z0-9]/g, '').toLowerCase()}_official`),
      genre: S('하이브리드'),
      location: { mapValue: { fields: { lat: D(p.lat), lng: D(p.lng), geohash: S(p.geohash) } } },
      operatingHours,
      entryFeeMin: I(p.feeMin),
      entryFeeMax: I(p.feeMax),
      heroImageUrls: heroUrls,
      imageUrls,
      menuBoardUrls: boardUrls,
      thumbnailUrl: thumbUrl,
      tags: strArr(['하이브리드', p.region.area, ...shuffle(TAG_POOL.slice(1)).slice(0, 2)]),
      favoriteCount: I(0),
      rating: D(0),
      ratingSum: D(0),
      reviewCount: I(0),
      isActive: B(true),
      isVybeRecommended: B(p.recommended),
      isNonSmoking: B(p.nonSmoking),
      createdAt: TS(nowIso),
      updatedAt: TS(nowIso),
    });
    const id = created.name.split('/').pop();

    // 2) info
    await createDoc(t, `clubs/${id}/info`, { ...baseInfo, updatedAt: TS(nowIso) }, id);

    // 3) menus (이름 다르게, 이미지/가격/카테고리는 베이스 재사용)
    const menuNames = shuffle(MENU_NAMES).slice(0, p.menuCount);
    const srcMenus = shuffle(baseMenus).slice(0, p.menuCount);
    for (let m = 0; m < p.menuCount; m++) {
      const src = srcMenus[m].fields;
      const f = { ...src };
      f.clubId = S(id);
      f.name = S(menuNames[m]);
      if (f.imageUrl) f.imageUrl = src.imageUrl; // 베이스 이미지 URL 그대로
      f.isFeatured = B(m < 2);
      await createDoc(t, `clubs/${id}/menus`, f);
    }

    // 4) reviews (내용/작성자/평점 다르게). 생성 시 onReviewCreated 트리거가
    //    ratingSum/reviewCount 누적 + rating 재계산 → 클럽 집계 자동 반영.
    for (let r = 0; r < p.reviewCount; r++) {
      await createDoc(t, `clubs/${id}/reviews`, {
        clubId: S(id),
        userId: S('seed'),
        userName: S(reviewNames[r]),
        rating: I(ratings[r]),
        content: S(reviewTexts[r]),
        imageUrls: arr([]),
        createdAt: TS(new Date(Date.now() - r * 86400000).toISOString()),
        updatedAt: TS(nowIso),
      });
    }

    // 5) photos (사진탭) — imageUrls round-robin 카테고리
    if (!NO_PHOTOS) {
      const cats = ['venue', 'food', 'inside'];
      const urls = imageUrls.arrayValue.values.slice(0, 12);
      for (let pi = 0; pi < urls.length; pi++) {
        await createDoc(t, `clubs/${id}/photos`, {
          clubId: S(id), userId: S('seed'), url: urls[pi], category: S(cats[pi % cats.length]),
          createdAt: TS(new Date(Date.now() - pi * 3600000).toISOString()),
        });
      }
    }
  });

  let last = -1;
  const { ok, f } = await pool(tasks, CONC, (d, total) => {
    const pct = Math.floor((d / total) * 100);
    if (pct !== last && pct % 10 === 0) { last = pct; console.log(`  ${pct}% (${d}/${total} 클럽)`); }
  });
  console.log(`\n완료! 생성 ${ok} 클럽, 실패 ${f}`);
  console.log('※ rating/ratingSum/reviewCount 는 onReviewCreated 트리거가 수 초 내 비동기로 채움.');
}

run().catch((e) => { console.error(e); process.exit(1); });
