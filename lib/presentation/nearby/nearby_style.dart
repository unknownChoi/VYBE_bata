import 'package:flutter_naver_map/flutter_naver_map.dart';

/// 주변 탭 화면 상수. 화면·프레젠터·위젯이 같은 값을 봐야 해서 한곳에 모은다.

/// 이 줌 이하로 축소되면 개별 핀 대신 지역(area)별 클러스터 동그라미 표시.
const double kNearbyRegionZoomThreshold = 13.0;

/// 핀 탭 시 확대할 줌. 이미 이보다 더 확대돼 있으면 줄이지 않는다.
const double kNearbyPinFocusZoom = 17.0;

/// 지역 클러스터 탭 시 줌.
const double kNearbyRegionFocusZoom = 15.0;

/// 리스트 시트 스냅 위치 (디자인 nearby_glass.jsx SNAPS).
/// 최소 높이에서도 핸들·제목·필터 칩 줄까지 보이도록 0.3에서 시작한다.
const double kNearbySheetMin = 0.3;
const double kNearbySheetMid = 0.56;
const double kNearbySheetMax = 0.88;

/// 상단 GNB + 필터 칩 줄 + 핀 라벨이 차지하는 높이 (카메라 여백용, 설계 단위).
const double kNearbyMapTopInset = 170;

/// 여백을 다 빼고도 남겨야 하는 최소 지도 높이 (설계 단위).
/// 화면이 짧을 때 여백만으로 지도 밴드가 사라져 fit이 깨지는 걸 막는다.
const double kNearbyMinMapBand = 120;

/// 핀 카드 대략 높이 — 카메라 pivot 계산용(내용에 따라 달라져 근사치로 쓴다).
const double kNearbyPinCardApproxHeight = 380;

/// 주변 탭 인덱스 (MainScaffold PageView 기준).
const int kNearbyTabIndex = 1;

/// 대한민국 전체가 보이는 bounds (fitCountry 카메라용, 제주 포함).
const NLatLngBounds kKoreaBounds = NLatLngBounds(
  southWest: NLatLng(33.0, 124.6),
  northEast: NLatLng(38.7, 131.0),
);
