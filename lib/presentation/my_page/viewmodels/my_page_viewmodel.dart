import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:vybe/core/providers/auth_providers.dart';
import 'package:vybe/data/models/club_model.dart';
import 'package:vybe/data/models/review_model.dart';
import 'package:vybe/data/repositories/club_repository_impl.dart';
import 'package:vybe/data/repositories/review_repository_impl.dart';

part 'my_page_viewmodel.g.dart';

/// 내 리뷰 1건 = 리뷰 + 클럽 표시 정보(이름·지역) 조인.
class MyReviewEntry {
  final ReviewModel review;
  final ClubModel? club;

  const MyReviewEntry({required this.review, required this.club});

  String get clubName => club?.name ?? '알 수 없는 클럽';
  String get clubArea => club?.area ?? '';

  /// 작성일 표기 (예: 2026.07.12)
  String get dateLabel {
    final d = review.createdAt;
    return '${d.year}.${d.month.toString().padLeft(2, '0')}.${d.day.toString().padLeft(2, '0')}';
  }
}

/// 내가 작성한 리뷰 목록 (collectionGroup 스트림 → 클럽 정보 조인).
@riverpod
Stream<List<MyReviewEntry>> myReviews(Ref ref) {
  final uid = ref.watch(currentUidProvider);
  if (uid == null) return Stream.value(const []);

  final reviewRepo = ref.watch(reviewRepositoryProvider);
  final clubRepo = ref.watch(clubRepositoryProvider);
  // 스트림 갱신 간 클럽 재조회 방지 캐시.
  final clubCache = <String, ClubModel?>{};

  return reviewRepo.watchUserReviews(uid).asyncMap((reviews) async {
    final ids = reviews.map((r) => r.clubId).toSet();
    await Future.wait(ids.where((id) => !clubCache.containsKey(id)).map(
      (id) async {
        clubCache[id] = await clubRepo.getClub(id);
      },
    ));
    return reviews
        .map((r) => MyReviewEntry(review: r, club: clubCache[r.clubId]))
        .toList();
  });
}

/// 마이페이지 동작 (리뷰 삭제).
@riverpod
class MyPageActions extends _$MyPageActions {
  @override
  void build() {}

  Future<void> deleteReview(String clubId, String reviewId) =>
      ref.read(reviewRepositoryProvider).deleteReview(clubId, reviewId);
}

// ============================================================
// 목록 정렬 · 필터 (디자인 MRReviewBar)
// ============================================================

/// 내 리뷰 목록 정렬 기준.
///
/// 디자인의 '좋아요순'은 reviews 스키마에 좋아요 필드가 없어 제외했다.
enum MyReviewSort {
  latest('최신순'),
  rating('별점순');

  final String label;

  const MyReviewSort(this.label);
}

/// 정렬 기준 + 사진 필터 한 쌍. 목록을 거르는 규칙은 [apply] 한 곳에만 둔다.
class MyReviewFilter {
  final MyReviewSort sort;

  /// 사진이 붙은 리뷰만 보기.
  final bool photoOnly;

  const MyReviewFilter({
    this.sort = MyReviewSort.latest,
    this.photoOnly = false,
  });

  MyReviewFilter copyWith({MyReviewSort? sort, bool? photoOnly}) =>
      MyReviewFilter(
        sort: sort ?? this.sort,
        photoOnly: photoOnly ?? this.photoOnly,
      );

  /// 원본 목록(최신순으로 이미 정렬돼 온다)에 필터·정렬을 적용한다.
  List<MyReviewEntry> apply(List<MyReviewEntry> source) {
    final list = photoOnly
        ? source.where((e) => e.review.imageUrls.isNotEmpty).toList()
        : List<MyReviewEntry>.of(source);

    // 별점이 같으면 최신 리뷰가 위 — tie-break를 고정하지 않으면 스트림이
    // 갱신될 때마다 같은 별점끼리 순서가 뒤바뀌어 보인다.
    if (sort == MyReviewSort.rating) {
      list.sort((a, b) {
        final byRating = b.review.rating.compareTo(a.review.rating);
        return byRating != 0
            ? byRating
            : b.review.createdAt.compareTo(a.review.createdAt);
      });
    }
    return list;
  }
}

/// 정렬·필터 선택 상태 (화면 표시 전용 — 저장하지 않는다).
@riverpod
class MyReviewFilterController extends _$MyReviewFilterController {
  @override
  MyReviewFilter build() => const MyReviewFilter();

  void setSort(MyReviewSort sort) => state = state.copyWith(sort: sort);

  void togglePhotoOnly() =>
      state = state.copyWith(photoOnly: !state.photoOnly);
}

/// 화면에 실제로 그릴 목록 — 원본 스트림에 정렬·필터를 얹은 것.
///
/// 원본([myReviews])은 그대로 남겨 둔다 — 헤더의 전체 개수는 필터와 무관하다.
@riverpod
AsyncValue<List<MyReviewEntry>> visibleMyReviews(Ref ref) {
  final filter = ref.watch(myReviewFilterControllerProvider);
  return ref.watch(myReviewsProvider).whenData(filter.apply);
}
