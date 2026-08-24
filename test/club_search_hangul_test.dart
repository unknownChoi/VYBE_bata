import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vybe/data/datasources/remote/algolia_club_search_datasource.dart';
import 'package:vybe/data/datasources/remote/firebase_club_datasource.dart';
import 'package:vybe/data/models/club_model.dart';
import 'package:vybe/data/models/operating_hours.dart';
import 'package:vybe/data/repositories/club_repository_impl.dart';

/// 검색 경로 3곳(연관 검색어 · 검색 결과 · 주변 지도)이 전부 거치는
/// [ClubRepositoryImpl.searchClubsPage] 에서 조합 중 자모를 처리하는지.

ClubModel _club(String name) => ClubModel(
  clubId: name,
  name: name,
  description: '',
  address: '',
  area: '홍대',
  phone: '',
  instagramUrl: '',
  lat: 37.5563,
  lng: 126.9236,
  geohash: 'wydm',
  genre: '힙합',
  rating: 4.5,
  operatingHours: const OperatingHours(),
  entryFeeMin: 20000,
  entryFeeMax: 30000,
  imageUrls: const [],
  thumbnailUrl: '',
  tags: const [],
  favoriteCount: 0,
  isActive: true,
  isVybeRecommended: false,
  createdAt: _t,
  updatedAt: _t,
);

final _t = DateTime(2026, 8, 24);

/// hit가 완전(complete)하면 Firestore 조인이 없다 — 이 테스트에선 쓰이지 않는다.
/// (진짜 FirebaseClubDataSource 는 생성만 해도 Firestore 인스턴스를 잡는다.)
class _UnusedClubDataSource implements FirebaseClubDataSource {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeSearchDataSource extends AlgoliaClubSearchDataSource {
  final List<ClubModel> clubs;

  /// 엔진이 실제로 받은 쿼리 — 자모가 그대로 넘어가면 결과가 0건이 된다.
  String? lastQuery;
  int? lastHitsPerPage;

  _FakeSearchDataSource(this.clubs);

  @override
  bool get isConfigured => true;

  @override
  Future<SearchClubsResult> searchClubs(
    String query, {
    int page = 0,
    int hitsPerPage = 10,
  }) async {
    lastQuery = query;
    lastHitsPerPage = hitsPerPage;
    return SearchClubsResult(
      clubs: clubs,
      ids: clubs.map((c) => c.clubId).toList(),
      hasMore: false,
      complete: true,
      totalHits: clubs.length,
    );
  }
}

void main() {
  // AlgoliaClubSearchDataSource 생성자가 .env 를 읽는다 (네트워크는 안 탄다).
  setUpAll(() => dotenv.testLoad(fileInput: ''));

  late _FakeSearchDataSource search;
  late ClubRepositoryImpl repo;

  setUp(() {
    search = _FakeSearchDataSource([
      _club('홍대 클럽 프리즘'),
      _club('홍대 클럽 나인'),
      _club('어썸레드'),
    ]);
    repo = ClubRepositoryImpl(_UnusedClubDataSource(), search);
  });

  test('조합 중 자모는 엔진에 안 보내고, 결과를 초성으로 거른다', () async {
    final page = await repo.searchClubsPage('홍대 ㅇ', pageSize: 8);

    // 자모를 그대로 던지면 엔진이 0건을 준다 → 완성된 부분만 보내야 한다.
    expect(search.lastQuery, '홍대');
    // 초성 ㅇ 이 있는 곳만 — '프리즘'은 빠지고 '나인'·'어썸레드'는 남는다.
    expect(page.clubs.map((c) => c.name), ['어썸레드', '홍대 클럽 나인']);
    // 첫 글자에서 걸린 '어썸레드'가 위 (ㅇ이 네 번째인 '나인'보다 앞).
    expect(page.totalCount, 2);
  });

  test('자모를 거를 땐 후보를 넉넉히 받아 온다', () async {
    await repo.searchClubsPage('홍대 ㅇ', pageSize: 8);
    expect(search.lastHitsPerPage, greaterThan(8));

    await repo.searchClubsPage('홍대 어', pageSize: 8);
    // 자모가 없으면 평소대로 페이지 크기 그대로.
    expect(search.lastHitsPerPage, 8);
    expect(search.lastQuery, '홍대 어');
  });

  test("'홍대 ㅋ' — 이름이 ㅋ으로 시작하는 다른 클럽이 홍대 클럽을 밀어내지 않는다",
      () async {
    // 엔진('홍대')은 area 로 걸린 '클럽 스테이션' 류도 같이 준다. 초성 위치만 보면
    // 이름 첫 글자가 ㅋ이라 상위를 통째로 먹어 '홍대 클럽 프리즘'이 사라졌다.
    search = _FakeSearchDataSource([
      _club('클럽 스테이션'),
      _club('클럽 콜러'),
      _club('홍대 클럽 프리즘'),
      _club('홍대 클럽 나인'),
      _club('미드나잏 홍대'),
    ]);
    repo = ClubRepositoryImpl(_UnusedClubDataSource(), search);

    final page = await repo.searchClubsPage('홍대 ㅋ', pageSize: 8);
    expect(page.clubs.map((c) => c.name), [
      '홍대 클럽 프리즘',
      '홍대 클럽 나인',
      '클럽 스테이션',
      '클럽 콜러',
    ]);
  });

  test('자모가 없으면 결과·개수를 손대지 않는다', () async {
    final page = await repo.searchClubsPage('홍대', pageSize: 8);
    expect(page.clubs, hasLength(3));
    expect(page.totalCount, 3);
  });
}
