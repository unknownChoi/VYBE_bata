import 'dart:math' as math;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
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

  /// 입장비 무료(entryFeeMin=0) 클럽 목록. 입장비 무료 페이지 데이터 소스.
  Future<List<ClubModel>> getFreeEntryClubs() async {
    logFirebaseAccess(
      file: 'firebase_club_datasource.dart',
      service: 'Firestore(clubs) [where isActive=true, entryFeeMin=0]',
      purpose: '입장비 무료 클럽 목록 조회',
    );
    final snapshot = await _firestore
        .collection('clubs')
        .where('isActive', isEqualTo: true)
        .where('entryFeeMin', isEqualTo: 0)
        .get();
    return snapshot.docs.map(ClubModel.fromFirestore).toList();
  }

  /// 힙합 클럽 목록(genre=힙합). 힙합 페이지 인기 클럽 TOP 10 데이터 소스.
  /// 정렬(평점/리뷰순)·상위 N개는 화면에서 처리.
  Future<List<ClubModel>> getHipHopClubs() async {
    logFirebaseAccess(
      file: 'firebase_club_datasource.dart',
      service: "Firestore(clubs) [where isActive=true, genre='힙합']",
      purpose: '힙합 장르 클럽 목록 조회',
    );
    final snapshot = await _firestore
        .collection('clubs')
        .where('isActive', isEqualTo: true)
        .where('genre', isEqualTo: '힙합')
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

    // 릴리즈에선 문자열 조립까지 통째로 제거되도록 kDebugMode로 감싼다.
    if (kDebugMode) {
      debugPrint('[NearbySearch] query center=($lat, $lng) '
          'radius=${radiusKm.toStringAsFixed(3)}km '
          'precision=$precision '
          'prefixes(${prefixes.length})=$prefixes');
    }

    final snapshots = await Future.wait(
      prefixes.map((prefix) => _firestore
          .collection('clubs')
          .where('isActive', isEqualTo: true)
          .where('location.geohash', isGreaterThanOrEqualTo: prefix)
          .where('location.geohash', isLessThan: '$prefix{')
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

    if (kDebugMode) {
      debugPrint('[NearbySearch] result count=${result.length} '
          'clubs=${result.map((c) => '${c.name}@(${c.lat},${c.lng},${c.geohash})').toList()}');
    }

    return result;
  }

}
