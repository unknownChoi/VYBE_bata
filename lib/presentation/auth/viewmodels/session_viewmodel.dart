import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:vybe/core/storage/local_prefs.dart';
import 'package:vybe/core/utils/session_utils.dart';
import 'package:vybe/data/repositories/auth_repository_impl.dart';
import 'package:vybe/data/repositories/user_repository_impl.dart';

part 'session_viewmodel.g.dart';

/// 조회 제한 시간. 앱 첫 화면을 붙잡는 구간이라 짧게 — 넘기면 통과시킨다.
const _timeout = Duration(seconds: 3);

/// 저장된 세션 검사 결과. 화면은 이 값만 보고 진입 여부를 정한다.
enum SessionStatus {
  /// 로그인 상태로 진입 가능.
  ready,

  /// 비로그인 — 원래 없었거나, 유효하지 않아 여기서 정리했다.
  signedOut,
}

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
@Riverpod(keepAlive: true)
class SessionCheck extends _$SessionCheck {
  @override
  Future<SessionStatus> build() => _check();

  /// 앱 복귀(resumed) 시 재검사.
  ///
  /// 여기선 **서버 무효화 여부만** 본다. 프로필 완성 여부는 다시 보지 않는다 —
  /// 본인인증은 외부 앱/웹뷰를 다녀오는 흐름이라, 복귀마다 재판정하면
  /// 가입 도중인 사용자를 로그아웃시킨다.
  Future<void> recheckSession() async {
    final auth = ref.read(authRepositoryProvider);
    if (auth.currentUid == null) return;

    final valid = await _sessionStillValid();
    if (valid) return;

    await _signOut();
    state = const AsyncData(SessionStatus.signedOut);
  }

  Future<SessionStatus> _check() async {
    final auth = ref.read(authRepositoryProvider);

    // Firebase가 초기화 때 복원해 둔 세션. 이 시점엔 이미 스플래시가 최소
    // 1.5초 떠 있었으므로 복원이 끝나 있다.
    final uid = auth.currentUid;
    if (uid == null) return SessionStatus.signedOut;

    // 자동 로그인이 꺼져 있으면 어차피 정리할 세션이라 더 볼 것이 없다.
    if (!await _autoLoginEnabled()) {
      await _signOut();
      return SessionStatus.signedOut;
    }

    // 프로필 조회와 토큰 검증은 서로 무관 — 동시에 돌려 대기 시간이
    // 합산되지 않게 한다(앱 첫 화면을 붙잡는 구간이다).
    final (profile, sessionValid) =
        await (_loadProfile(uid), _sessionStillValid()).wait;

    final action = decideSessionAction(
      uid: uid,
      autoLoginEnabled: true,
      profileFound: profile.found,
      isVerified: profile.isVerified,
      lookupFailed: profile.failed,
    );

    if (action != SessionAction.keep || !sessionValid) {
      await _signOut();
      return SessionStatus.signedOut;
    }
    return SessionStatus.ready;
  }

  /// `users/{uid}` 조회. 실패를 예외 대신 [failed] 로 돌려준다 — 판정
  /// (fail-open)이 조회 실패와 '문서 없음'을 구분해야 하기 때문.
  Future<({bool found, bool isVerified, bool failed})> _loadProfile(
    String uid,
  ) async {
    try {
      final user = await ref
          .read(userRepositoryProvider)
          .getUser(uid)
          .timeout(_timeout);
      return (
        found: user != null,
        isVerified: user?.isVerified ?? false,
        failed: false,
      );
    } catch (_) {
      return (found: false, isVerified: false, failed: true);
    }
  }

  /// 자동 로그인 설정. 저장소를 못 열면 켜진 것으로 본다(기존 동작 유지).
  Future<bool> _autoLoginEnabled() async {
    try {
      final prefs = await ref.read(localPrefsProvider.future).timeout(_timeout);
      return prefs.autoLogin;
    } catch (_) {
      return true;
    }
  }

  /// 서버에서 무효화(탈퇴·비활성)된 세션인지. 네트워크 실패는 유효로 본다.
  Future<bool> _sessionStillValid() async {
    try {
      return await ref
          .read(authRepositoryProvider)
          .refreshSession()
          .timeout(_timeout);
    } catch (_) {
      return true;
    }
  }

  Future<void> _signOut() async {
    try {
      await ref.read(authRepositoryProvider).signOut();
    } catch (_) {
      // 로그아웃 실패로 앱 진입이 막히면 안 된다 — 화면은 uid로 다시 판단한다.
    }
  }
}
