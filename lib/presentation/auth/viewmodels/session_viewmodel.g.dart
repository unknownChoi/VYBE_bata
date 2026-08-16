// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'session_viewmodel.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// 앱 시작 시 저장된 로그인 세션(자동 로그인)을 검사한다.
///
/// Firebase Auth는 세션을 기기에 저장하므로 앱을 껐다 켜도 로그인이 유지된다.
/// 이 뷰모델은 그 세션을 **그대로 믿어도 되는지**만 판단한다.
///
/// 1. 자동 로그인이 꺼져 있으면 → 정리
/// 2. `users/{uid}.isVerified` 가 false/문서 없음 → 가입 도중 끊긴 유령 세션 → 정리
/// 3. 서버에서 무효화된 세션(탈퇴·비활성) → 정리
///
/// **fail-open** — 조회 실패·타임아웃은 전부 통과. 오프라인 사용자를 로그인
/// 화면으로 튕기는 쪽이 훨씬 큰 사고다. 예외를 삼키는 곳은 여기 한 곳뿐이고
/// datasource는 그대로 던진다 (버전 게이트와 같은 원칙).
///
/// keepAlive — 게이트가 트리 최상단이라 화면 전환마다 재검사되면 안 된다.

@ProviderFor(SessionCheck)
final sessionCheckProvider = SessionCheckProvider._();

/// 앱 시작 시 저장된 로그인 세션(자동 로그인)을 검사한다.
///
/// Firebase Auth는 세션을 기기에 저장하므로 앱을 껐다 켜도 로그인이 유지된다.
/// 이 뷰모델은 그 세션을 **그대로 믿어도 되는지**만 판단한다.
///
/// 1. 자동 로그인이 꺼져 있으면 → 정리
/// 2. `users/{uid}.isVerified` 가 false/문서 없음 → 가입 도중 끊긴 유령 세션 → 정리
/// 3. 서버에서 무효화된 세션(탈퇴·비활성) → 정리
///
/// **fail-open** — 조회 실패·타임아웃은 전부 통과. 오프라인 사용자를 로그인
/// 화면으로 튕기는 쪽이 훨씬 큰 사고다. 예외를 삼키는 곳은 여기 한 곳뿐이고
/// datasource는 그대로 던진다 (버전 게이트와 같은 원칙).
///
/// keepAlive — 게이트가 트리 최상단이라 화면 전환마다 재검사되면 안 된다.
final class SessionCheckProvider
    extends $AsyncNotifierProvider<SessionCheck, SessionStatus> {
  /// 앱 시작 시 저장된 로그인 세션(자동 로그인)을 검사한다.
  ///
  /// Firebase Auth는 세션을 기기에 저장하므로 앱을 껐다 켜도 로그인이 유지된다.
  /// 이 뷰모델은 그 세션을 **그대로 믿어도 되는지**만 판단한다.
  ///
  /// 1. 자동 로그인이 꺼져 있으면 → 정리
  /// 2. `users/{uid}.isVerified` 가 false/문서 없음 → 가입 도중 끊긴 유령 세션 → 정리
  /// 3. 서버에서 무효화된 세션(탈퇴·비활성) → 정리
  ///
  /// **fail-open** — 조회 실패·타임아웃은 전부 통과. 오프라인 사용자를 로그인
  /// 화면으로 튕기는 쪽이 훨씬 큰 사고다. 예외를 삼키는 곳은 여기 한 곳뿐이고
  /// datasource는 그대로 던진다 (버전 게이트와 같은 원칙).
  ///
  /// keepAlive — 게이트가 트리 최상단이라 화면 전환마다 재검사되면 안 된다.
  SessionCheckProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'sessionCheckProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$sessionCheckHash();

  @$internal
  @override
  SessionCheck create() => SessionCheck();
}

String _$sessionCheckHash() => r'271f27cc0cc02e4104ad90bca2a53fd2f604b31b';

/// 앱 시작 시 저장된 로그인 세션(자동 로그인)을 검사한다.
///
/// Firebase Auth는 세션을 기기에 저장하므로 앱을 껐다 켜도 로그인이 유지된다.
/// 이 뷰모델은 그 세션을 **그대로 믿어도 되는지**만 판단한다.
///
/// 1. 자동 로그인이 꺼져 있으면 → 정리
/// 2. `users/{uid}.isVerified` 가 false/문서 없음 → 가입 도중 끊긴 유령 세션 → 정리
/// 3. 서버에서 무효화된 세션(탈퇴·비활성) → 정리
///
/// **fail-open** — 조회 실패·타임아웃은 전부 통과. 오프라인 사용자를 로그인
/// 화면으로 튕기는 쪽이 훨씬 큰 사고다. 예외를 삼키는 곳은 여기 한 곳뿐이고
/// datasource는 그대로 던진다 (버전 게이트와 같은 원칙).
///
/// keepAlive — 게이트가 트리 최상단이라 화면 전환마다 재검사되면 안 된다.

abstract class _$SessionCheck extends $AsyncNotifier<SessionStatus> {
  FutureOr<SessionStatus> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<AsyncValue<SessionStatus>, SessionStatus>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<SessionStatus>, SessionStatus>,
              AsyncValue<SessionStatus>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
