import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:vybe/data/datasources/remote/firebase_club_datasource.dart';
import 'package:vybe/data/models/club_info_model.dart';
import 'package:vybe/data/models/club_model.dart';
import 'package:vybe/data/models/menu_model.dart';
import 'package:vybe/data/models/photo_model.dart';
import 'package:vybe/domain/repositories/club_repository.dart';

part 'club_repository_impl.g.dart';

@riverpod
ClubRepository clubRepository(Ref ref) =>
    ClubRepositoryImpl(FirebaseClubDataSource());

class ClubRepositoryImpl implements ClubRepository {
  final FirebaseClubDataSource _dataSource;

  ClubRepositoryImpl(this._dataSource);

  @override
  Future<List<ClubModel>> getActiveClubs() => _dataSource.getActiveClubs();

  @override
  Future<List<ClubModel>> getServiceDrinkClubs() =>
      _dataSource.getServiceDrinkClubs();

  @override
  Future<List<ClubModel>> getFreeEntryClubs() =>
      _dataSource.getFreeEntryClubs();

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
}
