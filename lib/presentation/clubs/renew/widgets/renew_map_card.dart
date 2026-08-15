import 'package:flutter/material.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vybe/core/providers/location_providers.dart';
import 'package:vybe/core/utils/naver_overlay_image_queue.dart';
import 'package:vybe/data/models/club_model.dart';
import 'package:vybe/design_system/colors.dart';
import 'package:vybe/presentation/common/renew/renew_glass.dart';
import 'package:vybe/presentation/common/widgets/vybe_map_pin.dart';
import 'package:vybe/presentation/common/widgets/vybe_my_location_dot.dart';

/// 매장 정보 탭 위치 지도 (디자인 VRLocation 지도 카드 — 높이 180 · radius 19).
///
/// 디자인은 정적 일러스트지만 실제 앱은 네이버 지도를 그대로 띄운다.
class RenewMapCard extends ConsumerStatefulWidget {
  final ClubModel club;

  const RenewMapCard({super.key, required this.club});

  @override
  ConsumerState<RenewMapCard> createState() => _RenewMapCardState();
}

class _RenewMapCardState extends ConsumerState<RenewMapCard> {
  // 마커 이미지 캐시 — fromWidget 재생성 시 플러그인 캐시 정리 로그 방지.
  NOverlayImage? _myLocationIcon;
  NOverlayImage? _clubPinIcon;

  @override
  Widget build(BuildContext context) {
    final club = widget.club;
    // 앱 진입 시 설정된 내 위치 — 내 위치 마커 기준.
    final myLocation = ref.watch(userLocationProvider);
    // 좌표가 없는 클럽(0,0)은 핀을 찍을 수 없어 내 위치를 중심으로 둔다.
    final hasLocation = club.lat != 0 || club.lng != 0;
    final center = hasLocation
        ? NLatLng(club.lat, club.lng)
        : NLatLng(myLocation.lat, myLocation.lng);

    return Container(
      height: 180.h,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(19.r),
        border: Border.all(color: RenewGlass.tileBorder),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18.r),
        child: NaverMap(
          // 탭뷰(가로 스와이프) 안에서도 지도가 제스처를 독점하도록.
          forceGesture: true,
          options: NaverMapViewOptions(
            initialCameraPosition: NCameraPosition(target: center, zoom: 16),
            mapType: NMapType.basic,
            activeLayerGroups: const [
              NLayerGroup.building,
              NLayerGroup.transit,
            ],
            nightModeEnable: true,
            scrollGesturesEnable: true,
            zoomGesturesEnable: true,
            rotationGesturesEnable: false,
            tiltGesturesEnable: false,
          ),
          onMapReady: (controller) => _onMapReady(
            controller,
            center: center,
            hasLocation: hasLocation,
            myLocation: myLocation,
          ),
        ),
      ),
    );
  }

  Future<void> _onMapReady(
    NaverMapController controller, {
    required NLatLng center,
    required bool hasLocation,
    required UserLocation myLocation,
  }) async {
    if (!mounted) return;
    await controller.updateCamera(
      NCameraUpdate.withParams(target: center, zoom: 16),
    );
    if (!mounted) return;

    // 1) 클럽 핀 — 이 지도의 주인공. 보라 라벨 + 핀을 한 장의 마커 이미지로
    //    만들어 지도를 움직여도 좌표에 정확히 붙어 따라간다.
    if (hasLocation) {
      // 마커 이미지 생성은 반드시 직렬화 — 다른 지도(주변 탭)와 첫 생성이
      // 겹치면 플러그인이 temp 폴더를 서로 지워 네이티브 크래시가 난다.
      final pin = _clubPinIcon ??= await NaverOverlayImageQueue.run(
        () => NOverlayImage.fromWidget(
          widget: _PinWithLabel(label: widget.club.name),
          size: Size(240.r, 64.r),
          context: context,
        ),
      );
      if (!mounted) return;
      await controller.addOverlay(
        NMarker(
          id: 'club_marker',
          position: NLatLng(widget.club.lat, widget.club.lng),
          icon: pin,
          // 핀 바닥(캔버스 하단 중앙)이 좌표를 가리키도록
          anchor: const NPoint(0.5, 1.0),
        ),
      );
    }

    // 2) 내 위치 점. locationOverlay 기본 아이콘이 환경에 따라 안 보여
    //    커스텀 마커로 그린다.
    if (!mounted) return;
    final dot = _myLocationIcon ??= await NaverOverlayImageQueue.run(
      () => NOverlayImage.fromWidget(
        widget: const VybeMyLocationDot(),
        size: const Size(28, 28),
        context: context,
      ),
    );
    if (!mounted) return;
    await controller.addOverlay(
      NMarker(
        id: 'my_location_marker',
        position: NLatLng(myLocation.lat, myLocation.lng),
        icon: dot,
        anchor: const NPoint(0.5, 0.5),
      ),
    );
  }
}

/// 지도 마커용 보라 라벨 + 핀. fromWidget으로 이미지화하므로 하단 정렬.
class _PinWithLabel extends StatelessWidget {
  final String label;
  const _PinWithLabel({required this.label});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 240.r,
      height: 64.r,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Container(
            padding: EdgeInsets.symmetric(horizontal: 11.w, vertical: 5.h),
            decoration: BoxDecoration(
              color: VybeColors.mainPurple500,
              borderRadius: BorderRadius.circular(10.r),
              border: Border.all(
                color: VybeColors.mainLime500.withValues(alpha: 0.40),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.36),
                  blurRadius: 30.r,
                  offset: Offset(0, 10.h),
                ),
              ],
            ),
            child: Text(
              label,
              style: RenewGlass.caption(
                color: Colors.white,
                lineHeight: 14,
                weight: FontWeight.w600,
              ),
            ),
          ),
          SizedBox(height: 4.h),
          SizedBox(
            width: 24.r,
            height: 27.r,
            child: const CustomPaint(painter: VybeMapPinPainter()),
          ),
        ],
      ),
    );
  }
}
