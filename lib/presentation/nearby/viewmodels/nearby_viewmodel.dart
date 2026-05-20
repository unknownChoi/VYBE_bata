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
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref
          .read(clubRepositoryProvider)
          .getClubsNearby(lat, lng, radiusKm),
    );
  }
}
