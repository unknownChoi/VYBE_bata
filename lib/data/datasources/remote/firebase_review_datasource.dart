import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:vybe/core/utils/firebase_logger.dart';
import 'package:vybe/data/datasources/remote/firestore_paths.dart';
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
        .collection(FirestorePaths.clubs)
        .doc(clubId)
        .collection(FirestorePaths.reviews)
        .where('isHidden', isEqualTo: false)
        .orderBy('createdAt', descending: true)
        .get();
    return snapshot.docs.map(ReviewModel.fromFirestore).toList();
  }

  Stream<List<ReviewModel>> watchReviews(String clubId) {
    logFirebaseAccess(
      file: 'firebase_review_datasource.dart',
      service: 'Firestore(clubs/$clubId/reviews) [Stream]',
      purpose: '클럽 리뷰 실시간 구독',
    );
    return _firestore
        .collection(FirestorePaths.clubs)
        .doc(clubId)
        .collection(FirestorePaths.reviews)
        .where('isHidden', isEqualTo: false)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((s) => s.docs.map(ReviewModel.fromFirestore).toList());
  }

  /// 유저가 작성한 모든 리뷰 (전 클럽 대상 collectionGroup 쿼리).
  /// 마이페이지 '내 리뷰 관리' 데이터 소스.
  /// 인덱스: reviews COLLECTION_GROUP (userId ASC, createdAt DESC) 필요.
  ///
  /// 여기엔 `isHidden` 필터를 걸지 않는다 — 숨김은 **작성자 탈퇴** 시에만 붙고,
  /// 탈퇴하면 로그인 자체가 막혀 이 화면에 들어올 수 없다. 필터를 더하면
  /// 3필드 인덱스만 늘어난다.
  Stream<List<ReviewModel>> watchUserReviews(String userId) {
    logFirebaseAccess(
      file: 'firebase_review_datasource.dart',
      service: 'Firestore(collectionGroup:reviews) [Stream]',
      purpose: '내가 작성한 리뷰 목록 실시간 구독 (마이페이지)',
    );
    return _firestore
        .collectionGroup(FirestorePaths.reviews)
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((s) => s.docs.map(ReviewModel.fromFirestore).toList());
  }

  /// 리뷰 문서 ID를 미리 발급한다 (네트워크 호출 없음).
  ///
  /// 첨부 이미지 Storage 경로가 `reviews/{clubId}/{reviewId}/...` 라서
  /// 문서를 쓰기 전에 reviewId가 필요하다 → 업로드 → imageUrls 채워서 set.
  String newReviewId(String clubId) => _firestore
      .collection(FirestorePaths.clubs)
      .doc(clubId)
      .collection(FirestorePaths.reviews)
      .doc()
      .id;

  /// review.reviewId가 비어있지 않으면 그 ID로 생성, 비어있으면 자동 발급.
  Future<void> createReview(String clubId, ReviewModel review) async {
    logFirebaseAccess(
      file: 'firebase_review_datasource.dart',
      service: 'Firestore(clubs/$clubId/reviews)',
      purpose: '리뷰 작성',
    );
    final collection = _firestore
        .collection(FirestorePaths.clubs)
        .doc(clubId)
        .collection(FirestorePaths.reviews);
    if (review.reviewId.isEmpty) {
      await collection.add(review.toFirestore());
    } else {
      await collection.doc(review.reviewId).set(review.toFirestore());
    }
  }

  Future<void> updateReview(
    String clubId,
    String reviewId,
    ReviewModel review,
  ) async {
    logFirebaseAccess(
      file: 'firebase_review_datasource.dart',
      service: 'Firestore(clubs/$clubId/reviews/$reviewId)',
      purpose: '리뷰 수정',
    );
    await _firestore
        .collection(FirestorePaths.clubs)
        .doc(clubId)
        .collection(FirestorePaths.reviews)
        .doc(reviewId)
        .update({
          'rating': review.rating,
          'content': review.content,
          'imageUrls': review.imageUrls,
          'tags': review.tags,
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
        .collection(FirestorePaths.clubs)
        .doc(clubId)
        .collection(FirestorePaths.reviews)
        .doc(reviewId)
        .delete();
  }
}
