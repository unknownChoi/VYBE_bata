// performances/{performanceId} 공연 일정 시드 — 장르 페이지(힙합) 데이터.
//
// 동작:
//   1) genre==="힙합" 클럽 수집 → 지역별 그룹.
//   2) 지역별 "절반" 클럽만 공연 데이터 추가 (평점순 상위 절반).
//      - 모든 공연 startAt(시각)은 전역에서 유일 (요구사항: 모든 공연 일정이 달라야 함).
//      - 멀티-날짜: 대상 중 일부는 오늘 + 내일 공연 doc 2개.
//   3) hero용 isFeatured 는 '오늘' 공연 중 일부만 true.
//
// 멱등성: performanceId 를 결정적으로 생성(perf_<clubId>_<date>) → 재실행해도 같은 doc 덮어씀.
//
// 실행: gcloud 로그인 상태에서  node scripts/seed_performances.js
//   --dry : 쓰지 않고 배정 결과만 출력

const { execSync } = require('child_process');
const https = require('https');

const PROJECT = 'vybe-bata-c07aa';
const DRY = process.argv.includes('--dry');
const GENRE = '힙합';


// 라인업 아티스트 풀 (이름 전역 유일, rapper/dj 혼합).
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

// genre==="힙합" 클럽 수집 (id·name·area·rating).
async function listHipHopClubs(token) {
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
      if ((f.genre?.stringValue || '') !== GENRE) continue;
      clubs.push({
        id: doc.name.split('/').pop(),
        name: f.name?.stringValue || '',
        area: f.area?.stringValue || '',
        rating: parseFloat(f.rating?.doubleValue ?? f.rating?.integerValue ?? '0'),
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
      genre: { stringValue: GENRE },
      artistName: { stringValue: p.artistName },
      artistType: { stringValue: p.artistType },
      startAt: { timestampValue: p.startAtIso },
      date: { stringValue: p.date },
      isFeatured: { booleanValue: p.isFeatured },
      isActive: { booleanValue: true },
      createdAt: { timestampValue: new Date().toISOString() },
    },
  });
  // documentId 지정 PATCH = upsert.
  const res = await fsReq(
    token, 'PATCH',
    `/v1/projects/${PROJECT}/databases/(default)/documents/performances/${p.id}`,
    body
  );
  if (res.status !== 200) throw new Error(`upsert performance failed: ${res.status} ${res.body}`);
}

// KST 기준 YYYYMMDD.
function kstDateStr(d) {
  const k = new Date(d.getTime() + 9 * 3600 * 1000);
  return `${k.getUTCFullYear()}${String(k.getUTCMonth() + 1).padStart(2, '0')}${String(k.getUTCDate()).padStart(2, '0')}`;
}

// 밤 날짜(YYYYMMDD) + 시각(시,분) → UTC ISO. 새벽(시<12)은 달력상 +1일.
function nightSlotToIso(dateStr, hour, min) {
  const y = +dateStr.slice(0, 4), mo = +dateStr.slice(4, 6), da = +dateStr.slice(6, 8);
  // KST 벽시계 → UTC: -9h. Date.UTC 로 만든 뒤 보정.
  let baseDay = da;
  // 새벽 시간대는 다음 날 달력.
  const dayOffset = hour < 12 ? 1 : 0;
  const utcMs = Date.UTC(y, mo - 1, baseDay + dayOffset, hour, min) - 9 * 3600 * 1000;
  return new Date(utcMs).toISOString();
}

async function run() {
  const token = execSync('gcloud auth print-access-token').toString().trim();
  const clubs = await listHipHopClubs(token);

  // 지역별 그룹 + 평점 내림차순.
  const byArea = {};
  for (const c of clubs) (byArea[c.area] ||= []).push(c);
  for (const a of Object.keys(byArea)) byArea[a].sort((x, y) => y.rating - x.rating);

  const today = kstDateStr(new Date());
  const tomorrow = kstDateStr(new Date(Date.now() + 24 * 3600 * 1000));

  // 전역 유일 시각 풀: 21:30 부터 11분 간격 (HH:MM 중복 없음).
  let slotIdx = 0;
  const nextSlot = () => {
    const totalMin = 21 * 60 + 30 + slotIdx * 11; // 21:30 시작
    slotIdx++;
    const hour = Math.floor(totalMin / 60) % 24;
    const min = totalMin % 60;
    return { hour, min };
  };

  let artistIdx = 0;
  const nextArtist = () => ARTISTS[artistIdx++ % ARTISTS.length];

  const perfPlan = [];

  for (const area of Object.keys(byArea)) {
    const list = byArea[area];
    // 지역별 절반(평점 상위)만 공연 추가.
    const half = Math.round(list.length / 2);
    const targets = list.slice(0, half);
    targets.forEach((c, i) => {
      // 오늘 공연 1건.
      const aToday = nextArtist();
      const sToday = nextSlot();
      perfPlan.push({
        id: `perf_${c.id}_${today}`,
        clubId: c.id, clubName: c.name, clubArea: area,
        artistName: aToday.name, artistType: aToday.type,
        date: today,
        startAtIso: nightSlotToIso(today, sToday.hour, sToday.min),
        slot: `${String(sToday.hour).padStart(2, '0')}:${String(sToday.min).padStart(2, '0')}`,
        isFeatured: i === 0, // 지역별 1위 클럽만 hero featured
      });
      // 멀티-날짜 데모: 지역 1위 클럽은 내일 공연도 추가.
      if (i === 0) {
        const aTom = nextArtist();
        const sTom = nextSlot();
        perfPlan.push({
          id: `perf_${c.id}_${tomorrow}`,
          clubId: c.id, clubName: c.name, clubArea: area,
          artistName: aTom.name, artistType: aTom.type,
          date: tomorrow,
          startAtIso: nightSlotToIso(tomorrow, sTom.hour, sTom.min),
          slot: `${String(sTom.hour).padStart(2, '0')}:${String(sTom.min).padStart(2, '0')}`,
          isFeatured: false, // hero는 오늘만
        });
      }
    });
  }

  console.log(`힙합 클럽 ${clubs.length}개 / 지역 ${Object.keys(byArea).length}곳`);
  for (const a of Object.keys(byArea)) {
    const n = byArea[a].length;
    console.log(`  ${a}: ${n}개 → 공연 ${Math.round(n / 2)}개 클럽`);
  }
  console.log(`공연 doc ${perfPlan.length}개 (today=${today}, tomorrow=${tomorrow})\n`);

  // 시각 전역 유일성 검증.
  const slots = perfPlan.map((p) => p.slot);
  const dup = slots.filter((s, i) => slots.indexOf(s) !== i);
  if (dup.length) throw new Error(`시각 중복 발생: ${dup.join(', ')}`);
  console.log(`✓ 모든 공연 시각 유일 (${slots.length}건)\n`);

  if (DRY) {
    for (const p of perfPlan) {
      console.log(`  ${p.date} ${p.slot}  ${p.clubArea}/${p.clubName}  ${p.artistName}(${p.artistType})${p.isFeatured ? '  ★hero' : ''}`);
    }
    console.log('\n(dry run — 쓰기 없음)');
    return;
  }

  // 공연 doc 쓰기.
  for (let i = 0; i < perfPlan.length; i++) {
    await upsertPerformance(token, perfPlan[i]);
    const p = perfPlan[i];
    console.log(`[${i + 1}/${perfPlan.length}] ${p.date} ${p.slot}  ${p.clubArea}/${p.clubName}  ${p.artistName}${p.isFeatured ? '  ★' : ''}`);
  }
  console.log(`\n완료 — 공연 ${perfPlan.length}개`);
}

run().catch((e) => {
  console.error(e);
  process.exit(1);
});
