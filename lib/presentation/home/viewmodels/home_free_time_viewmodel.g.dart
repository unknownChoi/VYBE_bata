// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'home_free_time_viewmodel.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// 시간대 무료입장 클럽 — 지금 무료 → 곧 시작 → 가까운 순.
///
/// 서버는 `freeEntry.type == 'timed'`까지만 좁히고(요일·시:분 쿼리는 불가),
/// "지금 무료인가"는 [toHomeFreeTimeClub] 안에서 `FreeEntryPolicy.statusAt`이 판정한다.
///
/// 시각이 바뀌어도 자동 갱신하지는 않는다 — 홈에 머무는 동안 카드가 저절로
/// 재정렬되면 스크롤 중 항목이 튀므로, 갱신은 화면 재진입(invalidate) 시점에 맡긴다.

@ProviderFor(homeFreeTimeClubs)
final homeFreeTimeClubsProvider = HomeFreeTimeClubsProvider._();

/// 시간대 무료입장 클럽 — 지금 무료 → 곧 시작 → 가까운 순.
///
/// 서버는 `freeEntry.type == 'timed'`까지만 좁히고(요일·시:분 쿼리는 불가),
/// "지금 무료인가"는 [toHomeFreeTimeClub] 안에서 `FreeEntryPolicy.statusAt`이 판정한다.
///
/// 시각이 바뀌어도 자동 갱신하지는 않는다 — 홈에 머무는 동안 카드가 저절로
/// 재정렬되면 스크롤 중 항목이 튀므로, 갱신은 화면 재진입(invalidate) 시점에 맡긴다.

final class HomeFreeTimeClubsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<HomeFreeTimeClub>>,
          List<HomeFreeTimeClub>,
          FutureOr<List<HomeFreeTimeClub>>
        >
    with
        $FutureModifier<List<HomeFreeTimeClub>>,
        $FutureProvider<List<HomeFreeTimeClub>> {
  /// 시간대 무료입장 클럽 — 지금 무료 → 곧 시작 → 가까운 순.
  ///
  /// 서버는 `freeEntry.type == 'timed'`까지만 좁히고(요일·시:분 쿼리는 불가),
  /// "지금 무료인가"는 [toHomeFreeTimeClub] 안에서 `FreeEntryPolicy.statusAt`이 판정한다.
  ///
  /// 시각이 바뀌어도 자동 갱신하지는 않는다 — 홈에 머무는 동안 카드가 저절로
  /// 재정렬되면 스크롤 중 항목이 튀므로, 갱신은 화면 재진입(invalidate) 시점에 맡긴다.
  HomeFreeTimeClubsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'homeFreeTimeClubsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$homeFreeTimeClubsHash();

  @$internal
  @override
  $FutureProviderElement<List<HomeFreeTimeClub>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<HomeFreeTimeClub>> create(Ref ref) {
    return homeFreeTimeClubs(ref);
  }
}

String _$homeFreeTimeClubsHash() => r'b42c95f172a81b00f89aae116de72d393da38036';
