import 'package:flutter/material.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';

/// 주변 탭 네이버 지도 본체.
///
/// 지도 조작(마커·카메라)은 전부 `NearbyMapPresenter` 가 하고, 이 위젯은
/// 지도 옵션과 콜백 배선만 맡는다.
class NearbyMapView extends StatelessWidget {
  /// 초기 카메라 중심 (내 위치).
  final NLatLng initialCenter;

  final ValueChanged<NaverMapController> onMapReady;
  final VoidCallback onCameraIdle;

  /// 사용자가 손으로 지도를 움직였을 때만 호출된다 (프로그램 이동 제외).
  final VoidCallback onUserPan;

  const NearbyMapView({
    super.key,
    required this.initialCenter,
    required this.onMapReady,
    required this.onCameraIdle,
    required this.onUserPan,
  });

  @override
  Widget build(BuildContext context) {
    return NaverMap(
      // 지도가 제스처를 선점(EagerGestureRecognizer)해 부모 PageView 가로
      // 스와이프에 팬이 가로채이지 않도록. 시트 영역은 지도 밖이라 영향 없음.
      forceGesture: true,
      options: NaverMapViewOptions(
        // 초기 위치 = 내 위치 (화면 가운데).
        initialCameraPosition: NCameraPosition(target: initialCenter, zoom: 16),
        mapType: NMapType.basic,
        activeLayerGroups: const [NLayerGroup.building, NLayerGroup.transit],
        nightModeEnable: true,
      ),
      onMapReady: onMapReady,
      onCameraChange: (reason, animated) {
        if (reason == NCameraUpdateReason.gesture) onUserPan();
      },
      onCameraIdle: onCameraIdle,
    );
  }
}
