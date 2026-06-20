import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:vybe/data/models/club_model.dart';
import 'package:vybe/data/repositories/club_repository_impl.dart';

part 'nearby_viewmodel.g.dart';

const _kInitialLat = 37.5572;
const _kInitialLng = 126.9239;
const _kInitialRadius = 2.0;

@riverpod
class NearbyViewModel extends _$NearbyViewModel {
  @override
  Future<List<ClubModel>> build() {
    return ref
        .read(clubRepositoryProvider)
        .getClubsNearby(_kInitialLat, _kInitialLng, _kInitialRadius);
  }

  Future<void> searchNearby(double lat, double lng, double radiusKm) async {
    ref.read(nearbyCenterProvider.notifier).set(lat, lng);
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref
          .read(clubRepositoryProvider)
          .getClubsNearby(lat, lng, radiusKm),
    );
  }
}

/// 마지막 조회 중심 좌표. 거리순 정렬의 기준점.
@riverpod
class NearbyCenter extends _$NearbyCenter {
  @override
  ({double lat, double lng}) build() =>
      (lat: _kInitialLat, lng: _kInitialLng);

  void set(double lat, double lng) => state = (lat: lat, lng: lng);
}

/// 지역 클러스터에서 선택한 area. null이면 전체. 바텀시트 리스트 필터용.
@riverpod
class SelectedArea extends _$SelectedArea {
  @override
  String? build() => null;

  void select(String? area) => state = area;
}
