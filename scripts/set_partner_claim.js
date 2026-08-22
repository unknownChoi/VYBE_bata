// 업주(파트너) 계정에 커스텀 클레임을 심는다 — `{ partner: true, clubIds: [...] }`.
//
// 이 클레임이 있어야 파트너 웹에서 `clubs/{clubId}/tableLayout/{clubId}` 를 쓸 수 있다
// (firestore.rules 참고). 클럽은 클레임에 적힌 것만 — 남의 클럽은 못 건드린다.
//
// 실행: gcloud 로그인 상태에서
//   node scripts/set_partner_claim.js --uid=abc123 --clubs=clubA,clubB
//   node scripts/set_partner_claim.js --email=owner@example.com --clubs=clubA
//   node scripts/set_partner_claim.js --uid=abc123 --revoke   (파트너 권한 회수)
//   node scripts/set_partner_claim.js --uid=abc123 --show     (현재 클레임만 확인)
//
// ⚠ 권한 회수는 즉시 반영되지 않는다. 커스텀 클레임은 ID 토큰에 박혀 있어
//   --revoke 를 해도 그 계정의 **기존 토큰이 만료될 때까지(최대 1시간)** 쓰기가
//   계속 통과한다. 계약 해지처럼 즉시 끊어야 하면 리프레시 토큰까지 무효화해야
//   하는데(admin.auth().revokeRefreshTokens + Rules 의 auth_time 검사), 지금은
//   그 경로가 없다. 급하면 클럽 문서 쪽에서 막을 것.
//
// ⚠ 클레임 전체는 1000바이트 제한이다. 업주 한 명이 클럽 수십 곳을 갖는 구조가
//   되면 clubIds 배열 대신 `clubs.ownerUids` + Rules 의 get() 방식으로 옮겨야 한다
//   (Rules get 은 read 1회가 과금된다).

const { execSync } = require('child_process');
const https = require('https');

const PROJECT = 'vybe-bata-c07aa';

const arg = (name) => {
  const hit = process.argv.find((a) => a.startsWith(`--${name}=`));
  return hit ? hit.split('=').slice(1).join('=') : '';
};
const has = (name) => process.argv.includes(`--${name}`);

const UID = arg('uid');
const EMAIL = arg('email');
const CLUBS = arg('clubs')
  .split(',')
  .map((s) => s.trim())
  .filter(Boolean);
const REVOKE = has('revoke');
const SHOW = has('show');

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

function idpReq(token, path, payload) {
  const body = JSON.stringify(payload);
  return request(
    {
      hostname: 'identitytoolkit.googleapis.com',
      path,
      method: 'POST',
      headers: {
        Authorization: `Bearer ${token}`,
        'Content-Type': 'application/json',
        'X-Goog-User-Project': PROJECT,
        'Content-Length': Buffer.byteLength(body),
      },
    },
    body
  );
}

async function lookup(token, payload) {
  const res = await idpReq(
    token,
    `/v1/projects/${PROJECT}/accounts:lookup`,
    payload
  );
  if (res.status !== 200) throw new Error(`lookup ${res.status}: ${res.body}`);
  const users = JSON.parse(res.body).users || [];
  if (!users.length) throw new Error('계정을 찾을 수 없다');
  return users[0];
}

async function run() {
  if (!UID && !EMAIL) {
    console.error('--uid 또는 --email 이 필요하다. 사용법은 파일 상단 주석 참고.');
    process.exit(1);
  }

  const token = execSync('gcloud auth print-access-token').toString().trim();
  const user = await lookup(
    token,
    UID ? { localId: [UID] } : { email: [EMAIL] }
  );

  const current = user.customAttributes ? JSON.parse(user.customAttributes) : {};
  console.log(`계정 ${user.localId}${user.email ? ` (${user.email})` : ''}`);
  console.log('현재 클레임:', JSON.stringify(current));

  if (SHOW) return;

  // 기존 클레임(admin 등)은 보존하고 파트너 관련 키만 갈아 끼운다 —
  // 통째로 덮으면 어드민 계정에 파트너를 붙이는 순간 admin 이 날아간다.
  const next = { ...current };
  if (REVOKE) {
    delete next.partner;
    delete next.clubIds;
  } else {
    if (!CLUBS.length) {
      console.error('--clubs=clubA,clubB 가 필요하다 (회수는 --revoke).');
      process.exit(1);
    }
    next.partner = true;
    next.clubIds = CLUBS;
  }

  const serialized = JSON.stringify(next);
  if (Buffer.byteLength(serialized) > 1000) {
    console.error(`클레임이 1000바이트를 넘는다 (${Buffer.byteLength(serialized)}). 클럽 수를 줄이거나 ownerUids 방식으로 바꿀 것.`);
    process.exit(1);
  }

  const res = await idpReq(token, `/v1/projects/${PROJECT}/accounts:update`, {
    localId: user.localId,
    customAttributes: serialized,
  });
  if (res.status !== 200) throw new Error(`update ${res.status}: ${res.body}`);

  console.log('새 클레임:', serialized);
  console.log(
    REVOKE
      ? '\n회수 완료 — 단, 이미 발급된 ID 토큰은 최대 1시간 더 유효하다.'
      : '\n부여 완료 — 업주는 재로그인(또는 토큰 갱신) 후에 반영된다.'
  );
}

run().catch((e) => {
  console.error(e.message || e);
  process.exit(1);
});
