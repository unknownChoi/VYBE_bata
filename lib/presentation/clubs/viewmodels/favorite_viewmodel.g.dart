// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'favorite_viewmodel.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// 유저 찜 목록 실시간 스트림

@ProviderFor(favoriteList)
final favoriteListProvider = FavoriteListFamily._();

/// 유저 찜 목록 실시간 스트림

final class FavoriteListProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<FavoriteModel>>,
          List<FavoriteModel>,
          Stream<List<FavoriteModel>>
        >
    with
        $FutureModifier<List<FavoriteModel>>,
        $StreamProvider<List<FavoriteModel>> {
  /// 유저 찜 목록 실시간 스트림
  FavoriteListProvider._({
    required FavoriteListFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'favoriteListProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$favoriteListHash();

  @override
  String toString() {
    return r'favoriteListProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $StreamProviderElement<List<FavoriteModel>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<FavoriteModel>> create(Ref ref) {
    final argument = this.argument as String;
    return favoriteList(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is FavoriteListProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$favoriteListHash() => r'5dd0b8e16ef436cb1be74cfaa2cac5979aaf5acc';

/// 유저 찜 목록 실시간 스트림

final class FavoriteListFamily extends $Family
    with $FunctionalFamilyOverride<Stream<List<FavoriteModel>>, String> {
  FavoriteListFamily._()
    : super(
        retry: null,
        name: r'favoriteListProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// 유저 찜 목록 실시간 스트림

  FavoriteListProvider call(String userId) =>
      FavoriteListProvider._(argument: userId, from: this);

  @override
  String toString() => r'favoriteListProvider';
}

/// 특정 클럽 찜 여부

@ProviderFor(isFavorite)
final isFavoriteProvider = IsFavoriteFamily._();

/// 특정 클럽 찜 여부

final class IsFavoriteProvider
    extends $FunctionalProvider<AsyncValue<bool>, bool, FutureOr<bool>>
    with $FutureModifier<bool>, $FutureProvider<bool> {
  /// 특정 클럽 찜 여부
  IsFavoriteProvider._({
    required IsFavoriteFamily super.from,
    required (String, String) super.argument,
  }) : super(
         retry: null,
         name: r'isFavoriteProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$isFavoriteHash();

  @override
  String toString() {
    return r'isFavoriteProvider'
        ''
        '$argument';
  }

  @$internal
  @override
  $FutureProviderElement<bool> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<bool> create(Ref ref) {
    final argument = this.argument as (String, String);
    return isFavorite(ref, argument.$1, argument.$2);
  }

  @override
  bool operator ==(Object other) {
    return other is IsFavoriteProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$isFavoriteHash() => r'dc1ca6b45e0be05d4b44fd950777b82359058951';

/// 특정 클럽 찜 여부

final class IsFavoriteFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<bool>, (String, String)> {
  IsFavoriteFamily._()
    : super(
        retry: null,
        name: r'isFavoriteProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// 특정 클럽 찜 여부

  IsFavoriteProvider call(String userId, String clubId) =>
      IsFavoriteProvider._(argument: (userId, clubId), from: this);

  @override
  String toString() => r'isFavoriteProvider';
}

@ProviderFor(FavoriteViewModel)
final favoriteViewModelProvider = FavoriteViewModelProvider._();

final class FavoriteViewModelProvider
    extends $NotifierProvider<FavoriteViewModel, AsyncValue<void>> {
  FavoriteViewModelProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'favoriteViewModelProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$favoriteViewModelHash();

  @$internal
  @override
  FavoriteViewModel create() => FavoriteViewModel();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AsyncValue<void> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AsyncValue<void>>(value),
    );
  }
}

String _$favoriteViewModelHash() => r'1796d5ad8aef5f50dda0e7d278cb4d31c33a9ca6';

abstract class _$FavoriteViewModel extends $Notifier<AsyncValue<void>> {
  AsyncValue<void> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<AsyncValue<void>, AsyncValue<void>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<void>, AsyncValue<void>>,
              AsyncValue<void>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
