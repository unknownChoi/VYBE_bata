import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:vybe/core/utils/firebase_logger.dart';
import 'package:vybe/data/datasources/remote/firestore_paths.dart';
import 'package:vybe/data/models/banner_model.dart';

class FirebaseBannerDataSource {
  final FirebaseFirestore _firestore;

  FirebaseBannerDataSource() : _firestore = FirebaseFirestore.instance;

  Future<List<BannerModel>> getActiveBanners() async {
    logFirebaseAccess(
      file: 'firebase_banner_datasource.dart',
      service: 'Firestore(banners) [where isActive=true]',
      purpose: '홈 화면 배너 목록 조회',
    );
    final now = DateTime.now();
    final snapshot = await _firestore
        .collection(FirestorePaths.banners)
        .where('isActive', isEqualTo: true)
        .get();
    final banners = snapshot.docs
        .map(BannerModel.fromFirestore)
        .where((b) => b.startAt.isBefore(now) && b.endAt.isAfter(now))
        .toList();
    banners.sort((a, b) => a.order.compareTo(b.order));
    return banners;
  }
}
