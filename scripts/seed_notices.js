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

const BUCKET_BASE =
  'https://firebasestorage.googleapis.com/v0/b/vybe-bata-c07aa.firebasestorage.app/o/';

// 샘플 이미지는 별도 업로드 없이 기존 clubs/{clubId}/gallery/ URL 재활용.
// (Storage 규칙 clubs/** read: if true — 공개 읽기라 앱에서 그대로 렌더된다)
const SAMPLE_IMG = (clubId, n) =>
  `${BUCKET_BASE}clubs%2F${clubId}%2Fgallery%2F${n}.png?alt=media`;

const CLUB_A = '0xhYvbbj3GlVgSHKpqOB'; // 홍대 클럽 레이저
const CLUB_B = '1kX6M1jUZBhRRQJ6ZRFb'; // 클럽 오메가

// 홈 배너 원본 이미지 — category:'ad' 공지가 어떤 배너 얘기인지 바로 알아보게
// 같은 그림을 붙인다.
// (banners/ 는 토큰이 있어야 열린다 — clubs/ 와 달리 공개 읽기 규칙이 없음)
const BANNER_TOKEN = {
  1: 'f939cfa4-addd-416b-981b-a11cacc70a25',
  2: 'c690a69f-fa83-453b-ac2f-d42007d516f1',
  3: '12f6f56e-73a9-4196-8030-1fca6348ef46',
  4: '14ef12df-8c8c-4de4-8e2a-79da8566382e',
};
const BANNER_IMG = (n) =>
  `${BUCKET_BASE}banners%2Fbanner_ad_${n}.png?alt=media&token=${BANNER_TOKEN[n]}`;

// 게시 필드 (어드민 페이지에서 입력할 값들의 시드 표현)
//   daysAgo    : publishedAt = 오늘 기준 N일 전. 음수면 N일 뒤 = 예약 게시
//                (NEW 배지는 게시 7일 이내 기준)
//   endInDays  : endAt = 오늘 기준 N일 뒤. 음수면 이미 종료. 생략하면 무기한 게시
//   isActive   : 게시 상태. 생략하면 true(게시). false면 게시중단 —
//                게시 기간 안이어도 앱에 안 보인다
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
  {
    id: 'notice_009',
    title: '[광고] 여름 시즌 파티 프로모션',
    content:
      '제휴 클럽에서 진행하는 여름 시즌 파티를 소개합니다.\n\n'
      + '· 기간: 8월 한 달간 매주 금·토\n'
      + '· 혜택: vybe 앱 화면 제시 시 웰컴 드링크 1잔\n\n'
      + '본 게시물은 광고이며, 상세 조건은 각 클럽 운영 정책에 따릅니다.',
    category: 'ad',
    isPinned: false,
    daysAgo: 2,
    imageUrls: [SAMPLE_IMG(CLUB_B, 1)],
  },

  // ── 광고 공지 ────────────────────────────────────────────────────────────
  // 배너를 놓친 사용자도 공지 목록에서 같은 내용을 볼 수 있게 한다.
  // 첨부 사진은 해당 배너 이미지 그대로 — 어떤 배너 얘기인지 바로 알아보게.
  {
    id: 'notice_010',
    title: '[광고] vybe 첫 방문 웰컴 이벤트',
    content:
      'vybe에 처음 오신 분들을 위한 웰컴 이벤트를 진행합니다.\n\n'
      + '· 대상: vybe 신규 가입 회원\n'
      + '· 혜택: 제휴 클럽 입장 시 웰컴 드링크 1잔\n'
      + '· 사용 방법: 입장 시 vybe 마이페이지 화면을 보여주세요\n\n'
      + '혜택은 1인 1회 적용되며, 클럽 사정에 따라 조기 종료될 수 있습니다.\n'
      + '자세한 내용은 홈 화면 배너에서 확인하실 수 있습니다.\n\n'
      + '본 게시물은 광고입니다.',
    category: 'ad',
    isPinned: false,
    daysAgo: 5,
    imageUrls: [BANNER_IMG(1)],
  },
  {
    id: 'notice_011',
    title: '[광고] 홍대 클럽 레이저 위켄드 파티',
    content:
      '이번 주말 홍대 클럽 레이저에서 위켄드 파티가 열립니다.\n\n'
      + '· 일시: 금요일·토요일 22:00 ~ 06:00\n'
      + '· 장소: 홍대 클럽 레이저\n'
      + '· 라인업: 헤드라이너 DJ 세트 + 게스트 세션\n\n'
      + '입장료와 테이블 정보는 홈 배너 또는 클럽 상세 페이지에서 확인해 주세요.\n\n'
      + '본 게시물은 광고입니다.',
    category: 'ad',
    isPinned: false,
    daysAgo: 2,
    imageUrls: [BANNER_IMG(2)],
  },
  {
    id: 'notice_012',
    title: '[광고] 여름 나이트 페스티벌',
    content:
      '여름 시즌을 맞아 제휴 클럽에서 페스티벌이 이어집니다.\n\n'
      + '· 기간: 8월 한 달\n'
      + '· 참여 클럽: 홍대 · 강남 · 이태원 제휴 클럽\n'
      + '· 내용: 주차별 테마 파티, 게스트 DJ 초청\n\n'
      + '클럽별 상세 일정은 각 클럽 상세 페이지의 오늘의 라인업에서 확인할 수 있습니다.\n\n'
      + '본 게시물은 광고입니다.',
    category: 'ad',
    isPinned: false,
    daysAgo: 6,
    imageUrls: [BANNER_IMG(3)],
  },
  {
    id: 'notice_013',
    title: '[광고] 리뷰 쓰고 경품 받아가세요',
    content:
      '다녀온 클럽에 리뷰를 남겨주세요.\n\n'
      + '· 대상: 사진을 1장 이상 첨부한 리뷰\n'
      + '· 경품: 추첨을 통해 제휴 클럽 입장권 증정\n'
      + '· 발표: 이벤트 종료 후 공지사항에서 안내\n\n'
      + '광고성이거나 방문 사실과 무관한 리뷰는 추첨에서 제외됩니다.\n\n'
      + '본 게시물은 광고입니다.',
    category: 'ad',
    isPinned: false,
    daysAgo: 1,
    imageUrls: [BANNER_IMG(4)],
  },

  // ── 게시 기간·상태 검증용 샘플 3건 ────────────────────────────────────
  // 셋 다 앱 공지 목록에 보이면 안 된다. 보이면 필터가 깨진 것.
  {
    id: 'notice_101',
    title: '[검증] 예약 게시 — 3일 뒤 공개',
    content:
      '게시 시작일이 아직 오지 않은 공지입니다.\n\n'
      + '앱 목록에 보이면 publishedAt 필터가 동작하지 않는 것입니다.',
    category: 'notice',
    isPinned: false,
    daysAgo: -3, // 3일 뒤 게시
    imageUrls: [],
  },
  {
    id: 'notice_102',
    title: '[검증] 게시 종료 — 어제 종료됨',
    content:
      '게시 종료일이 지난 공지입니다.\n\n'
      + '앱 목록에 보이면 endAt 필터가 동작하지 않는 것입니다.',
    category: 'notice',
    isPinned: false,
    daysAgo: 10,
    endInDays: -1, // 어제 종료
    imageUrls: [],
  },
  {
    id: 'notice_103',
    title: '[검증] 게시중단 — 기간은 유효',
    content:
      '게시 기간 안이지만 게시 상태가 "게시중단"인 공지입니다.\n\n'
      + '앱 목록에 보이면 isActive가 기간보다 우선한다는 규칙이 깨진 것입니다.',
    category: 'notice',
    isPinned: true, // 고정 공지여도 게시중단이면 안 보여야 한다
    daysAgo: 1,
    endInDays: 30,
    isActive: false,
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
    // 연결된 프로모션. 빈 문자열이면 앱이 평소대로 공지 상세를 연다.
    isPinned: { booleanValue: notice.isPinned },
    // 게시 상태 — false면 게시 기간 안이어도 앱에 노출되지 않는다.
    isActive: { booleanValue: notice.isActive ?? true },
    publishedAt: { timestampValue: daysAgoIso(notice.daysAgo) },
    // 게시 종료. 없으면 null(무기한) — 필드를 빼면 이전 실행의 endAt이 남으므로
    // 항상 써서 재실행 결과를 결정적으로 만든다.
    endAt:
      notice.endInDays === undefined
        ? { nullValue: null }
        : { timestampValue: daysAgoIso(-notice.endInDays) },
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
    // 앱에 실제로 보이는지 = NoticeModel.isVisibleAt 과 같은 판정
    const stopped = n.isActive === false;
    const notYet = n.daysAgo < 0;
    const ended = n.endInDays !== undefined && n.endInDays <= 0;
    const state = stopped
      ? '게시중단'
      : notYet
        ? `예약(${-n.daysAgo}일 뒤)`
        : ended
          ? '종료됨'
          : '게시중';
    const period =
      n.endInDays === undefined ? '무기한' : `~${n.endInDays}일 뒤`;
    console.log(
      `  ${n.id}  ${pin}${n.title}  (${n.category}, ${n.daysAgo}일 전, ${period}, ${state})`
    );
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
