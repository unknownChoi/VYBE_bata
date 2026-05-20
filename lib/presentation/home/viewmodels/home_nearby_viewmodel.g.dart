// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'home_nearby_viewmodel.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(homeNearbyClubs)
final homeNearbyClubsProvider = HomeNearbyClubsProvider._();

final class HomeNearbyClubsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<ClubModel>>,
          List<ClubModel>,
          FutureOr<List<ClubModel>>
        >
    with $FutureModifier<List<ClubModel>>, $FutureProvider<List<ClubModel>> {
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

String _$homeNearbyClubsHash() => r'1f6fe01769fb20990332bebf9e297df4e05cad23';
