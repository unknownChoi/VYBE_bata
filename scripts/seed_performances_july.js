// performances/{performanceId} — 7월 공연 데이터 시드 (전체 클럽 대상).
//
// 요구사항:
//   - 모든 클럽(장르 무관)에 공연 추가.
//   - 클럽마다 공연 "날짜" 3개 (7월 중 랜덤 3일).
//   - 하루 아티스트 공연 수는 랜덤(1~4건).
//
// 문서 1개 = (클럽 × 날짜 × 아티스트). performanceId = perf_<clubId>_<date>_<n> (결정적 → 멱등).
// genre 는 각 클럽의 genre 사용(장르 페이지 크로스-클럽 쿼리 유지).
// startAt 시각은 전역 유일(21:30부터 11분 간격 증가) — 데모 변별용.
//
// 실행: gcloud 로그인 상태에서  node scripts/seed_performances_july.js
//   --dry : 쓰지 않고 배정 결과만 출력

const { execSync } = require('child_process');
const https = require('https');

const PROJECT = 'vybe-bata-c07aa';
const DRY = process.argv.includes('--dry');

const YEAR = 2026;
const MONTH = 7; // 7월
const DATES_PER_CLUB = 3; // 클럽당 공연 날짜 수
const MAX_ARTISTS_PER_DAY = 4; // 하루 최대 아티스트 공연 수(1~MAX 랜덤)

// 라인업 아티스트 풀 (rapper/dj 혼합).
const ARTISTS = [
  { name: 'YANO', type: 'rapper' }, { name: 'GRIM', type: 'dj' },
  { name: 'SWERVE', type: 'rapper' }, { name: 'KODA', type: 'dj' },
  { name: 'VICE', type: 'rapper' }, { name: 'ECHO', type: 'dj' },
  { name: 'NOVA', type: 'rapper' }, { name: 'RAWKID', type: 'rapper' },
  { name: 'BLAZE', type: 'rapper' }, { name: 'OG TANG', type: 'rapper' },
  { name: 'FLASH', type: 'dj' }, { name: 'ZICO', type: 'rapper' },
  { name: 'PEAK', type: 'dj' }, { name: 'TONE', type: 'rapper' },
  { name: 'HALO', type: 'dj' }, { name: 'DRIFT', type: 'dj' },
  { name: 'MONO', type: 'rapper' }, { name: 'PULSE', type: 'dj' },
  { name: 'KASH', type: 'rapper' }, { name: 'VERSE', type: 'rapper' },
  { name: 'SAGE', type: 'dj' }, { name: 'RIFT', type: 'dj' },
  { name: 'NEON', type: 'rapper' }, { name: 'GHOST', type: 'rapper' },
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

// 전체 클럽 수집 (id·name·area·genre).
async function listAllClubs(token) {
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
      clubs.push({
        id: doc.name.split('/').pop(),
        name: f.name?.stringValue || '',
        area: f.area?.stringValue || '',
        genre: f.genre?.stringValue || '',
      });
    }
    pageToken = json.nextPageToken || '';
  } while (pageToken);
  return clubs;
}

// performanceId 결정적 → 재실행 시 같은 doc 덮어쓰기(멱등).
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

// 밤 날짜(YYYYMMDD) + 시각(시,분) → UTC ISO. 새벽(시<12)은 달력상 +1일.
function nightSlotToIso(dateStr, hour, min) {
  const y = +dateStr.slice(0, 4), mo = +dateStr.slice(4, 6), da = +dateStr.slice(6, 8);
  const dayOffset = hour < 12 ? 1 : 0;
  const utcMs = Date.UTC(y, mo - 1, da + dayOffset, hour, min) - 9 * 3600 * 1000;
  return new Date(utcMs).toISOString();
}

function ymd(y, m, d) {
  return `${y}${String(m).padStart(2, '0')}${String(d).padStart(2, '0')}`;
}

// 배열에서 랜덤 n개(중복 없음) 뽑아 정렬.
function pickDistinct(pool, n) {
  const arr = [...pool];
  for (let i = arr.length - 1; i > 0; i--) {
    const j = Math.floor(Math.random() * (i + 1));
    [arr[i], arr[j]] = [arr[j], arr[i]];
  }
  return arr.slice(0, n).sort((a, b) => a - b);
}

async function run() {
  const token = execSync('gcloud auth print-access-token').toString().trim();
  const clubs = await listAllClubs(token);

  const daysInMonth = new Date(YEAR, MONTH, 0).getDate(); // 7월=31
  const allDays = Array.from({ length: daysInMonth }, (_, i) => i + 1);

  // 전역 유일 시각 풀: 21:30 부터 11분 간격.
  let slotIdx = 0;
  const nextSlot = () => {
    const totalMin = 21 * 60 + 30 + slotIdx * 11;
    slotIdx++;
    const hour = Math.floor(totalMin / 60) % 24;
    const min = totalMin % 60;
    return { hour, min };
  };

  let artistIdx = 0;
  const nextArtist = () => ARTISTS[artistIdx++ % ARTISTS.length];

  const perfPlan = [];
  for (const c of clubs) {
    const dates = pickDistinct(allDays, DATES_PER_CLUB); // 랜덤 3일
    dates.forEach((day, di) => {
      const dateStr = ymd(YEAR, MONTH, day);
      const count = 1 + Math.floor(Math.random() * MAX_ARTISTS_PER_DAY); // 1~MAX
      for (let n = 0; n < count; n++) {
        const a = nextArtist();
        const s = nextSlot();
        perfPlan.push({
          id: `perf_${c.id}_${dateStr}_${n}`,
          clubId: c.id, clubName: c.name, clubArea: c.area, genre: c.genre,
          artistName: a.name, artistType: a.type,
          date: dateStr,
          startAtIso: nightSlotToIso(dateStr, s.hour, s.min),
          slot: `${String(s.hour).padStart(2, '0')}:${String(s.min).padStart(2, '0')}`,
          // 클럽 첫 날짜의 첫 공연만 hero featured.
          isFeatured: di === 0 && n === 0,
        });
      }
    });
  }

  console.log(`전체 클럽 ${clubs.length}개`);
  console.log(`공연 doc ${perfPlan.length}개 (클럽당 날짜 ${DATES_PER_CLUB}, 하루 1~${MAX_ARTISTS_PER_DAY}건 랜덤)\n`);

  if (DRY) {
    for (const p of perfPlan) {
      console.log(`  ${p.date} ${p.slot}  [${p.genre}] ${p.clubArea}/${p.clubName}  ${p.artistName}(${p.artistType})${p.isFeatured ? '  ★hero' : ''}`);
    }
    console.log('\n(dry run — 쓰기 없음)');
    return;
  }

  for (let i = 0; i < perfPlan.length; i++) {
    await upsertPerformance(token, perfPlan[i]);
    const p = perfPlan[i];
    if ((i + 1) % 20 === 0 || i === perfPlan.length - 1) {
      console.log(`[${i + 1}/${perfPlan.length}] 진행중...`);
    }
  }
  console.log(`\n완료 — 공연 ${perfPlan.length}개`);
}

run().catch((e) => {
  console.error(e);
  process.exit(1);
});
