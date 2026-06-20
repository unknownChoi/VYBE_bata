// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'location_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// 전역 내 위치 상태. 앱 진입 시 기본 좌표로 초기화된다.

@ProviderFor(UserLocationNotifier)
final userLocationProvider = UserLocationNotifierProvider._();

/// 전역 내 위치 상태. 앱 진입 시 기본 좌표로 초기화된다.
final class UserLocationNotifierProvider
    extends $NotifierProvider<UserLocationNotifier, UserLocation> {
  /// 전역 내 위치 상태. 앱 진입 시 기본 좌표로 초기화된다.
  UserLocationNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'userLocationProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$userLocationNotifierHash();

  @$internal
  @override
  UserLocationNotifier create() => UserLocationNotifier();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(UserLocation value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<UserLocation>(value),
    );
  }
}

String _$userLocationNotifierHash() =>
    r'6d329ecde377a55493ce8be3731d9d204bdab6dd';

/// 전역 내 위치 상태. 앱 진입 시 기본 좌표로 초기화된다.

abstract class _$UserLocationNotifier extends $Notifier<UserLocation> {
  UserLocation build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<UserLocation, UserLocation>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<UserLocation, UserLocation>,
              UserLocation,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
