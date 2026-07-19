import 'package:cloud_firestore/cloud_firestore.dart';
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
    // Algolia 미설정(.env 키 없음) 시 기존 Firestore searchTokens 검색으로 fallback.
    if (!_searchDataSource.isConfigured) {
      final page = await _dataSource.searchClubsPage(
        keyword,
        startAfter: cursor as DocumentSnapshot?,
        pageSize: pageSize,
      );
      return ClubSearchPage(
        clubs: page.clubs,
        cursor: page.lastDoc,
        hasMore: page.hasMore,
      );
    }

    // Algolia 관련도순 검색: cursor = 다음 페이지 번호(int, 0부터).
    final page = cursor as int? ?? 0;
    final result = await _searchDataSource.searchClubIds(
      keyword,
      page: page,
      hitsPerPage: pageSize,
    );

    // 인덱스엔 표시용 일부 필드만 있어 문서 본문은 Firestore에서 조인.
    // Algolia 관련도 순서를 유지하고, 동기화 지연으로 삭제/비활성된 문서는 제외.
    final clubs = await Future.wait(result.ids.map(_dataSource.getClub));
    final visible =
        clubs.whereType<ClubModel>().where((c) => c.isActive).toList();

    return ClubSearchPage(
      clubs: visible,
      cursor: page + 1,
      hasMore: result.hasMore,
    );
  }
}
