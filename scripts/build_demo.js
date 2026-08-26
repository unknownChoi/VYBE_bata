// 배포/공유용 단일 파일 데모를 만든다.
//
//   node scripts/build_demo.js  →  partner/demo.html (파일 하나)
//
// 왜 필요한가: partner/index.html 은 Firebase 로그인이 필요하고(계정·파트너 클레임),
// 로컬 도구는 gcloud 자격증명이 있어야 한다. **둘 다 외부 사람은 못 연다.**
// 이 데모는 서버·로그인·네트워크가 전부 없어서 파일을 더블클릭하면 바로 열린다.
//
// ⚠ 손으로 복사하지 말고 **항상 이 스크립트로 뽑을 것.** editor.js/css 를 고친 뒤
//   데모를 다시 만들지 않으면 받는 사람이 보는 화면이 실제 편집기와 달라진다.
//
// 데모의 한계(파일 안에도 표시된다):
//   - 저장이 Firestore 로 안 간다. 브라우저 안에서만 유지된다
//   - 클럽 목록이 샘플 2곳뿐이다

const fs = require('fs');
const path = require('path');

const DIR = path.join(__dirname, '..', 'partner');
const OUT = path.join(DIR, 'demo.html');

const css = fs.readFileSync(path.join(DIR, 'editor.css'), 'utf8');
// ES 모듈을 인라인 <script> 로 넣으려면 export 를 떼야 한다.
// (file:// 에서는 type="module" 이 CORS 로 막혀 빈 화면이 된다)
const js = fs
  .readFileSync(path.join(DIR, 'editor.js'), 'utf8')
  .replace(/^export\s+/gm, '');

// ── 샘플 배치도 ──
// scripts/seed_table_layout.js 의 샘플과 같은 모양. 화면 확인용이라 실제 데이터가 아니다.

const t = (id, tierKey, name, desc, col, row, price, people, bottles) => ({
  id, tierKey, name, desc,
  col, row, colSpan: 2, rowSpan: 2, shape: 'rect',
  price, minPeople: people, minBottles: bottles, minSpend: price,
  note: '', isActive: true,
});

const TIERS = [
  { key: 'vvip', name: 'VVIP', short: 'VVIP', colorKey: 'purple', order: 0 },
  { key: 'vip', name: 'VIP', short: 'VIP', colorKey: 'blue', order: 1 },
  { key: 'std', name: 'STANDARD', short: 'STD', colorKey: 'gray', order: 2 },
];

const MAIN_FLOOR = {
  floorId: 'f1', name: '1F', order: 0, cols: 12, rows: 16, cells: '',
  fixtures: [
    { id: 'fx_stage', type: 'stage', label: 'DJ BOOTH · STAGE', col: 1, row: 0, colSpan: 10, rowSpan: 2 },
    { id: 'fx_floor', type: 'dancefloor', label: 'DANCE FLOOR', col: 4, row: 5, colSpan: 4, rowSpan: 6 },
    { id: 'fx_bar', type: 'bar', label: 'BAR', col: 1, row: 14, colSpan: 10, rowSpan: 2 },
  ],
  tables: [
    t('S1', 'vvip', '스테이지 프론트 A', '무대 바로 앞 · 최고의 시야', 0, 3, 1000000, 8, 3),
    t('S2', 'vvip', '스테이지 프론트 B', '무대 바로 앞 · 최고의 시야', 10, 3, 1000000, 8, 3),
    t('V1', 'vip', '센터 사이드 1', '플로어 옆 · 활기찬 자리', 0, 6, 500000, 6, 2),
    t('V2', 'vip', '센터 사이드 2', '플로어 옆 · 활기찬 자리', 10, 6, 500000, 6, 2),
    t('V3', 'vip', '센터 사이드 3', '플로어 옆 · 활기찬 자리', 0, 9, 500000, 6, 2),
    t('V4', 'vip', '센터 사이드 4', '플로어 옆 · 활기찬 자리', 10, 9, 500000, 6, 2),
    t('T1', 'std', '바 라운지 1', '바 근처 · 편안한 자리', 1, 12, 200000, 4, 1),
    t('T2', 'std', '바 라운지 2', '바 근처 · 편안한 자리', 5, 12, 200000, 4, 1),
    t('T3', 'std', '바 라운지 3', '바 근처 · 편안한 자리', 9, 12, 200000, 4, 1),
  ],
};

// 오른쪽 아래를 도려낸 ㄱ자 라운지 — 방 모양(cells) 기능 시연용.
const UPPER_CELLS = [
  '111111111111', '111111111111', '111111111111', '111111111111',
  '111111111111', '111111111111', '111111111111',
  '111111100000', '111111100000', '111111100000', '111111100000', '111111100000',
].join('');

const UPPER_FLOOR = {
  floorId: 'f2', name: '2F 라운지', order: 1, cols: 12, rows: 12, cells: UPPER_CELLS,
  fixtures: [
    { id: 'fx2_stairs', type: 'stairs', label: 'STAIRS', col: 0, row: 0, colSpan: 2, rowSpan: 2 },
    { id: 'fx2_bar', type: 'bar', label: 'LOUNGE BAR', col: 3, row: 0, colSpan: 9, rowSpan: 2 },
    { id: 'fx2_rest', type: 'restroom', label: 'REST', col: 0, row: 10, colSpan: 2, rowSpan: 2 },
  ],
  tables: [
    t('L1', 'vip', '라운지 창가 1', '통창 옆 · 조용한 자리', 0, 3, 400000, 5, 2),
    t('L2', 'vip', '라운지 창가 2', '통창 옆 · 조용한 자리', 3, 3, 400000, 5, 2),
    t('L3', 'std', '라운지 센터 1', '2층 중앙 · 넓은 자리', 6, 3, 250000, 4, 1),
    t('L4', 'std', '라운지 센터 2', '2층 중앙 · 넓은 자리', 9, 3, 250000, 4, 1),
    t('L5', 'std', '라운지 코너 1', '구석 · 프라이빗', 1, 7, 250000, 4, 1),
    t('L6', 'std', '라운지 코너 2', '구석 · 프라이빗', 4, 7, 250000, 4, 1),
  ],
};

const SAMPLE = {
  demo_club_1: {
    schemaVersion: 1, clubId: 'demo_club_1', tiers: TIERS,
    floors: [MAIN_FLOOR, UPPER_FLOOR],
    notice: '가격 및 예약 조건은 요일·이벤트에 따라 변동될 수 있습니다.',
  },
  // 두 번째는 비워 둔다 — '배치도가 아직 없는 클럽'에서 처음 만드는 흐름을 보여준다.
  demo_club_2: null,
};

const html = `<!doctype html>
<html lang="ko">
<head>
<meta charset="utf-8" />
<meta name="viewport" content="width=device-width, initial-scale=1" />
<title>VYBE 테이블 배치 편집기 (데모)</title>
<style>
${css}
.demo-banner {
  background: #2a2320; border-bottom: 1px solid #5a4a2a; color: #FFD79A;
  padding: 10px 18px; font-size: 12px; line-height: 1.7;
}
.demo-banner b { color: #fff; }
</style>
</head>
<body>

<div class="demo-banner">
  <b>데모 모드</b> — 서버·로그인·네트워크 없이 도는 화면 확인용 파일입니다.
  저장을 눌러도 <b>실제 DB(Firestore)에 반영되지 않고</b> 이 브라우저 안에서만 유지됩니다.
  클럽 목록도 샘플 2곳뿐입니다. 실제 연동 방법은 함께 보낸
  <b>구현_요청_프롬프트.md</b> 를 참고하세요.
</div>

<div id="root"></div>

<script>
${js}

// ── 데모 전송 계층 ──
// 실제 페이지는 이 자리에 Firestore 호출이 들어간다 (partner/index.html 참고).
// 여기서는 메모리에만 담아 새로고침 전까지 유지한다.

const DEMO_CLUBS = [
  { id: 'demo_club_1', name: '샘플 클럽 A (2층 · ㄱ자 라운지)', area: '홍대' },
  { id: 'demo_club_2', name: '샘플 클럽 B (배치도 없음)', area: '강남' },
];

const store = ${JSON.stringify(SAMPLE, null, 2)};

mountEditor(document.getElementById('root'), {
  listClubs: async () => DEMO_CLUBS,
  getLayout: async (clubId) => store[clubId] || null,
  saveLayout: async (clubId, layout) => {
    store[clubId] = { ...layout, clubId, updatedBy: 'demo' };
  },
  deleteLayout: async (clubId) => { store[clubId] = null; },
}, {
  title: 'VYBE 테이블 배치 편집기 (데모)',
});
</script>
</body>
</html>
`;

fs.writeFileSync(OUT, html);
console.log('만들었다 →', OUT);
console.log('크기:', (Buffer.byteLength(html) / 1024).toFixed(0) + 'KB');
console.log('더블클릭으로 열린다 (서버 불필요).');
