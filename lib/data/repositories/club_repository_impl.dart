import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:vybe/data/datasources/remote/algolia_club_search_datasource.dart';
import 'package:vybe/data/datasources/remote/firebase_club_datasource.dart';
import 'package:vybe/data/models/club_info_model.dart';
import 'package:vybe/data/models/club_model.dart';
import 'package:vybe/data/models/menu_model.dart';
import 'package:vybe/data/models/photo_model.dart';
import 'package:vybe/domain/repositories/club_repository.dart';

part 'club_repository_impl.g.dart';

@riverpod
ClubRepository clubRepository(Ref ref) => ClubRepositoryImpl(
      FirebaseClubDataSource(),
      AlgoliaClubSearchDataSource(),
    );

class ClubRepositoryImpl implements ClubRepository {
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
  Future<List<ClubModel>> getHipHopClubs() => _dataSource.getHipHopClubs();

  @override
  Stream<List<ClubModel>> watchActiveClubs() => _dataSource.watchActiveClubs();

  @override
  Future<ClubModel?> getClub(String clubId) => _dataSource.getClub(clubId);

  @override
  Future<ClubInfoModel?> getClubInfo(String clubId) =>
      _dataSource.getClubInfo(clubId);

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
          double lat, double lng, double radiusKm) =>
      _dataSource.getClubsNearby(lat, lng, radiusKm);

  @override
  Future<ClubSearchPage> searchClubsPage(
    String keyword, {
    Object? cursor,
    int pageSize = 10,
  }) async {
    // 검색 엔진은 Algolia 단일 경로 (Firestore searchTokens는 폐기됨).
    // .env에 Algolia 키가 없으면 빈 결과 — 검색 사용하려면 키 필수.
    if (!_searchDataSource.isConfigured) return ClubSearchPage.empty;

    // Algolia 관련도순 검색: cursor = 다음 페이지 번호(int, 0부터).
    final page = cursor as int? ?? 0;
    final result = await _searchDataSource.searchClubs(
      keyword,
      page: page,
      hitsPerPage: pageSize,
    );

    // hit에 목록/필터/지도용 필드가 전부 있으면 Firestore 조인 생략 → 검색 1회 read 0.
    // Extension Indexable Fields가 아직 반영 안 됐으면(재색인 전) complete=false →
    // 예전처럼 clubId로 조인해 화면이 깨지지 않게 한다. (조인 시 pageSize만큼 read)
    final clubs = result.complete
        ? result.clubs
        : (await Future.wait(result.ids.map(_dataSource.getClub)))
            .whereType<ClubModel>()
            .toList();

    // Algolia 관련도 순서를 유지하고, 동기화 지연으로 삭제/비활성된 문서는 제외.
    final visible = clubs.where((c) => c.isActive).toList();

    return ClubSearchPage(
      clubs: visible,
      cursor: page + 1,
      hasMore: result.hasMore,
      totalCount: result.totalHits,
    );
  }
}
