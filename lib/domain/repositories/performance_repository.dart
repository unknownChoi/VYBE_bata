import 'package:vybe/data/models/performance_model.dart';

/// 공연 일정(performances) 데이터 접근 인터페이스.
/// presentation 레이어는 이 인터페이스만 소비한다.
abstract interface class PerformanceRepository {
  /// 오늘(KST) 해당 장르의 공연 목록(시작시각 오름차순). 기본 장르 = 힙합.
  Future<List<PerformanceModel>> getTodayPerformances({
    String genre,
    String? date,
  });
}
