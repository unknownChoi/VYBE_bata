import 'package:vybe/data/models/search_hashtag_model.dart';
import 'package:vybe/data/models/search_trend_model.dart';

abstract interface class SearchTrendRepository {
  /// 실시간 인기 검색어 스냅샷 (Cloud Functions 집계 결과)
  Future<SearchTrendSnapshot> getTrendSnapshot();

  /// 인기 해시태그 (검색량 순위 우선, 없으면 큐레이션 순서)
  Future<List<SearchHashtagModel>> getActiveHashtags();

  /// 검색 로그 기록 — 순위 집계 원본
  Future<void> logSearch({
    required String userId,
    required String keyword,
    required SearchSource source,
  });
}
