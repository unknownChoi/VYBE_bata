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
  ///
  /// [namePrefix]를 주면 파일명이 `{namePrefix}_{index}.{ext}`가 된다.
  /// 리뷰 수정처럼 기존 첨부가 남아 있는 경우에 필요하다 — 기본 인덱스 이름은
  /// 이미 올라가 있는 파일을 덮어써서 남겨둔 사진의 URL이 다른 이미지가 된다.
  Future<List<String>> uploadReviewImages({
    required String clubId,
    required String reviewId,
    required List<File> images,
    String? namePrefix,
  });

  /// 리뷰 첨부 이미지 삭제 (URL 기준). 개별 실패는 무시한다.
  Future<void> deleteReviewImages(List<String> imageUrls);
}
