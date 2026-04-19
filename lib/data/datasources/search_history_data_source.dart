import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:vybe/data/models/search_history_model.dart';

class SearchHistoryDataSource {
  final FirebaseFirestore _firestore;

  SearchHistoryDataSource() : _firestore = FirebaseFirestore.instance;

  Future<List<SearchHistoryModel>> getSearchHistory(String userId) async {
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
    await _firestore
        .collection('users')
        .doc(userId)
        .collection('searchHistory')
        .doc(historyId)
        .delete();
  }

  Future<void> clearAllSearchHistory(String userId) async {
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
