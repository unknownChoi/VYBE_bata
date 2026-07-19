import 'package:vybe/data/models/review_model.dart';

abstract class ReviewRepository {
  Future<List<ReviewModel>> getReviews(String clubId);
  Stream<List<ReviewModel>> watchReviews(String clubId);
  Stream<List<ReviewModel>> watchUserReviews(String userId);
  Future<void> createReview(String clubId, ReviewModel review);
  Future<void> updateReview(String clubId, String reviewId, ReviewModel review);
  Future<void> deleteReview(String clubId, String reviewId);
}
