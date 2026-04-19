import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:vybe/data/models/review_model.dart';
import 'package:vybe/data/repositories/review_repository_impl.dart';

part 'review_viewmodel.g.dart';

/// 클럽 리뷰 목록 실시간 스트림
@riverpod
Stream<List<ReviewModel>> reviewList(Ref ref, String clubId) {
  return ref.watch(reviewRepositoryProvider).watchReviews(clubId);
}

@riverpod
class ReviewViewModel extends _$ReviewViewModel {
  @override
  AsyncValue<void> build() => const AsyncData(null);

  Future<void> createReview(String clubId, ReviewModel review) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref.read(reviewRepositoryProvider).createReview(clubId, review),
    );
  }

  Future<void> updateReview(
      String clubId, String reviewId, ReviewModel review) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref
          .read(reviewRepositoryProvider)
          .updateReview(clubId, reviewId, review),
    );
  }

  Future<void> deleteReview(String clubId, String reviewId) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref
          .read(reviewRepositoryProvider)
          .deleteReview(clubId, reviewId),
    );
  }
}
