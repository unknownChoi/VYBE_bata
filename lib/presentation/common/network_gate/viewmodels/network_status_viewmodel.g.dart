// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'network_status_viewmodel.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// 기기 네트워크 연결 상태. `true` = 연결됨.
///
/// 앱 첫 로딩(스플래시)에서 [SplashDestination] 판정이 이 provider를 보며 시작되고,
/// [NetworkGate] 가 같은 값으로 차단 화면을 그린다 — 판정은 여기 한 곳뿐.
///
/// **keepAlive인 이유** — 게이트가 트리 최상단이라 재생성될 일이 없고,
/// 기기 연결 변화 구독도 앱이 사는 동안 계속 유지돼야 한다.
///
/// **fail-open** — 확인 실패는 datasource에서 이미 '연결됨'으로 접힌다.

@ProviderFor(NetworkStatus)
final networkStatusProvider = NetworkStatusProvider._();

/// 기기 네트워크 연결 상태. `true` = 연결됨.
///
/// 앱 첫 로딩(스플래시)에서 [SplashDestination] 판정이 이 provider를 보며 시작되고,
/// [NetworkGate] 가 같은 값으로 차단 화면을 그린다 — 판정은 여기 한 곳뿐.
///
/// **keepAlive인 이유** — 게이트가 트리 최상단이라 재생성될 일이 없고,
/// 기기 연결 변화 구독도 앱이 사는 동안 계속 유지돼야 한다.
///
/// **fail-open** — 확인 실패는 datasource에서 이미 '연결됨'으로 접힌다.
final class NetworkStatusProvider
    extends $AsyncNotifierProvider<NetworkStatus, bool> {
  /// 기기 네트워크 연결 상태. `true` = 연결됨.
  ///
  /// 앱 첫 로딩(스플래시)에서 [SplashDestination] 판정이 이 provider를 보며 시작되고,
  /// [NetworkGate] 가 같은 값으로 차단 화면을 그린다 — 판정은 여기 한 곳뿐.
  ///
  /// **keepAlive인 이유** — 게이트가 트리 최상단이라 재생성될 일이 없고,
  /// 기기 연결 변화 구독도 앱이 사는 동안 계속 유지돼야 한다.
  ///
  /// **fail-open** — 확인 실패는 datasource에서 이미 '연결됨'으로 접힌다.
  NetworkStatusProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'networkStatusProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$networkStatusHash();

  @$internal
  @override
  NetworkStatus create() => NetworkStatus();
}

String _$networkStatusHash() => r'070e7eaeb7c6ae1db2677109038a080759280043';

/// 기기 네트워크 연결 상태. `true` = 연결됨.
///
/// 앱 첫 로딩(스플래시)에서 [SplashDestination] 판정이 이 provider를 보며 시작되고,
/// [NetworkGate] 가 같은 값으로 차단 화면을 그린다 — 판정은 여기 한 곳뿐.
///
/// **keepAlive인 이유** — 게이트가 트리 최상단이라 재생성될 일이 없고,
/// 기기 연결 변화 구독도 앱이 사는 동안 계속 유지돼야 한다.
///
/// **fail-open** — 확인 실패는 datasource에서 이미 '연결됨'으로 접힌다.

abstract class _$NetworkStatus extends $AsyncNotifier<bool> {
  FutureOr<bool> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<AsyncValue<bool>, bool>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<bool>, bool>,
              AsyncValue<bool>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
