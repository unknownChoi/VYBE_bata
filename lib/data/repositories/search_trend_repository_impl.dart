import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:vybe/data/datasources/remote/firebase_search_trend_datasource.dart';
import 'package:vybe/data/models/search_hashtag_model.dart';
import 'package:vybe/data/models/search_trend_model.dart';
import 'package:vybe/domain/repositories/search_trend_repository.dart';

part 'search_trend_repository_impl.g.dart';

@Riverpod(keepAlive: true)
SearchTrendRepository searchTrendRepository(Ref ref) =>
    _SearchTrendRepositoryImpl(FirebaseSearchTrendDataSource());

class _SearchTrendRepositoryImpl implements SearchTrendRepository {
  final FirebaseSearchTrendDataSource _dataSource;

  _SearchTrendRepositoryImpl(this._dataSource);

  @override
  Future<SearchTrendSnapshot> getTrendSnapshot() =>
      _dataSource.getTrendSnapshot();

  @override
  Future<List<SearchHashtagModel>> getActiveHashtags() =>
      _dataSource.getActiveHashtags();

  @override
  Future<void> logSearch({
    required String userId,
    required String keyword,
    required SearchSource source,
  }) => _dataSource.logSearch(userId: userId, keyword: keyword, source: source);
}
