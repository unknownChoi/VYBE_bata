import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:vybe/core/utils/firebase_logger.dart';
import 'package:vybe/core/utils/geohash_utils.dart';
import 'package:vybe/data/models/club_info_model.dart';
import 'package:vybe/data/models/club_model.dart';
import 'package:vybe/data/models/menu_model.dart';

class FirebaseClubDataSource {
  final FirebaseFirestore _firestore;

  FirebaseClubDataSource() : _firestore = FirebaseFirestore.instance;

  Future<List<ClubModel>> getActiveClubs() async {
    logFirebaseAccess(
      file: 'firebase_club_datasource.dart',
      service: 'Firestore(clubs) [where isActive=true]',
      purpose: '활성 클럽 목록 조회',
    );
    final snapshot = await _firestore
        .collection('clubs')
        .where('isActive', isEqualTo: true)
        .get();
    return snapshot.docs.map(ClubModel.fromFirestore).toList();
  }

  Stream<List<ClubModel>> watchActiveClubs() {
    logFirebaseAccess(
      file: 'firebase_club_datasource.dart',
      service: 'Firestore(clubs) [Stream, where isActive=true]',
      purpose: '활성 클럽 목록 실시간 구독',
    );
    return _firestore
        .collection('clubs')
        .where('isActive', isEqualTo: true)
        .snapshots()
        .map((s) => s.docs.map(ClubModel.fromFirestore).toList());
  }

  Future<ClubModel?> getClub(String clubId) async {
    await Future.delayed(const Duration(seconds: 5)); // TODO: remove after skeleton test
    logFirebaseAccess(
      file: 'firebase_club_datasource.dart',
      service: 'Firestore(clubs/$clubId)',
      purpose: '클럽 상세 정보 조회',
    );
    final doc = await _firestore.collection('clubs').doc(clubId).get();
    if (!doc.exists) return null;
    return ClubModel.fromFirestore(doc);
  }

  Future<ClubInfoModel?> getClubInfo(String clubId) async {
    logFirebaseAccess(
      file: 'firebase_club_datasource.dart',
      service: 'Firestore(clubs/$clubId/info/$clubId)',
      purpose: '클럽 운영 정보 조회',
    );
    final doc = await _firestore
        .collection('clubs')
        .doc(clubId)
        .collection('info')
        .doc(clubId)
        .get();
    if (!doc.exists) return null;
    return ClubInfoModel.fromFirestore(doc);
  }

  Future<List<MenuModel>> getMenus(String clubId) async {
    await Future.delayed(const Duration(seconds: 5)); // TODO: remove after skeleton test
    logFirebaseAccess(
      file: 'firebase_club_datasource.dart',
      service: 'Firestore(clubs/$clubId/menus) [isAvailable=true]',
      purpose: '[메뉴탭] 전체 메뉴 목록 조회',
    );
    final snapshot = await _firestore
        .collection('clubs')
        .doc(clubId)
        .collection('menus')
        .where('isAvailable', isEqualTo: true)
        .get();
    return snapshot.docs.map(MenuModel.fromFirestore).toList();
  }

  Future<List<MenuModel>> getFeaturedMenus(String clubId) async {
    logFirebaseAccess(
      file: 'firebase_club_datasource.dart',
      service: 'Firestore(clubs/$clubId/menus) [isFeatured=true, isAvailable=true]',
      purpose: '[홈탭] 대표 메뉴 조회',
    );
    final snapshot = await _firestore
        .collection('clubs')
        .doc(clubId)
        .collection('menus')
        .where('isAvailable', isEqualTo: true)
        .where('isFeatured', isEqualTo: true)
        .get();
    return snapshot.docs.map(MenuModel.fromFirestore).toList();
  }

  Future<List<ClubModel>> getClubsByArea(String area) async {
    logFirebaseAccess(
      file: 'firebase_club_datasource.dart',
      service: 'Firestore(clubs) [where isActive=true, area=$area]',
      purpose: '지역별 클럽 목록 조회',
    );
    final snapshot = await _firestore
        .collection('clubs')
        .where('isActive', isEqualTo: true)
        .where('area', isEqualTo: area)
        .get();
    return snapshot.docs.map(ClubModel.fromFirestore).toList();
  }

  Future<List<ClubModel>> getClubsNearby(
      double lat, double lng, double radiusKm) async {
    logFirebaseAccess(
      file: 'firebase_club_datasource.dart',
      service: 'Firestore(clubs) [geohash range query, radius: ${radiusKm}km]',
      purpose: '지도 화면 내 클럽 조회',
    );

    final precision = GeohashUtils.precisionForRadius(radiusKm);
    final prefixes = GeohashUtils.neighborPrefixes(lat, lng, precision);

    // ignore: avoid_print
    print('[NearbySearch] query center=($lat, $lng) '
        'radius=${radiusKm.toStringAsFixed(3)}km '
        'precision=$precision '
        'prefixes(${prefixes.length})=$prefixes');

    final snapshots = await Future.wait(
      prefixes.map((prefix) => _firestore
          .collection('clubs')
          .where('isActive', isEqualTo: true)
          .where('location.geohash', isGreaterThanOrEqualTo: prefix)
          .where('location.geohash', isLessThan: '${prefix}{')
          .get()),
    );

    final seen = <String>{};
    final result = snapshots
        .expand((s) => s.docs)
        .where((doc) => seen.add(doc.id))
        .map(ClubModel.fromFirestore)
        .where((c) => c.lat != 0 && c.lng != 0)
        .where((c) =>
            GeohashUtils.haversineKm(lat, lng, c.lat, c.lng) <= radiusKm)
        .toList();

    // ignore: avoid_print
    print('[NearbySearch] result count=${result.length} '
        'clubs=${result.map((c) => '${c.name}@(${c.lat},${c.lng},${c.geohash})').toList()}');

    return result;
  }

  Future<List<ClubModel>> searchClubs(String keyword) async {
    logFirebaseAccess(
      file: 'firebase_club_datasource.dart',
      service: 'Firestore(clubs) [where isActive=true]',
      purpose: '클럽 검색 (keyword: $keyword)',
    );
    final snapshot = await _firestore
        .collection('clubs')
        .where('isActive', isEqualTo: true)
        .get();
    final lower = keyword.toLowerCase();
    return snapshot.docs
        .map(ClubModel.fromFirestore)
        .where((c) =>
            c.name.toLowerCase().contains(lower) ||
            c.tags.any((t) => t.toLowerCase().contains(lower)))
        .toList();
  }
}
