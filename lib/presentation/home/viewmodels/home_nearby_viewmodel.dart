import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:vybe/core/constants/app_geo.dart';
import 'package:vybe/core/providers/location_providers.dart';
import 'package:vybe/core/utils/geohash_utils.dart';
import 'package:vybe/data/models/club_model.dart';
import 'package:vybe/data/repositories/club_repository_impl.dart';

part 'home_nearby_viewmodel.g.dart';

/// 홈 '주변 클럽' 섹션에 보여줄 개수.
const _kMaxCards = 5;

/// 조회 반경(km) — 앞에서부터 넓혀 간다.
///
/// 첫 반경에서 한 곳도 안 잡히는 지역(도심 밖)이 있어 단계적으로 넓힌다.
/// 지역 하나가 대략 2km 안쪽이라 3km면 '내 동네', 10·30km는 그 밖 사용자용.
const _kRadiiKm = [3.0, 10.0, 30.0];

/// 내 위치에서 가까운 클럽 [_kMaxCards]곳 (가까운 순).
@riverpod
Future<List<ClubModel>> homeNearbyClubs(Ref ref) async {
  final me = ref.watch(userLocationProvider);
  final repo = ref.read(clubRepositoryProvider);

  for (final radiusKm in _kRadiiKm) {
    final found = await repo.getClubsNearby(me.lat, me.lng, radiusKm);
    if (found.isEmpty) continue;

    // 거리 계산은 정렬 전에 한 번씩만 (비교자 안에서 재계산하면 n log n번 돈다).
    final byDistance =
        found
            .map(
              (c) => (
                club: c,
                km: GeohashUtils.haversineKm(me.lat, me.lng, c.lat, c.lng),
              ),
            )
            .toList()
          ..sort((a, b) => a.km.compareTo(b.km));
    return byDistance.take(_kMaxCards).map((e) => e.club).toList();
  }

  // 반경 안에 클럽이 하나도 없는 지역(서울 밖) — 섹션을 비우는 대신 홍대로 폴백.
  final fallback = await repo.getClubsByArea(AppGeo.hongdaeLabel);
  return fallback.take(_kMaxCards).toList();
}
