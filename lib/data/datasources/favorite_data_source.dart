import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:vybe/data/models/favorite_model.dart';

class FavoriteDataSource {
  final FirebaseFirestore _firestore;

  FavoriteDataSource() : _firestore = FirebaseFirestore.instance;

  Stream<List<FavoriteModel>> watchUserFavorites(String userId) {
    return _firestore
        .collection('favorites')
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((s) => s.docs.map(FavoriteModel.fromFirestore).toList());
  }

  Future<bool> isFavorite(String userId, String clubId) async {
    final snapshot = await _firestore
        .collection('favorites')
        .where('userId', isEqualTo: userId)
        .where('clubId', isEqualTo: clubId)
        .limit(1)
        .get();
    return snapshot.docs.isNotEmpty;
  }

  Future<void> addFavorite(String userId, String clubId) async {
    await _firestore.collection('favorites').add({
      'userId': userId,
      'clubId': clubId,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> removeFavorite(String userId, String clubId) async {
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
