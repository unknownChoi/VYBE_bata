import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vybe/core/constants/app_geo.dart';
import 'package:vybe/core/providers/auth_providers.dart';
import 'package:vybe/core/providers/location_providers.dart';
import 'package:vybe/data/models/club_model.dart';
import 'package:vybe/design_system/colors.dart';
import 'package:vybe/presentation/clubs/club_detail_route.dart';
import 'package:vybe/presentation/clubs/viewmodels/favorite_viewmodel.dart';
import 'package:vybe/presentation/main_scaffold/main_scaffold.dart';
import 'package:vybe/presentation/main_scaffold/nav_bar_visibility_provider.dart';
import 'package:vybe/presentation/nearby/nearby_camera_math.dart';
import 'package:vybe/presentation/nearby/nearby_map_presenter.dart';
import 'package:vybe/presentation/nearby/nearby_marker_factory.dart';
import 'package:vybe/presentation/nearby/nearby_style.dart';
import 'package:vybe/presentation/nearby/viewmodels/nearby_search_provider.dart';
import 'package:vybe/presentation/nearby/viewmodels/nearby_viewmodel.dart';
import 'package:vybe/presentation/nearby/widgets/nearby_bottom_sheet.dart';
import 'package:vybe/presentation/nearby/widgets/nearby_glass.dart';
import 'package:vybe/presentation/nearby/widgets/nearby_pin_card_layer.dart';
import 'package:vybe/presentation/nearby/widgets/nearby_re_search_button.dart';
import 'package:vybe/presentation/nearby/widgets/nearby_top_overlay.dart';
import 'package:vybe/presentation/search/search_screen.dart';
import 'package:vybe/presentation/search/viewmodels/club_filter_viewmodel.dart';

/// 주변 탭 — 네이버 지도 + 하단 리스트 시트.
///
/// 이 파일은 **조립만** 한다. 실제 지도 조작(마커 렌더·아이콘 캐시·카메라)은
/// [NearbyMapPresenter]와 [NearbyMarkerFactory]가, 기하 계산은
/// [NearbyCameraMath]가 맡는다.
class NearbyScreen extends ConsumerStatefulWidget {
  const NearbyScreen({super.key});

  @override
  ConsumerState<NearbyScreen> createState() => _NearbyScreenState();
}

class _NearbyScreenState extends ConsumerState<NearbyScreen>
    with WidgetsBindingObserver {
  late final NearbyMarkerFactory _markers;
  late final NearbyMapPresenter _map;
  late final DraggableScrollableController _sheetController;

  /// LayoutBuilder가 레이아웃 단계에서 Stack을 재빌드할 때 시트가 재생성
  /// (initState 재실행 → 컨트롤러 중복 attach 어설션)되지 않도록 element 고정.
  final GlobalKey _sheetKey = GlobalKey();

  /// 화면 밖에서 마커 변경이 생겨 렌더를 보류한 상태 (다시 보일 때 렌더).
  bool _renderWhenVisible = false;

  /// 직전 build에서 주변 탭이 활성이었는지 (숨김→재진입 감지용).
  bool _wasActive = false;

  bool _showReSearch = false;
  bool _ignoreNextIdle = true;
  double _stackHeight = 0;

  /// 맵 준비 전에 도착한 클럽 목록 — onMapReady에서 소비한다.
  List<ClubModel> _pendingClubs = [];
  bool _pendingFitCamera = false;
  bool _pendingFitCountry = false;

  /// 마커 재렌더 판단용 시그니처 (필터 결과 clubId 집합 + 클러스터 모드).
  String? _lastMarkerSig;

  /// 직전 소비한 검색 요청 id (새 검색 감지 → 카메라 핀에 맞춤용). null=geo 모드.
  /// keyword 대신 requestId 비교 — 같은 키워드 재요청(힙합 '지도에서 보기' 등)도 fit.
  int? _lastSearchReqId;

  /// 핀 탭으로 하단에 떠 있는 클럽 카드. null이면 카드 없음(= 리스트 시트 표시).
  ClubModel? _pinCardClub;

  /// 지도 쪽 후처리(핀 색 교체 + 카메라 이동) 작업 핸들.
  /// 상세를 먼저 열고 뒤에서 돌리기 때문에, 복귀 시 선택 해제 전에 이걸 기다려야
  /// 뒤늦게 끝난 선택이 핀을 라임으로 남겨두는 걸 막는다.
  Future<void>? _pinFocusJob;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _sheetController = DraggableScrollableController()
      ..addListener(_onSheetChanged);
    _markers = NearbyMarkerFactory(contextOf: () => context);
    _map = NearbyMapPresenter(
      factory: _markers,
      onPinTap: _onPinTap,
      onRegionTap: _onRegionTap,
      onSelectionChanged: () => mounted ? setState(() {}) : null,
      onSelectionLost: () => mounted ? setState(() => _pinCardClub = null) : null,
      isMounted: () => mounted,
    );
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _sheetController
      ..removeListener(_onSheetChanged)
      ..dispose();
    super.dispose();
  }

  /// 앱이 백그라운드→포그라운드로 복귀하면 iOS가 temp 디렉토리(마커 PNG)를
  /// purge했을 수 있다. 캐시를 폐기해 다음 렌더에서 파일을 새로 쓰게 한다.
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state != AppLifecycleState.resumed) return;
    _invalidateIconCaches();
    final isActive = ref.read(currentTabIndexProvider) == kNearbyTabIndex;
    if (isActive && mounted) setState(() {});
  }

  void _invalidateIconCaches() {
    _markers.invalidate();
    _lastMarkerSig = null; // build의 변경 감지가 재렌더하도록.
    _renderWhenVisible = true;
  }

  void _onSheetChanged() => setState(() {});

  double get _sheetSize =>
      _sheetController.isAttached ? _sheetController.size : kNearbySheetMin;

  void _animateSheetTo(double size, {int ms = 300}) {
    if (!_sheetController.isAttached) return;
    _sheetController.animateTo(
      size,
      duration: Duration(milliseconds: ms),
      curve: Curves.easeOut,
    );
  }

  // ------------------------------------------------------------ 핀 상호작용

  /// 핀 탭 → 하단 클럽 요약 카드 오픈 (상세 이동은 카드 탭).
  ///
  /// 카드는 즉시 그리고, 핀 아이콘 교체(직렬 큐)·카메라 이동처럼 수백 ms 걸리는
  /// 지도 작업은 뒤에서 진행한다.
  Future<void> _onPinTap(ClubModel club) async {
    setState(() => _pinCardClub = club);
    // 시트는 감춰지지만 높이는 남아 있어, 카드를 닫았을 때 최소 높이로 돌아오도록
    // 미리 접어둔다 (디자인 closePin → SNAPS[0]).
    if (_sheetSize > kNearbySheetMin) {
      _animateSheetTo(kNearbySheetMin, ms: 280);
    }
    // 프로그램 이동이라 '현재 지역에서 재검색' 유도는 띄우지 않는다.
    _ignoreNextIdle = true;
    _pinFocusJob = _map
        .focusPin(
          club,
          pivotY: _pinCardPivotY(),
          focusZoom: kNearbyPinFocusZoom,
        )
        .catchError((_) {});
    await _pinFocusJob;
  }

  /// 지역 클러스터 탭 → 그 지역으로 줌 인 + 시트에 그 지역 목록.
  Future<void> _onRegionTap(String area, NLatLng center) async {
    ref.read(selectedAreaProvider.notifier).select(area);
    _animateSheetTo(kNearbySheetMid);
    await _map.moveTo(center, zoom: kNearbyRegionFocusZoom);
  }

  /// 핀 카드 탭 → 클럽 상세. 돌아오면 카드는 그대로 유지한다.
  Future<void> _openDetail(ClubModel club) async {
    await openClubDetail(context, club.clubId);
    if (!mounted) return;
    // 상세에서 스크롤하며 축소된 하단 nav 복원.
    ref.read(navBarVisibilityProvider.notifier).expand();
  }

  /// 카드 닫기 → 핀 선택 해제 + 리스트 시트 복귀.
  Future<void> _closePinCard() async {
    final club = _pinCardClub;
    if (club == null) return;
    setState(() => _pinCardClub = null);
    // 선택 표시 작업이 늦게 끝나 핀이 라임으로 남는 걸 막는다.
    await _pinFocusJob;
    if (!mounted) return;
    await _map.deselect(club);
  }

  // ---------------------------------------------------------------- 카메라

  /// 핀 카드가 떠 있을 때의 카메라 pivot.
  double _pinCardPivotY() {
    final navExpanded = ref.read(navBarVisibilityProvider);
    final cardTop =
        _stackHeight -
        (kNearbyPinCardApproxHeight.h +
            navBarTotalHeight(context, expanded: navExpanded) +
            10.h);
    return NearbyCameraMath.pinCardPivotY(
      stackHeight: _stackHeight,
      topInset: kNearbyMapTopInset.h,
      cardTop: cardTop,
    );
  }

  EdgeInsets _searchCameraPadding() => NearbyCameraMath.searchCameraPadding(
    stackHeight: _stackHeight,
    topInset: kNearbyMapTopInset.h,
    sheetMid: kNearbySheetMid,
    minBand: kNearbyMinMapBand.h,
    sidePad: 40.r,
    gap: 16.h,
  );

  Future<void> _fitTo(List<ClubModel> clubs, {required bool country}) async {
    final padding = _searchCameraPadding();
    if (country) {
      await _map.fitBounds(kKoreaBounds, padding);
      return;
    }
    await _map.fitClubs(
      clubs,
      padding: padding,
      singlePivotY: NearbyCameraMath.searchPivotY(
        stackHeight: _stackHeight,
        padding: padding,
      ),
    );
  }

  // ------------------------------------------------------------------ 검색

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
        transitionsBuilder: (_, anim, __, child) => FadeTransition(
          opacity: CurvedAnimation(
            parent: anim,
            curve: Curves.easeOutCubic,
            reverseCurve: Curves.easeInCubic,
          ),
          child: child,
        ),
      ),
    );
  }

  /// 검색 모드 해제 → geo 핀 복귀.
  void _clearSearch() {
    _map.clearSelection();
    setState(() => _pinCardClub = null);
    ref.read(nearbySearchResultProvider.notifier).clear();
  }

  /// 지역 클러스터 선택 해제 → 전체 목록으로 복귀.
  void _clearArea() {
    ref.read(selectedAreaProvider.notifier).select(null);
    _animateSheetTo(kNearbySheetMin);
  }

  /// 지금 보이는 영역으로 다시 조회 (검색·지역 선택은 해제).
  Future<void> _onReSearch() async {
    final bounds = await _map.visibleBounds();
    if (bounds == null || !mounted) return;

    setState(() => _showReSearch = false);
    ref.read(nearbySearchResultProvider.notifier).clear();
    ref.read(selectedAreaProvider.notifier).select(null);

    final query = NearbyCameraMath.viewportQuery(bounds);
    if (kDebugMode) {
      debugPrint(
        '[NearbySearch] re-search '
        'center=(${query.lat}, ${query.lng}) '
        'searchRadius=${query.radiusKm.toStringAsFixed(3)}km (buffer 20%)',
      );
    }
    await ref
        .read(nearbyViewModelProvider.notifier)
        .searchNearby(query.lat, query.lng, query.radiusKm);
  }

  // ------------------------------------------------------------------ 빌드

  @override
  Widget build(BuildContext context) {
    final myLocation = ref.watch(userLocationProvider);
    _map.myPosition = NLatLng(myLocation.lat, myLocation.lng);

    // 주변 탭이 화면에 보일 때만 마커를 렌더한다.
    // (KeepAlive로 화면 밖에서도 build/mounted가 유지되는데, 이때
    //  NOverlayImage.fromWidget을 offscreen context로 호출하면 네이티브 크래시)
    final isActive = ref.watch(currentTabIndexProvider) == kNearbyTabIndex;
    // 숨김 동안 iOS가 temp PNG를 purge했을 수 있어 재진입 순간 캐시를 버린다.
    if (isActive && !_wasActive) _invalidateIconCaches();
    _wasActive = isActive;

    _syncMarkers(isActive: isActive);

    return Scaffold(
      backgroundColor: VybeColors.background,
      body: LayoutBuilder(
        builder: (context, constraints) {
          _stackHeight = constraints.maxHeight;
          return Stack(
            children: [
              _buildMap(),
              if (_showReSearch &&
                  _pinCardClub == null &&
                  _sheetSize <= kNearbySheetMid - 0.01)
                NearbyReSearchButton(
                  sheetTop: _stackHeight * _sheetSize,
                  onTap: _onReSearch,
                ),
              if (_pinCardClub == null) _buildMyLocationButton(),
              _buildBottomSheet(),
              // 핀 카드는 리스트 시트 위 (디자인 zIndex 32).
              NearbyPinCardLayer(
                club: _pinCardClub,
                onOpenDetail: _openDetail,
                onClose: _closePinCard,
              ),
              // 상단 GNB는 시트보다 위 (시트가 최대로 올라와도 검색바 유지).
              NearbyTopOverlay(
                searchKeyword: ref.watch(nearbySearchResultProvider)?.keyword,
                area: ref.watch(selectedAreaProvider),
                onSearchTap: _openSearch,
                onClearSearch: _clearSearch,
                onClearArea: _clearArea,
              ),
            ],
          );
        },
      ),
    );
  }

  /// 지금 보여야 할 클럽 목록을 구해 마커 렌더를 예약한다.
  ///
  /// build 중에는 지도를 건드리지 않는다 — 실제 호출은 post-frame으로 미룬다.
  void _syncMarkers({required bool isActive}) {
    final searchResult = ref.watch(nearbySearchResultProvider);
    final clubsAsync = ref.watch(nearbyViewModelProvider);
    final sourceClubs = searchResult?.clubs ?? clubsAsync.asData?.value;
    if (sourceClubs == null) return;

    // 검색 칩 필터(찜 포함)를 마커에도 동일 적용.
    final activeFilters = ref.watch(clubFilterViewModelProvider);
    final favoritedIds = ref.watch(mergedFavoriteIdsProvider);
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

    // 검색(TOP 10 포함) 모드에서는 줌과 무관하게 항상 개별 핀 표시.
    _map.regionMode = _regionModeByZoom && searchResult == null;

    final searchReqId = searchResult?.requestId;
    // 새 검색 요청이면 카메라를 결과 핀에 맞춘다.
    // (_lastSearchReqId 갱신은 활성 탭에서 실제 렌더할 때만 — 화면 밖 build가
    //  값을 먼저 소비해 재진입 시 fit이 누락되는 것 방지)
    final newSearch = searchReqId != null && searchReqId != _lastSearchReqId;
    if (searchReqId == null) _lastSearchReqId = null;

    final sig =
        '${searchResult?.keyword ?? "geo"}#${searchReqId ?? 0}'
        '|${filtered.map((c) => c.clubId).join(',')}|${_map.regionMode}';
    final changed = sig != _lastMarkerSig;
    if (changed) {
      _lastMarkerSig = sig;
      _map.lastRendered = filtered;
      // 화면 밖이면 지금 렌더 금지 — 다시 보일 때 렌더하도록 표시.
      if (!isActive) _renderWhenVisible = true;
    }
    if (!isActive || !(changed || _renderWhenVisible)) return;

    _renderWhenVisible = false;
    _lastSearchReqId = searchReqId;
    final fitCountry = searchResult?.fitCountry ?? false;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      if (!_map.isReady) {
        _pendingClubs = filtered;
        // 맵 준비 후 fit 하도록 보류 (첫 진입이 검색 모드인 경우).
        if (newSearch) {
          _pendingFitCamera = true;
          _pendingFitCountry = fitCountry;
        }
        return;
      }
      _map.render(filtered);
      if (!newSearch) return;
      _fitTo(filtered, country: fitCountry);
      // 검색 직후 결과 리스트가 보이도록 시트 펼침.
      _animateSheetTo(kNearbySheetMid);
    });
  }

  /// 줌 임계값 기준 클러스터 모드 여부. 카메라 idle에서 갱신된다.
  bool _regionModeByZoom = false;

  Widget _buildMap() {
    // 지도가 먼저 만들어지는 경우를 위한 폴백 (build에서 항상 채워지긴 한다).
    final myPos =
        _map.myPosition ?? const NLatLng(AppGeo.hongdaeLat, AppGeo.hongdaeLng);
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
      onMapReady: _onMapReady,
      onCameraChange: (reason, animated) {
        // 사용자가 지도를 직접 움직일 때만 nav 축소 (프로그램 이동 제외).
        if (reason == NCameraUpdateReason.gesture) {
          ref.read(navBarVisibilityProvider.notifier).collapse();
        }
      },
      onCameraIdle: _onCameraIdle,
    );
  }

  Future<void> _onMapReady(NaverMapController controller) async {
    _map.controller = controller;
    final pos = _map.myPosition;
    if (pos != null) await _map.addMyLocationMarker(pos);
    if (_pendingClubs.isEmpty) return;

    final pending = _pendingClubs;
    _pendingClubs = [];
    await _map.render(pending);
    if (!_pendingFitCamera) return;

    _pendingFitCamera = false;
    await _fitTo(pending, country: _pendingFitCountry);
    _pendingFitCountry = false;
  }

  Future<void> _onCameraIdle() async {
    final pos = await _map.cameraPosition();
    if (pos != null) {
      // 줌 임계값 교차 시 마커 모드 전환 후 재렌더.
      // 검색(TOP 10 포함) 모드에서는 줌 아웃해도 개별 핀 유지.
      final searchActive = ref.read(nearbySearchResultProvider) != null;
      _regionModeByZoom = pos.zoom <= kNearbyRegionZoomThreshold;
      final next = _regionModeByZoom && !searchActive;
      if (next != _map.regionMode) {
        _map.regionMode = next;
        await _map.reRenderLast();
      }
    }
    if (_ignoreNextIdle) {
      _ignoreNextIdle = false;
      return;
    }
    if (!_showReSearch && mounted) setState(() => _showReSearch = true);
  }

  /// 지도 우측 플로팅 컨트롤 — 내 위치 (디자인 NGControls).
  Widget _buildMyLocationButton() {
    return Positioned(
      right: 16.w,
      bottom: _stackHeight * _sheetSize + 8.h,
      child: NearbyRoundButton(
        onTap: () => _map.moveToMyLocation(zoom: 16),
        child: Icon(Icons.my_location_rounded, size: 19.r, color: Colors.white),
      ),
    );
  }

  /// 리스트 시트. 핀 카드가 떠 있는 동안은 아래로 밀어 감춘다
  /// (디자인은 시트 높이를 0으로 만들지만 DraggableScrollableSheet는 minChildSize
  ///  아래로 못 내려가므로 슬라이드로 처리 — 시트 상태/스크롤은 그대로 보존된다).
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
          initialChildSize: kNearbySheetMin,
          minChildSize: kNearbySheetMin,
          maxChildSize: kNearbySheetMax,
          snap: true,
          snapSizes: const [kNearbySheetMin, kNearbySheetMid, kNearbySheetMax],
          builder: (_, scrollController) => NearbyBottomSheet(
            scrollController: scrollController,
            selectedClubId: _map.selectedClubId,
          ),
        ),
      ),
    );
  }
}
