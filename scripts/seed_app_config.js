// appConfig/{platform} 버전 정책 시드 (android / ios 문서 2건).
//
// 실서비스 편집 경로는 어드민 페이지(별도 구축) — 이 스크립트는 게이트를
// 붙여 보기 위한 초기값 투입용이다.
//
// 멱등성: 문서 ID가 플랫폼 고정("android"/"ios") → 재실행하면 덮어씀.
//         createdAt은 없고 updatedAt만 둔다(정책은 늘 최신값만 의미 있음).
//
// ⚠ minVersion은 **새 빌드가 스토어에 실제로 올라간 뒤** 올릴 것.
//   심사 중에 미리 올리면 심사자 기기가 강제 업데이트 벽에 막혀 리젝된다.
//
// 실행: gcloud 로그인 상태에서  node scripts/seed_app_config.js
//   --dry : 쓰지 않고 결과만 출력

const { execSync } = require('child_process');
const https = require('https');

const PROJECT = 'vybe-bata-c07aa';
const DRY = process.argv.includes('--dry');

// 초기값은 **아무도 막지 않는 상태**로 넣는다.
// minVersion/latestVersion을 현재 배포 버전(1.0.0)으로 맞춰 두면
// 시드를 돌리자마자 전 유저가 차단되는 사고가 난다.
const CONFIGS = [
  {
    platform: 'android',
    minVersion: '', // 비면 강제 업데이트 없음
    latestVersion: '', // 비면 업데이트 권유 없음
    // 비워 둔다 — 앱이 `market://details?id={설치된 packageName}` 으로 폴백한다.
    // 지금 applicationId가 아직 `com.example.vybe`(Flutter 기본 placeholder)라
    // Play 스토어 URL을 박아 넣으면 패키지명 확정 시 죽은 링크가 된다.
    // 폴백은 설치된 앱 자신의 패키지명을 쓰므로 이름이 바뀌어도 항상 맞는다.
    storeUrl: '',
    updateTitle: '',
    updateMessage: '',
    isMaintenance: false,
    maintenanceMessage: '',
  },
  {
    platform: 'ios',
    minVersion: '',
    latestVersion: '',
    // ⚠ iOS는 폴백이 없다(앱에서 App Store 앱 ID를 알 수 없음).
    //   App Store Connect에서 앱 등록 후 반드시 채울 것:
    //   https://apps.apple.com/kr/app/id{앱ID}
    //   비어 있으면 업데이트 버튼이 "스토어 링크가 설정되지 않았습니다" 토스트만 낸다.
    storeUrl: '',
    updateTitle: '',
    updateMessage: '',
    isMaintenance: false,
    maintenanceMessage: '',
  },
];

function request(options, body) {
  return new Promise((resolve, reject) => {
    const req = https.request(options, (res) => {
      // Buffer로 모았다가 마지막에 디코딩 (한글이 청크 경계에서 깨지는 것 방지).
      const chunks = [];
      res.on('data', (c) => chunks.push(c));
      res.on('end', () =>
        resolve({
          status: res.statusCode,
          body: Buffer.concat(chunks).toString('utf8'),
        })
      );
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

const BASE = `/v1/projects/${PROJECT}/databases/(default)/documents`;

async function writeConfig(token, config) {
  const fields = {
    platform: { stringValue: config.platform },
    minVersion: { stringValue: config.minVersion },
    latestVersion: { stringValue: config.latestVersion },
    storeUrl: { stringValue: config.storeUrl },
    updateTitle: { stringValue: config.updateTitle },
    updateMessage: { stringValue: config.updateMessage },
    isMaintenance: { booleanValue: config.isMaintenance },
    maintenanceMessage: { stringValue: config.maintenanceMessage },
    updatedAt: { timestampValue: new Date().toISOString() },
  };

  const mask = Object.keys(fields)
    .map((f) => `updateMask.fieldPaths=${encodeURIComponent(f)}`)
    .join('&');

  const res = await fsReq(
    token,
    'PATCH',
    `${BASE}/appConfig/${encodeURIComponent(config.platform)}?${mask}`,
    JSON.stringify({ fields })
  );
  if (res.status !== 200) {
    throw new Error(`appConfig ${config.platform} 실패: ${res.status} ${res.body}`);
  }
}

async function main() {
  console.log(`[seed_app_config] 버전 정책 ${CONFIGS.length}건`);
  CONFIGS.forEach((c) => {
    const gate =
      c.isMaintenance
        ? '점검 모드'
        : c.minVersion || c.latestVersion
          ? `강제<${c.minVersion || '-'} / 권유<${c.latestVersion || '-'}`
          : '차단 없음';
    console.log(`  ${c.platform}  ${gate}  ${c.storeUrl}`);
  });

  if (DRY) {
    console.log('\n--dry: 쓰지 않음');
    return;
  }

  const token = execSync('gcloud auth print-access-token').toString().trim();
  for (const config of CONFIGS) {
    await writeConfig(token, config);
  }

  console.log('\n완료.');
}

main().catch((e) => {
  console.error(e);
  process.exit(1);
});
