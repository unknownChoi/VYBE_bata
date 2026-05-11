// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'nearby_viewmodel.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(NearbyViewModel)
final nearbyViewModelProvider = NearbyViewModelProvider._();

final class NearbyViewModelProvider
    extends $AsyncNotifierProvider<NearbyViewModel, List<ClubModel>> {
  NearbyViewModelProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'nearbyViewModelProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$nearbyViewModelHash();

  @$internal
  @override
  NearbyViewModel create() => NearbyViewModel();
}

String _$nearbyViewModelHash() => r'091215521fee6d11d36328c1a3274a4b840e23bf';

abstract class _$NearbyViewModel extends $AsyncNotifier<List<ClubModel>> {
  FutureOr<List<ClubModel>> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<AsyncValue<List<ClubModel>>, List<ClubModel>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<List<ClubModel>>, List<ClubModel>>,
              AsyncValue<List<ClubModel>>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
