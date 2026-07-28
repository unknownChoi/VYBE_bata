import 'dart:io';

import 'package:vybe/data/models/review_model.dart';

abstract class ReviewRepository {
  Future<List<ReviewModel>> getReviews(String clubId);
  Stream<List<ReviewModel>> watchReviews(String clubId);
  Stream<List<ReviewModel>> watchUserReviews(String userId);
  Future<void> createReview(String clubId, ReviewModel review);
  Future<void> updateReview(String clubId, String reviewId, ReviewModel review);
  Future<void> deleteReview(String clubId, String reviewId);

  /// 리뷰 문서 ID 사전 발급 (첨부 이미지 Storage 경로에 필요).
  String newReviewId(String clubId);

  /// 리뷰 첨부 이미지 업로드 → 다운로드 URL 목록 (입력 순서 유지).
  Future<List<String>> uploadReviewImages({
    required String clubId,
    required String reviewId,
    required List<File> images,
  });
}
