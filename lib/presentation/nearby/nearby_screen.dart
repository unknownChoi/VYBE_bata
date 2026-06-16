import 'package:flutter/material.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
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

  static const _initialCamera = NCameraPosition(
    target: NLatLng(37.5572, 126.9239),
    zoom: 14,
  );

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

    final overlayImage = await NOverlayImage.fromWidget(
      widget: SizedBox(
        width: 24.r,
        height: 27.r,
        child: const CustomPaint(painter: VybeMapPinPainter()),
      ),
      size: Size(24.r, 27.r),
      context: context,
    );

    final markers = clubs
        .map((c) => NMarker(
              id: c.clubId,
              position: NLatLng(c.lat, c.lng),
              icon: overlayImage,
            ))
        .toSet();

    await _mapController!.clearOverlays();
    await _mapController!.addOverlayAll(markers);
  }

  @override
  Widget build(BuildContext context) {
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
              _buildReSearchButton(),
              _buildBottomSheet(),
            ],
          );
        },
      ),
    );
  }

  Widget _buildMap() {
    return NaverMap(
      options: const NaverMapViewOptions(
        initialCameraPosition: _initialCamera,
        mapType: NMapType.basic,
        activeLayerGroups: [NLayerGroup.building, NLayerGroup.transit],
        nightModeEnable: true,
      ),
      onMapReady: (controller) async {
        _mapController = controller;
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
        onBackTap: () => Navigator.of(context).maybePop(),
        onSearchTap: () {
          // TODO: 검색 화면 이동
        },
      ),
    );
  }

  Widget _buildReSearchButton() {
    if (!_showReSearch) return const SizedBox.shrink();

    final sheetSize = _sheetController.isAttached ? _sheetController.size : 0.5;
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
      initialChildSize: 0.5,
      minChildSize: 0.15,
      maxChildSize: 0.85,
      snap: true,
      snapSizes: const [0.15, 0.5, 0.85],
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

