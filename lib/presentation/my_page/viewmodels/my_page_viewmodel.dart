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
