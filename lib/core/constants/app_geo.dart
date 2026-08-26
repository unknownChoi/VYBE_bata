import 'package:vybe/core/constants/korea_regions.dart';
import 'package:vybe/core/utils/geohash_utils.dart';

/// 위치 관련 기본값 + 좌표 → 지역 이름 변환.
///
/// 실제 좌표는 기기 GPS(`DeviceLocationDataSource`)에서 받아
/// `userLocationProvider`가 들고 있고, 여기 상수는 **GPS를 못 받았을 때의 폴백**과
/// **지역 판정 기준표** 두 가지로만 쓴다.
class AppGeo {
  const AppGeo._();

  /// 홍대 기준 좌표 — 위치 권한 거부·GPS 실패 시 폴백, [useFixedLocation] 테스트 좌표.
  static const hongdaeLat = 37.5572;
  static const hongdaeLng = 126.9239;

  /// 위 좌표에 대응하는 지역 라벨.
  static const hongdaeLabel = '홍대';

  /// true면 기기 GPS를 아예 읽지 않고 항상 홍대 좌표로 고정한다.
  ///
  /// 예전(위치 연동 전) 동작 그대로 — 지역이 홍대로 고정된 상태를 다시 보고 싶을 때
  /// 이 값만 true로 바꾼다. 판정은 `UserLocationNotifier.resolveFromDevice()` 한 곳.
  static const useFixedLocation = true;

  /// 국내 어느 시군구에도 안 잡힐 때(해외 등) 위치 칩에 쓰는 라벨.
  ///
  /// 지금은 국내 밖이면 [overseasFallbackAreas] 로 대체하고 [outsideKoreaLabel] 을
  /// 쓰므로 화면에 뜰 일이 거의 없다 — 대체까지 실패했을 때의 최후 문구.
  static const unknownAreaLabel = '내 주변';

  /// 기기가 국내 밖일 때 위치 칩에 쓰는 문구.
  ///
  /// 좌표는 [overseasFallbackAreas] 중 하나로 대체하지만, 라벨까지 '강남'이라고
  /// 쓰면 해외에 있는 사용자에게 **거짓말**이 된다. 목록은 채우되 위치는 모른다고 밝힌다.
  static const outsideKoreaLabel = '위치 확인 불가';

  /// 국내 밖일 때 **좌표만** 빌려 쓸 상권. 앱 실행마다 이 중 하나를 랜덤으로 고른다.
  ///
  /// 해외 좌표를 그대로 두면 반경 3~30km 안에 클럽이 하나도 없어 홈 '주변 클럽'·
  /// 주변 탭이 통째로 빈 화면이 된다. 대표 상권으로 옮겨 화면을 채우되 라벨은
  /// [outsideKoreaLabel] 로 바꾼다.
  /// ⚠ 값은 전부 [hotspotCenters] 의 키여야 한다 (테스트가 지킨다).
  static const overseasFallbackAreas = <String>['홍대', '건대', '이태원', '강남'];

  /// 클럽 상권 중심 좌표 — 이 안에 있으면 행정구역명 대신 상권명을 보여준다.
  ///
  /// '마포구'보다 '홍대'가, '강남구'보다 '강남'이 이 앱에선 더 맞는 이름이다.
  /// ⚠ 키 문자열은 `clubs.area` 값과 **정확히 같아야** 한다 (지역 필터·거리표가
  /// 같은 문자열을 쓴다). 좌표는 `scripts/seed_hybrid_clubs.js`의 REGIONS와 동일.
  /// DB에 새 상권을 추가하면 여기도 같이 추가할 것.
  static const hotspotCenters = <String, ({double lat, double lng})>{
    '홍대': (lat: 37.5547, lng: 126.9230),
    '신촌': (lat: 37.5559, lng: 126.9368),
    '강남': (lat: 37.4979, lng: 127.0276),
    '압구정': (lat: 37.5271, lng: 127.0286),
    '이태원': (lat: 37.5345, lng: 126.9946),
    '건대': (lat: 37.5403, lng: 127.0698),
  };

  /// 상권 판정 반경. 좁게 잡는다 — 넓히면 상권 이름이 구 전체를 잡아먹는다
  /// (마포구 중심이 홍대에서 1.2km밖에 안 떨어져 있다).
  static const hotspotRadiusKm = 2.0;

  /// 시군구 판정 상한. 넘어가면 국내로 보지 않고 null(= '내 주변')을 준다.
  ///
  /// 면적이 큰 군(홍천·안동)의 경계까지 덮되, 해외에서 한국 지역명이 뜨지 않을
  /// 만큼만 잡은 값.
  static const regionRadiusKm = 60.0;

  /// [lat]·[lng]가 속한 지역 이름. 국내가 아니면 null.
  ///
  /// 상권([hotspotCenters]) → 시군구([koreaRegions]) 순으로 본다.
  /// 상권을 먼저 보는 이유는 위 [hotspotCenters] 주석 참고.
  static String? areaOf(double lat, double lng) {
    final hotspot = _nearest(
      lat,
      lng,
      hotspotCenters.entries.map(
        (e) => (label: e.key, lat: e.value.lat, lng: e.value.lng),
      ),
      hotspotRadiusKm,
    );
    if (hotspot != null) return hotspot;

    return _nearest(
      lat,
      lng,
      koreaRegions.map((r) => (label: r.label, lat: r.lat, lng: r.lng)),
      regionRadiusKm,
    );
  }

  /// [candidates] 중 가장 가까운 항목의 라벨. [maxKm] 밖이면 null.
  ///
  /// 반경이 아니라 최근접이 먼저 — 홍대·신촌처럼 서로의 반경 안에 들어오는
  /// 지역은 거리로만 갈린다.
  static String? _nearest(
    double lat,
    double lng,
    Iterable<({String label, double lat, double lng})> candidates,
    double maxKm,
  ) {
    String? nearest;
    var nearestKm = double.infinity;
    for (final c in candidates) {
      final km = GeohashUtils.haversineKm(lat, lng, c.lat, c.lng);
      if (km < nearestKm) {
        nearestKm = km;
        nearest = c.label;
      }
    }
    return nearestKm <= maxKm ? nearest : null;
  }
}
