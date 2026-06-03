import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:vybe/core/utils/firebase_logger.dart';
import 'package:vybe/data/models/review_model.dart';

class FirebaseReviewDataSource {
  final FirebaseFirestore _firestore;

  FirebaseReviewDataSource() : _firestore = FirebaseFirestore.instance;

  Future<List<ReviewModel>> getReviews(String clubId) async {
    logFirebaseAccess(
      file: 'firebase_review_datasource.dart',
      service: 'Firestore(clubs/$clubId/reviews)',
      purpose: '클럽 리뷰 목록 조회',
    );
    final snapshot = await _firestore
        .collection('clubs')
        .doc(clubId)
        .collection('reviews')
        .orderBy('createdAt', descending: true)
        .get();
    return snapshot.docs.map(ReviewModel.fromFirestore).toList();
  }

  Stream<List<ReviewModel>> watchReviews(String clubId) async* {
    await Future.delayed(const Duration(seconds: 5)); // TODO: remove after skeleton test
    logFirebaseAccess(
      file: 'firebase_review_datasource.dart',
      service: 'Firestore(clubs/$clubId/reviews) [Stream]',
      purpose: '클럽 리뷰 실시간 구독',
    );
    yield* _firestore
        .collection('clubs')
        .doc(clubId)
        .collection('reviews')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((s) => s.docs.map(ReviewModel.fromFirestore).toList());
  }

  Future<void> createReview(String clubId, ReviewModel review) async {
    logFirebaseAccess(
      file: 'firebase_review_datasource.dart',
      service: 'Firestore(clubs/$clubId/reviews)',
      purpose: '리뷰 작성',
    );
    await _firestore
        .collection('clubs')
        .doc(clubId)
        .collection('reviews')
        .add(review.toFirestore());
  }

  Future<void> updateReview(
      String clubId, String reviewId, ReviewModel review) async {
    logFirebaseAccess(
      file: 'firebase_review_datasource.dart',
      service: 'Firestore(clubs/$clubId/reviews/$reviewId)',
      purpose: '리뷰 수정',
    );
    await _firestore
        .collection('clubs')
        .doc(clubId)
        .collection('reviews')
        .doc(reviewId)
        .update({
      'rating': review.rating,
      'content': review.content,
      'imageUrls': review.imageUrls,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> deleteReview(String clubId, String reviewId) async {
    logFirebaseAccess(
      file: 'firebase_review_datasource.dart',
      service: 'Firestore(clubs/$clubId/reviews/$reviewId)',
      purpose: '리뷰 삭제',
    );
    await _firestore
        .collection('clubs')
        .doc(clubId)
        .collection('reviews')
        .doc(reviewId)
        .delete();
  }
}
