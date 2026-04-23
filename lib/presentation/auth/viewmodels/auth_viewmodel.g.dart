// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auth_viewmodel.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// 로그인 상태 스트림 (null = 비로그인, non-null = uid)

@ProviderFor(authState)
final authStateProvider = AuthStateProvider._();

/// 로그인 상태 스트림 (null = 비로그인, non-null = uid)

final class AuthStateProvider
    extends $FunctionalProvider<AsyncValue<String?>, String?, Stream<String?>>
    with $FutureModifier<String?>, $StreamProvider<String?> {
  /// 로그인 상태 스트림 (null = 비로그인, non-null = uid)
  AuthStateProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'authStateProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$authStateHash();

  @$internal
  @override
  $StreamProviderElement<String?> $createElement($ProviderPointer pointer) =>
      $StreamProviderElement(pointer);

  @override
  Stream<String?> create(Ref ref) {
    return authState(ref);
  }
}

String _$authStateHash() => r'3aa16daa73577df74caf22fdb773f48fb082345f';

/// 로그인 액션 ViewModel

@ProviderFor(AuthViewModel)
final authViewModelProvider = AuthViewModelProvider._();

/// 로그인 액션 ViewModel
final class AuthViewModelProvider
    extends $NotifierProvider<AuthViewModel, AsyncValue<void>> {
  /// 로그인 액션 ViewModel
  AuthViewModelProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'authViewModelProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$authViewModelHash();

  @$internal
  @override
  AuthViewModel create() => AuthViewModel();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AsyncValue<void> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AsyncValue<void>>(value),
    );
  }
}

String _$authViewModelHash() => r'3a2ff6439ffabd1331932f8af1430ccb0ccbb5d5';

/// 로그인 액션 ViewModel

abstract class _$AuthViewModel extends $Notifier<AsyncValue<void>> {
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
