import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:vybe/core/utils/hangul_search.dart';
import 'package:vybe/data/datasources/remote/algolia_club_search_datasource.dart';
import 'package:vybe/data/datasources/remote/firebase_club_datasource.dart';
import 'package:vybe/data/models/club_info_model.dart';
import 'package:vybe/data/models/club_model.dart';
import 'package:vybe/data/models/club_table_layout.dart';
import 'package:vybe/data/models/menu_model.dart';
import 'package:vybe/data/models/photo_model.dart';
import 'package:vybe/domain/repositories/club_repository.dart';

part 'club_repository_impl.g.dart';

@riverpod
ClubRepository clubRepository(Ref ref) =>
    ClubRepositoryImpl(FirebaseClubDataSource(), AlgoliaClubSearchDataSource());

class ClubRepositoryImpl implements ClubRepository {
  /// 조합 중 자모를 거를 때 한 번에 받아 볼 후보 수 상한.
  /// 응답 크기(카드용 필드 전부)와 맞바꾸는 값이라 무한정 키우지 않는다.
  static const int _jamoCandidateLimit = 80;

  final FirebaseClubDataSource _dataSource;
  final AlgoliaClubSearchDataSource _searchDataSource;

  ClubRepositoryImpl(this._dataSource, this._searchDataSource);

  @override
  Future<List<ClubModel>> getActiveClubs() => _dataSource.getActiveClubs();

  @override
  Future<List<ClubModel>> getServiceDrinkClubs() =>
      _dataSource.getServiceDrinkClubs();

  @override
  Future<List<ClubModel>> getFreeEntryClubs() =>
      _dataSource.getFreeEntryClubs();

  @override
  Future<List<ClubModel>> getTimedFreeEntryClubs() =>
      _dataSource.getTimedFreeEntryClubs();

  @override
  Future<List<ClubModel>> getClubsByGenre(String genre) =>
      _dataSource.getClubsByGenre(genre);

  @override
  Stream<List<ClubModel>> watchActiveClubs() => _dataSource.watchActiveClubs();

  @override
  Future<ClubModel?> getClub(String clubId) => _dataSource.getClub(clubId);

  @override
  Future<ClubInfoModel?> getClubInfo(String clubId) =>
      _dataSource.getClubInfo(clubId);

  @override
  Future<ClubTableLayout?> getTableLayout(String clubId) =>
      _dataSource.getTableLayout(clubId);

  @override
  Future<List<MenuModel>> getMenus(String clubId) =>
      _dataSource.getMenus(clubId);

  @override
  Future<List<PhotoModel>> getPhotos(String clubId) =>
      _dataSource.getPhotos(clubId);

  @override
  Future<List<ClubModel>> getClubsByArea(String area) =>
      _dataSource.getClubsByArea(area);

  @override
  Future<List<ClubModel>> getClubsNearby(
    double lat,
    double lng,
    double radiusKm,
  ) => _dataSource.getClubsNearby(lat, lng, radiusKm);

  @override
  Future<ClubSearchPage> searchClubsPage(
    String keyword, {
    Object? cursor,
    int pageSize = 10,
  }) async {
    // 검색 엔진은 Algolia 단일 경로 (Firestore searchTokens는 폐기됨).
    // .env에 Algolia 키가 없으면 빈 결과 — 검색 사용하려면 키 필수.
    if (!_searchDataSource.isConfigured) return ClubSearchPage.empty;

    // 한글 조합 중 자모('홍대 ㅇ')는 인덱스에 없는 토큰이라 그대로 던지면 AND 매칭이
    // 결과를 통째로 0건으로 만든다(실측: '홍대' 57건 → '홍대 ㅇ' 0건).
    // 엔진엔 완성된 부분만 던지고, 자모는 아래에서 결과 초성으로 거른다.
    final parsed = HangulQuery.parse(keyword);

    // 자모를 거를 때는 후보를 넉넉히 받는다 — 엔진은 자모를 모르니 걸러지기 전
    // 목록에서 pageSize 만큼만 받으면 원하는 클럽이 그 안에 없을 수 있다.
    final hitsPerPage = parsed.hasJamo
        ? (pageSize * 8).clamp(pageSize, _jamoCandidateLimit)
        : pageSize;

    // Algolia 관련도순 검색: cursor = 다음 페이지 번호(int, 0부터).
    final page = cursor as int? ?? 0;
    final result = await _searchDataSource.searchClubs(
      parsed.engineQuery,
      page: page,
      hitsPerPage: hitsPerPage,
    );

    // hit에 목록/필터/지도용 필드가 전부 있으면 Firestore 조인 생략 → 검색 1회 read 0.
    // Extension Indexable Fields가 아직 반영 안 됐으면(재색인 전) complete=false →
    // 예전처럼 clubId로 조인해 화면이 깨지지 않게 한다. (조인 시 pageSize만큼 read)
    final clubs = result.complete
        ? result.clubs
        : (await Future.wait(
            result.ids.map(_dataSource.getClub),
          )).whereType<ClubModel>().toList();

    // Algolia 관련도 순서를 유지하고, 동기화 지연으로 삭제/비활성된 문서는 제외.
    var visible = clubs.where((c) => c.isActive).toList();

    // 조합 중 자모는 이름 초성으로 판정한다 ('홍대 ㅇ' → 어썸레드).
    if (parsed.hasJamo) {
      visible = _rankByJamo(
        visible.where((c) => parsed.matches(c.name)).toList(),
        parsed,
      );
    }

    return ClubSearchPage(
      clubs: visible,
      cursor: page + 1,
      hasMore: result.hasMore,
      // 자모를 걸렀으면 엔진이 준 전체 매칭 수(nbHits)는 거른 뒤 개수와 다르다 —
      // 화면 '검색결과 N'이 목록보다 큰 숫자를 말하지 않게 실제 통과 수를 쓴다.
      totalCount: parsed.hasJamo ? visible.length : result.totalHits,
    );
  }

  /// 자모가 걸린 자리로 순서를 정한다. 키는 넷 —
  /// ① **단어 첫 글자**에서 걸렸나 ('홍대 ㅇ' → '어썸레드'가 '홍대 클럽 나인'의
  ///    '나<b>인</b>'보다 위. 사람은 새 단어를 시작하는 중이지 단어 중간을 겨냥하지 않는다)
  /// ② 이름에 **완성된 검색어**가 들어 있나 ('홍대 ㅋ' → 이름이 ㅋ으로 시작하는
  ///    '클럽 스테이션'(area로 걸린 것)보다 '홍대 클럽 프리즘'이 위.
  ///    이 키가 없으면 이름이 '클럽 …'인 30여 곳이 상위 8칸을 통째로 먹는다)
  /// ③ 걸린 위치가 앞쪽인가 ④ 엔진 관련도 순서
  ///
  /// Dart의 `List.sort`는 안정 정렬이 아니라, 앞 키가 같을 때 엔진 관련도 순서가
  /// 뒤섞이지 않도록 원래 index를 마지막 tie-break로 같이 넣는다.
  static List<ClubModel> _rankByJamo(List<ClubModel> clubs, HangulQuery query) {
    final head = query.engineQuery.toLowerCase();
    final ranked = List.generate(clubs.length, (i) {
      final name = clubs[i].name;
      final match = query.highlightIn(name);
      return (
        word: (match?.wordStart ?? false) ? 0 : 1,
        head: head.isNotEmpty && name.toLowerCase().contains(head) ? 0 : 1,
        pos: match?.start ?? name.length,
        order: i,
        club: clubs[i],
      );
    });
    ranked.sort((a, b) {
      if (a.word != b.word) return a.word - b.word;
      if (a.head != b.head) return a.head - b.head;
      if (a.pos != b.pos) return a.pos - b.pos;
      return a.order - b.order;
    });
    return ranked.map((e) => e.club).toList();
  }
}
