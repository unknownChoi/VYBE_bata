/// Firestore 컬렉션 이름과 Storage 경로 — **문자열은 여기에만 둔다.**
///
/// 컬렉션 이름은 Rules·인덱스·Cloud Functions·seed 스크립트와 반드시 같아야 하는데,
/// datasource마다 문자열을 적어 두면 오타가 컴파일에 걸리지 않고 런타임에
/// '문서 없음'으로만 나타난다. 한곳에 모아 두면 스키마 문서(CLAUDE.md)와
/// 대조하기도 쉽다.
///
/// ⚠ 값을 바꾸는 것은 **DB 마이그레이션**이다 — Rules·인덱스·Functions·기존 문서를
/// 같이 옮기지 않으면 앱이 빈 화면이 된다.
class FirestorePaths {
  const FirestorePaths._();

  // ── 최상위 컬렉션 ──
  static const users = 'users';
  static const clubs = 'clubs';
  static const favorites = 'favorites';
  static const banners = 'banners';
  static const notices = 'notices';
  static const performances = 'performances';
  static const appConfig = 'appConfig';
  static const vybeRecommendations = 'vybeRecommendations';
  static const searchLogs = 'searchLogs';
  static const searchTrends = 'searchTrends';
  static const searchHashtags = 'searchHashtags';

  // ── 서브컬렉션 ──
  /// `clubs/{clubId}/info/{clubId}`
  static const clubInfo = 'info';

  /// `clubs/{clubId}/menus/{menuId}`
  static const menus = 'menus';

  /// `clubs/{clubId}/photos/{photoId}`
  static const photos = 'photos';

  /// `clubs/{clubId}/tableLayout/{clubId}` — 배치도는 클럽당 문서 1건(문서 id = clubId).
  static const tableLayout = 'tableLayout';

  /// `clubs/{clubId}/reviews/{reviewId}` — 마이페이지는 collectionGroup으로도 읽는다.
  static const reviews = 'reviews';

  /// `users/{uid}/searchHistory/{historyId}`
  static const searchHistory = 'searchHistory';

  // ── 고정 문서 id ──
  /// `searchTrends/current` — 집계 스냅샷 (앱은 이 문서 1건만 읽는다).
  static const trendsCurrentDoc = 'current';
}

/// Firebase Storage 경로. 규칙(`storage.rules`)의 경로 패턴과 짝이다.
class StoragePaths {
  const StoragePaths._();

  /// `users/{uid}/profile.jpg` — 덮어쓰기.
  static String profileImage(String uid) => 'users/$uid/profile.jpg';

  /// `reviews/{clubId}/{reviewId}/{fileName}` — 리뷰 첨부 (최대 4장).
  static String reviewImage(String clubId, String reviewId, String fileName) =>
      'reviews/$clubId/$reviewId/$fileName';
}
