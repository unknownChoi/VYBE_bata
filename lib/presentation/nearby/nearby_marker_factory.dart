import 'package:flutter/widgets.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vybe/core/utils/naver_overlay_image_queue.dart';
import 'package:vybe/data/models/club_model.dart';
import 'package:vybe/presentation/common/widgets/vybe_my_location_dot.dart';
import 'package:vybe/presentation/nearby/widgets/nearby_map_markers.dart';

/// 지도 마커 이미지를 만들고 캐시하는 곳. 화면은 [iconFor]만 부르면 된다.
///
/// **왜 별도 클래스인가** — 이미지 생성에는 화면 로직과 무관한 제약이 둘 붙는다.
/// ① 동시 생성 금지(플러그인이 서로의 temp 폴더를 지워 네이티브 크래시)
/// ② 앱 복귀 시 캐시 폐기(iOS가 temp PNG를 purge해 죽은 경로가 남는다).
/// 화면에 섞여 있으면 이 둘이 build/lifecycle 코드 사이에 흩어진다.
class NearbyMarkerFactory {
  /// `NOverlayImage.fromWidget`이 요구하는 렌더 컨텍스트.
  /// 화면 밖(offscreen) 컨텍스트로 부르면 네이티브가 죽으므로,
  /// **탭이 보일 때만** 호출하는 책임은 호출측에 있다.
  final BuildContext Function() contextOf;

  NearbyMarkerFactory({required this.contextOf});

  /// 클럽 핀 캐시. 키에 평점·영업여부까지 넣는다 — 영업 상태는 시간이 지나면
  /// 뒤집히므로 clubId만으로 캐시하면 라벨이 옛 상태로 굳는다.
  final Map<String, NOverlayImage> _clubPins = {};

  /// 지역 클러스터 동그라미 캐시. 키: `area|count`.
  final Map<String, NOverlayImage> _regionPins = {};

  NOverlayImage? _myLocation;

  /// 이름 라벨 + 핀 (선택 시 라임 + 별점·영업여부 확장).
  Future<NOverlayImage> iconFor(ClubModel club, {required bool selected}) {
    final isOpen = club.operatingHours.today.isCurrentlyOpen;
    final key = '${club.clubId}|$selected|${club.rating}|$isOpen';
    return _cached(_clubPins, key, () {
      return NOverlayImage.fromWidget(
        widget: NearbyPin(
          label: club.name,
          selected: selected,
          rating: club.rating,
          reviewCount: club.reviewCount,
          isOpen: isOpen,
        ),
        size: Size(NearbyPin.canvasWidth.r, NearbyPin.canvasHeight.r),
        context: contextOf(),
      );
    });
  }

  /// area별 클러스터 동그라미 (지역명 + 클럽 수).
  Future<NOverlayImage> regionIcon(String area, int count) {
    return _cached(_regionPins, '$area|$count', () {
      return NOverlayImage.fromWidget(
        widget: NearbyRegionCluster(area: area, count: count),
        size: Size(88.r, 88.r),
        context: contextOf(),
      );
    });
  }

  /// 내 위치 파란 점.
  Future<NOverlayImage> myLocationIcon() async {
    return _myLocation ??= await NaverOverlayImageQueue.run<NOverlayImage>(
      () => NOverlayImage.fromWidget(
        widget: const VybeMyLocationDot(),
        size: const Size(28, 28),
        context: contextOf(),
      ),
    );
  }

  /// 캐시된 이미지를 전부 버린다.
  ///
  /// 앱이 백그라운드→포그라운드로 돌아오면 iOS가 temp 디렉토리(마커 PNG)를
  /// purge했을 수 있다. 캐시된 [NOverlayImage]는 사라진 파일 경로를 들고 있어
  /// 재사용하면 네이티브가 죽는다(`NOverlayImage.swift` force-unwrap).
  void invalidate() {
    _clubPins.clear();
    _regionPins.clear();
    _myLocation = null;
  }

  /// 캐시 조회 → 없으면 **직렬 큐**로 생성. 동시 생성 시 플러그인이 temp 폴더를
  /// 서로 지워 네이티브 크래시가 난다 (`NaverOverlayImageQueue` 주석 참고).
  Future<NOverlayImage> _cached(
    Map<String, NOverlayImage> cache,
    String key,
    Future<NOverlayImage> Function() build,
  ) async {
    final hit = cache[key];
    if (hit != null) return hit;
    final img = await NaverOverlayImageQueue.run(build);
    cache[key] = img;
    return img;
  }

  /// 핀 겹침 순서 (디자인 zIndex: 선택 7 > VYBE 추천 5 > 기본 2).
  /// 선택된 핀의 이름 라벨이 옆 핀에 가리지 않도록 위로 올린다.
  static int zIndexFor(ClubModel club, {required bool selected}) {
    if (selected) return 7;
    return club.isVybeRecommended ? 5 : 2;
  }

  /// 내 위치 마커는 클럽 핀보다 항상 위 (기본 zIndex = 0).
  static const int myLocationZIndex = 1000000;

  /// 내 위치 마커 id — clearOverlays 후 재추가 판단에 쓴다.
  static const String myLocationMarkerId = 'my_location_marker';
}
