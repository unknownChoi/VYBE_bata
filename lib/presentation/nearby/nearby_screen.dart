import 'package:flutter/material.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vybe/core/providers/auth_providers.dart';
import 'package:vybe/core/providers/location_providers.dart';
import 'package:vybe/core/utils/geohash_utils.dart';
import 'package:vybe/data/models/club_model.dart';
import 'package:vybe/design_system/colors.dart';
import 'package:vybe/presentation/clubs/club_detail_screen.dart';
import 'package:vybe/presentation/clubs/viewmodels/favorite_viewmodel.dart';
import 'package:vybe/presentation/common/widgets/vybe_map_pin.dart';
import 'package:vybe/presentation/nearby/viewmodels/nearby_viewmodel.dart';
import 'package:vybe/presentation/search/viewmodels/club_filter_viewmodel.dart';
import 'package:vybe/presentation/main_scaffold/nav_bar_visibility_provider.dart';
import 'package:vybe/presentation/nearby/widgets/nearby_bottom_sheet.dart';
import 'package:vybe/presentation/nearby/widgets/nearby_gnb.dart';

class NearbyScreen extends ConsumerStatefulWidget {
  const NearbyScreen({super.key});

  @override
  ConsumerState<NearbyScreen> createState() => _NearbyScreenState();
}

class _NearbyScreenState extends ConsumerState<NearbyScreen> {
  // 이 줌 이하로 축소되면 개별 핀 대신 지역(area)별 클러스터 동그라미 표시.
  static const double _kRegionZoomThreshold = 13.0;

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

    // 클럽 리스트 시트를 최소로 내리고 상세 시트를 띄움.
    if (_sheetController.isAttached) {
      _sheetController.animateTo(
        0.2,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );
    }
    // 선택 핀이 카메라 중앙에 오도록 이동.
    await _mapController?.updateCamera(
      NCameraUpdate.scrollAndZoomTo(target: NLatLng(club.lat, club.lng)),
    );
    if (!mounted) return;
    setState(() => _detailClub = club);
    await _showDetailSheet(club);
  }

  // 상세 페이지를 모달 바텀시트로 그대로 띄운다.
  Future<void> _showDetailSheet(ClubModel club) async {
    final screenHeight = MediaQuery.of(context).size.height;
    final topPadding = MediaQuery.of(context).padding.top;
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: const Color(0x8C000000),
      builder: (ctx) => SizedBox(
        height: screenHeight - topPadding - 8.h,
        child: ClipRRect(
          borderRadius: BorderRadius.vertical(top: Radius.circular(28.r)),
          child: ClubDetailScreen(
            clubId: club.clubId,
            onClose: () => Navigator.of(ctx).pop(),
          ),
        ),
      ),
    );
    // 시트 닫힘 → 선택 핀 복원.
    await _closeDetail();
  }

  // 상세 시트 닫기 → 선택 핀 보라로 복원.
  Future<void> _closeDetail() async {
    final closed = _detailClub;
    if (mounted) setState(() => _detailClub = null);
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
    _sheetController = DraggableScrollableController();
    _sheetController.addListener(_onSheetChanged);
  }

  @override
  void dispose() {
    _sheetController.removeListener(_onSheetChanged);
    _sheetController.dispose();
    super.dispose();
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
    if (_regionMode) {
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
            0.5,
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

    clubsAsync.whenData((clubs) {
      // 검색 칩 필터(찜 포함)를 마커에도 동일 적용.
      final filtered = activeFilters.isEmpty
          ? clubs
          : clubs
              .where((c) => clubMatchesFilters(c, activeFilters,
                  favoritedIds: favoritedIds))
              .toList();
      final sig = '${filtered.map((c) => c.clubId).join(',')}|$_regionMode';
      if (sig != _lastMarkerSig) {
        _lastMarkerSig = sig;
        _lastRenderedClubs = filtered;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted) return;
          if (_mapController != null) {
            _addMarkers(filtered);
          } else {
            _pendingClubs = filtered;
          }
        });
      }
    });

    return Scaffold(
      backgroundColor: VybeColors.background,
      body: LayoutBuilder(
        builder: (context, constraints) {
          _stackHeight = constraints.maxHeight;
          return Stack(
            children: [
              _buildMap(),
              _buildTopOverlay(),
              _buildLocateButton(),
              _buildReSearchButton(),
              _buildBottomSheet(),
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
          await _addMarkers(_pendingClubs);
          _pendingClubs = [];
        }
      },
      onCameraChange: (reason, animated) {
        // 사용자가 지도를 직접 움직일 때만 nav 축소 (프로그램 이동 제외).
        if (reason == NCameraUpdateReason.gesture) {
          ref.read(navBarVisibilityProvider.notifier).collapse();
        }
      },
      onCameraIdle: () async {
        // 현재 지도 줌 → 비율(%) 출력. 네이버 지도 zoom 범위 0~21 기준.
        final pos = await _mapController?.getCameraPosition();
        if (pos != null) {
          final percent = (pos.zoom / 21 * 100).toStringAsFixed(1);
          debugPrint('[지도 줌] ${pos.zoom.toStringAsFixed(2)} ($percent%)');

          // 줌 임계값 교차 시 마커 모드 전환 후 재렌더.
          final newRegionMode = pos.zoom <= _kRegionZoomThreshold;
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

  Widget _buildTopOverlay() {
    return SafeArea(
      child: NearbyGnb(
        onSearchTap: () {
          // TODO: 검색 화면 이동
        },
      ),
    );
  }

  // 내 위치로 카메라 이동 FAB (디자인: MapControls)
  Widget _buildLocateButton() {
    // 상세 시트가 떠 있으면 지도 컨트롤 숨김.
    if (_detailClub != null) return const SizedBox.shrink();
    final sheetSize = _sheetController.isAttached ? _sheetController.size : 0.2;

    return Positioned(
      right: 16.w,
      bottom: _stackHeight * sheetSize + 16.h,
      child: GestureDetector(
        onTap: _onLocate,
        child: Container(
          width: 44.r,
          height: 44.r,
          decoration: BoxDecoration(
            color: const Color(0xEB101013),
            shape: BoxShape.circle,
            border: Border.all(color: VybeColors.gray800, width: 1),
            boxShadow: const [
              BoxShadow(
                color: Color(0x4D000000),
                blurRadius: 12,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Icon(
            Icons.my_location_rounded,
            size: 20.r,
            color: Colors.white,
          ),
        ),
      ),
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

    final sheetSize = _sheetController.isAttached ? _sheetController.size : 0.2;
    if (sheetSize > 0.5) return const SizedBox.shrink();

    return Positioned(
      bottom: _stackHeight * sheetSize + 16.h,
      left: 0,
      right: 0,
      child: Center(
        child: GestureDetector(
          onTap: _onReSearch,
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
            decoration: BoxDecoration(
              color: VybeColors.surface,
              borderRadius: BorderRadius.circular(20.r),
              border: Border.all(color: VybeColors.gray800, width: 1),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.refresh_rounded, size: 16.r, color: Colors.white),
                SizedBox(width: 6.w),
                Text(
                  '현재 지역에서 재검색',
                  style: TextStyle(
                    fontFamily: 'Pretendard',
                    fontWeight: FontWeight.w500,
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
    );
  }

  Widget _buildBottomSheet() {
    return DraggableScrollableSheet(
      key: _sheetKey,
      controller: _sheetController,
      initialChildSize: 0.2,
      minChildSize: 0.2,
      maxChildSize: 0.85,
      snap: true,
      snapSizes: const [0.2, 0.5, 0.85],
      builder: (_, scrollController) => NearbyBottomSheet(
        scrollController: scrollController,
      ),
    );
  }

  Future<void> _onReSearch() async {
    if (_mapController == null) return;
    setState(() => _showReSearch = false);
    // 지역 선택 해제 (새 영역 조회).
    ref.read(selectedAreaProvider.notifier).select(null);

    final bounds = await _mapController!.getContentBounds();
    final centerLat =
        (bounds.southWest.latitude + bounds.northEast.latitude) / 2;
    final centerLng =
        (bounds.southWest.longitude + bounds.northEast.longitude) / 2;
    final radiusKm = GeohashUtils.haversineKm(
      centerLat, centerLng,
      bounds.northEast.latitude, bounds.northEast.longitude,
    );
    final searchRadius = radiusKm * 1.2;

    // ignore: avoid_print
    print('[NearbySearch] re-search '
        'bounds SW=(${bounds.southWest.latitude}, ${bounds.southWest.longitude}) '
        'NE=(${bounds.northEast.latitude}, ${bounds.northEast.longitude}) '
        'center=($centerLat, $centerLng) '
        'rawRadius=${radiusKm.toStringAsFixed(3)}km '
        'searchRadius=${searchRadius.toStringAsFixed(3)}km (buffer 20%)');

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

