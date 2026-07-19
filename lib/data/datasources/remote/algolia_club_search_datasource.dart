import 'package:algoliasearch/algoliasearch_lite.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Algolia 클럽 검색 datasource.
///
/// Firestore clubs 컬렉션은 Firebase Extension(firestore-algolia-search)이
/// `clubs` 인덱스로 자동 동기화한다. 여기서는 검색 전용(Search-Only) 키로
/// 관련도순 objectID 페이지만 받아오고, 문서 본문은 Firestore에서 조인한다
/// (인덱스에는 표시용 일부 필드만 있어 ClubModel 전체를 못 만든다).
///
/// .env 키: ALGOLIA_APP_ID / ALGOLIA_SEARCH_API_KEY
/// 키가 없으면 [isConfigured] = false → 호출측이 Firestore 토큰 검색으로 fallback.
class AlgoliaClubSearchDataSource {
  static const _indexName = 'clubs';

  final SearchClient? _client;

  AlgoliaClubSearchDataSource() : _client = _buildClient();

  static SearchClient? _buildClient() {
    final appId = dotenv.env['ALGOLIA_APP_ID'];
    final apiKey = dotenv.env['ALGOLIA_SEARCH_API_KEY'];
    if (appId == null || appId.isEmpty || apiKey == null || apiKey.isEmpty) {
      return null;
    }
    return SearchClient(appId: appId, apiKey: apiKey);
  }

  bool get isConfigured => _client != null;

  /// 관련도순 clubId 페이지 조회.
  /// [page]는 0부터. 반환 ids는 Algolia 관련도 순서 그대로.
  Future<({List<String> ids, bool hasMore})> searchClubIds(
    String query, {
    int page = 0,
    int hitsPerPage = 10,
  }) async {
    final client = _client;
    if (client == null) return (ids: <String>[], hasMore: false);

    final response = await client.searchIndex(
      request: SearchForHits(
        indexName: _indexName,
        query: query,
        page: page,
        hitsPerPage: hitsPerPage,
        // 비활성 클럽은 결과에서 제외 (Firestore read 규칙과 동일 기준).
        filters: 'isActive:true',
        attributesToRetrieve: ['objectID'],
      ),
    );

    final ids = response.hits.map((h) => h.objectID).toList();
    final nbPages = response.nbPages ?? 0;
    return (ids: ids, hasMore: page + 1 < nbPages);
  }
}
