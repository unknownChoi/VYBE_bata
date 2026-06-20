import 'package:flutter/material.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vybe/core/providers/location_providers.dart';
import 'package:vybe/core/utils/geohash_utils.dart';
import 'package:vybe/data/models/club_model.dart';
import 'package:vybe/design_system/colors.dart';
import 'package:vybe/presentation/common/widgets/vybe_map_pin.dart';
import 'package:vybe/presentation/nearby/viewmodels/nearby_viewmodel.dart';
import 'package:vybe/presentation/nearby/widgets/nearby_bottom_sheet.dart';
import 'package:vybe/presentation/nearby/widgets/nearby_gnb.dart';

class NearbyScreen extends ConsumerStatefulWidget {
  const NearbyScreen({super.key});

  @override
  ConsumerState<NearbyScreen> createState() => _NearbyScreenState();
}

class _NearbyScreenState extends ConsumerState<NearbyScreen> {
  NaverMapController? _mapController;
  bool _showReSearch = false;
  bool _ignoreNextIdle = true;
  late final DraggableScrollableController _sheetController;
  double _stackHeight = 0;
  List<ClubModel> _pendingClubs = [];
  List<ClubModel>? _lastRenderedClubs;
  NLatLng? _myPos;

  // 마커 이미지 캐시 — 매번 fromWidget 재생성하면 플러그인 이미지 캐시
  // 정리(Directory.delete) 로그가 반복돼 캐시해 재사용.
  // 클럽 핀은 이름 라벨 포함이라 (clubId + 선택여부)별로 캐시.
  final Map<String, NOverlayImage> _clubPinCache = {};
  NOverlayImage? _myLocationIcon;

  // 클럽별 마커 핸들 + 마지막 렌더된 클럽 목록 (선택 토글용).
  final Map<String, NMarker> _clubMarkers = {};
  String? _selectedClubId;

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

  // 핀 탭 → 이전 선택 보라/현재 선택 녹색으로 아이콘 교체.
  Future<void> _onPinTap(ClubModel club) async {
    if (_selectedClubId == club.clubId) return;
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

    await _mapController!.clearOverlays();
    await _mapController!.addOverlayAll(markers);
    // clearOverlays가 내 위치 마커도 지우므로 재추가.
    if (_myPos != null) await _addMyLocationMarker(_myPos!);
  }

  @override
  Widget build(BuildContext context) {
    final myLocation = ref.watch(userLocationProvider);
    _myPos = NLatLng(myLocation.lat, myLocation.lng);

    final clubsAsync = ref.watch(nearbyViewModelProvider);
    clubsAsync.whenData((clubs) {
      if (!identical(clubs, _lastRenderedClubs)) {
        _lastRenderedClubs = clubs;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted) return;
          if (_mapController != null) {
            _addMarkers(clubs);
          } else {
            _pendingClubs = clubs;
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
      onCameraIdle: () {
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
    if (!_showReSearch) return const SizedBox.shrink();

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

