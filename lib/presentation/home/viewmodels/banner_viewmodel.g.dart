// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'banner_viewmodel.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(bannerList)
final bannerListProvider = BannerListProvider._();

final class BannerListProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<BannerModel>>,
          List<BannerModel>,
          FutureOr<List<BannerModel>>
        >
    with
        $FutureModifier<List<BannerModel>>,
        $FutureProvider<List<BannerModel>> {
  BannerListProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'bannerListProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$bannerListHash();

  @$internal
  @override
  $FutureProviderElement<List<BannerModel>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<BannerModel>> create(Ref ref) {
    return bannerList(ref);
  }
}

String _$bannerListHash() => r'c3294804dd5915599a4426e4310aab4dd7ac8534';
