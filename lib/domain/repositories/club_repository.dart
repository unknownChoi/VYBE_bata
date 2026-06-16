import 'package:vybe/data/models/club_info_model.dart';
import 'package:vybe/data/models/club_model.dart';
import 'package:vybe/data/models/menu_model.dart';
import 'package:vybe/data/models/photo_model.dart';

abstract class ClubRepository {
  Future<List<ClubModel>> getActiveClubs();
  Stream<List<ClubModel>> watchActiveClubs();
  Future<ClubModel?> getClub(String clubId);
  Future<ClubInfoModel?> getClubInfo(String clubId);
  Future<List<MenuModel>> getMenus(String clubId);
  Future<List<PhotoModel>> getPhotos(String clubId);
  Future<List<ClubModel>> getClubsByArea(String area);
  Future<List<ClubModel>> getClubsNearby(double lat, double lng, double radiusKm);
  Future<List<ClubModel>> searchClubs(String keyword);
}
