// notices/{noticeId} 공지사항 시드.
//
// 실서비스 작성 경로는 어드민 페이지(별도 구축) — 이 스크립트는 앱 화면을
// 붙여 보기 위한 샘플 데이터 투입용이다.
//
// 멱등성: noticeId를 결정적으로 지정(notice_001…) → 재실행하면 같은 doc 덮어씀.
//         createdAt은 updateMask에서 제외해 최초 생성 시각을 보존한다.
//
// 사진은 Storage `notices/{noticeId}/{index}.{ext}` 에 업로드한 뒤 다운로드 URL을
// imageUrls에 넣는다. 샘플은 사진 없는 공지 위주 — 필요하면 아래 배열에 URL 추가.
//
// 실행: gcloud 로그인 상태에서  node scripts/seed_notices.js
//   --dry : 쓰지 않고 결과만 출력

const { execSync } = require('child_process');
const https = require('https');

const PROJECT = 'vybe-bata-c07aa';
const DRY = process.argv.includes('--dry');

// 샘플 이미지는 별도 업로드 없이 기존 clubs/{clubId}/gallery/ URL 재활용.
// (Storage 규칙 clubs/** read: if true — 공개 읽기라 앱에서 그대로 렌더된다)
const SAMPLE_IMG = (clubId, n) =>
  'https://firebasestorage.googleapis.com/v0/b/vybe-bata-c07aa.firebasestorage.app/o/'
  + `clubs%2F${clubId}%2Fgallery%2F${n}.png?alt=media`;

const CLUB_A = '0xhYvbbj3GlVgSHKpqOB'; // 홍대 클럽 레이저
const CLUB_B = '1kX6M1jUZBhRRQJ6ZRFb'; // 클럽 오메가

// publishedAt: 오늘 기준 N일 전 (NEW 배지는 7일 이내 기준)
const NOTICES = [
  {
    id: 'notice_001',
    title: 'vybe 베타 서비스 오픈 안내',
    content:
      'vybe 베타 서비스가 시작되었습니다.\n\n'
      + '지도로 주변 클럽을 찾고, 입장료·영업시간·메뉴를 한 번에 확인해 보세요. '
      + '다녀온 클럽에는 리뷰를 남길 수 있습니다.\n\n'
      + '베타 기간에는 일부 기능이 순차적으로 추가됩니다. '
      + '이용 중 불편한 점은 언제든 알려주세요.',
    category: 'notice',
    isPinned: true,
    daysAgo: 2,
    imageUrls: [],
  },
  {
    id: 'notice_002',
    title: '리뷰 작성 기능 업데이트',
    content:
      '리뷰 작성 화면이 새로워졌습니다.\n\n'
      + '· 별점을 0.5점 단위로 남길 수 있어요\n'
      + '· 사진을 최대 4장까지 첨부할 수 있어요\n'
      + '· 추천 태그로 분위기를 빠르게 표현할 수 있어요\n\n'
      + '작성한 리뷰는 마이페이지 > 내 리뷰 관리에서 확인·삭제할 수 있습니다.',
    category: 'update',
    isPinned: false,
    daysAgo: 5,
    imageUrls: [],
  },
  {
    id: 'notice_003',
    title: '무료입장 클럽 모아보기 오픈',
    content:
      '입장료 없이 즐길 수 있는 클럽만 모아둔 페이지가 열렸습니다.\n\n'
      + '검색 화면의 #무료입장 태그에서 바로 이동할 수 있어요. '
      + '클럽마다 무료입장 조건이 다르니 상세 내용을 확인해 주세요.',
    category: 'event',
    isPinned: false,
    daysAgo: 12,
    imageUrls: [],
  },
  {
    id: 'notice_004',
    title: '8월 위켄드 라인업 미리보기',
    content:
      '이번 달 주말 라인업을 미리 확인해 보세요.\n\n'
      + '· 8/8 (금) 홍대 — 힙합 나이트\n'
      + '· 8/9 (토) 강남 — 테크노 세션\n'
      + '· 8/16 (토) 이태원 — EDM 페스티벌 애프터\n\n'
      + '자세한 시간표는 각 클럽 상세 페이지의 오늘의 라인업에서 확인할 수 있습니다.',
    category: 'event',
    isPinned: false,
    daysAgo: 1,
    imageUrls: [SAMPLE_IMG(CLUB_A, 1), SAMPLE_IMG(CLUB_A, 2)],
  },
  {
    id: 'notice_005',
    title: '지도 검색 속도 개선',
    content:
      '내 주변 지도의 클럽 로딩 속도를 개선했습니다.\n\n'
      + '지도를 이동할 때 화면 범위에 맞춰 필요한 클럽만 불러오도록 바꿔 '
      + '데이터 사용량도 함께 줄었습니다. 최신 버전으로 업데이트해 주세요.',
    category: 'update',
    isPinned: false,
    daysAgo: 3,
    imageUrls: [],
  },
  {
    id: 'notice_006',
    title: '서비스 점검 안내 (8/20 03:00~05:00)',
    content:
      '안정적인 서비스 제공을 위해 아래 시간 동안 점검을 진행합니다.\n\n'
      + '· 일시: 8월 20일(수) 03:00 ~ 05:00 (2시간)\n'
      + '· 영향: 로그인, 리뷰 작성, 찜하기 일시 중단\n\n'
      + '점검 시간은 상황에 따라 앞당겨지거나 늦어질 수 있습니다. '
      + '이용에 불편을 드려 죄송합니다.',
    category: 'notice',
    isPinned: false,
    daysAgo: 6,
    imageUrls: [],
  },
  {
    id: 'notice_007',
    title: '리뷰 이벤트 당첨자 발표',
    content:
      '7월 리뷰 이벤트에 참여해 주신 모든 분께 감사드립니다.\n\n'
      + '당첨되신 분께는 가입하신 연락처로 개별 안내드릴 예정입니다. '
      + '경품은 발표일로부터 2주 이내에 순차 발송됩니다.',
    category: 'event',
    isPinned: false,
    daysAgo: 18,
    imageUrls: [SAMPLE_IMG(CLUB_B, 1)],
  },
  {
    id: 'notice_008',
    title: '건전한 리뷰 문화를 위한 안내',
    content:
      '리뷰는 다른 이용자에게 중요한 참고 자료가 됩니다.\n\n'
      + '아래에 해당하는 리뷰는 사전 고지 없이 삭제될 수 있습니다.\n'
      + '· 욕설, 비방, 차별 표현이 포함된 경우\n'
      + '· 방문 사실과 무관한 광고성 내용\n'
      + '· 타인의 개인정보나 초상권을 침해하는 사진\n\n'
      + '함께 즐거운 나이트라이프 문화를 만들어 주세요.',
    category: 'notice',
    isPinned: false,
    daysAgo: 25,
    imageUrls: [],
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

function daysAgoIso(days) {
  return new Date(Date.now() - days * 24 * 60 * 60 * 1000).toISOString();
}

async function writeNotice(token, notice) {
  const now = new Date().toISOString();
  const fields = {
    noticeId: { stringValue: notice.id },
    title: { stringValue: notice.title },
    content: { stringValue: notice.content },
    imageUrls: {
      arrayValue: {
        values: notice.imageUrls.map((url) => ({ stringValue: url })),
      },
    },
    category: { stringValue: notice.category },
    isPinned: { booleanValue: notice.isPinned },
    isActive: { booleanValue: true },
    publishedAt: { timestampValue: daysAgoIso(notice.daysAgo) },
    authorName: { stringValue: 'VYBE 운영팀' },
    updatedAt: { timestampValue: now },
  };

  // createdAt은 최초 1회만 — 이미 있으면 유지되도록 mask에서 제외하고,
  // 신규 문서일 때만 함께 써 넣는다.
  const existing = await fsReq(
    token,
    'GET',
    `${BASE}/notices/${encodeURIComponent(notice.id)}`
  );
  if (existing.status === 404) {
    fields.createdAt = { timestampValue: daysAgoIso(notice.daysAgo) };
  }

  const mask = Object.keys(fields)
    .map((f) => `updateMask.fieldPaths=${encodeURIComponent(f)}`)
    .join('&');

  const res = await fsReq(
    token,
    'PATCH',
    `${BASE}/notices/${encodeURIComponent(notice.id)}?${mask}`,
    JSON.stringify({ fields })
  );
  if (res.status !== 200) {
    throw new Error(`notice ${notice.id} 실패: ${res.status} ${res.body}`);
  }
}

async function main() {
  console.log(`[seed_notices] 공지 ${NOTICES.length}건`);
  NOTICES.forEach((n) => {
    const pin = n.isPinned ? '[고정] ' : '';
    console.log(`  ${n.id}  ${pin}${n.title}  (${n.category}, ${n.daysAgo}일 전)`);
  });

  if (DRY) {
    console.log('\n--dry: 쓰지 않음');
    return;
  }

  const token = execSync('gcloud auth print-access-token').toString().trim();
  for (const notice of NOTICES) {
    await writeNotice(token, notice);
  }

  console.log('\n완료.');
}

main().catch((e) => {
  console.error(e);
  process.exit(1);
});
