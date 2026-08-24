// clubs/{clubId}/tableLayout/{clubId} 문서 생성 — 클럽 상세 '테이블' 섹션 데이터.
//
// 화면 확인용 샘플이다. 실제 배치는 업주용 편집기(scripts/table_editor_server.js)로 덮어쓴다.
//
// 좌표는 **정수 그리드 셀**(col·row·colSpan·rowSpan). 층마다 cols × rows 격자를 두고
// 셀이 정사각이라 캔버스 비율이 cols/rows 로 자동 도출된다 — 폭이 다른 웹·앱이 같은 그림을 그린다.
//
// ⚠ 테이블은 최소 2×2 여야 한다(앱이 강제로 키운다) — 1칸은 탭 타겟 44px 미달.
// ⚠ 겹치면 앱이 그대로 겹쳐 그린다. 배치 시 셀 점유가 안 겹치게 둘 것.
//
// 실행: gcloud 로그인 상태에서  node scripts/seed_table_layout.js
//   --count=N : 앞에서부터 N개 클럽에 심는다 (기본 3, 그중 1곳은 2층)
//   --club=ID : 특정 클럽 하나만
//   --force   : 이미 배치도가 있어도 덮어쓴다 (기본은 skip)
//   --dry     : 쓰지 않고 대상만 출력

const { execSync } = require('child_process');
const https = require('https');

const PROJECT = 'vybe-bata-c07aa';
const FORCE = process.argv.includes('--force');
const DRY = process.argv.includes('--dry');
const COUNT = Number(
  (process.argv.find((a) => a.startsWith('--count=')) || '').split('=')[1] || 3
);
const ONLY_CLUB = (
  process.argv.find((a) => a.startsWith('--club=')) || ''
).split('=')[1];

const SCHEMA_VERSION = 1;

// ── 샘플 배치 ──
// 12 × 16 격자. 무대 위 / 댄스플로어 가운데 / 바 아래 / 테이블은 벽을 따라.

const TIERS = [
  { key: 'vvip', name: 'VVIP', short: 'VVIP', colorKey: 'purple', order: 0 },
  { key: 'vip', name: 'VIP', short: 'VIP', colorKey: 'blue', order: 1 },
  { key: 'std', name: 'STANDARD', short: 'STD', colorKey: 'gray', order: 2 },
];

const t = (id, tierKey, name, desc, col, row, price, people, bottles) => ({
  id,
  tierKey,
  name,
  desc,
  col,
  row,
  colSpan: 2,
  rowSpan: 2,
  shape: 'rect',
  price,
  minPeople: people,
  minBottles: bottles,
  minSpend: price,
  note: '',
  isActive: true,
});

const MAIN_FLOOR = {
  floorId: 'f1',
  name: '1F',
  order: 0,
  cols: 12,
  rows: 16,
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

// 2층 — 층 전환 탭 확인용. 격자를 12×12 로 다르게 잡아 캔버스 비율도 층마다
// 달라지는지(cols/rows 도출) 같이 확인한다.
// 방 모양(cells) — 길이 cols*rows 의 '1'/'0'. '0' = 방 밖(바닥 없음).
// 오른쪽 아래를 도려낸 ㄱ자 라운지. 직사각형이 아닌 홀이 앱에서 어떻게 그려지는지 확인용.
const UPPER_CELLS = [
  '111111111111',
  '111111111111',
  '111111111111',
  '111111111111',
  '111111111111',
  '111111111111',
  '111111111111',
  '111111100000',
  '111111100000',
  '111111100000',
  '111111100000',
  '111111100000',
].join('');

const UPPER_FLOOR = {
  floorId: 'f2',
  name: '2F 라운지',
  order: 1,
  cols: 12,
  rows: 12,
  cells: UPPER_CELLS,
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
    // ⚠ 아래 두 자리는 ㄱ자로 도려낸 오른쪽(col 7~11, row 7~11)을 피해 왼쪽에 둔다.
    t('L5', 'std', '라운지 코너 1', '구석 · 프라이빗', 1, 7, 250000, 4, 1),
    t('L6', 'std', '라운지 코너 2', '구석 · 프라이빗', 4, 7, 250000, 4, 1),
  ],
};

const NOTICE = '가격 및 예약 조건은 요일·이벤트에 따라 변동될 수 있습니다.';

// ── Firestore REST ──

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

/// JS 값 → Firestore REST Value.
function toValue(v) {
  if (v === null || v === undefined) return { nullValue: null };
  if (typeof v === 'boolean') return { booleanValue: v };
  if (typeof v === 'number') {
    return Number.isInteger(v)
      ? { integerValue: String(v) }
      : { doubleValue: v };
  }
  if (typeof v === 'string') return { stringValue: v };
  if (v instanceof Date) return { timestampValue: v.toISOString() };
  if (Array.isArray(v)) return { arrayValue: { values: v.map(toValue) } };
  return { mapValue: { fields: toFields(v) } };
}

function toFields(obj) {
  const out = {};
  for (const [k, v] of Object.entries(obj)) out[k] = toValue(v);
  return out;
}

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
      clubs.push({
        id: doc.name.split('/').pop(),
        name: doc.fields?.name?.stringValue || '',
      });
    }
    pageToken = json.nextPageToken || '';
  } while (pageToken);
  return clubs;
}

async function hasLayout(token, clubId) {
  const res = await fsReq(
    token,
    'GET',
    `/v1/projects/${PROJECT}/databases/(default)/documents/clubs/${clubId}/tableLayout/${clubId}`
  );
  return res.status === 200;
}

// 문서 전체 교체(set). updateMask 없는 commit update = 전체 덮어쓰기라
// 예전 층·테이블이 남지 않는다.
async function setLayout(token, clubId, floors) {
  const doc = {
    schemaVersion: SCHEMA_VERSION,
    clubId,
    tiers: TIERS,
    floors,
    notice: NOTICE,
    updatedAt: new Date(),
    updatedBy: 'seed_table_layout.js',
  };
  const body = JSON.stringify({
    writes: [
      {
        update: {
          name: `projects/${PROJECT}/databases/(default)/documents/clubs/${clubId}/tableLayout/${clubId}`,
          fields: toFields(doc),
        },
      },
    ],
  });
  const res = await fsReq(
    token,
    'POST',
    `/v1/projects/${PROJECT}/databases/(default)/documents:commit`,
    body
  );
  if (res.status !== 200) throw new Error(`commit failed: ${res.status} ${res.body}`);
}

async function run() {
  const token = execSync('gcloud auth print-access-token').toString().trim();
  const all = await listClubs(token);

  let targets;
  if (ONLY_CLUB) {
    targets = all.filter((c) => c.id === ONLY_CLUB);
    if (targets.length === 0) throw new Error(`클럽을 찾을 수 없다: ${ONLY_CLUB}`);
  } else {
    targets = all.slice(0, COUNT);
  }

  console.log(`클럽 ${all.length}개 / 대상 ${targets.length}개\n`);

  for (let i = 0; i < targets.length; i++) {
    const { id, name } = targets[i];

    if (!FORCE && (await hasLayout(token, id))) {
      console.log(`  skip (이미 있음) ${id.slice(0, 8)}…  ${name}`);
      continue;
    }

    // 첫 클럽만 2층 — 층 전환 탭을 확인할 대상.
    const floors = i === 0 ? [MAIN_FLOOR, UPPER_FLOOR] : [MAIN_FLOOR];
    const label = `${floors.length}층 · 테이블 ${floors.reduce((s, f) => s + f.tables.length, 0)}자리`;

    if (DRY) {
      console.log(`  ${id.slice(0, 8)}…  ${label}  ${name}`);
      continue;
    }
    await setLayout(token, id, floors);
    console.log(`[${i + 1}/${targets.length}] ${id.slice(0, 8)}…  ${label}  ${name}`);
  }

  console.log(`\n완료${DRY ? ' (dry run)' : ''}`);
}

run().catch((e) => {
  console.error(e);
  process.exit(1);
});
