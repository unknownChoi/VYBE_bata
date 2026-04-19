// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'club_detail_viewmodel.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(clubDetail)
final clubDetailProvider = ClubDetailFamily._();

final class ClubDetailProvider
    extends
        $FunctionalProvider<
          AsyncValue<ClubModel?>,
          ClubModel?,
          FutureOr<ClubModel?>
        >
    with $FutureModifier<ClubModel?>, $FutureProvider<ClubModel?> {
  ClubDetailProvider._({
    required ClubDetailFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'clubDetailProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$clubDetailHash();

  @override
  String toString() {
    return r'clubDetailProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<ClubModel?> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<ClubModel?> create(Ref ref) {
    final argument = this.argument as String;
    return clubDetail(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is ClubDetailProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$clubDetailHash() => r'0b7ca5739fee33e30ed357bd0d1f1d7e308a2c0d';

final class ClubDetailFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<ClubModel?>, String> {
  ClubDetailFamily._()
    : super(
        retry: null,
        name: r'clubDetailProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  ClubDetailProvider call(String clubId) =>
      ClubDetailProvider._(argument: clubId, from: this);

  @override
  String toString() => r'clubDetailProvider';
}

@ProviderFor(clubInfo)
final clubInfoProvider = ClubInfoFamily._();

final class ClubInfoProvider
    extends
        $FunctionalProvider<
          AsyncValue<ClubInfoModel?>,
          ClubInfoModel?,
          FutureOr<ClubInfoModel?>
        >
    with $FutureModifier<ClubInfoModel?>, $FutureProvider<ClubInfoModel?> {
  ClubInfoProvider._({
    required ClubInfoFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'clubInfoProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$clubInfoHash();

  @override
  String toString() {
    return r'clubInfoProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<ClubInfoModel?> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<ClubInfoModel?> create(Ref ref) {
    final argument = this.argument as String;
    return clubInfo(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is ClubInfoProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$clubInfoHash() => r'0e88294e5e6caa2c7b98e1f7495ba7732f695e61';

final class ClubInfoFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<ClubInfoModel?>, String> {
  ClubInfoFamily._()
    : super(
        retry: null,
        name: r'clubInfoProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  ClubInfoProvider call(String clubId) =>
      ClubInfoProvider._(argument: clubId, from: this);

  @override
  String toString() => r'clubInfoProvider';
}

@ProviderFor(clubMenus)
final clubMenusProvider = ClubMenusFamily._();

final class ClubMenusProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<MenuModel>>,
          List<MenuModel>,
          FutureOr<List<MenuModel>>
        >
    with $FutureModifier<List<MenuModel>>, $FutureProvider<List<MenuModel>> {
  ClubMenusProvider._({
    required ClubMenusFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'clubMenusProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$clubMenusHash();

  @override
  String toString() {
    return r'clubMenusProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<List<MenuModel>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<MenuModel>> create(Ref ref) {
    final argument = this.argument as String;
    return clubMenus(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is ClubMenusProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$clubMenusHash() => r'd9d34a37a0394d0b72fd43115ca504daefca6d77';

final class ClubMenusFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<List<MenuModel>>, String> {
  ClubMenusFamily._()
    : super(
        retry: null,
        name: r'clubMenusProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  ClubMenusProvider call(String clubId) =>
      ClubMenusProvider._(argument: clubId, from: this);

  @override
  String toString() => r'clubMenusProvider';
}
