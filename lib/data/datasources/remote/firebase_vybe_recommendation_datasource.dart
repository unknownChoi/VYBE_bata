import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:vybe/core/utils/firebase_logger.dart';
import 'package:vybe/data/datasources/remote/firestore_paths.dart';
import 'package:vybe/data/models/vybe_recommendation_model.dart';

class FirebaseVybeRecommendationDataSource {
  final FirebaseFirestore _firestore;

  FirebaseVybeRecommendationDataSource()
    : _firestore = FirebaseFirestore.instance;

  /// 활성 추천 목록을 rank 오름차순으로 조회(1 = featured).
  Future<List<VybeRecommendationModel>> getActiveRecommendations() async {
    logFirebaseAccess(
      file: 'firebase_vybe_recommendation_datasource.dart',
      service:
          'Firestore(vybeRecommendations) [where isActive=true, orderBy rank]',
      purpose: 'vybe 추천 페이지 큐레이션 목록 조회',
    );
    final snapshot = await _firestore
        .collection(FirestorePaths.vybeRecommendations)
        .where('isActive', isEqualTo: true)
        .orderBy('rank')
        .get();
    return snapshot.docs.map(VybeRecommendationModel.fromFirestore).toList();
  }
}
