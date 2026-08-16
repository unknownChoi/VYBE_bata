// 기존 문서에 isHidden=false 필드를 채운다 — 회원 탈퇴(soft delete) 준비 작업.
//
// ⚠ 이걸 먼저 돌리지 않고 앱에 where('isHidden','==',false) 필터를 넣으면
//   Firestore는 **필드가 없는 문서를 == false 로 잡지 못해** 클럽 리뷰 탭·사진 탭이
//   통째로 빈 화면이 된다. 반드시 앱 배포보다 먼저 실행할 것.
//
// 대상:
//   clubs/{clubId}/reviews/{reviewId}
//   clubs/{clubId}/photos/{photoId}
//   favorites/{favoriteId}
//
// 이미 isHidden 이 있는 문서는 건너뛴다 → 여러 번 돌려도 안전(멱등).
// 탈퇴로 isHidden=true 가 된 문서를 false 로 되돌리지 않는다.
//
// 실행: gcloud 로그인 상태에서  node scripts/backfill_is_hidden.js
//   --dry : 쓰지 않고 대상 개수만 출력

const { execSync } = require('child_process');
const https = require('https');

const PROJECT = 'vybe-bata-c07aa';
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

// 컬렉션 경로의 모든 문서를 페이지네이션으로 수집.
// 404(컬렉션 없음)는 빈 배열 — 리뷰/사진이 하나도 없는 클럽이 정상적으로 있다.
async function listDocs(token, collectionPath) {
  const docs = [];
  let pageToken = '';
  do {
    const qs = `pageSize=300${pageToken ? `&pageToken=${encodeURIComponent(pageToken)}` : ''}`;
    const res = await fsReq(
      token,
      'GET',
      `/v1/projects/${PROJECT}/databases/(default)/documents/${collectionPath}?${qs}`
    );
    if (res.status === 404) return docs;
    if (res.status !== 200) {
      throw new Error(`list ${collectionPath} failed: ${res.status} ${res.body}`);
    }
    const json = JSON.parse(res.body);
    for (const doc of json.documents || []) {
      docs.push({
        id: doc.name.split('/').pop(),
        path: doc.name.split('/documents/')[1],
        hasIsHidden: doc.fields?.isHidden !== undefined,
      });
    }
    pageToken = json.nextPageToken || '';
  } while (pageToken);
  return docs;
}

// documents:commit 으로 최대 500건씩 한 번에 쓴다.
// 문서마다 PATCH 를 날리면 4천 건에 요청이 4천 번 — 느리고 중간에 끊길 여지가 커진다.
// updateMask 로 isHidden 하나만 머지 → 다른 필드는 건드리지 않는다.
const COMMIT_CHUNK = 500;

async function commitIsHiddenFalse(token, docPaths) {
  const body = JSON.stringify({
    writes: docPaths.map((p) => ({
      update: {
        name: `projects/${PROJECT}/databases/(default)/documents/${p}`,
        fields: { isHidden: { booleanValue: false } },
      },
      updateMask: { fieldPaths: ['isHidden'] },
    })),
  });
  const res = await fsReq(
    token,
    'POST',
    `/v1/projects/${PROJECT}/databases/(default)/documents:commit`,
    body
  );
  if (res.status !== 200) throw new Error(`commit failed: ${res.status} ${res.body}`);
}

// 여러 컬렉션에서 모은 대상 경로를 500건씩 커밋.
async function flush(token, pending) {
  while (pending.length >= COMMIT_CHUNK) {
    const chunk = pending.splice(0, COMMIT_CHUNK);
    if (!DRY) await commitIsHiddenFalse(token, chunk);
  }
}

async function backfill(token, collectionPath, stats, pending) {
  const docs = await listDocs(token, collectionPath);
  const targets = docs.filter((d) => !d.hasIsHidden);

  stats.total += docs.length;
  stats.skipped += docs.length - targets.length;
  stats.patched += targets.length;

  pending.push(...targets.map((d) => d.path));
  await flush(token, pending);
}

async function run() {
  const token = execSync('gcloud auth print-access-token').toString().trim();

  // 1) 클럽 목록 — 리뷰·사진은 클럽 하위 컬렉션이라 클럽을 먼저 훑어야 한다.
  //    (collectionGroup 쿼리는 runQuery + 인덱스가 필요해 스크립트에선 단순 순회가 낫다)
  const clubs = await listDocs(token, 'clubs');
  console.log(`클럽 ${clubs.length}개\n`);

  const reviewStats = { total: 0, patched: 0, skipped: 0 };
  const photoStats = { total: 0, patched: 0, skipped: 0 };

  // 커밋 대기열은 컬렉션을 넘나들며 공유한다 — 클럽마다 리뷰가 몇 건뿐이라
  // 컬렉션 단위로 끊어 커밋하면 500 배치가 거의 안 채워진다.
  const pending = [];

  for (let i = 0; i < clubs.length; i++) {
    const { id } = clubs[i];
    await backfill(token, `clubs/${id}/reviews`, reviewStats, pending);
    await backfill(token, `clubs/${id}/photos`, photoStats, pending);
    console.log(
      `[${i + 1}/${clubs.length}] ${id.slice(0, 8)}… ` +
        `reviews=${reviewStats.patched} photos=${photoStats.patched}`
    );
  }

  // 2) 찜 (top-level)
  const favoriteStats = { total: 0, patched: 0, skipped: 0 };
  await backfill(token, 'favorites', favoriteStats, pending);

  // 남은 잔여분 커밋 (500 미만)
  if (pending.length > 0 && !DRY) {
    await commitIsHiddenFalse(token, pending.splice(0, pending.length));
  }

  const line = (label, s) =>
    `  ${label.padEnd(10)} 전체 ${s.total} / 채움 ${s.patched} / 건너뜀 ${s.skipped}`;

  console.log(`\n완료${DRY ? ' (dry run)' : ''}`);
  console.log(line('reviews', reviewStats));
  console.log(line('photos', photoStats));
  console.log(line('favorites', favoriteStats));
}

run().catch((e) => {
  console.error(e);
  process.exit(1);
});
