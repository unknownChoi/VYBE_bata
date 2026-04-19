// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_viewmodel.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// 현재 로그인 유저 실시간 스트림

@ProviderFor(currentUser)
final currentUserProvider = CurrentUserFamily._();

/// 현재 로그인 유저 실시간 스트림

final class CurrentUserProvider
    extends
        $FunctionalProvider<
          AsyncValue<UserModel?>,
          UserModel?,
          Stream<UserModel?>
        >
    with $FutureModifier<UserModel?>, $StreamProvider<UserModel?> {
  /// 현재 로그인 유저 실시간 스트림
  CurrentUserProvider._({
    required CurrentUserFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'currentUserProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$currentUserHash();

  @override
  String toString() {
    return r'currentUserProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $StreamProviderElement<UserModel?> $createElement($ProviderPointer pointer) =>
      $StreamProviderElement(pointer);

  @override
  Stream<UserModel?> create(Ref ref) {
    final argument = this.argument as String;
    return currentUser(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is CurrentUserProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$currentUserHash() => r'28553ed260ef5483504afe8d9fa14e1fb0e2b890';

/// 현재 로그인 유저 실시간 스트림

final class CurrentUserFamily extends $Family
    with $FunctionalFamilyOverride<Stream<UserModel?>, String> {
  CurrentUserFamily._()
    : super(
        retry: null,
        name: r'currentUserProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// 현재 로그인 유저 실시간 스트림

  CurrentUserProvider call(String uid) =>
      CurrentUserProvider._(argument: uid, from: this);

  @override
  String toString() => r'currentUserProvider';
}

@ProviderFor(UserViewModel)
final userViewModelProvider = UserViewModelProvider._();

final class UserViewModelProvider
    extends $NotifierProvider<UserViewModel, AsyncValue<void>> {
  UserViewModelProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'userViewModelProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$userViewModelHash();

  @$internal
  @override
  UserViewModel create() => UserViewModel();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AsyncValue<void> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AsyncValue<void>>(value),
    );
  }
}

String _$userViewModelHash() => r'cebc8ad9af5007759f06f847e4a35aff4541c48b';

abstract class _$UserViewModel extends $Notifier<AsyncValue<void>> {
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
