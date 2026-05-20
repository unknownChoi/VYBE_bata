// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'favorite_viewmodel.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// 유저 찜 clubId Set — 스트림 1번으로 전체 찜 상태 관리

@ProviderFor(favoritedClubIds)
final favoritedClubIdsProvider = FavoritedClubIdsFamily._();

/// 유저 찜 clubId Set — 스트림 1번으로 전체 찜 상태 관리

final class FavoritedClubIdsProvider
    extends
        $FunctionalProvider<
          AsyncValue<Set<String>>,
          Set<String>,
          Stream<Set<String>>
        >
    with $FutureModifier<Set<String>>, $StreamProvider<Set<String>> {
  /// 유저 찜 clubId Set — 스트림 1번으로 전체 찜 상태 관리
  FavoritedClubIdsProvider._({
    required FavoritedClubIdsFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'favoritedClubIdsProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$favoritedClubIdsHash();

  @override
  String toString() {
    return r'favoritedClubIdsProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $StreamProviderElement<Set<String>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<Set<String>> create(Ref ref) {
    final argument = this.argument as String;
    return favoritedClubIds(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is FavoritedClubIdsProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$favoritedClubIdsHash() => r'e82f36feafad0e4ff22840ecbcd49bafa305f964';

/// 유저 찜 clubId Set — 스트림 1번으로 전체 찜 상태 관리

final class FavoritedClubIdsFamily extends $Family
    with $FunctionalFamilyOverride<Stream<Set<String>>, String> {
  FavoritedClubIdsFamily._()
    : super(
        retry: null,
        name: r'favoritedClubIdsProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// 유저 찜 clubId Set — 스트림 1번으로 전체 찜 상태 관리

  FavoritedClubIdsProvider call(String userId) =>
      FavoritedClubIdsProvider._(argument: userId, from: this);

  @override
  String toString() => r'favoritedClubIdsProvider';
}

/// 낙관적 오버라이드: clubId → true(찜) / false(찜취소)
/// 스트림 업데이트 전까지 UI에 즉시 반영하기 위해 사용

@ProviderFor(FavoriteViewModel)
final favoriteViewModelProvider = FavoriteViewModelProvider._();

/// 낙관적 오버라이드: clubId → true(찜) / false(찜취소)
/// 스트림 업데이트 전까지 UI에 즉시 반영하기 위해 사용
final class FavoriteViewModelProvider
    extends $NotifierProvider<FavoriteViewModel, Map<String, bool>> {
  /// 낙관적 오버라이드: clubId → true(찜) / false(찜취소)
  /// 스트림 업데이트 전까지 UI에 즉시 반영하기 위해 사용
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
  Override overrideWithValue(Map<String, bool> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<Map<String, bool>>(value),
    );
  }
}

String _$favoriteViewModelHash() => r'efa7167d7530ee0e4f0cafe31d481513bc6bcda9';

/// 낙관적 오버라이드: clubId → true(찜) / false(찜취소)
/// 스트림 업데이트 전까지 UI에 즉시 반영하기 위해 사용

abstract class _$FavoriteViewModel extends $Notifier<Map<String, bool>> {
  Map<String, bool> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<Map<String, bool>, Map<String, bool>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<Map<String, bool>, Map<String, bool>>,
              Map<String, bool>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
