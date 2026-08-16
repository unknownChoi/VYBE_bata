import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:vybe/core/providers/location_providers.dart';
import 'package:vybe/data/models/club_model.dart';
import 'package:vybe/data/repositories/club_repository_impl.dart';

part 'nearby_viewmodel.g.dart';

const _kInitialRadius = 2.0;

@riverpod
class NearbyViewModel extends _$NearbyViewModel {
  /// 최초 조회 중심 = 내 위치.
  ///
  /// `userLocationProvider`를 watch 하므로 스플래시에서 GPS가 늦게 들어와도
  /// 그 좌표로 자동 재조회된다. (홍대 고정으로 되돌리려면 `AppGeo.useFixedLocation`)
  @override
  Future<List<ClubModel>> build() {
    final me = ref.watch(userLocationProvider);
    return ref
        .read(clubRepositoryProvider)
        .getClubsNearby(me.lat, me.lng, _kInitialRadius);
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

/// 마지막 조회 중심 좌표. 거리순 정렬의 기준점. 시작값은 내 위치.
@riverpod
class NearbyCenter extends _$NearbyCenter {
  @override
  ({double lat, double lng}) build() {
    final me = ref.watch(userLocationProvider);
    return (lat: me.lat, lng: me.lng);
  }

  void set(double lat, double lng) => state = (lat: lat, lng: lng);
}

/// 지역 클러스터에서 선택한 area. null이면 전체. 바텀시트 리스트 필터용.
@riverpod
class SelectedArea extends _$SelectedArea {
  @override
  String? build() => null;

  void select(String? area) => state = area;
}
