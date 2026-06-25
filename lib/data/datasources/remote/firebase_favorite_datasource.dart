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

  Future<void> addFavorite(
    String userId,
    String clubId, {
    String? folderId,
  }) async {
    logFirebaseAccess(
      file: 'firebase_favorite_datasource.dart',
      service: 'Firestore(favorites)',
      purpose: '찜 추가 (userId=$userId, clubId=$clubId)',
    );
    await _firestore.collection('favorites').add({
      'userId': userId,
      'clubId': clubId,
      if (folderId != null) 'folderId': folderId,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  /// 찜의 소속 그룹 변경. folderId=null이면 그룹 해제(전체).
  Future<void> moveFavoriteToFolder(
    String userId,
    String clubId,
    String? folderId,
  ) async {
    logFirebaseAccess(
      file: 'firebase_favorite_datasource.dart',
      service: 'Firestore(favorites) [where userId=$userId, clubId=$clubId]',
      purpose: '찜 그룹 이동 (folderId=$folderId)',
    );
    final snapshot = await _firestore
        .collection('favorites')
        .where('userId', isEqualTo: userId)
        .where('clubId', isEqualTo: clubId)
        .get();
    final batch = _firestore.batch();
    for (final doc in snapshot.docs) {
      batch.update(doc.reference, {
        'folderId': folderId ?? FieldValue.delete(),
      });
    }
    await batch.commit();
  }

  Future<void> removeFavorite(String userId, String clubId) async {
    logFirebaseAccess(
      file: 'firebase_favorite_datasource.dart',
      service: 'Firestore(favorites) [where userId=$userId, clubId=$clubId]',
      purpose: '찜 삭제 (중복 포함 전체)',
    );
    final snapshot = await _firestore
        .collection('favorites')
        .where('userId', isEqualTo: userId)
        .where('clubId', isEqualTo: clubId)
        .get();
    final batch = _firestore.batch();
    for (final doc in snapshot.docs) {
      batch.delete(doc.reference);
    }
    await batch.commit();
  }
}
