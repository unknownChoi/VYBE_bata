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
    final collection = _firestore
        .collection('users')
        .doc(userId)
        .collection('searchHistory');
    final existing =
        await collection.where('keyword', isEqualTo: keyword).get();

    // 중복 제거 + 신규 추가를 단일 batch로 (순차 await 제거).
    final batch = _firestore.batch();
    for (final doc in existing.docs) {
      batch.delete(doc.reference);
    }
    batch.set(collection.doc(), {
      'userId': userId,
      'keyword': keyword,
      'createdAt': FieldValue.serverTimestamp(),
    });
    await batch.commit();
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
    if (snapshot.docs.isEmpty) return;

    // 순차 await 대신 batch 삭제. 문서는 검색어(중복 제거)마다 1개씩 쌓여
    // 보통 수십 개지만, batch 쓰기 한도(500)를 넘지 않게 잘라서 커밋한다.
    const chunkSize = 400;
    for (var i = 0; i < snapshot.docs.length; i += chunkSize) {
      final end = (i + chunkSize).clamp(0, snapshot.docs.length);
      final batch = _firestore.batch();
      for (final doc in snapshot.docs.sublist(i, end)) {
        batch.delete(doc.reference);
      }
      await batch.commit();
    }
  }
}
