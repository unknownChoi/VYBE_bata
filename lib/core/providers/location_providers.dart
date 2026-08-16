import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:vybe/core/constants/app_geo.dart';
import 'package:vybe/data/datasources/local/device_location_datasource.dart';

part 'location_providers.g.dart';

/// 내 위치 좌표 + 그 좌표가 속한 지역.
class UserLocation {
  final double lat;
  final double lng;

  /// 좌표에서 찾은 지역 라벨(예: '강남'). 등록된 지역 밖이면 null.
  ///
  /// [outsideKorea] 일 때는 기기 좌표가 아니라 **대체한 상권**의 이름이 들어간다
  /// ([lat]·[lng] 와 항상 짝이 맞게). 화면 문구는 [areaLabel] 로만 읽을 것.
  final String? area;

  /// 기기 GPS로 받은 좌표인지. false면 폴백·대체 좌표.
  final bool fromDevice;

  /// 기기가 국내 밖이라 좌표를 상권으로 대체했는지.
  ///
  /// true면 [lat]·[lng]·[area] 는 실제 내 위치가 아니다 — 화면엔 '위치 확인 불가'.
  final bool outsideKorea;

  const UserLocation({
    required this.lat,
    required this.lng,
    this.area,
    this.fromDevice = false,
    this.outsideKorea = false,
  });

  /// 위치 칩에 표시할 라벨.
  ///
  /// 국내 밖이면 대체한 상권명이 아니라 '위치 확인 불가' — 좌표를 빌려 왔다는 걸
  /// 숨기고 '강남'이라고 쓰면 해외 사용자에게 거짓 정보가 된다.
  String get areaLabel => outsideKorea
      ? AppGeo.outsideKoreaLabel
      : (area ?? AppGeo.unknownAreaLabel);
}

/// 전역 내 위치 상태.
///
/// 앱 첫 로딩(`SplashGate`)에서 [UserLocationNotifier.resolveFromDevice]를 한 번
/// 돌려 기기 GPS 좌표로 갱신하고, 홈 위치 칩·주변 페이지·주변 클럽 섹션이 전부
/// 이 좌표 하나를 본다.
///
/// **keepAlive인 이유** — 스플래시에서 좌표를 받을 때는 이 provider를 보는 화면이
/// 아직 없다. autoDispose면 받자마자 버려져 홈이 폴백 좌표로 다시 시작한다.
@Riverpod(keepAlive: true)
class UserLocationNotifier extends _$UserLocationNotifier {
  /// GPS 전·실패 시 좌표. 지역까지 홍대로 둔다 — 좌표가 홍대인데 라벨만 '내 주변'이면
  /// 칩과 목록(홍대 클럽)이 어긋나 보인다.
  static const _fallback = UserLocation(
    lat: AppGeo.hongdaeLat,
    lng: AppGeo.hongdaeLng,
    area: AppGeo.hongdaeLabel,
  );

  @override
  UserLocation build() => _fallback;

  /// 기기 GPS로 내 위치를 갱신한다. 갱신되면 true.
  ///
  /// 앱 첫 로딩과 위치 칩 탭에서 호출. 실패하면 **상태를 건드리지 않는다** —
  /// 이미 받아 둔 좌표가 있으면 그대로 두고, 없으면 폴백으로 계속 간다.
  Future<bool> resolveFromDevice() async {
    // 지역 고정 테스트 모드 — GPS를 아예 읽지 않는다(권한 팝업도 안 뜸).
    if (AppGeo.useFixedLocation) {
      state = _fallback;
      return false;
    }

    final position = await ref
        .read(deviceLocationDataSourceProvider)
        .getCurrentPosition();
    if (position == null || !ref.mounted) return false;

    setLocation(position.lat, position.lng, fromDevice: true);
    return true;
  }

  /// 좌표 직접 지정. 지역 라벨은 좌표에서 다시 계산한다.
  ///
  /// 국내 어느 지역에도 안 잡히면(해외 등) [_applyOverseasFallback] 로 넘긴다.
  void setLocation(double lat, double lng, {bool fromDevice = false}) {
    final area = AppGeo.areaOf(lat, lng);
    if (area == null) {
      _applyOverseasFallback(lat, lng);
      return;
    }

    debugPrint('[UserLocation] ($lat, $lng) → $area');
    state = UserLocation(
      lat: lat,
      lng: lng,
      area: area,
      fromDevice: fromDevice,
    );
  }

  /// 앱 실행 중 한 번 뽑아 두는 대체 상권.
  ///
  /// **매번 새로 뽑지 않는 이유** — 위치 칩을 누를 때마다 홍대→강남→건대로 좌표가
  /// 튀면 주변 클럽 목록이 통째로 바뀌어 앱이 고장난 것처럼 보인다.
  String? _overseasArea;

  static final _random = Random();

  /// 국내 밖일 때 — 좌표는 상권 4곳 중 랜덤 1곳, 라벨은 '위치 확인 불가'.
  ///
  /// 해외 좌표를 그대로 두면 반경 안에 클럽이 0곳이라 홈·주변 탭이 빈 화면이 된다.
  void _applyOverseasFallback(double deviceLat, double deviceLng) {
    final area = _overseasArea ??=
        AppGeo.overseasFallbackAreas[_random.nextInt(
          AppGeo.overseasFallbackAreas.length,
        )];
    final center = AppGeo.hotspotCenters[area];

    // 후보에 hotspotCenters에 없는 이름이 섞였을 때(오타 등) — 홍대 폴백으로 버틴다.
    if (center == null) {
      debugPrint('[UserLocation] 대체 상권 좌표 없음($area) → 폴백 좌표');
      state = _fallback;
      return;
    }

    debugPrint(
      '[UserLocation] ($deviceLat, $deviceLng) 국내 밖 → $area 좌표로 대체 '
      '(라벨: ${AppGeo.outsideKoreaLabel})',
    );
    state = UserLocation(
      lat: center.lat,
      lng: center.lng,
      area: area,
      outsideKorea: true,
    );
  }
}
