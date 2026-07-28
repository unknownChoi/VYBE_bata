import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:vybe/data/models/review_model.dart';
import 'package:vybe/data/repositories/review_repository_impl.dart';
import 'package:vybe/data/repositories/user_repository_impl.dart';

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
    final result = await AsyncValue.guard(
      () => ref.read(reviewRepositoryProvider).createReview(clubId, review),
    );
    if (!ref.mounted) return;
    state = result;
  }

  /// 리뷰 작성(사진 포함) 한 번에 처리.
  ///
  /// 작성자 이름은 users/{uid}를 직접 조회해 채운다 — `currentUserProvider`는
  /// autoDispose 스트림이라 `ref.read(...future)`로 꺼내면 첫 emit 전에 provider가
  /// dispose돼 future가 에러로 끝난다(→ 이름 빈 값 → 목록에 '익명'). 일회성
  /// `getUser()`는 그 lifecycle에 걸리지 않는다.
  ///
  /// reviewId를 먼저 발급 → 사진을 `reviews/{clubId}/{reviewId}/`에 업로드 →
  /// 받은 URL을 imageUrls에 담아 문서 생성. 업로드가 실패하면 문서도 안 만든다.
  ///
  /// 성공 여부를 반환한다 — 사진 업로드가 길어 화면이 먼저 닫히면 provider가
  /// dispose되어 state를 못 쓰므로, 호출측은 state 대신 이 반환값으로 분기한다.
  Future<bool> submitReview({
    required String clubId,
    required String userId,
    required double rating,
    required String content,
    required List<String> tags,
    required List<File> images,
  }) async {
    // ⚠ 의존성은 반드시 첫 await 전에 전부 꺼낸다.
    // 이 provider는 autoDispose이고 호출측이 `ref.read(...notifier)`로만 잡아서
    // 리스너가 없다 → 프레임 끝에 dispose된다. await 뒤에 `ref`를 다시 쓰면
    // "Cannot use the Ref of reviewViewModelProvider after it has been disposed".
    final userRepository = ref.read(userRepositoryProvider);
    final repository = ref.read(reviewRepositoryProvider);

    state = const AsyncLoading();
    final result = await AsyncValue.guard(() async {
      // 이름 조회를 사진 업로드보다 먼저 — 실패 시 업로드 파일이 남지 않는다.
      final user = await userRepository.getUser(userId);
      final userName = user?.name ?? '';

      final reviewId = repository.newReviewId(clubId);
      final imageUrls = images.isEmpty
          ? const <String>[]
          : await repository.uploadReviewImages(
              clubId: clubId,
              reviewId: reviewId,
              images: images,
            );
      final now = DateTime.now();
      await repository.createReview(
        clubId,
        ReviewModel(
          reviewId: reviewId,
          clubId: clubId,
          userId: userId,
          userName: userName,
          rating: rating,
          content: content,
          imageUrls: imageUrls,
          tags: tags,
          createdAt: now,
          updatedAt: now,
        ),
      );
    });
    // 호출측은 실패 시 일반 토스트만 띄우므로, 원인은 여기서 남긴다.
    if (result case AsyncError(:final error, :final stackTrace)) {
      debugPrint('[ReviewViewModel] submitReview failed: $error\n$stackTrace');
    }
    // 업로드 중 화면이 닫혀 provider가 dispose됐으면 state 접근 금지 (결과만 반환).
    if (ref.mounted) state = result;
    return !result.hasError;
  }

  Future<void> updateReview(
    String clubId,
    String reviewId,
    ReviewModel review,
  ) async {
    state = const AsyncLoading();
    final result = await AsyncValue.guard(
      () => ref
          .read(reviewRepositoryProvider)
          .updateReview(clubId, reviewId, review),
    );
    if (!ref.mounted) return;
    state = result;
  }

  Future<void> deleteReview(String clubId, String reviewId) async {
    state = const AsyncLoading();
    final result = await AsyncValue.guard(
      () => ref.read(reviewRepositoryProvider).deleteReview(clubId, reviewId),
    );
    if (!ref.mounted) return;
    state = result;
  }
}
