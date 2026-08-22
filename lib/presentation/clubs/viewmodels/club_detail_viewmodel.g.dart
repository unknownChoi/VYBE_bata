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

/// 테이블 배치도. null 이면 홈 탭 테이블 섹션·가격표 화면을 그리지 않는다.

@ProviderFor(clubTableLayout)
final clubTableLayoutProvider = ClubTableLayoutFamily._();

/// 테이블 배치도. null 이면 홈 탭 테이블 섹션·가격표 화면을 그리지 않는다.

final class ClubTableLayoutProvider
    extends
        $FunctionalProvider<
          AsyncValue<ClubTableLayout?>,
          ClubTableLayout?,
          FutureOr<ClubTableLayout?>
        >
    with $FutureModifier<ClubTableLayout?>, $FutureProvider<ClubTableLayout?> {
  /// 테이블 배치도. null 이면 홈 탭 테이블 섹션·가격표 화면을 그리지 않는다.
  ClubTableLayoutProvider._({
    required ClubTableLayoutFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'clubTableLayoutProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$clubTableLayoutHash();

  @override
  String toString() {
    return r'clubTableLayoutProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<ClubTableLayout?> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<ClubTableLayout?> create(Ref ref) {
    final argument = this.argument as String;
    return clubTableLayout(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is ClubTableLayoutProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$clubTableLayoutHash() => r'4ab185ba19474fc268b2127c38d0307e28a7ebec';

/// 테이블 배치도. null 이면 홈 탭 테이블 섹션·가격표 화면을 그리지 않는다.

final class ClubTableLayoutFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<ClubTableLayout?>, String> {
  ClubTableLayoutFamily._()
    : super(
        retry: null,
        name: r'clubTableLayoutProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// 테이블 배치도. null 이면 홈 탭 테이블 섹션·가격표 화면을 그리지 않는다.

  ClubTableLayoutProvider call(String clubId) =>
      ClubTableLayoutProvider._(argument: clubId, from: this);

  @override
  String toString() => r'clubTableLayoutProvider';
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

@ProviderFor(clubPhotos)
final clubPhotosProvider = ClubPhotosFamily._();

final class ClubPhotosProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<PhotoModel>>,
          List<PhotoModel>,
          FutureOr<List<PhotoModel>>
        >
    with $FutureModifier<List<PhotoModel>>, $FutureProvider<List<PhotoModel>> {
  ClubPhotosProvider._({
    required ClubPhotosFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'clubPhotosProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$clubPhotosHash();

  @override
  String toString() {
    return r'clubPhotosProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<List<PhotoModel>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<PhotoModel>> create(Ref ref) {
    final argument = this.argument as String;
    return clubPhotos(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is ClubPhotosProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$clubPhotosHash() => r'b5ada9fc21b95bf367d4a056d6bc954f32465d5b';

final class ClubPhotosFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<List<PhotoModel>>, String> {
  ClubPhotosFamily._()
    : super(
        retry: null,
        name: r'clubPhotosProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  ClubPhotosProvider call(String clubId) =>
      ClubPhotosProvider._(argument: clubId, from: this);

  @override
  String toString() => r'clubPhotosProvider';
}

@ProviderFor(nearbyClubs)
final nearbyClubsProvider = NearbyClubsFamily._();

final class NearbyClubsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<ClubModel>>,
          List<ClubModel>,
          FutureOr<List<ClubModel>>
        >
    with $FutureModifier<List<ClubModel>>, $FutureProvider<List<ClubModel>> {
  NearbyClubsProvider._({
    required NearbyClubsFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'nearbyClubsProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$nearbyClubsHash();

  @override
  String toString() {
    return r'nearbyClubsProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<List<ClubModel>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<ClubModel>> create(Ref ref) {
    final argument = this.argument as String;
    return nearbyClubs(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is NearbyClubsProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$nearbyClubsHash() => r'59cb244a44b2b7f14068d405c1ba0186c878609c';

final class NearbyClubsFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<List<ClubModel>>, String> {
  NearbyClubsFamily._()
    : super(
        retry: null,
        name: r'nearbyClubsProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  NearbyClubsProvider call(String clubId) =>
      NearbyClubsProvider._(argument: clubId, from: this);

  @override
  String toString() => r'nearbyClubsProvider';
}
