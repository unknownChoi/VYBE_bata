/// 저장된 로그인 세션(자동 로그인) 유효성 판정.
///
/// Firebase·Flutter 의존이 없는 **순수 로직**이라 단위 테스트로 검증한다
/// (`test/session_utils_test.dart`). 판정을 여기 한 곳에만 둬서 게이트 화면·
/// 뷰모델이 각자 다른 규칙을 갖지 않게 한다 (`version_utils.dart` 와 같은 패턴).
library;

/// 앱 시작 시 저장된 세션을 어떻게 할지.
enum SessionAction {
  /// 그대로 로그인 상태로 진입.
  keep,

  /// 세션을 정리하고 로그인 화면으로 — 유령 세션이거나 자동 로그인이 꺼져 있다.
  signOut,

  /// 애초에 세션이 없다 (원래 비로그인).
  none,
}

/// 저장된 세션으로 앱에 들여보낼지 판정한다.
///
/// **fail-open** — `users/{uid}` 조회에 실패했으면([lookupFailed]) 막지 않는다.
/// 오프라인 사용자를 로그인 화면으로 튕기는 쪽이 훨씬 큰 사고다.
///
/// [isVerified] 가 판정 기준인 이유: `onUserCreated` 트리거가 `users/{uid}` 를
/// uid·provider 만으로 먼저 만들기 때문에 **문서 존재 여부로는** 본인인증까지
/// 끝난 계정인지 알 수 없다.
SessionAction decideSessionAction({
  required String? uid,
  required bool autoLoginEnabled,
  required bool profileFound,
  required bool isVerified,
  bool lookupFailed = false,
}) {
  if (uid == null) return SessionAction.none;

  // 사용자가 자동 로그인을 껐으면 프로필을 볼 것도 없이 정리한다.
  if (!autoLoginEnabled) return SessionAction.signOut;

  if (lookupFailed) return SessionAction.keep;

  // 세션은 있는데 프로필이 비어 있다 = 가입 도중 끊긴 유령 세션.
  if (!profileFound || !isVerified) return SessionAction.signOut;

  return SessionAction.keep;
}

/// 서버에서 세션이 무효화됐음을 뜻하는 FirebaseAuth 에러 코드.
///
/// 다른 기기에서 탈퇴했거나 계정이 비활성화된 경우. 이 코드가 아니면
/// (네트워크 오류 등) 세션은 유효한 것으로 본다 — fail-open.
const _kRevokedCodes = {
  'user-not-found',
  'user-disabled',
  'user-token-expired',
  'invalid-user-token',
  'user-mismatch',
};

bool isSessionRevokedCode(String code) => _kRevokedCodes.contains(code);
