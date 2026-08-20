import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:vybe/core/providers/location_providers.dart';
import 'package:vybe/data/repositories/club_repository_impl.dart';
import 'package:vybe/presentation/home/home_models.dart';

part 'home_free_time_viewmodel.g.dart';

/// 홈 '이 시간에만 무료입장' 섹션에 보여줄 카드 수.
const _kMaxCards = 10;

/// 시간대 무료입장 클럽 — 지금 무료 → 곧 시작 → 가까운 순.
///
/// 서버는 `freeEntry.type == 'timed'`까지만 좁히고(요일·시:분 쿼리는 불가),
/// "지금 무료인가"는 [toHomeFreeTimeClub] 안에서 `FreeEntryPolicy.statusAt`이 판정한다.
///
/// 시각이 바뀌어도 자동 갱신하지는 않는다 — 홈에 머무는 동안 카드가 저절로
/// 재정렬되면 스크롤 중 항목이 튀므로, 갱신은 화면 재진입(invalidate) 시점에 맡긴다.
@riverpod
Future<List<HomeFreeTimeClub>> homeFreeTimeClubs(Ref ref) async {
  final me = ref.watch(userLocationProvider);
  final clubs = await ref.read(clubRepositoryProvider).getTimedFreeEntryClubs();

  // 목록 전체가 같은 기준 시각을 쓴다 — 카드마다 now를 읽으면 정렬과 표기가 어긋난다.
  final now = DateTime.now();
  final cards =
      clubs
          .map(
            (c) => toHomeFreeTimeClub(
              c,
              now: now,
              myLat: me.lat,
              myLng: me.lng,
            ),
          )
          .whereType<HomeFreeTimeClub>()
          .toList()
        ..sort(compareHomeFreeTime);

  return cards.take(_kMaxCards).toList();
}
