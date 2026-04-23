import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:vybe/core/utils/firebase_logger.dart';
import 'package:vybe/data/models/favorite_model.dart';

class FirebaseFavoriteDataSource {
  final FirebaseFirestore _firestore;

  FirebaseFavoriteDataSource() : _firestore = FirebaseFirestore.instance;

  Stream<List<FavoriteModel>> watchUserFavorites(String userId) {
    logFirebaseAccess(
      file: 'firebase_favorite_datasource.dart',
      service: 'Firestore(favorites) [Stream, where userId=$userId]',
      purpose: '사용자 찜 목록 실시간 구독',
    );
    return _firestore
        .collection('favorites')
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((s) => s.docs.map(FavoriteModel.fromFirestore).toList());
  }

  Future<bool> isFavorite(String userId, String clubId) async {
    logFirebaseAccess(
      file: 'firebase_favorite_datasource.dart',
      service: 'Firestore(favorites) [where userId=$userId, clubId=$clubId]',
      purpose: '찜 여부 확인',
    );
    final snapshot = await _firestore
        .collection('favorites')
        .where('userId', isEqualTo: userId)
        .where('clubId', isEqualTo: clubId)
        .limit(1)
        .get();
    return snapshot.docs.isNotEmpty;
  }

  Future<void> addFavorite(String userId, String clubId) async {
    logFirebaseAccess(
      file: 'firebase_favorite_datasource.dart',
      service: 'Firestore(favorites)',
      purpose: '찜 추가 (userId=$userId, clubId=$clubId)',
    );
    await _firestore.collection('favorites').add({
      'userId': userId,
      'clubId': clubId,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> removeFavorite(String userId, String clubId) async {
    logFirebaseAccess(
      file: 'firebase_favorite_datasource.dart',
      service: 'Firestore(favorites) [where userId=$userId, clubId=$clubId]',
      purpose: '찜 삭제',
    );
    final snapshot = await _firestore
        .collection('favorites')
        .where('userId', isEqualTo: userId)
        .where('clubId', isEqualTo: clubId)
        .limit(1)
        .get();
    for (final doc in snapshot.docs) {
      await doc.reference.delete();
    }
  }
}
