// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'promotion_repository_impl.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(promotionRepository)
final promotionRepositoryProvider = PromotionRepositoryProvider._();

final class PromotionRepositoryProvider
    extends
        $FunctionalProvider<
          PromotionRepository,
          PromotionRepository,
          PromotionRepository
        >
    with $Provider<PromotionRepository> {
  PromotionRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'promotionRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$promotionRepositoryHash();

  @$internal
  @override
  $ProviderElement<PromotionRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  PromotionRepository create(Ref ref) {
    return promotionRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(PromotionRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<PromotionRepository>(value),
    );
  }
}

String _$promotionRepositoryHash() =>
    r'e5695f7b749cc8966b8ab1baef84e9bb1d118db8';
