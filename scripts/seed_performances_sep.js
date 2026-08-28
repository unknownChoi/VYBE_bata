// performances/{performanceId} — 오늘(실행일)부터 9월 마지막날까지 공연 일정 시드.
//
// 요구사항:
//   1) 9월 마지막날까지 공연이 예정되어 있을 것. 단 일주일에 공연 없는 날을 랜덤으로 둘 것.
//   2) 장르 힙합 클럽 → artistType 'dj' + 'rapper' 혼합 / EDM 클럽 → 'dj'만.
//
// 대상: genre 가 '힙합' | 'EDM' 인 클럽만 (나머지 장르는 공연 데이터 없음).
//
// ⚠ 공연일은 **클럽 영업일(operatingHours.isOpen)** 안에서만 잡는다 — 현재 DB의 클럽은
//   전부 목·금·토만 영업이라, 밖에 공연을 두면 "문 닫은 날 공연 예정"이 된다.
//   그래서 '주 2일 휴무'는 목·금·토 중 **매주 랜덤 1일 휴무**(= 주 2일 공연)로 적용한다.
//   운영일이 3일 미만인 부분 주(첫 주·마지막 주)는 휴무일을 따로 빼지 않는다.
//
// 문서 1개 = (클럽 × 날짜 × 아티스트). performanceId = perf_<clubId>_<date>_<n>.
// 난수는 전부 clubId·날짜 해시 기반 결정적 PRNG → **재실행해도 같은 결과**(멱등, 잔여 doc 없음).
//
// 실행: gcloud 로그인 상태에서  node scripts/seed_performances_sep.js
//   --dry   : 쓰지 않고 배정 결과만 출력
//   --purge : 쓰기 전에 기존 performances 문서를 모두 삭제

const { execSync } = require('child_process');
const https = require('https');

const PROJECT = 'vybe-bata-c07aa';
const DRY = process.argv.includes('--dry');
const PURGE = process.argv.includes('--purge');

const TARGET_GENRES = ['힙합', 'EDM'];
const END_DATE = '20260930';          // 9월 마지막날까지
const CLUB_NIGHT_RATIO = 0.6;         // 공연일마다 참여하는 클럽 비율
const MAX_ARTISTS_PER_NIGHT = 3;      // 클럽당 하루 1~3팀
const FEATURED_PER_DATE = 3;          // hero 캐러셀용 isFeatured 클럽 수/일
const COMMON_DAY_RATIO = 0.25;        // 이 비율 이상 클럽이 여는 요일만 공연 후보일로 본다

// 아티스트 풀 — 같은 밤에 같은 이름이 두 클럽에 서지 않도록 넉넉히 둔다.
// (EDM 클럽 30곳 × 0.6 × 최대 3팀 ≈ 밤당 dj 슬롯 최대 54)
const DJS = [
  'GRIM', 'KODA', 'ECHO', 'FLASH', 'PEAK', 'HALO', 'DRIFT', 'PULSE',
  'SAGE', 'RIFT', 'AXIS', 'LUMEN', 'ORBIT', 'PRISM', 'VOLT', 'ZENON',
  'CIRRUS', 'NOCTIS', 'HELIX', 'QUARTZ', 'SABLE', 'TIDAL', 'UMBRA', 'VECTOR',
  'WAVEN', 'XENO', 'YUKI', 'ZEPHYR', 'AURA', 'BOLT', 'CINDER', 'DUSK',
  'EMBER', 'FLUX', 'GLOW', 'HAZE', 'IRIS', 'JOLT', 'KRYO', 'LUNA',
  'MIRAGE', 'NEBULA', 'ONYX', 'PLASMA', 'QUASAR', 'RIPTIDE', 'SOLAR', 'TRACE',
  'ULTRA', 'VORTEX', 'WATT', 'ZODIAC',
  'ARC', 'BINARY', 'COBALT', 'DELTA', 'ECLIPSE', 'FROST', 'GRAVITY', 'HORIZON',
  'IGNIS', 'JET', 'KILO', 'LASER', 'MAGNET', 'NITRO', 'OCTA', 'PIXEL',
  'RADAR', 'STROBE', 'TITAN', 'VAPOR',
];
const RAPPERS = [
  'YANO', 'SWERVE', 'VICE', 'NOVA', 'RAWKID', 'BLAZE', 'OG TANG', 'ZICO',
  'TONE', 'MONO', 'KASH', 'VERSE', 'NEON', 'GHOST', 'DOPE K', 'LOUD',
  'PAYBACK', 'SKRT', 'TRILL', 'UZI J', 'WAVY', 'YOUNG C', 'ZEAL', 'BARZ',
  'CIPHER', 'DRIP', 'FLOWZ', 'GRIT', 'HOOK', 'ILL M', 'JAWS', 'KRUSH',
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

// ── 결정적 난수 ──────────────────────────────────────────────
// 문자열 시드 → 32bit 해시 → mulberry32. 같은 시드면 항상 같은 수열.
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

// ── 날짜 유틸 (KST 기준) ─────────────────────────────────────
const DAY_KEYS = ['sun', 'mon', 'tue', 'wed', 'thu', 'fri', 'sat'];

function kstToday() {
  const k = new Date(Date.now() + 9 * 3600 * 1000);
  return `${k.getUTCFullYear()}${String(k.getUTCMonth() + 1).padStart(2, '0')}${String(k.getUTCDate()).padStart(2, '0')}`;
}

function parseYmd(s) {
  return { y: +s.slice(0, 4), m: +s.slice(4, 6), d: +s.slice(6, 8) };
}

function ymd(y, m, d) {
  return `${y}${String(m).padStart(2, '0')}${String(d).padStart(2, '0')}`;
}

// dateStr 의 요일 키('mon'…). 자정 UTC 로 만들어 요일만 본다(시간대 영향 없음).
function dayKeyOf(dateStr) {
  const { y, m, d } = parseYmd(dateStr);
  return DAY_KEYS[new Date(Date.UTC(y, m - 1, d)).getUTCDay()];
}

// 그 날짜가 속한 주(월요일 시작)의 월요일 YYYYMMDD — 주 단위 그룹 키.
function weekKeyOf(dateStr) {
  const { y, m, d } = parseYmd(dateStr);
  const dt = new Date(Date.UTC(y, m - 1, d));
  const dow = dt.getUTCDay();            // 0=일
  const back = (dow + 6) % 7;            // 월요일까지 되감기
  dt.setUTCDate(dt.getUTCDate() - back);
  return ymd(dt.getUTCFullYear(), dt.getUTCMonth() + 1, dt.getUTCDate());
}

function eachDate(fromStr, toStr) {
  const a = parseYmd(fromStr), b = parseYmd(toStr);
  const out = [];
  const cur = new Date(Date.UTC(a.y, a.m - 1, a.d));
  const end = new Date(Date.UTC(b.y, b.m - 1, b.d));
  while (cur <= end) {
    out.push(ymd(cur.getUTCFullYear(), cur.getUTCMonth() + 1, cur.getUTCDate()));
    cur.setUTCDate(cur.getUTCDate() + 1);
  }
  return out;
}

// 밤 날짜(YYYYMMDD) + KST 시각(시,분) → UTC ISO. 새벽(시<12)은 달력상 +1일.
function nightSlotToIso(dateStr, hour, min) {
  const { y, m, d } = parseYmd(dateStr);
  const dayOffset = hour < 12 ? 1 : 0;
  const utcMs = Date.UTC(y, m - 1, d + dayOffset, hour, min) - 9 * 3600 * 1000;
  return new Date(utcMs).toISOString();
}

// ── Firestore ────────────────────────────────────────────────
// 대상 장르 클럽 수집 (id·name·area·genre·영업 요일).
async function listTargetClubs(token) {
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
      const genre = f.genre?.stringValue || '';
      if (!TARGET_GENRES.includes(genre)) continue;
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
        genre,
        openDays,
      });
    }
    pageToken = json.nextPageToken || '';
  } while (pageToken);
  return clubs;
}

async function listPerformanceIds(token) {
  const ids = [];
  let pageToken = '';
  do {
    const qs = `pageSize=300&mask.fieldPaths=performanceId${pageToken ? `&pageToken=${encodeURIComponent(pageToken)}` : ''}`;
    const res = await fsReq(
      token, 'GET',
      `/v1/projects/${PROJECT}/databases/(default)/documents/performances?${qs}`
    );
    if (res.status !== 200) throw new Error(`list performances failed: ${res.status} ${res.body}`);
    const json = JSON.parse(res.body);
    for (const doc of json.documents || []) ids.push(doc.name.split('/').pop());
    pageToken = json.nextPageToken || '';
  } while (pageToken);
  return ids;
}

async function deletePerformance(token, id) {
  const res = await fsReq(
    token, 'DELETE',
    `/v1/projects/${PROJECT}/databases/(default)/documents/performances/${id}`
  );
  if (res.status !== 200) throw new Error(`delete failed: ${res.status} ${res.body}`);
}

// documentId 지정 PATCH = upsert → 재실행 시 같은 doc 덮어쓰기(멱등).
async function upsertPerformance(token, p) {
  const body = JSON.stringify({
    fields: {
      performanceId: { stringValue: p.id },
      clubId: { stringValue: p.clubId },
      clubName: { stringValue: p.clubName },
      clubArea: { stringValue: p.clubArea },
      genre: { stringValue: p.genre },
      artistName: { stringValue: p.artistName },
      artistType: { stringValue: p.artistType },
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
  if (res.status !== 200) throw new Error(`upsert performance failed: ${res.status} ${res.body}`);
}

// ── 배정 ─────────────────────────────────────────────────────
function buildPlan(clubs, today) {
  // 1) 후보 날짜 = 오늘~9/30 중 **대상 클럽 다수가 영업하는 요일**(현재 DB 기준 목·금·토).
  //    전 요일 영업인 예외 클럽 1~2곳 때문에 월·화·수·일이 후보에 섞이면,
  //    주별 휴무일 추첨이 애초에 아무도 안 여는 날에 걸려 규칙이 무의미해진다.
  const dayOpenCount = {};
  for (const c of clubs) for (const d of c.openDays) dayOpenCount[d] = (dayOpenCount[d] || 0) + 1;
  const openDayKeys = new Set(
    Object.keys(dayOpenCount).filter((d) => dayOpenCount[d] >= clubs.length * COMMON_DAY_RATIO)
  );

  const candidates = eachDate(today, END_DATE).filter((d) => openDayKeys.has(dayKeyOf(d)));

  // 2) 주별로 랜덤 휴무일 1일 제외 (그 주 영업일이 3일 이상일 때만).
  const byWeek = {};
  for (const d of candidates) (byWeek[weekKeyOf(d)] ||= []).push(d);

  const restDays = new Set();
  for (const wk of Object.keys(byWeek).sort()) {
    const days = byWeek[wk];
    if (days.length < 3) continue; // 부분 주(첫 주·마지막 주)는 그대로 둔다
    const rnd = rngFrom(`rest_${wk}`);
    restDays.add(days[Math.floor(rnd() * days.length)]);
  }

  const showDates = candidates.filter((d) => !restDays.has(d));

  // 3) 날짜 × 클럽 × 아티스트.
  const plan = [];
  for (const date of showDates) {
    const dayKey = dayKeyOf(date);
    const openClubs = clubs.filter((c) => c.openDays.has(dayKey));

    // 그 밤에 공연하는 클럽 — 클럽·날짜 해시로 결정적 선택.
    const performing = openClubs.filter(
      (c) => rngFrom(`night_${c.id}_${date}`)() < CLUB_NIGHT_RATIO
    );

    // 밤 단위 아티스트 풀 — 같은 이름이 같은 날 두 클럽에 서지 않게 소진식으로 뽑는다.
    const nightRnd = rngFrom(`pool_${date}`);
    const djPool = shuffled(DJS, nightRnd);
    const rapPool = shuffled(RAPPERS, nightRnd);
    let djIdx = 0, rapIdx = 0;
    const takeDj = () => ({ name: djPool[djIdx++ % djPool.length], type: 'dj' });
    const takeRapper = () => ({ name: rapPool[rapIdx++ % rapPool.length], type: 'rapper' });

    // hero 노출 클럽 — 날짜별 랜덤 N곳.
    const featured = new Set(
      shuffled(performing.map((c) => c.id), rngFrom(`feat_${date}`)).slice(0, FEATURED_PER_DATE)
    );

    for (const c of performing) {
      const rnd = rngFrom(`set_${c.id}_${date}`);
      const count = 1 + Math.floor(rnd() * MAX_ARTISTS_PER_NIGHT); // 1~3팀

      // 힙합: dj + rapper 혼합(2팀 이상이면 양쪽 최소 1팀 보장) / EDM: dj만.
      const types = [];
      if (c.genre === 'EDM') {
        for (let i = 0; i < count; i++) types.push('dj');
      } else if (count === 1) {
        types.push(rnd() < 0.5 ? 'dj' : 'rapper');
      } else {
        types.push('dj', 'rapper');
        for (let i = 2; i < count; i++) types.push(rnd() < 0.5 ? 'dj' : 'rapper');
        // 오프닝 dj → 헤드라이너 래퍼 같은 고정 순서를 피해 섞는다.
        const mixed = shuffled(types, rnd);
        types.length = 0;
        types.push(...mixed);
      }

      // 시작 시각: 첫 팀 22:00~23:30(10분 단위), 이후 60~90분 간격.
      let totalMin = 22 * 60 + Math.floor(rnd() * 10) * 10;
      types.forEach((type, n) => {
        if (n > 0) totalMin += 60 + Math.floor(rnd() * 4) * 10;
        const hour = Math.floor(totalMin / 60) % 24;
        const min = totalMin % 60;
        const a = type === 'dj' ? takeDj() : takeRapper();
        plan.push({
          id: `perf_${c.id}_${date}_${n}`,
          clubId: c.id, clubName: c.name, clubArea: c.area, genre: c.genre,
          artistName: a.name, artistType: a.type,
          date,
          startAtIso: nightSlotToIso(date, hour, min),
          slot: `${String(hour).padStart(2, '0')}:${String(min).padStart(2, '0')}`,
          // hero 는 클럽의 첫 공연 1건만.
          isFeatured: n === 0 && featured.has(c.id),
        });
      });
    }
  }

  return { plan, candidates, showDates, restDays, commonDays: openDayKeys };
}

async function run() {
  const token = execSync('gcloud auth print-access-token').toString().trim();
  const clubs = await listTargetClubs(token);
  const today = kstToday();

  const byGenre = {};
  for (const c of clubs) byGenre[c.genre] = (byGenre[c.genre] || 0) + 1;

  const { plan, candidates, showDates, restDays, commonDays } = buildPlan(clubs, today);

  console.log(`대상 클럽 ${clubs.length}개 — ${Object.entries(byGenre).map(([g, n]) => `${g} ${n}`).join(' / ')}`);
  console.log(`기간 ${today} ~ ${END_DATE}`);
  console.log(`공연 후보 요일: ${[...commonDays].join(' ')}`);
  console.log(`영업 후보일 ${candidates.length}일 → 휴무 ${restDays.size}일 → 공연일 ${showDates.length}일`);
  console.log(`휴무일: ${[...restDays].sort().map((d) => `${d}(${dayKeyOf(d)})`).join(' ')}`);
  console.log(`공연 doc ${plan.length}개\n`);

  // 날짜별 요약.
  const perDate = {};
  for (const p of plan) {
    const e = (perDate[p.date] ||= { docs: 0, clubs: new Set(), dj: 0, rapper: 0 });
    e.docs++; e.clubs.add(p.clubId); e[p.artistType]++;
  }
  for (const d of showDates) {
    const e = perDate[d];
    if (!e) { console.log(`  ${d}(${dayKeyOf(d)})  공연 없음`); continue; }
    console.log(`  ${d}(${dayKeyOf(d)})  클럽 ${e.clubs.size} · 공연 ${e.docs} (dj ${e.dj} / rapper ${e.rapper})`);
  }

  // 검증 — 장르별 artistType 규칙.
  const genreOf = Object.fromEntries(clubs.map((c) => [c.id, c.genre]));
  const badEdm = plan.filter((p) => genreOf[p.clubId] === 'EDM' && p.artistType !== 'dj');
  if (badEdm.length) throw new Error(`EDM 클럽에 dj 아닌 공연 ${badEdm.length}건`);

  const hipClubNights = {};
  for (const p of plan) {
    if (genreOf[p.clubId] !== '힙합') continue;
    (hipClubNights[`${p.clubId}_${p.date}`] ||= new Set()).add(p.artistType);
  }
  const hipTypes = new Set();
  for (const s of Object.values(hipClubNights)) for (const t of s) hipTypes.add(t);
  if (!(hipTypes.has('dj') && hipTypes.has('rapper'))) {
    throw new Error(`힙합 클럽 artistType 이 dj·rapper 두 종류가 아님: ${[...hipTypes]}`);
  }

  // 검증 — 문 닫은 날 공연이 없는지.
  const openDaysOf = Object.fromEntries(clubs.map((c) => [c.id, c.openDays]));
  const closedDayPerf = plan.filter((p) => !openDaysOf[p.clubId].has(dayKeyOf(p.date)));
  if (closedDayPerf.length) throw new Error(`휴무일 공연 ${closedDayPerf.length}건`);

  // 검증 — 같은 밤 같은 아티스트가 두 곳에 서지 않는지.
  const nightArtist = {};
  const clash = [];
  for (const p of plan) {
    const key = `${p.date}_${p.artistName}`;
    if (nightArtist[key] && nightArtist[key] !== p.clubId) clash.push(key);
    nightArtist[key] = p.clubId;
  }
  if (clash.length) console.log(`\n⚠ 같은 밤 아티스트 중복 ${clash.length}건 (풀 소진 — 허용)`);

  console.log(`\n✓ 검증 통과 — EDM=dj만, 힙합=dj+rapper, 전부 영업일 안`);

  if (DRY) {
    console.log('\n(dry run — 쓰기 없음)');
    return;
  }

  if (PURGE) {
    const ids = await listPerformanceIds(token);
    for (let i = 0; i < ids.length; i++) {
      await deletePerformance(token, ids[i]);
      if ((i + 1) % 50 === 0 || i === ids.length - 1) console.log(`삭제 ${i + 1}/${ids.length}`);
    }
    console.log(`기존 performances ${ids.length}개 삭제 완료\n`);
  }

  for (let i = 0; i < plan.length; i++) {
    await upsertPerformance(token, plan[i]);
    if ((i + 1) % 50 === 0 || i === plan.length - 1) {
      console.log(`[${i + 1}/${plan.length}] 진행중...`);
    }
  }
  console.log(`\n완료 — 공연 ${plan.length}개 / 공연일 ${showDates.length}일`);
}

run().catch((e) => {
  console.error(e);
  process.exit(1);
});
