import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:vybe/data/models/search_hashtag_model.dart';
import 'package:vybe/data/models/search_trend_model.dart';
import 'package:vybe/data/repositories/search_trend_repository_impl.dart';

part 'search_trend_viewmodel.g.dart';

/// 실시간 인기 검색어 스냅샷.
///
/// 서버 갱신 주기는 2시간(20:00~09:00은 1시간)이라 세션 중 재조회 의미가 적다
/// → keepAlive. 강제 갱신이 필요하면 invalidate.
@Riverpod(keepAlive: true)
Future<SearchTrendSnapshot> searchTrends(Ref ref) {
  return ref.read(searchTrendRepositoryProvider).getTrendSnapshot();
}

/// 인기 해시태그. 서버 갱신 주기 4시간(20:00~09:00은 1시간).
@Riverpod(keepAlive: true)
Future<List<SearchHashtagModel>> popularHashtags(Ref ref) {
  return ref.read(searchTrendRepositoryProvider).getActiveHashtags();
}
