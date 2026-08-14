import 'dart:io';

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:vybe/data/datasources/remote/firebase_review_datasource.dart';
import 'package:vybe/data/datasources/remote/firebase_storage_datasource.dart';
import 'package:vybe/data/models/review_model.dart';
import 'package:vybe/domain/repositories/review_repository.dart';

part 'review_repository_impl.g.dart';

@riverpod
ReviewRepository reviewRepository(Ref ref) => ReviewRepositoryImpl(
  FirebaseReviewDataSource(),
  FirebaseStorageDataSource(),
);

class ReviewRepositoryImpl implements ReviewRepository {
  final FirebaseReviewDataSource _dataSource;
  final FirebaseStorageDataSource _storageDataSource;

  ReviewRepositoryImpl(this._dataSource, this._storageDataSource);

  @override
  Future<List<ReviewModel>> getReviews(String clubId) =>
      _dataSource.getReviews(clubId);

  @override
  Stream<List<ReviewModel>> watchReviews(String clubId) =>
      _dataSource.watchReviews(clubId);

  @override
  Stream<List<ReviewModel>> watchUserReviews(String userId) =>
      _dataSource.watchUserReviews(userId);

  @override
  Future<void> createReview(String clubId, ReviewModel review) =>
      _dataSource.createReview(clubId, review);

  @override
  Future<void> updateReview(
          String clubId, String reviewId, ReviewModel review) =>
      _dataSource.updateReview(clubId, reviewId, review);

  @override
  Future<void> deleteReview(String clubId, String reviewId) =>
      _dataSource.deleteReview(clubId, reviewId);

  @override
  String newReviewId(String clubId) => _dataSource.newReviewId(clubId);

  @override
  Future<List<String>> uploadReviewImages({
    required String clubId,
    required String reviewId,
    required List<File> images,
    String? namePrefix,
  }) async {
    final urls = <String>[];
    // 파일명은 인덱스 기반 — 같은 리뷰 재업로드 시 덮어쓰기 되어 고아 파일이 안 생긴다.
    // 단, 기존 첨부를 남겨둔 채 추가하는 수정 경로는 namePrefix로 이름을 갈라야
    // 남겨둔 파일을 덮어쓰지 않는다.
    for (var i = 0; i < images.length; i++) {
      final file = images[i];
      final ext = file.path.split('.').last.toLowerCase();
      final base = namePrefix == null ? '$i' : '${namePrefix}_$i';
      urls.add(
        await _storageDataSource.uploadReviewImage(
          clubId: clubId,
          reviewId: reviewId,
          fileName: '$base.${ext.isEmpty ? 'jpg' : ext}',
          imageFile: file,
        ),
      );
    }
    return urls;
  }

  @override
  Future<void> deleteReviewImages(List<String> imageUrls) async {
    for (final url in imageUrls) {
      await _storageDataSource.deleteFileByUrl(url);
    }
  }
}
