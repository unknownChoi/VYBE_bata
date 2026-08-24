import 'package:vybe/data/models/club_model.dart';
import 'package:vybe/presentation/search/viewmodels/club_filter_viewmodel.dart';

/// 이번 build에서 지도에 무엇을 그릴지에 대한 결정.
///
/// 화면(`NearbyScreen`)은 provider를 읽어 이 함수를 부르고 결과대로 실행만 한다 —
/// "어떤 클럽을, 다시 그려야 하는가, 카메라를 맞춰야 하는가"는 전부 여기서 정한다.
/// 순수 함수라 지도 컨트롤러 없이 테스트할 수 있다.
class NearbyMarkerPlan {
  /// 칩 필터를 통과해 실제로 핀을 찍을 클럽.
  final List<ClubModel> clubs;

  /// 렌더 대상이 바뀌었는지 판단하는 시그니처 (직전 값과 비교해 쓴다).
  final String signature;

  /// 지역 클러스터 모드로 그릴지. 검색 모드에서는 줌과 무관하게 개별 핀이다.
  final bool regionMode;

  /// 새 검색 요청인지 — true면 카메라를 결과 핀에 맞춘다.
  final bool isNewSearch;

  /// 전국 범위로 맞출지 (검색 결과가 전국에 흩어진 경우).
  final bool fitCountry;

  /// 이번에 소비한 검색 요청 id. null이면 geo 모드.
  final int? searchRequestId;

  const NearbyMarkerPlan({
    required this.clubs,
    required this.signature,
    required this.regionMode,
    required this.isNewSearch,
    required this.fitCountry,
    required this.searchRequestId,
  });
}

/// 지금 그려야 할 마커 계획을 만든다.
///
/// - [sourceClubs] : 검색 결과 또는 geo 조회 결과 원본
/// - [lastSearchRequestId] : 직전에 **실제로 렌더하며** 소비한 요청 id.
///   키워드가 아니라 요청 id로 비교하는 이유 — 같은 키워드 재요청
///   (힙합 '지도에서 보기' 등)도 카메라를 다시 맞춰야 한다.
/// - [regionModeByZoom] : 카메라 idle이 갱신한 줌 기준 클러스터 여부
NearbyMarkerPlan planNearbyMarkers({
  required List<ClubModel> sourceClubs,
  required Set<ClubFilter> activeFilters,
  required Set<String> favoritedIds,
  required String? searchKeyword,
  required int? searchRequestId,
  required bool searchFitCountry,
  required bool regionModeByZoom,
  required int? lastSearchRequestId,
}) {
  // 검색 칩 필터(찜 포함)를 마커에도 동일 적용.
  final clubs = activeFilters.isEmpty
      ? sourceClubs
      : sourceClubs
            .where(
              (c) => clubMatchesFilters(
                c,
                activeFilters,
                favoritedIds: favoritedIds,
              ),
            )
            .toList();

  final isSearch = searchRequestId != null;
  // 검색(TOP 10 포함) 모드에서는 줌과 무관하게 항상 개별 핀 표시.
  final regionMode = regionModeByZoom && !isSearch;

  return NearbyMarkerPlan(
    clubs: clubs,
    signature:
        '${searchKeyword ?? "geo"}#${searchRequestId ?? 0}'
        '|${clubs.map((c) => c.clubId).join(',')}|$regionMode',
    regionMode: regionMode,
    isNewSearch: isSearch && searchRequestId != lastSearchRequestId,
    fitCountry: searchFitCountry,
    searchRequestId: searchRequestId,
  );
}
