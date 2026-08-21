import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:vybe/core/utils/firebase_logger.dart';
import 'package:vybe/data/datasources/remote/firestore_paths.dart';
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
        .collection(FirestorePaths.favorites)
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
        .collection(FirestorePaths.favorites)
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
    await _firestore.collection(FirestorePaths.favorites).add({
      'userId': userId,
      'clubId': clubId,
      // 탈퇴 시 서버가 true로 바꾼다. 찜 목록은 이 값으로 거르지 않지만,
      // `onFavoriteDeleted`가 "집계에서 이미 뺐는지"를 이 필드로 판단하므로
      // 기존 문서(백필됨)와 같은 모양을 유지한다.
      'isHidden': false,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> removeFavorite(String userId, String clubId) async {
    logFirebaseAccess(
      file: 'firebase_favorite_datasource.dart',
      service: 'Firestore(favorites) [where userId=$userId, clubId=$clubId]',
      purpose: '찜 삭제 (중복 포함 전체)',
    );
    final snapshot = await _firestore
        .collection(FirestorePaths.favorites)
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
