// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'nearby_search_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(NearbySearchResultNotifier)
final nearbySearchResultProvider = NearbySearchResultNotifierProvider._();

final class NearbySearchResultNotifierProvider
    extends $NotifierProvider<NearbySearchResultNotifier, NearbySearchResult?> {
  NearbySearchResultNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'nearbySearchResultProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$nearbySearchResultNotifierHash();

  @$internal
  @override
  NearbySearchResultNotifier create() => NearbySearchResultNotifier();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(NearbySearchResult? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<NearbySearchResult?>(value),
    );
  }
}

String _$nearbySearchResultNotifierHash() =>
    r'bae97fcf9d796539a01f3a7dfe7a2418b1c08d94';

abstract class _$NearbySearchResultNotifier
    extends $Notifier<NearbySearchResult?> {
  NearbySearchResult? build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<NearbySearchResult?, NearbySearchResult?>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<NearbySearchResult?, NearbySearchResult?>,
              NearbySearchResult?,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
