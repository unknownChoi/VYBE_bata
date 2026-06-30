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
    final bucket = date ?? _kstDateStr(DateTime.now());
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

  /// KST(UTC+9) 기준 YYYYMMDD. 자정 직후 새벽까지 같은 '오늘'로 보려면
  /// 호출부에서 date를 직접 넘겨 처리(여기선 단순 KST 달력일).
  String _kstDateStr(DateTime now) {
    final k = now.toUtc().add(const Duration(hours: 9));
    final y = k.year.toString().padLeft(4, '0');
    final m = k.month.toString().padLeft(2, '0');
    final d = k.day.toString().padLeft(2, '0');
    return '$y$m$d';
  }
}
