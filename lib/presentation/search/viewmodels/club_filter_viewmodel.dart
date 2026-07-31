import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:vybe/core/utils/geohash_utils.dart';
import 'package:vybe/data/models/club_model.dart';

part 'club_filter_viewmodel.g.dart';

/// 필터 칩 종류. FilterChipBar 토글 칩과 1:1 매핑.
/// favorite은 런타임 찜 목록(favoritedIds) 의존 — clubMatchesFilters에 주입 필요.
enum ClubFilter {
  vybeRecommended,
  favorite,
  open,
  serviceDrink,
  freeEntry,
  hiphop,
  edm,
  hybrid,
  noSmoking,
}

/// 현재 활성화된 필터 집합을 보관. 칩 탭으로 toggle, 리스트 화면에서 watch.
@riverpod
class ClubFilterViewModel extends _$ClubFilterViewModel {
  @override
  Set<ClubFilter> build() => const {};

  void toggle(ClubFilter f) {
    final next = Set<ClubFilter>.from(state);
    if (next.contains(f)) {
      next.remove(f);
    } else {
      next.add(f);
    }
    state = next;
  }
}

/// 정렬 기준. FilterChipBar 정렬 드롭다운 옵션과 1:1 매핑.
enum ClubSort { recommended, distance, rating, reviewCount }

const Map<ClubSort, String> kClubSortLabels = {
  ClubSort.recommended: '추천순',
  ClubSort.distance: '거리순',
  ClubSort.rating: '평점순',
  ClubSort.reviewCount: '리뷰 많은순',
};

/// 현재 선택된 정렬 기준. 기본값 추천순.
@riverpod
class ClubSortViewModel extends _$ClubSortViewModel {
  @override
  ClubSort build() => ClubSort.recommended;

  void select(ClubSort s) => state = s;
}

/// 정렬 기준에 따라 새 리스트 반환. distance는 기준점(refLat/refLng) 필요.
List<ClubModel> sortClubs(
  List<ClubModel> clubs,
  ClubSort sort, {
  double? refLat,
  double? refLng,
}) {
  final list = List<ClubModel>.from(clubs);
  switch (sort) {
    case ClubSort.recommended:
      // 추천 클럽 우선, 그다음 평점 높은순.
      list.sort((a, b) {
        if (a.isVybeRecommended != b.isVybeRecommended) {
          return a.isVybeRecommended ? -1 : 1;
        }
        return b.rating.compareTo(a.rating);
      });
    case ClubSort.distance:
      if (refLat != null && refLng != null) {
        list.sort((a, b) => GeohashUtils.haversineKm(refLat, refLng, a.lat, a.lng)
            .compareTo(GeohashUtils.haversineKm(refLat, refLng, b.lat, b.lng)));
      }
    case ClubSort.rating:
      list.sort((a, b) {
        final r = b.rating.compareTo(a.rating);
        return r != 0 ? r : b.reviewCount.compareTo(a.reviewCount);
      });
    case ClubSort.reviewCount:
      list.sort((a, b) => b.reviewCount.compareTo(a.reviewCount));
  }
  return list;
}

/// 활성 필터 전부를 AND로 적용해 클럽 통과 여부 반환.
/// favorite 필터를 쓰려면 현재 사용자의 찜 clubId 집합을 [favoritedIds]로 전달.
bool clubMatchesFilters(
  ClubModel c,
  Set<ClubFilter> filters, {
  Set<String> favoritedIds = const {},
}) {
  for (final f in filters) {
    if (!_matchesFilter(c, f, favoritedIds)) return false;
  }
  return true;
}

bool _matchesFilter(ClubModel c, ClubFilter f, Set<String> favoritedIds) {
  switch (f) {
    case ClubFilter.vybeRecommended:
      return c.isVybeRecommended;
    case ClubFilter.favorite:
      return favoritedIds.contains(c.clubId);
    case ClubFilter.open:
      return c.operatingHours.today.isCurrentlyOpen;
    case ClubFilter.serviceDrink:
      return c.tags.any((t) => t.contains('서비스 음료') || t.contains('서비스음료'));
    case ClubFilter.freeEntry:
      return c.entryFeeMin == 0;
    case ClubFilter.hiphop:
      return _genreOrTag(c, ['힙합', '힙합', 'hiphop', 'hip-hop']);
    case ClubFilter.edm:
      return _genreOrTag(c, ['edm']);
    case ClubFilter.hybrid:
      return _genreOrTag(c, ['하이브리드', 'hybrid']);
    case ClubFilter.noSmoking:
      return c.isNonSmoking;
  }
}

/// genre 또는 tags에 키워드(소문자 비교)가 포함되면 통과.
bool _genreOrTag(ClubModel c, List<String> keywords) {
  final genre = c.genre.toLowerCase();
  final tags = c.tags.map((t) => t.toLowerCase()).toList();
  return keywords.any(
    (k) => genre.contains(k) || tags.any((t) => t.contains(k)),
  );
}
