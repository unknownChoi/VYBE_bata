import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'device_location_datasource.g.dart';

/// 기기 GPS 좌표 조회. **위치 플러그인(geolocator) 코드는 여기에만 둔다.**
///
/// 위치 서비스 꺼짐 · 권한 거부 · 타임아웃 · 기기 오류를 전부 여기서 흡수하고
/// 실패는 예외 대신 `null`로 돌린다 — 위치를 못 받아도 앱은 폴백 좌표
/// (`AppGeo.hongdaeLat`)로 그대로 돌아가야 한다.
class DeviceLocationDataSource {
  const DeviceLocationDataSource();

  /// GPS 고정(fix)을 기다리는 한계. 넘기면 마지막으로 알던 좌표로 넘어간다.
  ///
  /// 앱 첫 로딩(스플래시 2.6초)에 호출하므로 길게 잡을수록 첫 화면이 폴백 좌표로
  /// 그려질 확률이 올라간다.
  static const _timeout = Duration(seconds: 5);

  /// 현재 좌표. 권한이 없거나 못 받으면 null.
  ///
  /// 권한이 `denied`면 여기서 시스템 권한 팝업을 띄운다(앱 첫 로딩 1회).
  /// `deniedForever`는 다시 묻지 않는다 — 설정 앱으로 보내는 건 상위 화면 몫.
  Future<({double lat, double lng})?> getCurrentPosition() async {
    try {
      if (!await Geolocator.isLocationServiceEnabled()) {
        debugPrint('[DeviceLocation] 기기 위치 서비스 꺼짐 → 폴백 좌표 사용');
        return null;
      }

      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        debugPrint('[DeviceLocation] 위치 권한 없음($permission) → 폴백 좌표 사용');
        return null;
      }

      // 정확도는 medium — 지역(홍대/강남) 판정과 반경 2km 클럽 조회엔 충분하고,
      // best는 실내에서 fix를 못 잡아 타임아웃까지 끄는 경우가 많다.
      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.medium,
          timeLimit: _timeout,
        ),
      );
      return (lat: position.latitude, lng: position.longitude);
    } catch (e) {
      // 타임아웃·기기 오류 — 마지막으로 알던 좌표라도 쓴다(없으면 폴백).
      debugPrint('[DeviceLocation] 현재 위치 실패: $e');
      return _lastKnown();
    }
  }

  Future<({double lat, double lng})?> _lastKnown() async {
    try {
      final last = await Geolocator.getLastKnownPosition();
      if (last == null) return null;
      debugPrint('[DeviceLocation] 마지막으로 알던 좌표 사용');
      return (lat: last.latitude, lng: last.longitude);
    } catch (e) {
      debugPrint('[DeviceLocation] 마지막 좌표 조회 실패: $e');
      return null;
    }
  }
}

@riverpod
DeviceLocationDataSource deviceLocationDataSource(Ref ref) =>
    const DeviceLocationDataSource();
