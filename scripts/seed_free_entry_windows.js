// clubs/{id} 문서에 freeEntry(map) + isFreeEntry(bool) 필드 추가 — 시간대별 무료입장 데이터.
//
// freeEntry : { type: "none"|"always"|"timed", condition: string, windows: [{days,start,end,label}] }
//   type='always' : 기존 상시 무료 클럽(entryFeeMin=0). condition 은 freeEntryCondition 을 그대로 승계
//   type='timed'  : 특정 시간대만 무료. 그 외 시간엔 entryFeeMin~entryFeeMax 일반 입장비
//   type='none'   : 무료 없음
// isFreeEntry : (type !== 'none') 파생값 — 입장비 무료 페이지 쿼리·검색 필터·Algolia 전용.
//   ⚠ freeEntry 를 쓰는 쪽이 반드시 같이 쓴다 (트리거 없음)
//
// timed 배정 규칙: 지역별로 유료 클럽(entryFeeMin>0)의 **절반**.
//   - 상시 무료(entryFeeMin=0) 클럽은 후보에서 제외 — timed 는 entryFeeMin 이 '평상시 요금'이어야 한다
//   - 선정·시간대 모두 clubId 해시 기반 → 몇 번을 돌려도 같은 클럽은 같은 결과
//
// ⚠ 창(window)은 전부 영업시간(목·금·토 22:00~06:00, 토 05:00) 안에 둔다.
//   밖에 두면 '지금 무료'가 영영 안 뜬다 (무료 뱃지는 영업 중일 때만 표시하는 규칙 때문).
//
// 실행: gcloud 로그인 상태에서  node scripts/seed_free_entry_windows.js
//   --force : 이미 freeEntry 있는 클럽도 다시 배정(기본은 skip)
//   --dry   : 쓰지 않고 배정 결과만 출력

const { execSync } = require('child_process');
const https = require('https');

const PROJECT = 'vybe-bata-c07aa';
const FORCE = process.argv.includes('--force');
const DRY = process.argv.includes('--dry');

// 시간대 무료입장 패턴 풀. days 는 operatingHours 와 같은 키(mon..sun), 빈 배열이면 매일.
// start 포함 · end 미포함 · end <= start 면 자정을 넘긴다.
const PATTERNS = [
  {
    cond: '오픈런 1시간 30분 무료입장',
    windows: [{ days: ['thu', 'fri', 'sat'], start: '22:00', end: '23:30', label: '오픈런' }],
  },
  {
    cond: '자정 이전 입장 무료',
    // end='00:00' 은 자정 넘김 분기로 들어가 [22:00,24:00) 로 평가된다 (의도된 표기).
    windows: [{ days: ['thu', 'fri', 'sat'], start: '22:00', end: '00:00', label: '자정 전' }],
  },
  {
    cond: '새벽 2시 이후 무료입장',
    windows: [{ days: ['fri', 'sat'], start: '02:00', end: '05:00', label: '심야' }],
  },
  {
    cond: '23시~1시 무료입장',
    windows: [{ days: ['thu', 'fri', 'sat'], start: '23:00', end: '01:00', label: '막차 타임' }],
  },
  {
    cond: '목요일 전 시간대 무료',
    windows: [{ days: ['thu'], start: '22:00', end: '06:00', label: '목요일 전일' }],
  },
  {
    cond: '오픈 직후·새벽 2타임 무료',
    windows: [
      { days: ['fri', 'sat'], start: '22:00', end: '23:00', label: '오픈 타임' },
      { days: ['fri', 'sat'], start: '03:00', end: '05:00', label: '새벽 타임' },
    ],
  },
  {
    cond: '목·금 자정 전 무료입장',
    windows: [{ days: ['thu', 'fri'], start: '22:00', end: '00:00', label: '자정 전' }],
  },
  {
    cond: '토요일 새벽 1시 이후 무료',
    windows: [{ days: ['sat'], start: '01:00', end: '05:00', label: '토요일 심야' }],
  },
  {
    cond: '오픈 1시간 한정 무료',
    // days 빈 배열 = 매일. 영업일이 목·금·토뿐이라 실질 효과는 같지만 '매일' 경로도 데이터에 넣어 둔다.
    windows: [{ days: [], start: '22:00', end: '23:00', label: '오픈 1시간' }],
  },
  {
    cond: '금·토 새벽 3시 이후 무료',
    windows: [{ days: ['fri', 'sat'], start: '03:00', end: '05:00', label: '새벽' }],
  },
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

// 모든 클럽 문서 페이지네이션 수집.
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
      const f = doc.fields || {};
      clubs.push({
        id: doc.name.split('/').pop(),
        name: f.name?.stringValue || '',
        area: f.area?.stringValue || '',
        entryFeeMin: parseInt(f.entryFeeMin?.integerValue ?? '0', 10),
        entryFeeMax: parseInt(f.entryFeeMax?.integerValue ?? '0', 10),
        isActive: f.isActive?.booleanValue === true,
        condition: f.freeEntryCondition?.stringValue || '',
        has: f.freeEntry !== undefined,
      });
    }
    pageToken = json.nextPageToken || '';
  } while (pageToken);
  return clubs;
}

// clubId 문자열 해시 — 같은 클럽은 몇 번을 돌려도 같은 결과.
function hash(s) {
  let h = 0;
  for (let i = 0; i < s.length; i++) h = (h * 31 + s.charCodeAt(i)) >>> 0;
  return h;
}

// { type, condition, windows } → Firestore REST mapValue
function encodeFreeEntry(policy) {
  return {
    mapValue: {
      fields: {
        type: { stringValue: policy.type },
        condition: { stringValue: policy.condition },
        windows: {
          arrayValue: {
            values: policy.windows.map((w) => ({
              mapValue: {
                fields: {
                  days: { arrayValue: { values: w.days.map((d) => ({ stringValue: d })) } },
                  start: { stringValue: w.start },
                  end: { stringValue: w.end },
                  label: { stringValue: w.label || '' },
                },
              },
            })),
          },
        },
      },
    },
  };
}

async function setFreeEntry(token, clubId, policy) {
  const body = JSON.stringify({
    fields: {
      freeEntry: encodeFreeEntry(policy),
      isFreeEntry: { booleanValue: policy.type !== 'none' },
    },
  });
  const res = await fsReq(
    token,
    'PATCH',
    `/v1/projects/${PROJECT}/databases/(default)/documents/clubs/${clubId}` +
      '?updateMask.fieldPaths=freeEntry&updateMask.fieldPaths=isFreeEntry',
    body
  );
  if (res.status !== 200) throw new Error(`patch failed: ${res.status} ${res.body}`);
}

function summarize(windows) {
  return windows.map((w) => `${w.days.length ? w.days.join('·') : '매일'} ${w.start}~${w.end}`).join(' + ');
}

async function run() {
  const token = execSync('gcloud auth print-access-token').toString().trim();
  const clubs = await listClubs(token);
  const active = clubs.filter((c) => c.isActive);

  // 지역별로 유료 클럽의 절반을 timed 로 뽑는다 (해시 순 앞쪽 절반 = 실행마다 동일).
  const timedIds = new Set();
  const byArea = {};
  for (const c of active) (byArea[c.area] ??= []).push(c);

  const areaStat = [];
  for (const [area, list] of Object.entries(byArea)) {
    const paid = list
      .filter((c) => c.entryFeeMin > 0)
      .sort((a, b) => hash(a.id) - hash(b.id));
    const take = Math.round(paid.length / 2);
    paid.slice(0, take).forEach((c) => timedIds.add(c.id));
    areaStat.push({
      area,
      total: list.length,
      always: list.filter((c) => c.entryFeeMin === 0).length,
      paid: paid.length,
      timed: take,
    });
  }

  const policyOf = (c) => {
    if (c.entryFeeMin === 0) {
      return { type: 'always', condition: c.condition, windows: [] };
    }
    if (timedIds.has(c.id)) {
      // 선정에 쓴 해시를 그대로 나누면 패턴이 한쪽으로 쏠린다 — 소금을 섞어 분리한다.
      const p = PATTERNS[hash(`${c.id}#window`) % PATTERNS.length];
      return { type: 'timed', condition: p.cond, windows: p.windows };
    }
    return { type: 'none', condition: '', windows: [] };
  };

  const targets = FORCE ? clubs : clubs.filter((c) => !c.has);

  console.log(`클럽 ${clubs.length}개 / active ${active.length}개 / 대상 ${targets.length}개 (skip ${clubs.length - targets.length})\n`);
  console.log('지역별 배정');
  for (const s of areaStat.sort((a, b) => b.total - a.total)) {
    console.log(
      `  ${s.area.padEnd(6)} 전체 ${String(s.total).padStart(3)}  상시무료 ${String(s.always).padStart(3)}  유료 ${String(s.paid).padStart(3)}  → timed ${String(s.timed).padStart(3)}`
    );
  }
  console.log('');

  const count = { always: 0, timed: 0, none: 0 };
  for (let i = 0; i < targets.length; i++) {
    const c = targets[i];
    const policy = policyOf(c);
    count[policy.type]++;

    const line =
      policy.type === 'timed'
        ? `${policy.type.padEnd(6)} ${summarize(policy.windows)}  "${policy.condition}"`
        : policy.type.padEnd(6);

    if (DRY) {
      console.log(`  ${c.area.padEnd(4)} ${c.id.slice(0, 8)}… ${line}  ${c.name}`);
      continue;
    }
    await setFreeEntry(token, c.id, policy);
    console.log(`[${i + 1}/${targets.length}] ${c.area.padEnd(4)} ${c.id.slice(0, 8)}… ${line}  ${c.name}`);
  }

  console.log(
    `\n완료 — always ${count.always} / timed ${count.timed} / none ${count.none}${DRY ? ' (dry run)' : ''}`
  );
}

run().catch((e) => {
  console.error(e);
  process.exit(1);
});
