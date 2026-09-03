// performances/{performanceId} — 오늘(실행일, KST) EDM 공연 10건 추가 시드.
//
// 목적: EDM 장르 페이지(타임테이블)를 오늘 날짜 데이터로 확인하기 위한 샘플.
//   - 대상: genre 'EDM' + isActive != false + **오늘 요일에 영업하는 클럽만**
//     (문 닫은 날 공연은 화면에서 "영업 종료인데 공연 중"으로 어긋난다)
//   - artistType 은 'dj' 만 (EDM 규칙 — seed_performances_sep.js 와 동일)
//   - doc id = perf_<clubId>_<date>_t<n> — 기존 시드(perf_<clubId>_<date>_<n>)와
//     겹치지 않는 접미사라 덮어쓰지 않는다. 재실행하면 같은 10건을 upsert(멱등)
//
// 실행: gcloud 로그인 상태에서  node scripts/seed_performances_today_edm.js
//   --dry : 쓰지 않고 배정 결과만 출력

const { execSync } = require('child_process');
const https = require('https');

const PROJECT = 'vybe-bata-c07aa';
const DRY = process.argv.includes('--dry');

const COUNT = 10;            // 만들 공연 doc 수
const FEATURED = 3;          // hero 캐러셀용 isFeatured 건수

const DJS = [
  'GRIM', 'KODA', 'ECHO', 'FLASH', 'PEAK', 'HALO', 'DRIFT', 'PULSE',
  'SAGE', 'RIFT', 'AXIS', 'LUMEN', 'ORBIT', 'PRISM', 'VOLT', 'ZENON',
  'CIRRUS', 'NOCTIS', 'HELIX', 'QUARTZ', 'SABLE', 'TIDAL', 'UMBRA', 'VECTOR',
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

// ── 결정적 난수 (재실행 시 같은 결과) ────────────────────────
function hashSeed(str) {
  let h = 2166136261 >>> 0;
  for (let i = 0; i < str.length; i++) {
    h ^= str.charCodeAt(i);
    h = Math.imul(h, 16777619) >>> 0;
  }
  return h >>> 0;
}

function rngFrom(seedStr) {
  let a = hashSeed(seedStr);
  return function () {
    a |= 0;
    a = (a + 0x6d2b79f5) | 0;
    let t = Math.imul(a ^ (a >>> 15), 1 | a);
    t = (t + Math.imul(t ^ (t >>> 7), 61 | t)) ^ t;
    return ((t ^ (t >>> 14)) >>> 0) / 4294967296;
  };
}

function shuffled(arr, rnd) {
  const a = [...arr];
  for (let i = a.length - 1; i > 0; i--) {
    const j = Math.floor(rnd() * (i + 1));
    [a[i], a[j]] = [a[j], a[i]];
  }
  return a;
}

// ── 날짜 (KST) ───────────────────────────────────────────────
const DAY_KEYS = ['sun', 'mon', 'tue', 'wed', 'thu', 'fri', 'sat'];

function kstToday() {
  const k = new Date(Date.now() + 9 * 3600 * 1000);
  return `${k.getUTCFullYear()}${String(k.getUTCMonth() + 1).padStart(2, '0')}${String(k.getUTCDate()).padStart(2, '0')}`;
}

function parseYmd(s) {
  return { y: +s.slice(0, 4), m: +s.slice(4, 6), d: +s.slice(6, 8) };
}

function dayKeyOf(dateStr) {
  const { y, m, d } = parseYmd(dateStr);
  return DAY_KEYS[new Date(Date.UTC(y, m - 1, d)).getUTCDay()];
}

// 밤 날짜 + KST 시각 → UTC ISO. 새벽(시<12)은 달력상 +1일.
function nightSlotToIso(dateStr, hour, min) {
  const { y, m, d } = parseYmd(dateStr);
  const dayOffset = hour < 12 ? 1 : 0;
  return new Date(Date.UTC(y, m - 1, d + dayOffset, hour, min) - 9 * 3600 * 1000).toISOString();
}

// ── Firestore ────────────────────────────────────────────────
async function listEdmClubs(token) {
  const clubs = [];
  let pageToken = '';
  do {
    const qs = `pageSize=300${pageToken ? `&pageToken=${encodeURIComponent(pageToken)}` : ''}`;
    const res = await fsReq(
      token, 'GET',
      `/v1/projects/${PROJECT}/databases/(default)/documents/clubs?${qs}`
    );
    if (res.status !== 200) throw new Error(`list clubs failed: ${res.status} ${res.body}`);
    const json = JSON.parse(res.body);
    for (const doc of json.documents || []) {
      const f = doc.fields || {};
      if ((f.genre?.stringValue || '') !== 'EDM') continue;
      if (f.isActive?.booleanValue === false) continue;
      const ohFields = f.operatingHours?.mapValue?.fields || {};
      const openDays = new Set();
      for (const [k, v] of Object.entries(ohFields)) {
        if (v.mapValue?.fields?.isOpen?.booleanValue) openDays.add(k);
      }
      clubs.push({
        id: doc.name.split('/').pop(),
        name: f.name?.stringValue || '',
        area: f.area?.stringValue || '',
        openDays,
      });
    }
    pageToken = json.nextPageToken || '';
  } while (pageToken);
  return clubs;
}

async function upsertPerformance(token, p) {
  const body = JSON.stringify({
    fields: {
      performanceId: { stringValue: p.id },
      clubId: { stringValue: p.clubId },
      clubName: { stringValue: p.clubName },
      clubArea: { stringValue: p.clubArea },
      genre: { stringValue: 'EDM' },
      artistName: { stringValue: p.artistName },
      artistType: { stringValue: 'dj' },
      startAt: { timestampValue: p.startAtIso },
      date: { stringValue: p.date },
      isFeatured: { booleanValue: p.isFeatured },
      isActive: { booleanValue: true },
      createdAt: { timestampValue: new Date().toISOString() },
    },
  });
  const res = await fsReq(
    token, 'PATCH',
    `/v1/projects/${PROJECT}/databases/(default)/documents/performances/${p.id}`,
    body
  );
  if (res.status !== 200) throw new Error(`upsert failed: ${res.status} ${res.body}`);
}

async function run() {
  const token = execSync('gcloud auth print-access-token').toString().trim();
  const date = kstToday();
  const dayKey = dayKeyOf(date);

  const all = await listEdmClubs(token);
  const open = all.filter((c) => c.openDays.has(dayKey));
  if (!open.length) {
    console.log(`오늘(${date} ${dayKey}) 영업하는 EDM 클럽이 없다 — 만들 공연 없음`);
    return;
  }

  // 클럽 10곳 우선 (모자라면 같은 클럽에 2번째 셋 배정).
  const rnd = rngFrom(`today_edm_${date}`);
  const pool = shuffled(open, rnd);
  const picks = [];
  for (let i = 0; i < COUNT; i++) picks.push({ club: pool[i % pool.length], nth: Math.floor(i / pool.length) });

  const djPool = shuffled(DJS, rnd);
  const featuredIdx = new Set(shuffled([...Array(COUNT).keys()], rnd).slice(0, FEATURED));

  const plan = picks.map(({ club, nth }, i) => {
    // 첫 셋 22:00~23:30(10분 단위), 같은 클럽 두 번째 셋은 +60~90분.
    const r = rngFrom(`slot_${club.id}_${date}_${nth}`);
    let totalMin = 22 * 60 + Math.floor(r() * 10) * 10 + nth * (60 + Math.floor(r() * 4) * 10);
    const hour = Math.floor(totalMin / 60) % 24;
    const min = totalMin % 60;
    return {
      id: `perf_${club.id}_${date}_t${i}`,
      clubId: club.id,
      clubName: club.name,
      clubArea: club.area,
      artistName: djPool[i % djPool.length],
      date,
      startAtIso: nightSlotToIso(date, hour, min),
      slot: `${String(hour).padStart(2, '0')}:${String(min).padStart(2, '0')}`,
      isFeatured: featuredIdx.has(i),
    };
  });

  console.log(`오늘 ${date}(${dayKey}) · 영업 중 EDM 클럽 ${open.length}/${all.length}곳`);
  console.log(`공연 doc ${plan.length}개 (isFeatured ${plan.filter((p) => p.isFeatured).length})\n`);
  for (const p of plan.slice().sort((a, b) => a.slot.localeCompare(b.slot))) {
    console.log(`  ${p.slot}  ${p.clubName}(${p.clubArea})  DJ ${p.artistName}${p.isFeatured ? '  ★hero' : ''}`);
  }

  if (DRY) {
    console.log('\n--dry — 쓰지 않음');
    return;
  }

  let done = 0;
  for (const p of plan) {
    await upsertPerformance(token, p);
    done++;
  }
  console.log(`\n완료 — ${done}개 upsert`);
}

run().catch((e) => {
  console.error(e.message);
  process.exit(1);
});
