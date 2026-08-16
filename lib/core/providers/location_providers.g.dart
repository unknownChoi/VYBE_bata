// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'location_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// 전역 내 위치 상태.
///
/// 앱 첫 로딩(`SplashGate`)에서 [UserLocationNotifier.resolveFromDevice]를 한 번
/// 돌려 기기 GPS 좌표로 갱신하고, 홈 위치 칩·주변 페이지·주변 클럽 섹션이 전부
/// 이 좌표 하나를 본다.
///
/// **keepAlive인 이유** — 스플래시에서 좌표를 받을 때는 이 provider를 보는 화면이
/// 아직 없다. autoDispose면 받자마자 버려져 홈이 폴백 좌표로 다시 시작한다.

@ProviderFor(UserLocationNotifier)
final userLocationProvider = UserLocationNotifierProvider._();

/// 전역 내 위치 상태.
///
/// 앱 첫 로딩(`SplashGate`)에서 [UserLocationNotifier.resolveFromDevice]를 한 번
/// 돌려 기기 GPS 좌표로 갱신하고, 홈 위치 칩·주변 페이지·주변 클럽 섹션이 전부
/// 이 좌표 하나를 본다.
///
/// **keepAlive인 이유** — 스플래시에서 좌표를 받을 때는 이 provider를 보는 화면이
/// 아직 없다. autoDispose면 받자마자 버려져 홈이 폴백 좌표로 다시 시작한다.
final class UserLocationNotifierProvider
    extends $NotifierProvider<UserLocationNotifier, UserLocation> {
  /// 전역 내 위치 상태.
  ///
  /// 앱 첫 로딩(`SplashGate`)에서 [UserLocationNotifier.resolveFromDevice]를 한 번
  /// 돌려 기기 GPS 좌표로 갱신하고, 홈 위치 칩·주변 페이지·주변 클럽 섹션이 전부
  /// 이 좌표 하나를 본다.
  ///
  /// **keepAlive인 이유** — 스플래시에서 좌표를 받을 때는 이 provider를 보는 화면이
  /// 아직 없다. autoDispose면 받자마자 버려져 홈이 폴백 좌표로 다시 시작한다.
  UserLocationNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'userLocationProvider',
        isAutoDispose: false,
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
    r'2b95c0799836d3b156c07e4e273891ebb0339143';

/// 전역 내 위치 상태.
///
/// 앱 첫 로딩(`SplashGate`)에서 [UserLocationNotifier.resolveFromDevice]를 한 번
/// 돌려 기기 GPS 좌표로 갱신하고, 홈 위치 칩·주변 페이지·주변 클럽 섹션이 전부
/// 이 좌표 하나를 본다.
///
/// **keepAlive인 이유** — 스플래시에서 좌표를 받을 때는 이 provider를 보는 화면이
/// 아직 없다. autoDispose면 받자마자 버려져 홈이 폴백 좌표로 다시 시작한다.

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
