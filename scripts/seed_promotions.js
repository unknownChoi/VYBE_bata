// promotions/{promotionId} 프로모션(배너 상세) 시드 + banners 링크 연결.
//
// 실서비스 작성 경로는 어드민 페이지(별도 구축) — 이 스크립트는 앱 화면을
// 붙여 보기 위한 샘플 데이터 투입용이다.
//
// 하는 일 2가지:
//   1) promotions/{id} 문서 생성 (배너별로 다른 사진·본문)
//   2) 기존 banners/{id} 의 linkType/linkValue 를 promotion → 그 문서로 연결
//      (현재 배너는 linkType:'screen', linkValue:'home' 플레이스홀더라 탭해도
//       아무 일도 일어나지 않는다)
//
// 멱등성: promotionId를 결정적으로 지정(promo_001…) → 재실행하면 같은 doc 덮어씀.
//         createdAt은 updateMask에서 제외해 최초 생성 시각을 보존한다.
//
// 사진은 Storage `promotions/{promotionId}/{index}.{ext}` 에 업로드한 뒤 다운로드
// URL을 넣는 게 실운영 경로. 샘플은 기존 배너/클럽 갤러리 이미지를 재활용한다.
//
// 실행: gcloud 로그인 상태에서  node scripts/seed_promotions.js
//   --dry : 쓰지 않고 결과만 출력

const { execSync } = require('child_process');
const https = require('https');

const PROJECT = 'vybe-bata-c07aa';
const DRY = process.argv.includes('--dry');

const BUCKET_BASE =
  'https://firebasestorage.googleapis.com/v0/b/vybe-bata-c07aa.firebasestorage.app/o/';

// 배너 원본 이미지 (banners/banner_ad_N.png) — 상세 히어로로 그대로 재활용해
// 탭했을 때 방금 본 배너와 같은 그림이 이어지게 한다. 토큰이 있어야 열린다.
const BANNER_IMG = {
  banner_ad_1: `${BUCKET_BASE}banners%2Fbanner_ad_1.png?alt=media&token=f939cfa4-addd-416b-981b-a11cacc70a25`,
  banner_ad_2: `${BUCKET_BASE}banners%2Fbanner_ad_2.png?alt=media&token=c690a69f-fa83-453b-ac2f-d42007d516f1`,
  banner_ad_3: `${BUCKET_BASE}banners%2Fbanner_ad_3.png?alt=media&token=12f6f56e-73a9-4196-8030-1fca6348ef46`,
  banner_ad_4: `${BUCKET_BASE}banners%2Fbanner_ad_4.png?alt=media&token=14ef12df-8c8c-4de4-8e2a-79da8566382e`,
};

// 본문 사진은 별도 업로드 없이 기존 clubs/{clubId}/gallery/ URL 재활용.
// (Storage 규칙 clubs/** read: if true — 공개 읽기라 앱에서 그대로 렌더된다)
const SAMPLE_IMG = (clubId, n) =>
  `${BUCKET_BASE}clubs%2F${clubId}%2Fgallery%2F${n}.png?alt=media`;

const CLUB_A = '0xhYvbbj3GlVgSHKpqOB'; // 홍대 클럽 레이저
const CLUB_B = '1kX6M1jUZBhRRQJ6ZRFb'; // 클럽 오메가

// startAt/endAt: 오늘 기준 상대 일수 (표시용 기간 pill)
const PROMOTIONS = [
  {
    id: 'promo_001',
    bannerId: 'banner_ad_1',
    title: 'vybe 첫 방문 웰컴 이벤트',
    subtitle: '가입하고 바로 쓰는 입장 혜택',
    content:
      'vybe에 처음 오신 분들을 위한 웰컴 이벤트입니다.\n\n'
      + '· 대상: vybe 신규 가입 회원\n'
      + '· 혜택: 제휴 클럽 입장 시 웰컴 드링크 1잔\n'
      + '· 사용 방법: 입장 시 vybe 마이페이지 화면을 보여주세요\n\n'
      + '혜택은 1인 1회 적용되며, 클럽 사정에 따라 조기 종료될 수 있습니다.',
    startDaysAgo: 5,
    endDaysAfter: 25,
    imageUrls: [],
    ctaType: 'none',
    ctaValue: '',
    ctaLabel: '',
  },
  {
    id: 'promo_002',
    bannerId: 'banner_ad_2',
    title: '홍대 클럽 레이저 위켄드 파티',
    subtitle: '금·토 밤 헤드라이너 라인업 공개',
    content:
      '이번 주말 홍대 클럽 레이저에서 위켄드 파티가 열립니다.\n\n'
      + '· 일시: 금요일·토요일 22:00 ~ 06:00\n'
      + '· 장소: 홍대 클럽 레이저\n'
      + '· 라인업: 헤드라이너 DJ 세트 + 게스트 세션\n\n'
      + '입장료와 테이블 정보는 아래 버튼에서 클럽 상세 페이지로 확인하세요.',
    startDaysAgo: 2,
    endDaysAfter: 10,
    imageUrls: [SAMPLE_IMG(CLUB_A, 1), SAMPLE_IMG(CLUB_A, 2)],
    ctaType: 'club',
    ctaValue: CLUB_A,
    ctaLabel: '클럽 상세 보기',
  },
  {
    id: 'promo_003',
    bannerId: 'banner_ad_3',
    title: '여름 나이트 페스티벌',
    subtitle: '8월 한 달간 이어지는 시즌 이벤트',
    content:
      '여름 시즌을 맞아 제휴 클럽에서 페스티벌이 이어집니다.\n\n'
      + '· 기간: 8월 한 달\n'
      + '· 참여 클럽: 홍대 · 강남 · 이태원 제휴 클럽\n'
      + '· 내용: 주차별 테마 파티, 게스트 DJ 초청\n\n'
      + '클럽별 상세 일정은 각 클럽 상세 페이지의 오늘의 라인업에서 확인할 수 있습니다.',
    startDaysAgo: 6,
    endDaysAfter: 24,
    imageUrls: [SAMPLE_IMG(CLUB_B, 1)],
    ctaType: 'url',
    ctaValue: 'https://www.instagram.com/',
    ctaLabel: '인스타그램에서 보기',
  },
  {
    id: 'promo_004',
    bannerId: 'banner_ad_4',
    title: '리뷰 쓰고 경품 받아가세요',
    subtitle: '사진 리뷰 작성 이벤트',
    content:
      '다녀온 클럽에 리뷰를 남겨주세요.\n\n'
      + '· 대상: 사진을 1장 이상 첨부한 리뷰\n'
      + '· 경품: 추첨을 통해 제휴 클럽 입장권 증정\n'
      + '· 발표: 이벤트 종료 후 공지사항에서 안내\n\n'
      + '광고성이거나 방문 사실과 무관한 리뷰는 추첨에서 제외됩니다.',
    startDaysAgo: 1,
    endDaysAfter: 20,
    imageUrls: [],
    ctaType: 'none',
    ctaValue: '',
    ctaLabel: '',
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

function shiftDaysIso(days) {
  return new Date(Date.now() + days * 24 * 60 * 60 * 1000).toISOString();
}

async function patch(token, docPath, fields) {
  const mask = Object.keys(fields)
    .map((f) => `updateMask.fieldPaths=${encodeURIComponent(f)}`)
    .join('&');

  const res = await fsReq(
    token,
    'PATCH',
    `${BASE}/${docPath}?${mask}`,
    JSON.stringify({ fields })
  );
  if (res.status !== 200) {
    throw new Error(`${docPath} 실패: ${res.status} ${res.body}`);
  }
}

async function writePromotion(token, promo) {
  const now = new Date().toISOString();
  const fields = {
    promotionId: { stringValue: promo.id },
    title: { stringValue: promo.title },
    subtitle: { stringValue: promo.subtitle },
    heroImageUrl: { stringValue: BANNER_IMG[promo.bannerId] },
    content: { stringValue: promo.content },
    imageUrls: {
      arrayValue: {
        values: promo.imageUrls.map((url) => ({ stringValue: url })),
      },
    },
    ctaType: { stringValue: promo.ctaType },
    ctaValue: { stringValue: promo.ctaValue },
    ctaLabel: { stringValue: promo.ctaLabel },
    isActive: { booleanValue: true },
    startAt: { timestampValue: shiftDaysIso(-promo.startDaysAgo) },
    endAt: { timestampValue: shiftDaysIso(promo.endDaysAfter) },
    updatedAt: { timestampValue: now },
  };

  // createdAt은 최초 1회만 — 이미 있으면 유지되도록 mask에서 제외하고,
  // 신규 문서일 때만 함께 써 넣는다.
  const existing = await fsReq(
    token,
    'GET',
    `${BASE}/promotions/${encodeURIComponent(promo.id)}`
  );
  if (existing.status === 404) {
    fields.createdAt = { timestampValue: now };
  }

  await patch(token, `promotions/${encodeURIComponent(promo.id)}`, fields);
}

/// 배너를 프로모션에 연결. linkType/linkValue 두 필드만 건드린다
/// (이미지·기간·순서 등 나머지 배너 필드는 mask에 없어 그대로 보존).
async function linkBanner(token, promo) {
  await patch(token, `banners/${encodeURIComponent(promo.bannerId)}`, {
    linkType: { stringValue: 'promotion' },
    linkValue: { stringValue: promo.id },
  });
}

async function main() {
  console.log(`[seed_promotions] 프로모션 ${PROMOTIONS.length}건`);
  PROMOTIONS.forEach((p) => {
    console.log(
      `  ${p.id}  ${p.title}  (cta: ${p.ctaType}) ← ${p.bannerId}`
    );
  });

  if (DRY) {
    console.log('\n--dry: 쓰지 않음');
    return;
  }

  const token = execSync('gcloud auth print-access-token').toString().trim();
  for (const promo of PROMOTIONS) {
    await writePromotion(token, promo);
    await linkBanner(token, promo);
  }

  console.log('\n완료. 홈 배너를 탭하면 프로모션 상세로 이동합니다.');
}

main().catch((e) => {
  console.error(e);
  process.exit(1);
});
