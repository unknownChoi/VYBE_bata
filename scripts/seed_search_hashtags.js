// searchHashtags/{tagId} 인기 해시태그 큐레이션 시드 + searchTrends/fallback 백업 목록.
//
// 두 컬렉션을 한 번에 세팅하는 이유: 검색 화면의 두 섹션 모두 실사용자 로그가
// 쌓이기 전까지는 이 큐레이션 데이터로 동작하기 때문 (Phase 0).
//
//   searchHashtags   → 인기 해시태그 섹션. popularityRank가 붙기 전까지 order 순.
//   searchTrends/fallback → 실시간 인기 검색어의 빈자리를 채우는 목록.
//                           uniqueUsers=0으로 들어가 증감 아이콘은 표시되지 않는다.
//
// linkType 'page' 의 linkValue 는 앱의 전용 화면 키:
//   freeEntry / serviceDrinks / hipHop / hotPlaces / vybeRecommend
//
// 멱등성: tagId를 결정적으로 지정(tag_<slug>) → 재실행해도 같은 doc 덮어씀.
//         단 popularityRank는 집계 함수가 관리하므로 여기서 건드리지 않는다.
//
// 실행: gcloud 로그인 상태에서  node scripts/seed_search_hashtags.js
//   --dry : 쓰지 않고 결과만 출력

const { execSync } = require('child_process');
const https = require('https');

const PROJECT = 'vybe-bata-c07aa';
const DRY = process.argv.includes('--dry');

// 노출은 상위 8개. 문서를 더 많이 둬야 검색량에 따라 순서가 실제로 바뀐다.
const HASHTAGS = [
  { label: '힙합', linkType: 'page', linkValue: 'hipHop' },
  { label: '무료입장', linkType: 'page', linkValue: 'freeEntry' },
  { label: 'EDM', linkType: 'keyword', linkValue: 'EDM' },
  { label: '홍대', linkType: 'keyword', linkValue: '홍대' },
  { label: '이태원', linkType: 'keyword', linkValue: '이태원' },
  { label: '테크노', linkType: 'keyword', linkValue: '테크노' },
  { label: '서비스음료', linkType: 'page', linkValue: 'serviceDrinks' },
  { label: 'K-POP', linkType: 'keyword', linkValue: 'K-POP' },
  { label: '강남', linkType: 'keyword', linkValue: '강남' },
  { label: '핫플레이스', linkType: 'page', linkValue: 'hotPlaces' },
  { label: '라운지', linkType: 'keyword', linkValue: '라운지' },
  { label: 'VYBE추천', linkType: 'page', linkValue: 'vybeRecommend' },
];

// 실데이터가 모자랄 때 실시간 인기 검색어 뒷자리를 채울 키워드 (순서대로).
const TREND_FALLBACK = [
  '홍대',
  '강남',
  '이태원',
  '건대',
  'EDM',
  '힙합',
  '테크노',
  '라운지',
  '무료입장',
  '서비스음료',
];

function slug(label) {
  return label
    .toLowerCase()
    .replace(/[^a-z0-9가-힣]/g, '')
    .slice(0, 24);
}

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

async function writeHashtag(token, tag, order) {
  const tagId = `tag_${slug(tag.label)}`;
  const fields = {
    tagId: { stringValue: tagId },
    label: { stringValue: tag.label },
    linkType: { stringValue: tag.linkType },
    linkValue: { stringValue: tag.linkValue },
    order: { integerValue: String(order) },
    isActive: { booleanValue: true },
    createdAt: { timestampValue: new Date().toISOString() },
  };

  // popularityRank는 집계 함수 소유 → updateMask에서 제외해 덮어쓰지 않는다.
  const mask = Object.keys(fields)
    .map((f) => `updateMask.fieldPaths=${encodeURIComponent(f)}`)
    .join('&');

  // tagId에 한글이 들어가므로 경로 인코딩 필수 (Firestore 문서 ID 자체는 원본 유지).
  const res = await fsReq(
    token,
    'PATCH',
    `${BASE}/searchHashtags/${encodeURIComponent(tagId)}?${mask}`,
    JSON.stringify({ fields })
  );
  if (res.status !== 200) {
    throw new Error(`hashtag ${tagId} 실패: ${res.status} ${res.body}`);
  }
  return tagId;
}

async function writeFallback(token) {
  const items = TREND_FALLBACK.map((keyword, i) => ({
    mapValue: {
      fields: {
        rank: { integerValue: String(i + 1) },
        keyword: { stringValue: keyword },
      },
    },
  }));

  const fields = {
    items: { arrayValue: { values: items } },
    updatedAt: { timestampValue: new Date().toISOString() },
  };
  const mask = Object.keys(fields)
    .map((f) => `updateMask.fieldPaths=${encodeURIComponent(f)}`)
    .join('&');

  const res = await fsReq(
    token,
    'PATCH',
    `${BASE}/searchTrends/fallback?${mask}`,
    JSON.stringify({ fields })
  );
  if (res.status !== 200) {
    throw new Error(`fallback 실패: ${res.status} ${res.body}`);
  }
}

async function main() {
  console.log(`[seed_search_hashtags] 해시태그 ${HASHTAGS.length}개 / fallback ${TREND_FALLBACK.length}개`);
  HASHTAGS.forEach((t, i) => {
    console.log(`  ${String(i + 1).padStart(2)}. #${t.label}  (${t.linkType}: ${t.linkValue})  → tag_${slug(t.label)}`);
  });
  console.log(`  fallback: ${TREND_FALLBACK.join(', ')}`);

  if (DRY) {
    console.log('\n--dry: 쓰지 않음');
    return;
  }

  const token = execSync('gcloud auth print-access-token').toString().trim();

  for (let i = 0; i < HASHTAGS.length; i++) {
    await writeHashtag(token, HASHTAGS[i], i + 1);
  }
  await writeFallback(token);

  console.log('\n완료.');
}

main().catch((e) => {
  console.error(e);
  process.exit(1);
});
