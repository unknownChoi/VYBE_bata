import 'package:flutter_test/flutter_test.dart';
import 'package:vybe/data/models/club_model.dart';
import 'package:vybe/data/models/operating_hours.dart';
import 'package:vybe/presentation/nearby/nearby_marker_plan.dart';
import 'package:vybe/presentation/search/viewmodels/club_filter_viewmodel.dart';

ClubModel _club(String id, {bool recommended = false}) {
  return ClubModel(
    clubId: id,
    name: id,
    description: '',
    address: '',
    area: '홍대',
    phone: '',
    instagramUrl: '',
    lat: 37.55,
    lng: 126.92,
    geohash: '',
    genre: '힙합',
    rating: 4.0,
    reviewCount: 1,
    operatingHours: const OperatingHours(),
    entryFeeMin: 0,
    entryFeeMax: 0,
    heroImageUrls: const [],
    imageUrls: const [],
    menuBoardUrls: const [],
    thumbnailUrl: '',
    tags: const [],
    favoriteCount: 0,
    isActive: true,
    isVybeRecommended: recommended,
    createdAt: DateTime(2026, 1, 1),
    updatedAt: DateTime(2026, 1, 1),
  );
}

NearbyMarkerPlan _plan({
  required List<ClubModel> clubs,
  Set<ClubFilter> filters = const {},
  Set<String> favorites = const {},
  String? keyword,
  int? requestId,
  bool fitCountry = false,
  bool regionModeByZoom = false,
  int? lastRequestId,
}) {
  return planNearbyMarkers(
    sourceClubs: clubs,
    activeFilters: filters,
    favoritedIds: favorites,
    searchKeyword: keyword,
    searchRequestId: requestId,
    searchFitCountry: fitCountry,
    regionModeByZoom: regionModeByZoom,
    lastSearchRequestId: lastRequestId,
  );
}

void main() {
  group('필터', () {
    test('활성 필터가 없으면 원본을 그대로 쓴다', () {
      final clubs = [_club('a'), _club('b')];
      expect(_plan(clubs: clubs).clubs, same(clubs));
    });

    test('칩 필터가 마커에도 그대로 걸린다', () {
      final plan = _plan(
        clubs: [_club('a', recommended: true), _club('b')],
        filters: {ClubFilter.vybeRecommended},
      );
      expect(plan.clubs.map((c) => c.clubId), ['a']);
    });

    test('찜 필터는 넘겨받은 찜 집합으로 판정한다', () {
      final plan = _plan(
        clubs: [_club('a'), _club('b')],
        filters: {ClubFilter.favorite},
        favorites: {'b'},
      );
      expect(plan.clubs.map((c) => c.clubId), ['b']);
    });
  });

  group('클러스터 모드', () {
    test('줌 아웃 상태면 지역 클러스터로 그린다', () {
      expect(_plan(clubs: [], regionModeByZoom: true).regionMode, isTrue);
    });

    test('검색 모드에서는 줌 아웃이어도 개별 핀을 유지한다', () {
      final plan = _plan(
        clubs: [],
        regionModeByZoom: true,
        keyword: '힙합',
        requestId: 1,
      );
      expect(plan.regionMode, isFalse);
    });
  });

  group('시그니처', () {
    test('결과가 같으면 시그니처도 같다 (재렌더 안 함)', () {
      final a = _plan(clubs: [_club('a'), _club('b')]);
      final b = _plan(clubs: [_club('a'), _club('b')]);
      expect(a.signature, b.signature);
    });

    test('클럽 집합이 바뀌면 시그니처가 달라진다', () {
      final a = _plan(clubs: [_club('a')]);
      final b = _plan(clubs: [_club('a'), _club('b')]);
      expect(a.signature, isNot(b.signature));
    });

    test('같은 클럽이어도 클러스터 모드가 바뀌면 다시 그린다', () {
      final a = _plan(clubs: [_club('a')]);
      final b = _plan(clubs: [_club('a')], regionModeByZoom: true);
      expect(a.signature, isNot(b.signature));
    });

    test('같은 키워드라도 새 요청이면 시그니처가 달라진다', () {
      final a = _plan(clubs: [_club('a')], keyword: '힙합', requestId: 1);
      final b = _plan(clubs: [_club('a')], keyword: '힙합', requestId: 2);
      expect(a.signature, isNot(b.signature));
    });
  });

  group('새 검색 판정', () {
    test('geo 모드는 새 검색이 아니다', () {
      expect(_plan(clubs: []).isNewSearch, isFalse);
    });

    test('직전에 소비한 요청 id와 다르면 새 검색', () {
      final plan = _plan(
        clubs: [],
        keyword: '힙합',
        requestId: 2,
        lastRequestId: 1,
      );
      expect(plan.isNewSearch, isTrue);
    });

    test('이미 소비한 요청이면 카메라를 다시 맞추지 않는다', () {
      final plan = _plan(
        clubs: [],
        keyword: '힙합',
        requestId: 2,
        lastRequestId: 2,
      );
      expect(plan.isNewSearch, isFalse);
    });

    test('같은 키워드 재요청도 id가 다르면 새 검색이다', () {
      final plan = _plan(
        clubs: [],
        keyword: '힙합',
        requestId: 7,
        lastRequestId: 6,
      );
      expect(plan.isNewSearch, isTrue);
    });
  });
}
