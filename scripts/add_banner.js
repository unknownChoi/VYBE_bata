// banners/{bannerId} 배너 1건 추가 — 로컬 이미지 업로드 + Firestore 문서 생성.
//
// 실서비스 작성 경로는 어드민 페이지(별도 구축) — 이 스크립트는 배너를 손으로
// 하나 얹어 보기 위한 도구다.
//
// 하는 일 2가지:
//   1) Storage `banners/{bannerId}.{ext}` 에 업로드 (다운로드 토큰 포함 URL 생성)
//   2) banners/{bannerId} 문서 생성 — order 는 기본이 "맨 앞"(기존 최소값 - 1)
//
// 멱등성: bannerId 를 지정하면 재실행 시 같은 문서를 덮어쓴다(createdAt 은 보존).
//
// 이미지 규격은 CLAUDE.md '배너 이미지 규격' 참고 — 1026 x 600 (비율 1.71:1).
//
// 실행: gcloud 로그인 상태에서
//   node scripts/add_banner.js --file=~/Downloads/test_banner_1.png
//   옵션:
//     --id=banner_test_1     문서 ID (기본: banner_<파일명>)
//     --order=0              정렬 순서 (기본: 기존 최소 order - 1 = 맨 앞)
//     --link=notice:notice_ad_free_entry   linkType:linkValue (기본: none)
//     --inactive             isActive=false 로 생성
//     --dry                  쓰지 않고 결과만 출력

const { execSync } = require('child_process');
const fs = require('fs');
const path = require('path');
const https = require('https');
const crypto = require('crypto');

const PROJECT = 'vybe-bata-c07aa';
const BUCKET = 'vybe-bata-c07aa.firebasestorage.app';
const FS_BASE = `/v1/projects/${PROJECT}/databases/(default)/documents`;

const LINK_TYPES = ['notice', 'club', 'page', 'url', 'none'];

function arg(name, fallback) {
  const hit = process.argv.find(a => a.startsWith(`--${name}=`));
  return hit ? hit.slice(name.length + 3) : fallback;
}
const DRY = process.argv.includes('--dry');
const INACTIVE = process.argv.includes('--inactive');

// ─────────────────────────────────────────── HTTP

function request(options, body) {
  return new Promise((resolve, reject) => {
    const req = https.request(options, res => {
      let data = '';
      res.on('data', chunk => (data += chunk));
      res.on('end', () => resolve({ status: res.statusCode, body: data }));
    });
    req.on('error', reject);
    if (body) req.write(body);
    req.end();
  });
}

// 확장자가 아니라 **실제 매직 바이트**로 판정한다 — .png 로 저장된 JPEG 가 흔한데
// contentType 이 틀리면 브라우저·앱이 렌더를 거부할 수 있다.
function sniffImage(buf) {
  if (buf[0] === 0xff && buf[1] === 0xd8) return { ext: '.jpg', type: 'image/jpeg' };
  if (buf.slice(0, 8).equals(Buffer.from([0x89, 0x50, 0x4e, 0x47, 0x0d, 0x0a, 0x1a, 0x0a])))
    return { ext: '.png', type: 'image/png' };
  if (buf.slice(0, 4).toString() === 'RIFF' && buf.slice(8, 12).toString() === 'WEBP')
    return { ext: '.webp', type: 'image/webp' };
  return null;
}

async function uploadToStorage(token, fileData, destination, contentType, downloadToken) {
  const metadata = JSON.stringify({
    name: destination,
    contentType,
    metadata: { firebaseStorageDownloadTokens: downloadToken },
  });

  const boundary = '-------314159265358979323846';
  const delim = `\r\n--${boundary}\r\n`;
  const closeDelim = `\r\n--${boundary}--`;

  const body = Buffer.concat([
    Buffer.from(
      `--${boundary}\r\nContent-Type: application/json; charset=UTF-8\r\n\r\n${metadata}${delim}Content-Type: ${contentType}\r\n\r\n`
    ),
    fileData,
    Buffer.from(closeDelim),
  ]);

  const res = await request(
    {
      hostname: 'storage.googleapis.com',
      path: `/upload/storage/v1/b/${encodeURIComponent(BUCKET)}/o?uploadType=multipart&name=${encodeURIComponent(destination)}`,
      method: 'POST',
      headers: {
        Authorization: `Bearer ${token}`,
        'Content-Type': `multipart/related; boundary="${boundary}"`,
        'Content-Length': body.length,
      },
    },
    body
  );

  if (res.status !== 200) throw new Error(`Storage upload failed: ${res.status} ${res.body}`);
}

async function listBanners(token) {
  const res = await request({
    hostname: 'firestore.googleapis.com',
    path: `${FS_BASE}/banners?pageSize=300`,
    method: 'GET',
    headers: { Authorization: `Bearer ${token}` },
  });
  if (res.status !== 200) throw new Error(`banners 조회 실패: ${res.status} ${res.body}`);
  return JSON.parse(res.body).documents || [];
}

async function writeBanner(token, bannerId, fields, exists) {
  // createdAt 은 updateMask 에서 빼 최초 생성 시각을 보존한다(재실행 시 덮지 않음).
  const paths = Object.keys(fields).filter(k => !(exists && k === 'createdAt'));
  const query = paths.map(p => `updateMask.fieldPaths=${p}`).join('&');
  const body = JSON.stringify({ fields });

  const res = await request(
    {
      hostname: 'firestore.googleapis.com',
      path: `${FS_BASE}/banners/${bannerId}?${query}`,
      method: 'PATCH',
      headers: {
        Authorization: `Bearer ${token}`,
        'Content-Type': 'application/json',
        'Content-Length': Buffer.byteLength(body),
      },
    },
    body
  );
  if (res.status !== 200) throw new Error(`Firestore 쓰기 실패: ${res.status} ${res.body}`);
}

// ─────────────────────────────────────────── main

async function run() {
  let file = arg('file');
  if (!file) throw new Error('--file=<이미지 경로> 필요');
  if (file.startsWith('~')) file = path.join(process.env.HOME, file.slice(1));
  if (!fs.existsSync(file)) throw new Error(`파일 없음: ${file}`);

  const fileData = fs.readFileSync(file);
  const sniff = sniffImage(fileData);
  if (!sniff) throw new Error('이미지가 아니거나 지원하지 않는 포맷 (jpeg/png/webp)');

  const bannerId = arg('id', `banner_${path.basename(file, path.extname(file))}`);

  const [linkTypeRaw, ...rest] = arg('link', 'none').split(':');
  const linkType = linkTypeRaw || 'none';
  const linkValue = rest.join(':');
  if (!LINK_TYPES.includes(linkType))
    throw new Error(`--link 타입은 ${LINK_TYPES.join('|')} 중 하나`);

  const token = execSync('gcloud auth print-access-token').toString().trim();

  const existing = await listBanners(token);
  const orders = existing.map(d => Number(d.fields?.order?.integerValue ?? 0));
  const exists = existing.some(d => d.name.endsWith(`/banners/${bannerId}`));

  // 기본값 = 기존 최소 order - 1. 다른 문서를 손대지 않고 맨 앞에 꽂는다
  // (앱은 order 오름차순 정렬만 한다 — 값이 음수여도 무방).
  const minOrder = orders.length ? Math.min(...orders) : 1;
  const order = Number(arg('order', String(minOrder - 1)));
  if (!Number.isInteger(order)) throw new Error('--order 는 정수');

  const destination = `banners/${bannerId}${sniff.ext}`;
  const downloadToken = crypto.randomUUID();
  const imageUrl =
    `https://firebasestorage.googleapis.com/v0/b/${BUCKET}/o/` +
    `${encodeURIComponent(destination)}?alt=media&token=${downloadToken}`;

  const now = new Date();
  const endAt = new Date(now.getTime());
  endAt.setFullYear(endAt.getFullYear() + 1);

  const fields = {
    bannerId: { stringValue: bannerId },
    imageUrl: { stringValue: imageUrl },
    linkType: { stringValue: linkType },
    linkValue: { stringValue: linkValue },
    order: { integerValue: String(order) },
    isActive: { booleanValue: !INACTIVE },
    startAt: { timestampValue: now.toISOString() },
    endAt: { timestampValue: endAt.toISOString() },
    createdAt: { timestampValue: now.toISOString() },
  };

  console.log(`파일     : ${file} (${sniff.type}, ${(fileData.length / 1024).toFixed(0)}KB)`);
  console.log(`bannerId : ${bannerId}${exists ? ' (덮어쓰기)' : ' (신규)'}`);
  console.log(`Storage  : ${destination}`);
  console.log(`order    : ${order}   (기존: ${orders.sort((a, b) => a - b).join(', ') || '없음'})`);
  console.log(`link     : ${linkType}${linkValue ? `:${linkValue}` : ''}`);
  console.log(`isActive : ${!INACTIVE}`);

  if (DRY) {
    console.log('\n--dry 라 아무것도 쓰지 않음');
    return;
  }

  await uploadToStorage(token, fileData, destination, sniff.type, downloadToken);
  console.log('\n✓ Storage 업로드');

  await writeBanner(token, bannerId, fields, exists);
  console.log('✓ Firestore banners 문서 저장');
  console.log(`\n${imageUrl}`);
}

run().catch(err => {
  console.error(`✗ ${err.message}`);
  process.exit(1);
});
