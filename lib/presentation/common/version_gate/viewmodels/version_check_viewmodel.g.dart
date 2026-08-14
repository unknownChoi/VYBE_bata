// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'version_check_viewmodel.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// 앱 실행·복귀 시 버전 정책을 확인한다.
///
/// **fail-open** — 네트워크 실패·타임아웃·문서 없음·파싱 실패는 전부 통과.
/// 서버 사고로 전 유저가 앱에 못 들어가는 쪽이 훨씬 큰 사고다.
/// keepAlive — 게이트가 트리 최상단이라 재생성될 일이 없고, 화면 전환마다
/// 재조회되면 안 된다.

@ProviderFor(VersionCheck)
final versionCheckProvider = VersionCheckProvider._();

/// 앱 실행·복귀 시 버전 정책을 확인한다.
///
/// **fail-open** — 네트워크 실패·타임아웃·문서 없음·파싱 실패는 전부 통과.
/// 서버 사고로 전 유저가 앱에 못 들어가는 쪽이 훨씬 큰 사고다.
/// keepAlive — 게이트가 트리 최상단이라 재생성될 일이 없고, 화면 전환마다
/// 재조회되면 안 된다.
final class VersionCheckProvider
    extends $AsyncNotifierProvider<VersionCheck, VersionCheckResult> {
  /// 앱 실행·복귀 시 버전 정책을 확인한다.
  ///
  /// **fail-open** — 네트워크 실패·타임아웃·문서 없음·파싱 실패는 전부 통과.
  /// 서버 사고로 전 유저가 앱에 못 들어가는 쪽이 훨씬 큰 사고다.
  /// keepAlive — 게이트가 트리 최상단이라 재생성될 일이 없고, 화면 전환마다
  /// 재조회되면 안 된다.
  VersionCheckProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'versionCheckProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$versionCheckHash();

  @$internal
  @override
  VersionCheck create() => VersionCheck();
}

String _$versionCheckHash() => r'9af1fdf8f8640d159ed4fdaf0af925dfb1c25d6a';

/// 앱 실행·복귀 시 버전 정책을 확인한다.
///
/// **fail-open** — 네트워크 실패·타임아웃·문서 없음·파싱 실패는 전부 통과.
/// 서버 사고로 전 유저가 앱에 못 들어가는 쪽이 훨씬 큰 사고다.
/// keepAlive — 게이트가 트리 최상단이라 재생성될 일이 없고, 화면 전환마다
/// 재조회되면 안 된다.

abstract class _$VersionCheck extends $AsyncNotifier<VersionCheckResult> {
  FutureOr<VersionCheckResult> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref =
        this.ref as $Ref<AsyncValue<VersionCheckResult>, VersionCheckResult>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<VersionCheckResult>, VersionCheckResult>,
              AsyncValue<VersionCheckResult>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
