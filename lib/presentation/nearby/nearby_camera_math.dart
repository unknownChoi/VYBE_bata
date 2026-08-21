import 'package:flutter/widgets.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';
import 'package:vybe/core/utils/geohash_utils.dart';
import 'package:vybe/data/models/club_model.dart';

/// 주변 탭 지도의 카메라 기하 계산 — 화면·지도 SDK 상태와 무관한 순수 함수만 둔다.
///
/// 화면(`nearby_screen.dart`)에 두면 지도 컨트롤러가 붙어 있어야만 검증할 수 있어
/// 어긋난 pivot·padding을 눈으로만 잡아야 했다. 여기로 빼서 값만으로 테스트한다
/// (`test/nearby_camera_math_test.dart`).
///
/// 좌표계 약속 — pivot Y는 **화면 높이 대비 비율**(0~1). 0.5가 한가운데고,
/// 값이 작을수록 대상이 화면 위쪽에 놓인다(아래는 시트·카드가 덮는다).
class NearbyCameraMath {
  const NearbyCameraMath._();

  /// pivot이 화면 밖으로 나가지 않게 잡아 두는 범위.
  /// 위쪽 0.15보다 올리면 핀 라벨이 GNB에 물리고, 0.5보다 내리면 핀 카드에 가린다.
  static const double minPivotY = 0.15;
  static const double maxPivotY = 0.5;

  /// 높이를 아직 못 잰 첫 프레임에서 쓸 값.
  static const double fallbackPinPivotY = 0.3;
  static const double fallbackSearchPivotY = 0.5;

  /// 핀 카드가 떠 있을 때 '보이는 지도 밴드'의 세로 중심 비율.
  ///
  /// [topInset]은 상단 GNB 스크림 높이, [cardTop]은 핀 카드 상단 y좌표.
  /// 카드가 스크림까지 올라와 밴드가 사라지면 계산이 뒤집히므로 폴백을 준다.
  static double pinCardPivotY({
    required double stackHeight,
    required double topInset,
    required double cardTop,
  }) {
    if (stackHeight <= 0) return fallbackPinPivotY;
    if (cardTop <= topInset) return fallbackPinPivotY;
    return (((topInset + cardTop) / 2) / stackHeight).clamp(
      minPivotY,
      maxPivotY,
    );
  }

  /// 검색 결과 fitBounds용 카메라 여백.
  ///
  /// 핀이 상단 GNB·하단 시트에 가리지 않게 그만큼 잘라낸다. 다만 화면이 짧으면
  /// 여백만으로 지도 밴드가 0이 되어 fit이 깨지므로 [minBand]는 반드시 남긴다.
  static EdgeInsets searchCameraPadding({
    required double stackHeight,
    required double topInset,
    required double sheetMid,
    required double minBand,
    required double sidePad,
    required double gap,
  }) {
    var bottom = stackHeight > 0 ? stackHeight * sheetMid + gap : gap;
    if (stackHeight > 0 && stackHeight - topInset - bottom < minBand) {
      bottom = (stackHeight - topInset - minBand).clamp(0.0, bottom);
    }
    return EdgeInsets.only(
      left: sidePad,
      right: sidePad,
      top: topInset,
      bottom: bottom,
    );
  }

  /// [searchCameraPadding]으로 잘라낸 뒤 남은 밴드의 세로 중심 비율.
  /// 핀이 1개라 fitBounds를 못 쓸 때 pivot으로 같은 자리에 놓기 위한 값.
  static double searchPivotY({
    required double stackHeight,
    required EdgeInsets padding,
  }) {
    if (stackHeight <= 0) return fallbackSearchPivotY;
    final visibleBottom = stackHeight - padding.bottom;
    if (visibleBottom <= padding.top) return fallbackSearchPivotY;
    final centerY = (padding.top + visibleBottom) / 2;
    return (centerY / stackHeight).clamp(minPivotY, maxPivotY);
  }

  /// 클럽들을 모두 감싸는 bounds. 2개 미만이면 null (fitBounds가 성립 안 함).
  static NLatLngBounds? boundsOf(List<ClubModel> clubs) {
    if (clubs.length < 2) return null;
    final lats = clubs.map((c) => c.lat);
    final lngs = clubs.map((c) => c.lng);
    return NLatLngBounds(
      southWest: NLatLng(
        lats.reduce((a, b) => a < b ? a : b),
        lngs.reduce((a, b) => a < b ? a : b),
      ),
      northEast: NLatLng(
        lats.reduce((a, b) => a > b ? a : b),
        lngs.reduce((a, b) => a > b ? a : b),
      ),
    );
  }

  /// 지역 클러스터 중심 = 그룹 좌표 평균.
  static NLatLng centerOf(List<ClubModel> group) {
    final lat = group.map((c) => c.lat).reduce((a, b) => a + b) / group.length;
    final lng = group.map((c) => c.lng).reduce((a, b) => a + b) / group.length;
    return NLatLng(lat, lng);
  }

  /// '현재 지역에서 재검색'이 쓸 중심·반경.
  /// 반경은 중심→북동 모서리 거리에 [buffer]만큼 여유를 둔다 —
  /// 화면 경계에 걸친 클럽이 빠지지 않도록.
  static ({double lat, double lng, double radiusKm}) viewportQuery(
    NLatLngBounds bounds, {
    double buffer = 1.2,
  }) {
    final lat = (bounds.southWest.latitude + bounds.northEast.latitude) / 2;
    final lng = (bounds.southWest.longitude + bounds.northEast.longitude) / 2;
    final radiusKm = GeohashUtils.haversineKm(
      lat,
      lng,
      bounds.northEast.latitude,
      bounds.northEast.longitude,
    );
    return (lat: lat, lng: lng, radiusKm: radiusKm * buffer);
  }

  /// 좌표가 없는 클럽(0,0)은 거리 표기를 생략한다.
  static double? distanceMeters(ClubModel club, double lat, double lng) {
    if (club.lat == 0 && club.lng == 0) return null;
    return GeohashUtils.haversineKm(lat, lng, club.lat, club.lng) * 1000;
  }
}
