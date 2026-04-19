import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:vybe/data/models/review_model.dart';

class ReviewDataSource {
  final FirebaseFirestore _firestore;

  ReviewDataSource() : _firestore = FirebaseFirestore.instance;

  Future<List<ReviewModel>> getReviews(String clubId) async {
    final snapshot = await _firestore
        .collection('clubs')
        .doc(clubId)
        .collection('reviews')
        .orderBy('createdAt', descending: true)
        .get();
    return snapshot.docs.map(ReviewModel.fromFirestore).toList();
  }

  Stream<List<ReviewModel>> watchReviews(String clubId) {
    return _firestore
        .collection('clubs')
        .doc(clubId)
        .collection('reviews')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((s) => s.docs.map(ReviewModel.fromFirestore).toList());
  }

  Future<void> createReview(String clubId, ReviewModel review) async {
    await _firestore
        .collection('clubs')
        .doc(clubId)
        .collection('reviews')
        .add(review.toFirestore());
  }

  Future<void> updateReview(
      String clubId, String reviewId, ReviewModel review) async {
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
    await _firestore
        .collection('clubs')
        .doc(clubId)
        .collection('reviews')
        .doc(reviewId)
        .delete();
  }
}
