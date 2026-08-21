import 'package:flutter/widgets.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';
import 'package:vybe/data/models/club_model.dart';
import 'package:vybe/presentation/nearby/nearby_camera_math.dart';
import 'package:vybe/presentation/nearby/nearby_marker_factory.dart';

/// 지도에 무엇을 그리고 카메라를 어디로 옮길지를 맡는 곳.
///
/// 화면(`nearby_screen.dart`)은 "어떤 클럽 목록을 보여줄지"만 정하고,
/// 마커 추가·아이콘 교체·카메라 이동은 전부 여기로 넘긴다. 그래야 화면이
/// Riverpod 구독과 레이아웃만 다루고, 지도 SDK 호출 순서는 한곳에 모인다.
///
/// **호출 순서가 중요한 이유** — `clearOverlays`/`addOverlayAll`이 겹치면 서로를
/// 덮어써 마커가 통째로 사라진다. 그래서 렌더는 [_renderJob] 하나로 직렬화한다.
class NearbyMapPresenter {
  final NearbyMarkerFactory factory;

  /// 핀 탭 → 화면이 하단 클럽 카드를 띄운다.
  final void Function(ClubModel club) onPinTap;

  /// 지역 클러스터 탭 → 화면이 그 지역을 선택하고 시트를 펼친다.
  final void Function(String area, NLatLng center) onRegionTap;

  /// 선택 클럽이 바뀌었을 때 (화면 재빌드 요청).
  final VoidCallback onSelectionChanged;

  /// 목록에서 사라진 클럽이 선택돼 있었을 때 (화면이 핀 카드도 함께 닫는다).
  final VoidCallback onSelectionLost;

  /// 지도가 붙어 있는 화면이 아직 살아 있는지. false면 모든 지도 호출을 건너뛴다.
  final bool Function() isMounted;

  NearbyMapPresenter({
    required this.factory,
    required this.onPinTap,
    required this.onRegionTap,
    required this.onSelectionChanged,
    required this.onSelectionLost,
    required this.isMounted,
  });

  /// 지도가 준비되면 화면이 넣어 준다. null이면 렌더 요청은 조용히 무시된다.
  NaverMapController? controller;

  NaverMapController? get _controller => controller;
  bool get isReady => controller != null;

  /// clubId → 마커 핸들 (선택 토글용).
  final Map<String, NMarker> _markers = {};

  /// clubId → ClubModel (탭 콜백에서 사용).
  final Map<String, ClubModel> _clubById = {};

  String? _selectedClubId;
  String? get selectedClubId => _selectedClubId;

  /// 내 위치 (파란 점 · 내 위치 버튼).
  NLatLng? myPosition;

  /// 줌 아웃 상태에서 개별 핀 대신 지역 클러스터를 그릴지.
  bool regionMode = false;

  /// 마지막으로 렌더한 목록 — 클러스터 모드 전환 시 같은 목록을 다시 그린다.
  List<ClubModel>? lastRendered;

  // ---------------------------------------------------------------- 렌더

  Future<void> _renderJob = Future<void>.value();

  /// 마커 렌더 요청. 앞선 렌더가 끝난 뒤 이어서 돈다(직렬화).
  Future<void> render(List<ClubModel> clubs) {
    lastRendered = clubs;
    final next = _renderJob.then((_) => _render(clubs));
    _renderJob = next.catchError((_) {});
    return next;
  }

  /// 클러스터 모드가 바뀌었을 때 같은 목록을 다시 그린다.
  Future<void> reRenderLast() async {
    final last = lastRendered;
    if (last != null) await render(last);
  }

  Future<void> _render(List<ClubModel> clubs) async {
    final map = _controller;
    if (map == null || !isMounted()) return;

    _clubById
      ..clear()
      ..addEntries(clubs.map((c) => MapEntry(c.clubId, c)));

    // 목록에서 사라진 선택 클럽은 선택 해제 (떠 있던 핀 카드도 함께 닫는다).
    if (_selectedClubId != null && !_clubById.containsKey(_selectedClubId)) {
      _selectedClubId = null;
      onSelectionLost();
    }

    await map.clearOverlays();
    if (regionMode) {
      await _addRegionMarkers(clubs);
    } else {
      await _addClubMarkers(clubs);
    }
    // clearOverlays가 내 위치 마커도 지우므로 재추가.
    final pos = myPosition;
    if (pos != null) await addMyLocationMarker(pos);
  }

  /// 개별 클럽 핀(이름 라벨 + 핀). 줌 인 상태.
  Future<void> _addClubMarkers(List<ClubModel> clubs) async {
    _markers.clear();
    final markers = <NMarker>{};
    for (final club in clubs) {
      final selected = club.clubId == _selectedClubId;
      final marker = NMarker(
        id: club.clubId,
        position: NLatLng(club.lat, club.lng),
        icon: await factory.iconFor(club, selected: selected),
        // 핀 바닥(라벨+핀 캔버스 하단)이 좌표를 가리키도록.
        anchor: const NPoint(0.5, 1.0),
      );
      marker.setZIndex(NearbyMarkerFactory.zIndexFor(club, selected: selected));
      marker.setOnTapListener((_) => onPinTap(club));
      markers.add(marker);
      _markers[club.clubId] = marker;
    }
    await _controller?.addOverlayAll(markers);
  }

  /// area별 클러스터 동그라미(지역명 + 클럽 수). 줌 아웃 상태.
  Future<void> _addRegionMarkers(List<ClubModel> clubs) async {
    _markers.clear();

    // area별 그룹핑 (빈 area 제외 — 이름 없는 동그라미는 뜻이 없다).
    final byArea = <String, List<ClubModel>>{};
    for (final club in clubs) {
      if (club.area.isEmpty) continue;
      byArea.putIfAbsent(club.area, () => []).add(club);
    }

    final markers = <NMarker>{};
    for (final entry in byArea.entries) {
      final center = NearbyCameraMath.centerOf(entry.value);
      final marker = NMarker(
        id: 'region_${entry.key}',
        position: center,
        icon: await factory.regionIcon(entry.key, entry.value.length),
        anchor: const NPoint(0.5, 0.5),
      );
      marker.setOnTapListener((_) => onRegionTap(entry.key, center));
      markers.add(marker);
    }
    await _controller?.addOverlayAll(markers);
  }

  /// 내 위치 마커 추가 (파란 점).
  Future<void> addMyLocationMarker(NLatLng pos) async {
    final map = _controller;
    if (map == null || !isMounted()) return;
    final marker = NMarker(
      id: NearbyMarkerFactory.myLocationMarkerId,
      position: pos,
      icon: await factory.myLocationIcon(),
      anchor: const NPoint(0.5, 0.5),
    );
    marker.setZIndex(NearbyMarkerFactory.myLocationZIndex);
    marker.setGlobalZIndex(NearbyMarkerFactory.myLocationZIndex);
    await map.addOverlay(marker);
  }

  // ---------------------------------------------------------------- 선택

  /// [club] 핀을 선택(라임)으로 바꾸고 직전 선택은 기본색으로 되돌린다.
  Future<void> select(ClubModel club) async {
    if (_selectedClubId == club.clubId) return;
    final prev = _clubById[_selectedClubId];
    _selectedClubId = club.clubId;
    onSelectionChanged();
    if (prev != null) await _setIcon(prev, selected: false);
    await _setIcon(club, selected: true);
  }

  /// [club]이 아직 선택 상태면 해제하고 핀을 기본색(보라)으로 되돌린다.
  Future<void> deselect(ClubModel club) async {
    if (_selectedClubId != club.clubId) return;
    _selectedClubId = null;
    onSelectionChanged();
    await _setIcon(club, selected: false);
  }

  /// 지도를 건드리지 않고 선택만 지운다 (검색 모드 해제 등).
  void clearSelection() => _selectedClubId = null;

  /// 마커 아이콘 교체 — 해당 마커가 없으면(재렌더로 사라짐) 무시.
  Future<void> _setIcon(ClubModel club, {required bool selected}) async {
    final marker = _markers[club.clubId];
    if (marker == null) return;
    marker.setIcon(await factory.iconFor(club, selected: selected));
    marker.setZIndex(NearbyMarkerFactory.zIndexFor(club, selected: selected));
  }

  // -------------------------------------------------------------- 카메라

  /// 핀을 선택 상태로 바꾸고 카메라를 그 핀으로 확대 이동.
  /// [pivotY]는 하단 카드에 핀이 가리지 않도록 위로 올린 중심 비율.
  ///
  /// 이미 [focusZoom]보다 더 확대해 보고 있으면 그 줌을 유지한다 —
  /// 핀을 탭했는데 지도가 축소되면 조작이 어긋난 것처럼 느껴진다.
  Future<void> focusPin(
    ClubModel club, {
    required double pivotY,
    required double focusZoom,
  }) async {
    await select(club);
    final map = _controller;
    if (map == null) return;

    final current = await map.getCameraPosition();
    final zoom = current.zoom < focusZoom ? focusZoom : current.zoom;

    await map.updateCamera(
      NCameraUpdate.scrollAndZoomTo(
          target: NLatLng(club.lat, club.lng),
          zoom: zoom,
        )
        ..setPivot(NPoint(0.5, pivotY))
        ..setAnimation(
          animation: NCameraAnimation.easing,
          duration: const Duration(milliseconds: 450),
        ),
    );
  }

  /// 지정한 bounds가 전부 보이도록 축소 (TOP 10 '지도 보기' = 대한민국 전체).
  Future<void> fitBounds(NLatLngBounds bounds, EdgeInsets padding) async {
    await _controller?.updateCamera(
      NCameraUpdate.fitBounds(bounds, padding: padding),
    );
  }

  /// 검색 결과 핀들이 모두 보이도록 카메라 맞춤.
  /// 핀 1개는 fitBounds가 성립하지 않아 pivot으로 화면 위쪽에 놓는다.
  Future<void> fitClubs(
    List<ClubModel> clubs, {
    required EdgeInsets padding,
    required double singlePivotY,
    double singleZoom = 15,
  }) async {
    final map = _controller;
    if (map == null || clubs.isEmpty) return;

    final bounds = NearbyCameraMath.boundsOf(clubs);
    if (bounds == null) {
      await map.updateCamera(
        NCameraUpdate.withParams(
          target: NLatLng(clubs.first.lat, clubs.first.lng),
          zoom: singleZoom,
        )..setPivot(NPoint(0.5, singlePivotY)),
      );
      return;
    }
    await map.updateCamera(NCameraUpdate.fitBounds(bounds, padding: padding));
  }

  /// 지정 좌표로 이동 (지역 클러스터 탭 · 내 위치 버튼).
  Future<void> moveTo(NLatLng target, {required double zoom}) async {
    await _controller?.updateCamera(
      NCameraUpdate.withParams(target: target, zoom: zoom),
    );
  }

  /// 내 위치로 복귀. 좌표를 아직 못 받았으면 아무것도 하지 않는다.
  Future<void> moveToMyLocation({required double zoom}) async {
    final pos = myPosition;
    if (pos == null) return;
    await moveTo(pos, zoom: zoom);
  }

  /// 현재 보이는 영역 (재검색 반경 계산용).
  Future<NLatLngBounds?> visibleBounds() => switch (_controller) {
    final map? => map.getContentBounds(),
    null => Future<NLatLngBounds?>.value(),
  };

  /// 현재 카메라 (줌 임계값 판정용).
  Future<NCameraPosition?> cameraPosition() => switch (_controller) {
    final map? => map.getCameraPosition(),
    null => Future<NCameraPosition?>.value(),
  };
}
