// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'promotion_viewmodel.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// 프로모션 상세 1건. 배너 탭 시점에만 조회한다(홈 목록엔 본문이 없다).

@ProviderFor(promotion)
final promotionProvider = PromotionFamily._();

/// 프로모션 상세 1건. 배너 탭 시점에만 조회한다(홈 목록엔 본문이 없다).

final class PromotionProvider
    extends
        $FunctionalProvider<
          AsyncValue<PromotionModel?>,
          PromotionModel?,
          FutureOr<PromotionModel?>
        >
    with $FutureModifier<PromotionModel?>, $FutureProvider<PromotionModel?> {
  /// 프로모션 상세 1건. 배너 탭 시점에만 조회한다(홈 목록엔 본문이 없다).
  PromotionProvider._({
    required PromotionFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'promotionProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$promotionHash();

  @override
  String toString() {
    return r'promotionProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<PromotionModel?> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<PromotionModel?> create(Ref ref) {
    final argument = this.argument as String;
    return promotion(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is PromotionProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$promotionHash() => r'dfe0c769d73679eafa9ed6ec02f34eafd14ed20a';

/// 프로모션 상세 1건. 배너 탭 시점에만 조회한다(홈 목록엔 본문이 없다).

final class PromotionFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<PromotionModel?>, String> {
  PromotionFamily._()
    : super(
        retry: null,
        name: r'promotionProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// 프로모션 상세 1건. 배너 탭 시점에만 조회한다(홈 목록엔 본문이 없다).

  PromotionProvider call(String promotionId) =>
      PromotionProvider._(argument: promotionId, from: this);

  @override
  String toString() => r'promotionProvider';
}
