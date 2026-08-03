/// 위치 관련 기본값.
///
/// GPS 좌표를 아직 못 받았거나 위치 권한이 없을 때 쓰는 폴백.
/// 홈·주변·입장비 무료·서비스 음료·힙합 화면이 모두 이 좌표에서 시작한다.
class AppGeo {
  const AppGeo._();

  /// 홍대 기준 좌표 — 앱 전체 최초 로딩/폴백 위치.
  static const hongdaeLat = 37.5572;
  static const hongdaeLng = 126.9239;

  /// 위 좌표에 대응하는 지역 라벨.
  static const hongdaeLabel = '홍대';
}
