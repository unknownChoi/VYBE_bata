import 'package:algoliasearch/algoliasearch_lite.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:vybe/data/models/club_model.dart';

/// Algolia 클럽 검색 datasource.
///
/// Firestore clubs 컬렉션은 Firebase Extension(firestore-algolia-search)이
/// `clubs` 인덱스로 자동 동기화한다. hit에 목록/필터/지도용 필드가 모두 있으면
/// 그대로 ClubModel로 만들어 반환하고([SearchClubsResult.complete] = true),
/// 호출측은 Firestore 조인(문서 read)을 생략한다.
///
/// .env 키: ALGOLIA_APP_ID / ALGOLIA_SEARCH_API_KEY
/// 키가 없으면 [isConfigured] = false → 검색 결과 빈 값 (fallback 없음).
class AlgoliaClubSearchDataSource {
  static const _indexName = 'clubs';

  /// 목록 카드·필터·정렬·지도 핀에 필요한 필드.
  /// hit가 이 키를 전부 가지고 있어야 Firestore 조인을 생략할 수 있다.
  /// (Extension Indexable Fields에 하나라도 빠지면 complete=false → 조인 폴백)
  static const _requiredFields = [
    'name', // 카드 제목
    'area', // 카드 지역
    'genre', // 카드 장르 + 장르 필터
    'tags', // 서비스음료/장르 필터
    'rating', // 평점 표시·정렬
    'reviewCount', // 리뷰 수 표시·정렬
    'thumbnailUrl', // 카드 썸네일
    'entryFeeMin', // 입장료 표시 + 무료입장 필터
    'entryFeeMax', // 입장료 범위 표시
    'operatingHours', // 영업중 뱃지 + 영업중 필터
    'isActive', // 비활성 클럽 제외
    'isVybeRecommended', // 추천 리본 + 추천순 정렬
    'isNonSmoking', // 금연 필터
    'location', // 주변 탭 지도 핀 + 거리순 정렬
    'freeEntry', // 무료입장 정책 — '지금 무료' 판정(FreeEntryPolicy.statusAt)
    'isFreeEntry', // 무료입장 필터(ClubFilter.freeEntry)
  ];

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

  /// 관련도순 클럽 페이지 조회. [page]는 0부터.
  /// 반환 clubs/ids는 Algolia 관련도 순서 그대로.
  Future<SearchClubsResult> searchClubs(
    String query, {
    int page = 0,
    int hitsPerPage = 10,
  }) async {
    final client = _client;
    if (client == null) return SearchClubsResult.empty;

    // isActive 필터는 여기서 걸지 않는다 — Algolia filters는 인덱스 설정
    // attributesForFaceting에 선언된 속성만 동작(미선언 시 조용히 0건).
    // 비활성 클럽은 호출측에서 isActive 값으로 제외한다.
    final response = await client.searchIndex(
      request: SearchForHits(
        indexName: _indexName,
        query: query,
        page: page,
        hitsPerPage: hitsPerPage,
        // 인덱싱된 속성 전부 — 조인 없이 카드를 그리기 위해 본문까지 받는다.
        attributesToRetrieve: ['*'],
      ),
    );

    final hits = response.hits;
    final complete = hits.every(
      (h) => _requiredFields.every((f) => h.containsKey(f)),
    );
    final nbPages = response.nbPages ?? 0;

    return SearchClubsResult(
      clubs: complete
          ? hits.map((h) => ClubModel.fromSearchHit(h.objectID, h)).toList()
          : const [],
      ids: hits.map((h) => h.objectID).toList(),
      hasMore: page + 1 < nbPages,
      complete: complete,
      // 이번 페이지가 아닌 쿼리 전체 매칭 수. 응답에 이미 실려와 추가 비용 없음.
      totalHits: response.nbHits ?? hits.length,
    );
  }
}

/// [AlgoliaClubSearchDataSource.searchClubs] 결과.
///
/// [complete]가 false면 인덱스에 목록용 필드가 덜 동기화된 상태 —
/// [clubs]는 비어 있고 호출측이 [ids]로 Firestore를 조인해야 한다.
class SearchClubsResult {
  final List<ClubModel> clubs;
  final List<String> ids;
  final bool hasMore;
  final bool complete;

  /// 쿼리 전체 매칭 수(Algolia nbHits). 로드된 페이지 수와 무관.
  /// isActive=false 클럽도 포함된 값 — 서버 필터를 안 걸기 때문(아래 주석 참고).
  final int totalHits;

  const SearchClubsResult({
    required this.clubs,
    required this.ids,
    required this.hasMore,
    required this.complete,
    this.totalHits = 0,
  });

  static const empty = SearchClubsResult(
    clubs: [],
    ids: [],
    hasMore: false,
    complete: true,
  );
}
