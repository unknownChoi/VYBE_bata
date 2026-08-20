import 'package:vybe/data/models/club_info_model.dart';
import 'package:vybe/data/models/club_model.dart';
import 'package:vybe/data/models/menu_model.dart';
import 'package:vybe/data/models/photo_model.dart';

/// 검색 페이지 결과. [cursor]는 다음 페이지 요청용 불투명 토큰
/// (구현체 내부에선 Firestore DocumentSnapshot — 상위 레이어는 그대로 되돌려주기만).
class ClubSearchPage {
  final List<ClubModel> clubs;
  final Object? cursor;
  final bool hasMore;

  /// 이번 페이지가 아닌 **검색어 전체** 매칭 수. 결과 개수 표시용
  /// ([clubs].length는 지금까지 로드된 수라 "10, 20, 30…"으로 늘어남).
  final int totalCount;

  const ClubSearchPage({
    required this.clubs,
    required this.cursor,
    required this.hasMore,
    this.totalCount = 0,
  });

  static const empty = ClubSearchPage(clubs: [], cursor: null, hasMore: false);
}

abstract class ClubRepository {
  Future<List<ClubModel>> getActiveClubs();
  Future<List<ClubModel>> getServiceDrinkClubs();
  Future<List<ClubModel>> getFreeEntryClubs();

  /// 시간대 무료입장(freeEntry.type='timed') 클럽. 홈 '이 시간에만 무료입장' 섹션.
  Future<List<ClubModel>> getTimedFreeEntryClubs();
  Future<List<ClubModel>> getHipHopClubs();
  Stream<List<ClubModel>> watchActiveClubs();
  Future<ClubModel?> getClub(String clubId);
  Future<ClubInfoModel?> getClubInfo(String clubId);
  Future<List<MenuModel>> getMenus(String clubId);
  Future<List<PhotoModel>> getPhotos(String clubId);
  Future<List<ClubModel>> getClubsByArea(String area);
  Future<List<ClubModel>> getClubsNearby(double lat, double lng, double radiusKm);

  /// 평점순(desc) 검색. [cursor]로 다음 페이지(서버 페이지네이션).
  Future<ClubSearchPage> searchClubsPage(
    String keyword, {
    Object? cursor,
    int pageSize,
  });
}
