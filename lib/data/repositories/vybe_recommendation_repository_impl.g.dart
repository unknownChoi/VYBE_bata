// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'vybe_recommendation_repository_impl.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(vybeRecommendationRepository)
final vybeRecommendationRepositoryProvider =
    VybeRecommendationRepositoryProvider._();

final class VybeRecommendationRepositoryProvider
    extends
        $FunctionalProvider<
          VybeRecommendationRepository,
          VybeRecommendationRepository,
          VybeRecommendationRepository
        >
    with $Provider<VybeRecommendationRepository> {
  VybeRecommendationRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'vybeRecommendationRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$vybeRecommendationRepositoryHash();

  @$internal
  @override
  $ProviderElement<VybeRecommendationRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  VybeRecommendationRepository create(Ref ref) {
    return vybeRecommendationRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(VybeRecommendationRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<VybeRecommendationRepository>(value),
    );
  }
}

String _$vybeRecommendationRepositoryHash() =>
    r'4540e30fd63398d72956250c578e31931795a0f7';
