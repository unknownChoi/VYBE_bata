// 기존 clubs/{id}.imageUrls (카테고리 없는 URL 배열) →
// clubs/{id}/photos 서브컬렉션(카테고리 포함)으로 마이그레이션.
//
// 카테고리는 원본에 없으므로 venue/food/inside round-robin 배정.
// 배열 순서는 createdAt(내림차순 조회)로 보존 — index 0이 가장 최신.
//
// 실행: gcloud 로그인 상태에서  node scripts/seed_photos.js
//   --force : 이미 photos 있는 클럽도 다시 채움(기본은 skip)
//   --dry   : 쓰지 않고 대상/장수만 출력

const { execSync } = require('child_process');
const https = require('https');

const PROJECT = 'vybe-bata-c07aa';
const CATEGORIES = ['venue', 'food', 'inside'];
const FORCE = process.argv.includes('--force');
const DRY = process.argv.includes('--dry');

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

// 모든 클럽 문서 페이지네이션 수집 (id + imageUrls)
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
      const id = doc.name.split('/').pop();
      const arr = doc.fields?.imageUrls?.arrayValue?.values || [];
      const urls = arr.map((v) => v.stringValue).filter(Boolean);
      clubs.push({ id, urls });
    }
    pageToken = json.nextPageToken || '';
  } while (pageToken);
  return clubs;
}

async function hasPhotos(token, clubId) {
  const res = await fsReq(
    token,
    'GET',
    `/v1/projects/${PROJECT}/databases/(default)/documents/clubs/${clubId}/photos?pageSize=1`
  );
  if (res.status !== 200) return false;
  const json = JSON.parse(res.body);
  return (json.documents || []).length > 0;
}

async function addPhoto(token, clubId, url, category, createdAtIso) {
  const body = JSON.stringify({
    fields: {
      clubId: { stringValue: clubId },
      userId: { stringValue: 'seed' },
      url: { stringValue: url },
      category: { stringValue: category },
      createdAt: { timestampValue: createdAtIso },
    },
  });
  const res = await fsReq(
    token,
    'POST',
    `/v1/projects/${PROJECT}/databases/(default)/documents/clubs/${clubId}/photos`,
    body
  );
  if (res.status !== 200) throw new Error(`add photo failed: ${res.status} ${res.body}`);
}

async function run() {
  const token = execSync('gcloud auth print-access-token').toString().trim();
  const clubs = await listClubs(token);
  const withImages = clubs.filter((c) => c.urls.length > 0);
  const totalPhotos = withImages.reduce((s, c) => s + c.urls.length, 0);
  console.log(
    `클럽 ${clubs.length}개 / imageUrls 있는 클럽 ${withImages.length}개 / 총 사진 ${totalPhotos}장\n`
  );
  if (DRY) {
    withImages.forEach((c) => console.log(`  ${c.id.slice(0, 8)}… ${c.urls.length}장`));
    console.log('\n(dry run — 쓰지 않음)');
    return;
  }

  const now = Date.now();
  let done = 0;
  let skipped = 0;
  let photoCount = 0;
  for (let i = 0; i < withImages.length; i++) {
    const { id, urls } = withImages[i];
    try {
      if (!FORCE && (await hasPhotos(token, id))) {
        skipped++;
        console.log(`[${i + 1}/${withImages.length}] - ${id.slice(0, 8)}… skip (이미 photos 있음)`);
        continue;
      }
      for (let k = 0; k < urls.length; k++) {
        const category = CATEGORIES[k % CATEGORIES.length];
        const createdAt = new Date(now - k * 60000).toISOString(); // 순서 보존
        await addPhoto(token, id, urls[k], category, createdAt);
        photoCount++;
      }
      done++;
      console.log(`[${i + 1}/${withImages.length}] ✓ ${id.slice(0, 8)}… ${urls.length}장`);
    } catch (err) {
      console.error(`[${i + 1}/${withImages.length}] ✗ ${id}: ${String(err.message).slice(0, 80)}`);
    }
  }

  console.log(`\n완료! 시드 ${done}개 클럽, ${photoCount}장, skip ${skipped}개`);
}

run();
