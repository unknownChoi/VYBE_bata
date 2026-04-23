import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:vybe/core/utils/firebase_logger.dart';
import 'package:vybe/data/models/search_history_model.dart';

class FirebaseSearchHistoryDataSource {
  final FirebaseFirestore _firestore;

  FirebaseSearchHistoryDataSource() : _firestore = FirebaseFirestore.instance;

  Future<List<SearchHistoryModel>> getSearchHistory(String userId) async {
    logFirebaseAccess(
      file: 'firebase_search_history_datasource.dart',
      service: 'Firestore(users/$userId/searchHistory)',
      purpose: '최근 검색어 목록 표시',
    );
    final snapshot = await _firestore
        .collection('users')
        .doc(userId)
        .collection('searchHistory')
        .orderBy('createdAt', descending: true)
        .limit(20)
        .get();
    return snapshot.docs.map(SearchHistoryModel.fromFirestore).toList();
  }

  Future<void> addSearchHistory(String userId, String keyword) async {
    logFirebaseAccess(
      file: 'firebase_search_history_datasource.dart',
      service: 'Firestore(users/$userId/searchHistory)',
      purpose: '검색어 "$keyword" 저장 (중복 제거 후 추가)',
    );
    final existing = await _firestore
        .collection('users')
        .doc(userId)
        .collection('searchHistory')
        .where('keyword', isEqualTo: keyword)
        .get();
    for (final doc in existing.docs) {
      await doc.reference.delete();
    }
    await _firestore
        .collection('users')
        .doc(userId)
        .collection('searchHistory')
        .add({
      'userId': userId,
      'keyword': keyword,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> deleteSearchHistory(String userId, String historyId) async {
    logFirebaseAccess(
      file: 'firebase_search_history_datasource.dart',
      service: 'Firestore(users/$userId/searchHistory/$historyId)',
      purpose: '최근 검색어 개별 삭제',
    );
    await _firestore
        .collection('users')
        .doc(userId)
        .collection('searchHistory')
        .doc(historyId)
        .delete();
  }

  Future<void> clearAllSearchHistory(String userId) async {
    logFirebaseAccess(
      file: 'firebase_search_history_datasource.dart',
      service: 'Firestore(users/$userId/searchHistory)',
      purpose: '최근 검색어 전체 삭제',
    );
    final snapshot = await _firestore
        .collection('users')
        .doc(userId)
        .collection('searchHistory')
        .get();
    for (final doc in snapshot.docs) {
      await doc.reference.delete();
    }
  }
}
