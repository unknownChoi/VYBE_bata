import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vybe/core/constants/app_geo.dart';
import 'package:vybe/core/providers/auth_providers.dart';
import 'package:vybe/core/providers/location_providers.dart';
import 'package:vybe/core/utils/geohash_utils.dart';
import 'package:vybe/core/utils/map_launcher.dart';
import 'package:vybe/core/utils/naver_overlay_image_queue.dart';
import 'package:vybe/data/models/club_model.dart';
import 'package:vybe/design_system/colors.dart';
import 'package:vybe/presentation/clubs/club_detail_route.dart';
import 'package:vybe/presentation/clubs/viewmodels/favorite_viewmodel.dart';
import 'package:vybe/presentation/common/widgets/vybe_my_location_dot.dart';
import 'package:vybe/presentation/main_scaffold/main_scaffold.dart';
import 'package:vybe/presentation/main_scaffold/nav_bar_visibility_provider.dart';
import 'package:vybe/presentation/nearby/viewmodels/nearby_search_provider.dart';
import 'package:vybe/presentation/nearby/viewmodels/nearby_viewmodel.dart';
import 'package:vybe/presentation/nearby/widgets/club_pin_card.dart';
import 'package:vybe/presentation/nearby/widgets/nearby_bottom_sheet.dart';
import 'package:vybe/presentation/nearby/widgets/nearby_glass.dart';
import 'package:vybe/presentation/nearby/widgets/nearby_gnb.dart';
import 'package:vybe/presentation/nearby/widgets/nearby_map_markers.dart';
import 'package:vybe/presentation/search/search_screen.dart';
import 'package:vybe/presentation/search/viewmodels/club_filter_viewmodel.dart';

class NearbyScreen extends ConsumerStatefulWidget {
  const NearbyScreen({super.key});

  @override
  ConsumerState<NearbyScreen> createState() => _NearbyScreenState();
}

class _NearbyScreenState extends ConsumerState<NearbyScreen>
    with WidgetsBindingObserver {
  // 이 줌 이하로 축소되면 개별 핀 대신 지역(area)별 클러스터 동그라미 표시.
  static const double _kRegionZoomThreshold = 13.0;
  // 리스트 시트 스냅 위치 (디자인 nearby_glass.jsx SNAPS).
  // 최소 높이에서도 핸들·제목·필터 칩 줄까지 보이도록 0.3에서 시작한다.
  static const double _kSheetMin = 0.3;
  static const double _kSheetMid = 0.56;
  static const double _kSheetMax = 0.88;
  // 대한민국 전체가 보이는 bounds (fitCountry 카메라용, 제주 포함).
  static const NLatLngBounds _kKoreaBounds = NLatLngBounds(
    southWest: NLatLng(33.0, 124.6),
    northEast: NLatLng(38.7, 131.0),
  );
  // 주변 탭 인덱스 (MainScaffold PageView 기준).
  static const int _kNearbyTabIndex = 1;
  // 핀 카드 대략 높이 — 카메라 pivot 계산용(내용에 따라 달라져 근사치로 쓴다).
  static const double _kPinCardApproxHeight = 380;
  // 핀 탭 시 확대할 줌. 이미 이보다 더 확대돼 있으면 줄이지 않는다.
  static const double _kPinFocusZoom = 17.0;
  // 화면 밖에서 마커 변경이 생겨 렌더를 보류한 상태 (다시 보일 때 렌더).
  bool _renderWhenVisible = false;
  // 직전 build에서 주변 탭이 활성이었는지 (숨김→재진입 감지용).
  bool _wasActive = false;

  NaverMapController? _mapController;
  bool _showReSearch = false;
  bool _ignoreNextIdle = true;
  // 현재 지역 클러스터 모드 여부 (줌 임계값 기준).
  bool _regionMode = false;
  late final DraggableScrollableController _sheetController;
  // LayoutBuilder가 레이아웃 단계에서 Stack을 재빌드할 때 시트가 재생성(initState
  // 재실행 → 컨트롤러 중복 attach 어설션)되지 않도록 element 식별자를 고정한다.
  final GlobalKey _sheetKey = GlobalKey();
  double _stackHeight = 0;
  List<ClubModel> _pendingClubs = [];
  List<ClubModel>? _lastRenderedClubs;
  // 마커 재렌더 판단용 시그니처 (필터 결과 clubId 집합 + 클러스터 모드).
  String? _lastMarkerSig;
  NLatLng? _myPos;
  // 직전 소비한 검색 요청 id (새 검색 감지 → 카메라 핀에 맞춤용). null=geo 모드.
  // keyword 대신 requestId 비교 — 같은 키워드 재요청(힙합 '지도에서 보기' 등)도 fit.
  int? _lastSearchReqId;
  // 맵 준비 전 검색 진입 시 onMapReady에서 카메라 fit 하도록 보류 표시.
  bool _pendingFitCamera = false;
  // 보류된 fit이 대한민국 전체 보기인지 (fitCountry).
  bool _pendingFitCountry = false;

  // 마커 이미지 캐시 — 매번 fromWidget 재생성하면 플러그인 이미지 캐시
  // 정리(Directory.delete) 로그가 반복돼 캐시해 재사용.
  // 클럽 핀은 이름 라벨 포함이라 (clubId + 선택여부)별로 캐시.
  final Map<String, NOverlayImage> _clubPinCache = {};
  // 지역 클러스터 동그라미 이미지 캐시. 키: area|count.
  final Map<String, NOverlayImage> _regionPinCache = {};
  NOverlayImage? _myLocationIcon;

  // 클럽별 마커 핸들 + 마지막 렌더된 클럽 목록 (선택 토글용).
  final Map<String, NMarker> _clubMarkers = {};
  String? _selectedClubId;

  // 핀 탭으로 하단에 떠 있는 클럽 카드. null이면 카드 없음(= 리스트 시트 표시).
  ClubModel? _pinCardClub;

  // 이름 라벨 + 핀 이미지 (선택 시 라임 + 별점·영업여부 확장).
  // 캐시 키에 평점·영업여부까지 넣는다 — 영업 상태는 시간이 지나면 뒤집히므로
  // clubId만으로 캐시하면 라벨이 옛 상태로 굳는다.
  Future<NOverlayImage> _getClubPinIcon(ClubModel club, bool selected) async {
    final isOpen = club.operatingHours.today.isCurrentlyOpen;
    final key = '${club.clubId}|$selected|${club.rating}|$isOpen';
    final cached = _clubPinCache[key];
    if (cached != null) return cached;
    // 마커 이미지 생성은 반드시 직렬화 — 동시 생성 시 플러그인이 temp 폴더를
    // 서로 지워 네이티브 크래시가 난다 (NaverOverlayImageQueue 주석 참고).
    final img = await NaverOverlayImageQueue.run(
      () => NOverlayImage.fromWidget(
        widget: NearbyPin(
          label: club.name,
          selected: selected,
          rating: club.rating,
          reviewCount: club.reviewCount,
          isOpen: isOpen,
        ),
        size: Size(NearbyPin.canvasWidth.r, NearbyPin.canvasHeight.r),
        context: context,
      ),
    );
    _clubPinCache[key] = img;
    return img;
  }

  Future<NOverlayImage> _getMyLocationIcon() async {
    return _myLocationIcon ??= await NaverOverlayImageQueue.run<NOverlayImage>(
      () => NOverlayImage.fromWidget(
        widget: const VybeMyLocationDot(),
        size: const Size(28, 28),
        context: context,
      ),
    );
  }

  // 내 위치 마커 추가 (파란 점). 진입 시 1회.
  Future<void> _addMyLocationMarker(NLatLng pos) async {
    if (_mapController == null || !mounted) return;
    final icon = await _getMyLocationIcon();
    final marker = NMarker(
      id: 'my_location_marker',
      position: pos,
      icon: icon,
      anchor: const NPoint(0.5, 0.5),
    );
    // 클럽 핀보다 위로 (가려지지 않게). 기본 zIndex=0.
    marker.setZIndex(1000000);
    marker.setGlobalZIndex(1000000);
    await _mapController!.addOverlay(marker);
  }

  // 지도 쪽 후처리(핀 색 교체 + 카메라 이동) 작업 핸들.
  // 상세를 먼저 열고 뒤에서 돌리기 때문에, 복귀 시 선택 해제 전에 이걸 기다려야
  // 뒤늦게 끝난 선택이 핀을 녹색으로 남겨두는 걸 막는다.
  Future<void>? _pinFocusJob;

  // 핀 탭 → 하단 클럽 요약 카드 오픈 (상세 이동은 카드 탭).
  //
  // 디자인 nearby_glass.jsx: 핀을 고르면 리스트 시트를 내리고 요약 카드를 띄운다.
  // 카드는 즉시 그리고, 핀 아이콘 교체(NOverlayImage 직렬 큐)·카메라 이동처럼
  // 수백 ms 걸리는 지도 작업은 뒤에서 진행한다.
  Future<void> _onPinTap(ClubModel club) async {
    setState(() => _pinCardClub = club);
    // 시트는 감춰지지만 높이는 남아 있어, 카드를 닫았을 때 최소 높이로 돌아오도록
    // 미리 접어둔다 (디자인 closePin → SNAPS[0]).
    if (_sheetController.isAttached && _sheetController.size > _kSheetMin) {
      _sheetController.animateTo(
        _kSheetMin,
        duration: const Duration(milliseconds: 280),
        curve: Curves.easeOut,
      );
    }
    _pinFocusJob = _focusPin(club).catchError((_) {});
    await _pinFocusJob;
  }

  // 핀 카드 탭 → 클럽 상세. 돌아오면 카드는 그대로 유지한다.
  Future<void> _openDetail(ClubModel club) async {
    await openClubDetail(context, club.clubId);
    if (!mounted) return;
    // 상세에서 스크롤하며 축소된 하단 nav 복원.
    ref.read(navBarVisibilityProvider.notifier).expand();
  }

  // 카드 닫기 → 핀 선택 해제 + 리스트 시트 복귀.
  Future<void> _closePinCard() async {
    final club = _pinCardClub;
    if (club == null) return;
    setState(() => _pinCardClub = null);
    // 선택 표시 작업이 늦게 끝나 핀이 녹색으로 남는 걸 막는다.
    await _pinFocusJob;
    if (!mounted) return;
    await _deselectPin(club);
  }

  // 핀을 선택 상태(녹색)로 바꾸고 카메라를 그 핀으로 확대 이동.
  // 하단 카드에 핀이 가리지 않도록 pivot을 위로 올린다.
  Future<void> _focusPin(ClubModel club) async {
    // pivot은 context를 쓰므로 await 전에 계산.
    final pivotY = _pinCardPivotY();
    await _selectPin(club);
    final controller = _mapController;
    if (controller == null) return;

    // 이미 더 확대해서 보고 있으면 그 줌을 유지 (탭이 축소로 느껴지지 않게).
    final current = await controller.getCameraPosition();
    final zoom = current.zoom < _kPinFocusZoom ? _kPinFocusZoom : current.zoom;

    // 프로그램 이동이라 '현재 지역에서 재검색' 유도는 띄우지 않는다.
    _ignoreNextIdle = true;
    await controller.updateCamera(
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

  // 핀 카드가 떠 있을 때 '보이는 지도 밴드'의 세로 중심 비율 (0~1).
  double _pinCardPivotY() {
    if (_stackHeight <= 0) return 0.3;
    final top = 170.h; // 상단 GNB 스크림 높이
    final navExpanded = ref.read(navBarVisibilityProvider);
    final cardTop =
        _stackHeight -
        (_kPinCardApproxHeight.h +
            navBarTotalHeight(context, expanded: navExpanded) +
            10.h);
    if (cardTop <= top) return 0.3;
    return (((top + cardTop) / 2) / _stackHeight).clamp(0.15, 0.5);
  }

  // [club] 핀을 선택(녹색)으로 바꾸고 직전 선택은 기본색으로 되돌린다.
  Future<void> _selectPin(ClubModel club) async {
    if (_selectedClubId == club.clubId) return;
    final prev = _clubById[_selectedClubId];
    setState(() => _selectedClubId = club.clubId);
    if (prev != null) await _setPinIcon(prev, selected: false);
    await _setPinIcon(club, selected: true);
  }

  // [club]이 아직 선택 상태면 해제하고 핀을 기본색(보라)으로 되돌린다.
  Future<void> _deselectPin(ClubModel club) async {
    if (_selectedClubId != club.clubId) return;
    setState(() => _selectedClubId = null);
    await _setPinIcon(club, selected: false);
  }

  // 마커 아이콘 교체 — 해당 마커가 없으면(재렌더로 사라짐) 무시.
  Future<void> _setPinIcon(ClubModel club, {required bool selected}) async {
    final marker = _clubMarkers[club.clubId];
    if (marker == null) return;
    marker.setIcon(await _getClubPinIcon(club, selected));
    marker.setZIndex(_pinZIndex(club, selected));
  }

  // 핀 겹침 순서 (디자인 zIndex: 선택 7 > VYBE 추천 5 > 기본 2).
  // 선택된 핀의 이름 라벨이 옆 핀에 가리지 않도록 위로 올린다.
  int _pinZIndex(ClubModel club, bool selected) {
    if (selected) return 7;
    return club.isVybeRecommended ? 5 : 2;
  }

  // clubId → ClubModel 조회용 (탭 콜백에서 사용).
  final Map<String, ClubModel> _clubById = {};

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _sheetController = DraggableScrollableController();
    _sheetController.addListener(_onSheetChanged);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _sheetController.removeListener(_onSheetChanged);
    _sheetController.dispose();
    super.dispose();
  }

  // 앱이 백그라운드→포그라운드 복귀 시 iOS가 temp 디렉토리(마커 PNG)를 purge했을
  // 수 있다. 캐시된 NOverlayImage는 사라진 파일 경로를 들고 있어 재사용 시 네이티브
  // crash(NOverlayImage.swift force-unwrap)가 난다. 복귀 시 아이콘 캐시를 폐기해
  // 다음 렌더에서 파일을 새로 쓰도록 한다.
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _invalidateIconCaches();
      final isActive = ref.read(currentTabIndexProvider) == _kNearbyTabIndex;
      if (isActive && mounted) setState(() {});
    }
  }

  // 마커 아이콘 캐시 전부 폐기 + 강제 재렌더 표시.
  // 재렌더 시 NOverlayImage.fromWidget이 temp PNG를 새로 써서 stale 경로 crash 방지.
  void _invalidateIconCaches() {
    _clubPinCache.clear();
    _regionPinCache.clear();
    _myLocationIcon = null;
    _lastMarkerSig = null; // build의 whenData가 변경 감지해 재렌더하도록.
    _renderWhenVisible = true;
  }

  void _onSheetChanged() => setState(() {});

  // 마커 렌더 직렬화 — build 후처리·onMapReady·onCameraIdle에서 동시에 들어올 수
  // 있는데, 겹치면 clearOverlays/addOverlayAll이 서로를 덮어써 마커가 사라진다.
  Future<void> _renderJob = Future<void>.value();

  Future<void> _addMarkers(List<ClubModel> clubs) {
    final next = _renderJob.then((_) => _renderMarkers(clubs));
    _renderJob = next.catchError((_) {});
    return next;
  }

  Future<void> _renderMarkers(List<ClubModel> clubs) async {
    if (_mapController == null || !mounted) return;

    _clubById
      ..clear()
      ..addEntries(clubs.map((c) => MapEntry(c.clubId, c)));
    // 목록에서 사라진 선택 클럽은 선택 해제 (떠 있던 핀 카드도 함께 닫는다).
    if (_selectedClubId != null && !_clubById.containsKey(_selectedClubId)) {
      setState(() {
        _selectedClubId = null;
        _pinCardClub = null;
      });
    }

    await _mapController!.clearOverlays();
    // 줌 임계값에 따라 지역 클러스터 / 개별 핀 분기.
    // 검색(TOP 10 포함) 모드에서는 줌과 무관하게 항상 개별 핀 표시.
    final searchActive = ref.read(nearbySearchResultProvider) != null;
    if (_regionMode && !searchActive) {
      await _addRegionMarkers(clubs);
    } else {
      await _addClubMarkers(clubs);
    }
    // clearOverlays가 내 위치 마커도 지우므로 재추가.
    if (_myPos != null) await _addMyLocationMarker(_myPos!);
  }

  // 개별 클럽 핀(이름 라벨 + 핀). 줌 인 상태.
  Future<void> _addClubMarkers(List<ClubModel> clubs) async {
    final markers = <NMarker>{};
    _clubMarkers.clear();
    for (final c in clubs) {
      final selected = c.clubId == _selectedClubId;
      final marker = NMarker(
        id: c.clubId,
        position: NLatLng(c.lat, c.lng),
        icon: await _getClubPinIcon(c, selected),
        // 핀 바닥(라벨+핀 캔버스 하단)이 좌표를 가리키도록.
        anchor: const NPoint(0.5, 1.0),
      );
      marker.setZIndex(_pinZIndex(c, selected));
      marker.setOnTapListener((_) => _onPinTap(c));
      markers.add(marker);
      _clubMarkers[c.clubId] = marker;
    }
    await _mapController!.addOverlayAll(markers);
  }

  // area별 클러스터 동그라미(지역명 + 클럽 수). 줌 아웃 상태.
  Future<void> _addRegionMarkers(List<ClubModel> clubs) async {
    _clubMarkers.clear();
    // area별 그룹핑 (빈 area 제외).
    final byArea = <String, List<ClubModel>>{};
    for (final c in clubs) {
      if (c.area.isEmpty) continue;
      byArea.putIfAbsent(c.area, () => []).add(c);
    }

    final markers = <NMarker>{};
    for (final entry in byArea.entries) {
      final area = entry.key;
      final group = entry.value;
      // 그룹 중심 = 좌표 평균.
      final lat =
          group.map((c) => c.lat).reduce((a, b) => a + b) / group.length;
      final lng =
          group.map((c) => c.lng).reduce((a, b) => a + b) / group.length;
      final marker = NMarker(
        id: 'region_$area',
        position: NLatLng(lat, lng),
        icon: await _getRegionIcon(area, group.length),
        anchor: const NPoint(0.5, 0.5),
      );
      // 탭 → 해당 지역으로 줌 인 + 바텀시트에 그 지역 클럽 목록 표시.
      marker.setOnTapListener((_) async {
        ref.read(selectedAreaProvider.notifier).select(area);
        // 시트를 절반 높이로 펼쳐 리스트가 보이게.
        if (_sheetController.isAttached) {
          _sheetController.animateTo(
            _kSheetMid,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        }
        await _mapController?.updateCamera(
          NCameraUpdate.withParams(target: NLatLng(lat, lng), zoom: 15),
        );
      });
      markers.add(marker);
    }
    await _mapController!.addOverlayAll(markers);
  }

  // 지역 클러스터 동그라미 이미지. 캐시 키: area|count.
  Future<NOverlayImage> _getRegionIcon(String area, int count) async {
    final key = '$area|$count';
    final cached = _regionPinCache[key];
    if (cached != null) return cached;
    final img = await NaverOverlayImageQueue.run(
      () => NOverlayImage.fromWidget(
        widget: NearbyRegionCluster(area: area, count: count),
        size: Size(88.r, 88.r),
        context: context,
      ),
    );
    _regionPinCache[key] = img;
    return img;
  }

  @override
  Widget build(BuildContext context) {
    final myLocation = ref.watch(userLocationProvider);
    _myPos = NLatLng(myLocation.lat, myLocation.lng);

    final clubsAsync = ref.watch(nearbyViewModelProvider);
    final activeFilters = ref.watch(clubFilterViewModelProvider);

    // 찜 필터용 favoritedIds (바텀시트와 동일 로직 — 마커도 동일 조건 적용).
    final favoritedIds = ref.watch(mergedFavoriteIdsProvider);

    // 주변 탭이 화면에 보일 때만 마커를 렌더한다.
    // (KeepAlive로 화면 밖에서도 build/mounted가 유지되는데, 이때
    //  NOverlayImage.fromWidget을 offscreen context로 호출하면 네이티브 크래시)
    final isActive = ref.watch(currentTabIndexProvider) == _kNearbyTabIndex;

    // 탭이 숨겨졌다(다른 탭) 재진입하는 순간: 숨김 동안 iOS가 temp PNG를
    // purge했을 수 있어 캐시된 NOverlayImage 경로가 죽었을 수 있다.
    // 아이콘 캐시를 폐기해 아래 whenData에서 fresh 재렌더하도록 한다.
    if (isActive && !_wasActive) {
      _invalidateIconCaches();
    }
    _wasActive = isActive;

    // 검색 결과가 있으면 geo 클럽 대신 검색결과를 핀 소스로 사용.
    final searchResult = ref.watch(nearbySearchResultProvider);
    final List<ClubModel>? sourceClubs = searchResult != null
        ? searchResult.clubs
        : clubsAsync.asData?.value;

    if (sourceClubs != null) {
      // 검색 칩 필터(찜 포함)를 마커에도 동일 적용.
      final filtered = activeFilters.isEmpty
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
      final searchKeyword = searchResult?.keyword;
      final searchReqId = searchResult?.requestId;
      // 새 검색 요청이면 카메라를 결과 핀에 맞춤.
      // (_lastSearchReqId 갱신은 활성 탭에서 실제 렌더할 때만 — 화면 밖 build가
      //  값을 먼저 소비해 재진입 시 fit이 누락되는 것 방지)
      final newSearch = searchReqId != null && searchReqId != _lastSearchReqId;
      if (searchReqId == null) _lastSearchReqId = null;

      final sig =
          '${searchKeyword ?? "geo"}#${searchReqId ?? 0}|${filtered.map((c) => c.clubId).join(',')}|$_regionMode';
      final changed = sig != _lastMarkerSig;
      if (changed) {
        _lastMarkerSig = sig;
        _lastRenderedClubs = filtered;
        // 화면 밖이면 지금 렌더 금지 — 다시 보일 때 렌더하도록 표시.
        if (!isActive) _renderWhenVisible = true;
      }
      final fitCountry = searchResult?.fitCountry ?? false;
      if (isActive && (changed || _renderWhenVisible)) {
        _renderWhenVisible = false;
        _lastSearchReqId = searchReqId;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted) return;
          if (_mapController != null) {
            _addMarkers(filtered);
            if (newSearch) {
              // fitCountry(TOP 10 지도 보기)면 대한민국 전체, 아니면 핀 bounds.
              fitCountry ? _fitCountryCamera() : _fitCameraTo(filtered);
              // 검색 직후 결과 리스트가 보이도록 시트 펼침.
              if (_sheetController.isAttached) {
                _sheetController.animateTo(
                  _kSheetMid,
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeOut,
                );
              }
            }
          } else {
            _pendingClubs = filtered;
            // 맵 준비 후 fit 하도록 보류 (첫 진입이 검색 모드인 경우).
            if (newSearch) {
              _pendingFitCamera = true;
              _pendingFitCountry = fitCountry;
            }
          }
        });
      }
    }

    return Scaffold(
      backgroundColor: VybeColors.background,
      body: LayoutBuilder(
        builder: (context, constraints) {
          _stackHeight = constraints.maxHeight;
          return Stack(
            children: [
              _buildMap(),
              _buildReSearchButton(),
              _buildMapControls(),
              _buildBottomSheet(),
              // 핀 카드는 리스트 시트 위 (디자인 zIndex 32).
              _buildPinCard(),
              // 상단 GNB·칩은 시트보다 위 (시트가 최대로 올라와도 검색바 유지).
              _buildTopOverlay(),
            ],
          );
        },
      ),
    );
  }

  Widget _buildMap() {
    // _myPos는 build에서 항상 채워지지만, 지도가 먼저 만들어지는 경우를 위한 폴백.
    final myPos =
        _myPos ?? const NLatLng(AppGeo.hongdaeLat, AppGeo.hongdaeLng);
    return NaverMap(
      // 지도가 제스처를 선점(EagerGestureRecognizer)해 부모 PageView 가로
      // 스와이프에 팬이 가로채이지 않도록. 시트 영역은 지도 밖이라 영향 없음.
      forceGesture: true,
      options: NaverMapViewOptions(
        // 초기 위치 = 내 위치 (화면 가운데).
        initialCameraPosition: NCameraPosition(target: myPos, zoom: 16),
        mapType: NMapType.basic,
        activeLayerGroups: const [NLayerGroup.building, NLayerGroup.transit],
        nightModeEnable: true,
      ),
      onMapReady: (controller) async {
        _mapController = controller;
        if (_myPos != null) await _addMyLocationMarker(_myPos!);
        if (_pendingClubs.isNotEmpty) {
          final pending = _pendingClubs;
          _pendingClubs = [];
          await _addMarkers(pending);
          if (_pendingFitCamera) {
            _pendingFitCamera = false;
            _pendingFitCountry
                ? await _fitCountryCamera()
                : await _fitCameraTo(pending);
            _pendingFitCountry = false;
          }
        }
      },
      onCameraChange: (reason, animated) {
        // 사용자가 지도를 직접 움직일 때만 nav 축소 (프로그램 이동 제외).
        if (reason == NCameraUpdateReason.gesture) {
          ref.read(navBarVisibilityProvider.notifier).collapse();
        }
      },
      onCameraIdle: () async {
        final pos = await _mapController?.getCameraPosition();
        if (pos != null) {
          // 줌 임계값 교차 시 마커 모드 전환 후 재렌더.
          // 검색(TOP 10 포함) 모드에서는 줌 아웃해도 개별 핀 유지.
          final searchActive = ref.read(nearbySearchResultProvider) != null;
          final newRegionMode =
              pos.zoom <= _kRegionZoomThreshold && !searchActive;
          if (newRegionMode != _regionMode) {
            _regionMode = newRegionMode;
            if (_lastRenderedClubs != null) {
              await _addMarkers(_lastRenderedClubs!);
            }
          }
        }
        if (_ignoreNextIdle) {
          _ignoreNextIdle = false;
          return;
        }
        if (!_showReSearch) setState(() => _showReSearch = true);
      },
    );
  }

  // 상단 스크림 + 검색 GNB + 지도 위 필터 칩 줄 (디자인 NGGnb + NGChips).
  Widget _buildTopOverlay() {
    final keyword = ref.watch(nearbySearchResultProvider)?.keyword;
    final area = ref.watch(selectedAreaProvider);

    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: Stack(
        children: [
          // 지도 위 검색바 가독성용 스크림 + 상단 오로라(보라·라임).
          // 오로라는 스크림 범위 안에서만 얹는다 — 지도 전체에 깔면 실제
          // 지도 색이 왜곡돼 길·건물 구분이 어려워진다.
          IgnorePointer(
            child: Container(
              height: 150.h,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0xD10A090E),
                    Color(0x570A090E),
                    Color(0x000A090E),
                  ],
                  stops: [0.0, 0.58, 1.0],
                ),
              ),
              child: const DecoratedBox(
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    center: Alignment(-0.96, -1),
                    radius: 1.3,
                    colors: [Color(0x3D7731FE), Color(0x007731FE)],
                    stops: [0.0, 0.64],
                  ),
                ),
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: RadialGradient(
                      center: Alignment(1, -0.8),
                      radius: 1.1,
                      colors: [Color(0x14B5FF60), Color(0x00B5FF60)],
                      stops: [0.0, 0.66],
                    ),
                  ),
                ),
              ),
            ),
          ),
          SafeArea(
            bottom: false,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(height: 6.h),
                NearbyGnb(
                  searchKeyword: keyword,
                  onClearSearch: keyword == null ? null : _clearSearch,
                  onSearchTap: _openSearch,
                  area: area,
                  onClearArea: area == null ? null : _clearArea,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // 지역 클러스터 선택 해제 → 전체 목록으로 복귀.
  void _clearArea() {
    ref.read(selectedAreaProvider.notifier).select(null);
    if (_sheetController.isAttached) {
      _sheetController.animateTo(
        _kSheetMin,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  void _openSearch() {
    final uid = ref.read(currentUidProvider);
    Navigator.of(context).push(
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 280),
        reverseTransitionDuration: const Duration(milliseconds: 240),
        pageBuilder: (_, __, ___) => SearchScreen(
          showBackButton: true,
          // 지도 모드: 검색 제출 시 결과를 핀으로 표시.
          onMapResult: (q) => ref
              .read(nearbySearchResultProvider.notifier)
              .search(q, userId: uid),
        ),
        transitionsBuilder: (_, anim, __, child) {
          final curved = CurvedAnimation(
            parent: anim,
            curve: Curves.easeOutCubic,
            reverseCurve: Curves.easeInCubic,
          );
          return FadeTransition(opacity: curved, child: child);
        },
      ),
    );
  }

  // 검색 모드 해제 → geo 핀 복귀.
  void _clearSearch() {
    setState(() {
      _selectedClubId = null;
      _pinCardClub = null;
    });
    ref.read(nearbySearchResultProvider.notifier).clear();
  }

  // 지도 우측 플로팅 컨트롤 — 내 위치 (디자인 NGControls).
  // 핀 카드가 떠 있으면 숨긴다 (디자인 `{!pinClub && <NGControls/>}`).
  Widget _buildMapControls() {
    if (_pinCardClub != null) return const SizedBox.shrink();

    final sheetSize = _sheetController.isAttached
        ? _sheetController.size
        : _kSheetMin;

    return Positioned(
      right: 16.w,
      bottom: _stackHeight * sheetSize + 8.h,
      child: NearbyRoundButton(
        onTap: _onLocate,
        child: Icon(Icons.my_location_rounded, size: 19.r, color: Colors.white),
      ),
    );
  }

  // 검색 결과 카메라 여백 — 핀이 상단 GNB/하단 시트에 가리지 않고 화면 위쪽
  // (실제로 보이는 지도 밴드) 가운데에 오도록. 검색 직후 시트는 _kSheetMid까지
  // 펼쳐지므로 그 높이를 하단 여백으로 잡는다.
  EdgeInsets _searchCameraPadding() {
    // GNB + 필터 칩 줄 + 핀 라벨 높이.
    final top = 170.h;
    var bottom = _stackHeight > 0 ? _stackHeight * _kSheetMid + 16.h : 16.h;
    // 화면이 짧으면 여백만으로 지도 밴드가 사라져 fit이 깨진다 — 최소 밴드 확보.
    final minBand = 120.h;
    if (_stackHeight > 0 && _stackHeight - top - bottom < minBand) {
      bottom = (_stackHeight - top - minBand).clamp(0.0, bottom);
    }
    return EdgeInsets.only(left: 40.r, right: 40.r, top: top, bottom: bottom);
  }

  // 여백을 뺀 '보이는 지도 밴드'의 세로 중심 비율 (카메라 pivot용, 0~1).
  double _searchPivotY() {
    if (_stackHeight <= 0) return 0.5;
    final pad = _searchCameraPadding();
    final visibleBottom = _stackHeight - pad.bottom;
    if (visibleBottom <= pad.top) return 0.5;
    final centerY = (pad.top + visibleBottom) / 2;
    return (centerY / _stackHeight).clamp(0.15, 0.5);
  }

  // 대한민국 전체가 보이도록 카메라 축소 (TOP 10 지도 보기).
  Future<void> _fitCountryCamera() async {
    if (_mapController == null) return;
    await _mapController!.updateCamera(
      NCameraUpdate.fitBounds(_kKoreaBounds, padding: _searchCameraPadding()),
    );
  }

  // 검색 결과 핀들이 모두 보이도록 카메라 맞춤.
  Future<void> _fitCameraTo(List<ClubModel> clubs) async {
    if (_mapController == null || clubs.isEmpty) return;
    if (clubs.length == 1) {
      // 핀 1개는 fitBounds가 안 되므로 pivot으로 화면 위쪽에 놓는다.
      await _mapController!.updateCamera(
        NCameraUpdate.withParams(
          target: NLatLng(clubs.first.lat, clubs.first.lng),
          zoom: 15,
        )..setPivot(NPoint(0.5, _searchPivotY())),
      );
      return;
    }
    final lats = clubs.map((c) => c.lat);
    final lngs = clubs.map((c) => c.lng);
    final bounds = NLatLngBounds(
      southWest: NLatLng(
        lats.reduce((a, b) => a < b ? a : b),
        lngs.reduce((a, b) => a < b ? a : b),
      ),
      northEast: NLatLng(
        lats.reduce((a, b) => a > b ? a : b),
        lngs.reduce((a, b) => a > b ? a : b),
      ),
    );
    await _mapController!.updateCamera(
      NCameraUpdate.fitBounds(bounds, padding: _searchCameraPadding()),
    );
  }

  Future<void> _onLocate() async {
    if (_mapController == null || _myPos == null) return;
    await _mapController!.updateCamera(
      NCameraUpdate.withParams(target: _myPos, zoom: 16),
    );
  }

  Widget _buildReSearchButton() {
    if (!_showReSearch || _pinCardClub != null) return const SizedBox.shrink();

    final sheetSize = _sheetController.isAttached
        ? _sheetController.size
        : _kSheetMin;
    if (sheetSize > _kSheetMid - 0.01) return const SizedBox.shrink();

    return Positioned(
      bottom: _stackHeight * sheetSize + 8.h,
      left: 0,
      right: 0,
      child: Center(
        child: GestureDetector(
          onTap: _onReSearch,
          behavior: HitTestBehavior.opaque,
          child: NearbyFloatSurface(
            radius: 999,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 10.h),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.refresh_rounded,
                    size: 15.r,
                    color: VybeColors.mainLime500,
                  ),
                  SizedBox(width: 7.w),
                  Text(
                    '현재 지역에서 재검색',
                    style: TextStyle(
                      fontFamily: 'Pretendard',
                      fontWeight: FontWeight.w600,
                      fontSize: 14.sp,
                      height: 16 / 14,
                      letterSpacing: 14 * -0.025,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // 리스트 시트. 핀 카드가 떠 있는 동안은 아래로 밀어 감춘다
  // (디자인은 시트 높이를 0으로 만들지만 DraggableScrollableSheet는 minChildSize
  //  아래로 못 내려가므로 슬라이드로 처리 — 시트 상태/스크롤은 그대로 보존된다).
  Widget _buildBottomSheet() {
    final hidden = _pinCardClub != null;
    return IgnorePointer(
      ignoring: hidden,
      child: AnimatedSlide(
        offset: Offset(0, hidden ? 1 : 0),
        duration: const Duration(milliseconds: 280),
        curve: Curves.easeOutCubic,
        child: DraggableScrollableSheet(
          key: _sheetKey,
          controller: _sheetController,
          initialChildSize: _kSheetMin,
          minChildSize: _kSheetMin,
          maxChildSize: _kSheetMax,
          snap: true,
          snapSizes: const [_kSheetMin, _kSheetMid, _kSheetMax],
          builder: (_, scrollController) => NearbyBottomSheet(
            scrollController: scrollController,
            selectedClubId: _selectedClubId,
          ),
        ),
      ),
    );
  }

  // 핀 탭으로 뜨는 클럽 요약 카드 (디자인 NGPinCard). 카드 탭 → 클럽 상세.
  //
  // 카드가 닫혀도(_pinCardClub == null) Positioned는 남겨둔다 —
  // ClubPinCardTransition이 옛 카드를 붙잡고 퇴장 애니메이션을 돌린다.
  Widget _buildPinCard() {
    final club = _pinCardClub;
    // nav 바가 축소되면 그만큼 카드도 내려가 바와의 여백(10)을 유지한다.
    // 카드가 없을 땐 구독하지 않는다 — nav 축소마다 화면 전체가 리빌드되는 걸 막고,
    // 퇴장 애니메이션(240ms) 동안은 마지막 위치를 그대로 쓰면 충분하다.
    final navExpanded = club != null
        ? ref.watch(navBarVisibilityProvider)
        : ref.read(navBarVisibilityProvider);

    return AnimatedPositioned(
      duration: navBarResizeDuration,
      curve: navBarResizeCurve,
      left: 12.w,
      right: 12.w,
      bottom: navBarTotalHeight(context, expanded: navExpanded) + 10.h,
      // 사라지는 중인 카드는 탭을 받지 않는다 (닫자마자 상세로 들어가는 사고 방지).
      child: IgnorePointer(
        ignoring: club == null,
        child: ClubPinCardTransition(
          child: club == null ? null : _buildPinCardBody(club),
        ),
      ),
    );
  }

  Widget _buildPinCardBody(ClubModel club) {
    final uid = ref.watch(currentUidProvider);
    final favoritedIds = ref.watch(mergedFavoriteIdsProvider);
    final myLocation = ref.watch(userLocationProvider);
    final isFavorited = favoritedIds.contains(club.clubId);

    return ClubPinCard(
      // 다른 핀으로 갈아탈 때 새 카드로 인식돼 전환 애니메이션이 다시 돈다.
      key: ValueKey(club.clubId),
      club: club,
      isFavorited: isFavorited,
      distanceMeters: _distanceM(club, myLocation.lat, myLocation.lng),
      onTap: () => _openDetail(club),
      onClose: _closePinCard,
      onDirectionsTap: () => launchDirections(
        context,
        lat: club.lat,
        lng: club.lng,
        destination: club.address,
      ),
      onFavoriteTap: uid == null
          ? null
          : () => ref
                .read(favoriteViewModelProvider.notifier)
                .toggleFavorite(uid, club.clubId, isFavorited),
    );
  }

  // 좌표가 없는 클럽(0,0)은 거리 표기를 생략한다.
  double? _distanceM(ClubModel club, double lat, double lng) {
    if (club.lat == 0 && club.lng == 0) return null;
    return GeohashUtils.haversineKm(lat, lng, club.lat, club.lng) * 1000;
  }

  Future<void> _onReSearch() async {
    if (_mapController == null) return;
    setState(() => _showReSearch = false);
    // 검색 모드 해제 (geo 재조회로 복귀).
    ref.read(nearbySearchResultProvider.notifier).clear();
    // 지역 선택 해제 (새 영역 조회).
    ref.read(selectedAreaProvider.notifier).select(null);

    final bounds = await _mapController!.getContentBounds();
    final centerLat =
        (bounds.southWest.latitude + bounds.northEast.latitude) / 2;
    final centerLng =
        (bounds.southWest.longitude + bounds.northEast.longitude) / 2;
    final radiusKm = GeohashUtils.haversineKm(
      centerLat,
      centerLng,
      bounds.northEast.latitude,
      bounds.northEast.longitude,
    );
    final searchRadius = radiusKm * 1.2;

    if (kDebugMode) {
      debugPrint(
        '[NearbySearch] re-search '
        'bounds SW=(${bounds.southWest.latitude}, ${bounds.southWest.longitude}) '
        'NE=(${bounds.northEast.latitude}, ${bounds.northEast.longitude}) '
        'center=($centerLat, $centerLng) '
        'rawRadius=${radiusKm.toStringAsFixed(3)}km '
        'searchRadius=${searchRadius.toStringAsFixed(3)}km (buffer 20%)',
      );
    }

    // 버퍼 20% 추가해서 화면 경계 클럽 누락 방지
    await ref
        .read(nearbyViewModelProvider.notifier)
        .searchNearby(centerLat, centerLng, searchRadius);
  }
}
