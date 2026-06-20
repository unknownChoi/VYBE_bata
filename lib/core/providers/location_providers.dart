import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'location_providers.g.dart';

/// 앱 시작 시 설정되는 내 위치(기본값: 합정 인근).
/// 추후 실제 GPS 연동 시 [UserLocationNotifier.setLocation]으로 갱신한다.
class UserLocation {
  final double lat;
  final double lng;
  const UserLocation({required this.lat, required this.lng});
}

/// 전역 내 위치 상태. 앱 진입 시 기본 좌표로 초기화된다.
@riverpod
class UserLocationNotifier extends _$UserLocationNotifier {
  @override
  UserLocation build() => const UserLocation(
        lat: 37.55069527696864,
        lng: 126.92330205669276,
      );

  void setLocation(double lat, double lng) {
    state = UserLocation(lat: lat, lng: lng);
  }
}
