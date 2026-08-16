// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'home_nearby_viewmodel.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// 내 위치에서 가까운 클럽 [_kMaxCards]곳 (가까운 순).

@ProviderFor(homeNearbyClubs)
final homeNearbyClubsProvider = HomeNearbyClubsProvider._();

/// 내 위치에서 가까운 클럽 [_kMaxCards]곳 (가까운 순).

final class HomeNearbyClubsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<ClubModel>>,
          List<ClubModel>,
          FutureOr<List<ClubModel>>
        >
    with $FutureModifier<List<ClubModel>>, $FutureProvider<List<ClubModel>> {
  /// 내 위치에서 가까운 클럽 [_kMaxCards]곳 (가까운 순).
  HomeNearbyClubsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'homeNearbyClubsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$homeNearbyClubsHash();

  @$internal
  @override
  $FutureProviderElement<List<ClubModel>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<ClubModel>> create(Ref ref) {
    return homeNearbyClubs(ref);
  }
}

String _$homeNearbyClubsHash() => r'effb03d87cfd42a0327a7f9b57110422aaf970f6';
