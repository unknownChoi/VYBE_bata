import 'package:flutter/material.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vybe/core/providers/auth_providers.dart';
import 'package:vybe/core/providers/location_providers.dart';
import 'package:vybe/core/utils/geohash_utils.dart';
import 'package:vybe/data/models/club_model.dart';
import 'package:vybe/design_system/colors.dart';
import 'package:vybe/presentation/clubs/viewmodels/favorite_viewmodel.dart';
import 'package:vybe/presentation/common/widgets/vybe_map_pin.dart';
import 'package:vybe/presentation/nearby/viewmodels/nearby_viewmodel.dart';
import 'package:vybe/presentation/nearby/viewmodels/nearby_search_provider.dart';
import 'package:vybe/presentation/search/search_screen.dart';
import 'package:vybe/presentation/search/viewmodels/club_filter_viewmodel.dart';
import 'package:vybe/presentation/main_scaffold/nav_bar_visibility_provider.dart';
import 'package:vybe/presentation/nearby/widgets/nearby_bottom_sheet.dart';
import 'package:vybe/presentation/nearby/widgets/nearby_detail_sheet.dart';
import 'package:vybe/presentation/nearby/widgets/nearby_glass.dart';
import 'package:vybe/presentation/nearby/widgets/nearby_gnb.dart';

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
  static final NLatLngBounds _kKoreaBounds = NLatLngBounds(
    southWest: const NLatLng(33.0, 124.6),
    northEast: const NLatLng(38.7, 131.0),
  );
  // 주변 탭 인덱스 (MainScaffold PageView 기준).
  static const int _kNearbyTabIndex = 1;
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
  // 핀 탭 시 지도 위로 띄우는 상세 시트 대상 클럽 (null이면 시트 닫힘).
  ClubModel? _detailClub;

  // 이름 라벨 + 핀 이미지 (선택 시 녹색). 캐시 키: clubId|selected
  Future<NOverlayImage> _getClubPinIcon(ClubModel club, bool selected) async {
    final key = '${club.clubId}|$selected';
    final cached = _clubPinCache[key];
    if (cached != null) return cached;
    final img = await NOverlayImage.fromWidget(
      widget: _NearbyPin(label: club.name, selected: selected),
      size: Size(200.r, 56.r),
      context: context,
    );
    _clubPinCache[key] = img;
    return img;
  }

  Future<NOverlayImage> _getMyLocationIcon() async {
    return _myLocationIcon ??= await NOverlayImage.fromWidget(
      widget: const _MyLocationDot(),
      size: const Size(28, 28),
      context: context,
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

  // 핀 탭 → 이전 선택 보라/현재 선택 녹색으로 아이콘 교체 + 상세 시트 표시.
  Future<void> _onPinTap(ClubModel club) async {
    if (_selectedClubId != club.clubId) {
      final prevId = _selectedClubId;
      _selectedClubId = club.clubId;

      final prevMarker = prevId == null ? null : _clubMarkers[prevId];
      final prevClub = _clubById[prevId];
      if (prevMarker != null && prevClub != null) {
        prevMarker.setIcon(await _getClubPinIcon(prevClub, false));
      }
      final marker = _clubMarkers[club.clubId];
      if (marker != null) {
        marker.setIcon(await _getClubPinIcon(club, true));
      }
    }

    // 선택 핀이 카메라 중앙에 오도록 이동.
    await _mapController?.updateCamera(
      NCameraUpdate.scrollAndZoomTo(target: NLatLng(club.lat, club.lng)),
    );
    if (!mounted) return;
    // 리스트 시트의 내용만 상세로 교체 — 새 시트를 띄우지 않으므로
    // 현재 시트 높이가 그대로 유지된다 (animateTo 호출 금지).
    setState(() => _detailClub = club);
  }

  // 상세 닫기(X) → 시트 내용을 리스트로 되돌리고 선택 핀 보라로 복원.
  // 시트 높이는 건드리지 않는다 (열 때와 마찬가지로 그대로 유지).
  Future<void> _closeDetail() async {
    final closed = _detailClub;
    if (mounted) setState(() => _detailClub = null);
    // 상세 닫힘 → 하단 nav 원래 크기로 복원.
    ref.read(navBarVisibilityProvider.notifier).expand();
    if (closed != null && _selectedClubId == closed.clubId) {
      _selectedClubId = null;
      final marker = _clubMarkers[closed.clubId];
      if (marker != null) {
        marker.setIcon(await _getClubPinIcon(closed, false));
      }
    }
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

  Future<void> _addMarkers(List<ClubModel> clubs) async {
    if (_mapController == null || !mounted) return;

    _clubById
      ..clear()
      ..addEntries(clubs.map((c) => MapEntry(c.clubId, c)));
    // 목록에서 사라진 선택 클럽은 선택 해제.
    if (_selectedClubId != null && !_clubById.containsKey(_selectedClubId)) {
      _selectedClubId = null;
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
    final img = await NOverlayImage.fromWidget(
      widget: _RegionCluster(area: area, count: count),
      size: Size(88.r, 88.r),
      context: context,
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
    final uid = ref.watch(currentUidProvider);
    final streamFavIds = uid != null
        ? ref.watch(favoritedClubIdsProvider(uid)).asData?.value ?? <String>{}
        : <String>{};
    final optimistic = ref.watch(favoriteViewModelProvider);
    final favoritedIds = Set<String>.from(streamFavIds)
      ..addAll(optimistic.entries.where((e) => e.value).map((e) => e.key))
      ..removeAll(optimistic.entries.where((e) => !e.value).map((e) => e.key));

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
              // 상단 GNB·칩은 시트보다 위 (시트가 최대로 올라와도 검색바 유지).
              _buildTopOverlay(),
            ],
          );
        },
      ),
    );
  }

  Widget _buildMap() {
    final myPos = _myPos ?? const NLatLng(37.5572, 126.9239);
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
    _selectedClubId = null;
    ref.read(nearbySearchResultProvider.notifier).clear();
  }

  // 지도 우측 플로팅 컨트롤 — 내 위치 (디자인 NGControls).
  // 상세도 같은 시트 안에 뜨므로(시트 높이 = 컨트롤 위치 기준) 계속 표시한다.
  Widget _buildMapControls() {
    final sheetSize = _sheetController.isAttached
        ? _sheetController.size
        : _kSheetMin;

    return Positioned(
      right: 16.w,
      bottom: _stackHeight * sheetSize + 8.h,
      child: NearbyRoundButton(
        onTap: _onLocate,
        child: Icon(
          Icons.my_location_rounded,
          size: 19.r,
          color: Colors.white,
        ),
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
    if (!_showReSearch || _detailClub != null) return const SizedBox.shrink();

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

  // 리스트 시트. 핀이 선택되면 같은 시트 안에서 내용만 상세로 바뀐다
  // (새 시트를 띄우지 않아 현재 시트 높이가 그대로 유지된다).
  Widget _buildBottomSheet() {
    return DraggableScrollableSheet(
      key: _sheetKey,
      controller: _sheetController,
      initialChildSize: _kSheetMin,
      minChildSize: _kSheetMin,
      maxChildSize: _kSheetMax,
      snap: true,
      snapSizes: const [_kSheetMin, _kSheetMid, _kSheetMax],
      builder: (_, scrollController) {
        final detail = _detailClub;
        if (detail != null) {
          return NearbyDetailSheetContent(
            // clubId가 바뀌면 상세 내용 상태 초기화(스크롤 맨 위로).
            key: ValueKey(detail.clubId),
            clubId: detail.clubId,
            scrollController: scrollController,
            onClose: _closeDetail,
          );
        }
        return NearbyBottomSheet(
          scrollController: scrollController,
          selectedClubId: _selectedClubId,
        );
      },
    );
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

    // ignore: avoid_print
    print(
      '[NearbySearch] re-search '
      'bounds SW=(${bounds.southWest.latitude}, ${bounds.southWest.longitude}) '
      'NE=(${bounds.northEast.latitude}, ${bounds.northEast.longitude}) '
      'center=($centerLat, $centerLng) '
      'rawRadius=${radiusKm.toStringAsFixed(3)}km '
      'searchRadius=${searchRadius.toStringAsFixed(3)}km (buffer 20%)',
    );

    // 버퍼 20% 추가해서 화면 경계 클럽 누락 방지
    await ref
        .read(nearbyViewModelProvider.notifier)
        .searchNearby(centerLat, centerLng, searchRadius);
  }
}

// 내 위치 점 (파란 점 + 흰 테두리). fromWidget으로 마커 이미지화.
// 지도 마커: 이름 라벨 pill + 핀. 선택 시 녹색(LIME), 평소 보라.
// fromWidget으로 이미지화 → 핀 바닥이 캔버스 하단(=좌표)에 오도록 하단 정렬.
class _NearbyPin extends StatelessWidget {
  final String label;
  final bool selected;
  const _NearbyPin({required this.label, required this.selected});

  static const _purple = Color(0xFF622ACF);
  static const _lime = Color(0xFFB5FF60);
  static const _bg = Color(0xFF101013);

  @override
  Widget build(BuildContext context) {
    final pinColor = selected ? _lime : _purple;
    return SizedBox(
      width: 200.r,
      height: 56.r,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
            decoration: BoxDecoration(
              color: pinColor,
              borderRadius: BorderRadius.circular(8.r),
              boxShadow: [
                BoxShadow(
                  color: pinColor.withValues(alpha: 0.4),
                  blurRadius: selected ? 20.r : 12.r,
                  offset: Offset(0, 4.h),
                ),
              ],
            ),
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontFamily: 'Pretendard',
                fontSize: 12.sp,
                fontWeight: FontWeight.w700,
                height: 14 / 12,
                letterSpacing: 12 * -0.025,
                color: selected ? _bg : Colors.white,
              ),
            ),
          ),
          SizedBox(height: 4.h),
          SizedBox(
            width: 24.r,
            height: 27.r,
            child: CustomPaint(painter: VybeMapPinPainter(color: pinColor)),
          ),
        ],
      ),
    );
  }
}

// 지역 클러스터 동그라미. 보라 원 + 지역명(작게) + 클럽 수(크게) + glow.
class _RegionCluster extends StatelessWidget {
  final String area;
  final int count;
  const _RegionCluster({required this.area, required this.count});

  static const _purple = Color(0xFF622ACF);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 88.r,
      height: 88.r,
      child: Center(
        child: Container(
          width: 64.r,
          height: 64.r,
          decoration: BoxDecoration(
            color: _purple,
            shape: BoxShape.circle,
            border: Border.all(color: const Color(0xFFB388FF), width: 2),
            boxShadow: [
              BoxShadow(
                color: _purple.withValues(alpha: 0.5),
                blurRadius: 20.r,
                spreadRadius: 2.r,
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                area,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontFamily: 'Pretendard',
                  fontSize: 11.sp,
                  fontWeight: FontWeight.w600,
                  height: 13 / 11,
                  letterSpacing: 11 * -0.025,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: 1.h),
              Text(
                '$count',
                style: TextStyle(
                  fontFamily: 'Pretendard',
                  fontSize: 20.sp,
                  fontWeight: FontWeight.w700,
                  height: 22 / 20,
                  letterSpacing: 20 * -0.025,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MyLocationDot extends StatelessWidget {
  const _MyLocationDot();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 18,
        height: 18,
        decoration: BoxDecoration(
          color: const Color(0xFF0086FF),
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white, width: 3),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF0086FF).withValues(alpha: 0.4),
              blurRadius: 6,
              spreadRadius: 1,
            ),
          ],
        ),
      ),
    );
  }
}
