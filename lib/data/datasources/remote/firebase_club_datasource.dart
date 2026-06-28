import 'dart:math' as math;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:vybe/core/utils/firebase_logger.dart';
import 'package:vybe/core/utils/geohash_utils.dart';
import 'package:vybe/data/models/club_info_model.dart';
import 'package:vybe/data/models/club_model.dart';
import 'package:vybe/data/models/menu_model.dart';
import 'package:vybe/data/models/photo_model.dart';

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

  /// 서비스 음료(무료) 제공 클럽 목록. 서비스 음료 페이지 데이터 소스.
  Future<List<ClubModel>> getServiceDrinkClubs() async {
    logFirebaseAccess(
      file: 'firebase_club_datasource.dart',
      service:
          'Firestore(clubs) [where isActive=true, serviceDrink.isOffered=true]',
      purpose: '서비스 음료 제공 클럽 목록 조회',
    );
    final snapshot = await _firestore
        .collection('clubs')
        .where('isActive', isEqualTo: true)
        .where('serviceDrink.isOffered', isEqualTo: true)
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
    logFirebaseAccess(
      file: 'firebase_club_datasource.dart',
      service: 'Firestore(clubs/$clubId)',
      purpose: '클럽 상세 정보 조회',
    );
    final doc = await _firestore.collection('clubs').doc(clubId).get();
    if (!doc.exists) return null;
    return ClubModel.fromFirestore(doc);
  }

  /// 여러 클럽을 ID 목록으로 일괄 조회(whereIn 10개 청크).
  /// vybe 추천 등 clubId 참조 컬렉션과 조인할 때 사용.
  Future<List<ClubModel>> getClubsByIds(List<String> ids) async {
    if (ids.isEmpty) return [];
    logFirebaseAccess(
      file: 'firebase_club_datasource.dart',
      service: 'Firestore(clubs) [whereIn documentId, ${ids.length}개]',
      purpose: '클럽 ID 목록 일괄 조회(추천 조인용)',
    );
    final result = <ClubModel>[];
    for (var i = 0; i < ids.length; i += 10) {
      final chunk = ids.sublist(i, math.min(i + 10, ids.length));
      final snapshot = await _firestore
          .collection('clubs')
          .where(FieldPath.documentId, whereIn: chunk)
          .get();
      result.addAll(snapshot.docs.map(ClubModel.fromFirestore));
    }
    return result;
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

  Future<List<PhotoModel>> getPhotos(String clubId) async {
    logFirebaseAccess(
      file: 'firebase_club_datasource.dart',
      service: 'Firestore(clubs/$clubId/photos)',
      purpose: '[사진탭] 갤러리 사진 목록 조회',
    );
    final snapshot = await _firestore
        .collection('clubs')
        .doc(clubId)
        .collection('photos')
        .orderBy('createdAt', descending: true)
        .get();
    return snapshot.docs.map(PhotoModel.fromFirestore).toList();
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

  /// searchTokens(접두사 토큰, Cloud Function 생성) 기반 검색 — 평점순 + 서버 페이지네이션.
  /// [startAfter]가 있으면 그 문서 다음부터(다음 페이지). 본 만큼만 read.
  Future<({List<ClubModel> clubs, DocumentSnapshot? lastDoc, bool hasMore})>
      searchClubsPage(
    String keyword, {
    DocumentSnapshot? startAfter,
    int pageSize = 10,
  }) async {
    final tokens = _queryTokens(keyword);
    if (tokens.isEmpty) {
      return (clubs: <ClubModel>[], lastDoc: null, hasMore: false);
    }

    logFirebaseAccess(
      file: 'firebase_club_datasource.dart',
      service: 'Firestore(clubs) [isActive + searchTokens any, orderBy rating]',
      purpose: '클럽 검색 (keyword: $keyword, page: ${startAfter == null ? 1 : "next"})',
    );
    // clubs read 규칙(isActive==true) 충족 위해 isActive 필터 필수 + 평점 정렬.
    // → isActive + searchTokens(array) + rating 복합 인덱스 필요.
    Query<Map<String, dynamic>> query = _firestore
        .collection('clubs')
        .where('isActive', isEqualTo: true)
        .where('searchTokens', arrayContainsAny: tokens)
        .orderBy('rating', descending: true)
        .limit(pageSize);
    if (startAfter != null) query = query.startAfterDocument(startAfter);

    final snapshot = await query.get();
    final docs = snapshot.docs;
    return (
      clubs: docs.map(ClubModel.fromFirestore).toList(),
      lastDoc: docs.isEmpty ? null : docs.last,
      hasMore: docs.length == pageSize,
    );
  }

  /// 검색어 → arrayContainsAny용 토큰(최대 10개). 단어 + 공백제거 통째.
  /// 저장 토큰이 접두사 집합이라 부분 입력도 일치한다.
  List<String> _queryTokens(String raw) {
    final q = raw.toLowerCase().trim();
    if (q.isEmpty) return const [];
    final set = <String>{};
    final noSpace = q.replaceAll(RegExp(r'\s+'), '');
    if (noSpace.isNotEmpty) set.add(noSpace);
    for (final w in q.split(RegExp(r'\s+'))) {
      if (w.isNotEmpty) set.add(w);
    }
    return set.take(10).toList();
  }
}
