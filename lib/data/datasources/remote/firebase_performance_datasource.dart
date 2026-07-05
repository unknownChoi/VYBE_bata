import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:vybe/core/utils/firebase_logger.dart';
import 'package:vybe/data/models/performance_model.dart';

class FirebasePerformanceDataSource {
  final FirebaseFirestore _firestore;

  FirebasePerformanceDataSource() : _firestore = FirebaseFirestore.instance;

  /// 오늘(KST) 해당 장르의 공연을 시작시각 오름차순으로 조회.
  /// genre + date(YYYYMMDD) + isActive 복합 인덱스 사용.
  /// date 미지정 시 현재 KST 날짜 자동 계산.
  Future<List<PerformanceModel>> getTodayPerformances({
    String genre = '힙합',
    String? date,
  }) async {
    final bucket = date ?? _nightBucket(DateTime.now());
    logFirebaseAccess(
      file: 'firebase_performance_datasource.dart',
      service:
          "Firestore(performances) [where genre='$genre', date='$bucket', orderBy startAt]",
      purpose: '장르 페이지 오늘 공연 일정 조회',
    );
    // 인덱스 (genre, date, startAt) 사용. isActive는 클라에서 필터
    // (3개 equality + orderBy 동시 사용 시 추가 인덱스 필요 → 회피).
    final snapshot = await _firestore
        .collection('performances')
        .where('genre', isEqualTo: genre)
        .where('date', isEqualTo: bucket)
        .orderBy('startAt')
        .get();
    return snapshot.docs
        .map(PerformanceModel.fromFirestore)
        .where((p) => p.isActive)
        .toList();
  }

  /// 특정 클럽의 다가오는 공연(오늘 밤 이후) 시작시각 오름차순 조회.
  /// (clubId, startAt) 복합 인덱스 사용. 과거 공연은 date(YYYYMMDD) 문자열
  /// 비교로 클라에서 제외 — 오늘 밤 버킷 이상만 통과.
  Future<List<PerformanceModel>> getUpcomingPerformancesByClub(
    String clubId,
  ) async {
    final bucket = _nightBucket(DateTime.now());
    logFirebaseAccess(
      file: 'firebase_performance_datasource.dart',
      service:
          "Firestore(performances) [where clubId='$clubId', orderBy startAt]",
      purpose: '클럽 상세 공연 일정 조회',
    );
    final snapshot = await _firestore
        .collection('performances')
        .where('clubId', isEqualTo: clubId)
        .orderBy('startAt')
        .get();
    return snapshot.docs
        .map(PerformanceModel.fromFirestore)
        .where((p) => p.isActive && p.date.compareTo(bucket) >= 0)
        .toList();
  }

  /// 오늘 '밤' 버킷(YYYYMMDD). performances.date 는 밤 시작일 기준이라
  /// 새벽 공연(예 02:00)도 그 전날 date 로 저장됨(startAt만 +1일).
  /// 따라서 KST 새벽(06시 미만)에는 전날을 밤 버킷으로 써야 진행 중인
  /// 오늘밤 라인업이 유지됨(6시 이후 새 밤으로 롤오버).
  String _nightBucket(DateTime now) {
    var k = now.toUtc().add(const Duration(hours: 9));
    if (k.hour < 6) k = k.subtract(const Duration(days: 1));
    final y = k.year.toString().padLeft(4, '0');
    final m = k.month.toString().padLeft(2, '0');
    final d = k.day.toString().padLeft(2, '0');
    return '$y$m$d';
  }
}
