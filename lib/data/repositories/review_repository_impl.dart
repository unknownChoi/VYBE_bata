import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:vybe/data/datasources/review_data_source.dart';
import 'package:vybe/data/models/review_model.dart';
import 'package:vybe/domain/repositories/review_repository.dart';

part 'review_repository_impl.g.dart';

@riverpod
ReviewRepository reviewRepository(Ref ref) =>
    ReviewRepositoryImpl(ReviewDataSource());

class ReviewRepositoryImpl implements ReviewRepository {
  final ReviewDataSource _dataSource;

  ReviewRepositoryImpl(this._dataSource);

  @override
  Future<List<ReviewModel>> getReviews(String clubId) =>
      _dataSource.getReviews(clubId);

  @override
  Stream<List<ReviewModel>> watchReviews(String clubId) =>
      _dataSource.watchReviews(clubId);

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
}
