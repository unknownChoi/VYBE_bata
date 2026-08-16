abstract class AuthRepository {
  /// 로그인 상태 스트림. null = 비로그인, non-null = uid
  Stream<String?> get authStateChanges;
  String? get currentUid;

  Future<({String customToken, bool isNewUser})> kakaoLogin(String accessToken);
  Future<({String customToken, bool isNewUser})> naverLogin(String accessToken);
  Future<({String customToken, bool isNewUser})> phoneLogin(String phone);
  Future<void> signInWithCustomToken(String customToken);
  Future<bool> userExists(String uid);
  Future<bool> checkPhoneDuplicate(String phone);
  Future<bool> verifyIdentity(String impUid);
  Future<void> signOut();

  /// 회원 탈퇴. 데이터는 즉시 지우지 않고 노출만 막은 뒤 30일 후 파기한다.
  /// 반환값 = 완전 파기 예정 시각(재가입 가능 시점). 성공 시 로그아웃까지 끝난다.
  Future<DateTime> requestAccountDeletion(String reason);

  /// 저장된 세션이 서버에서도 유효한지 확인. `false` 면 로그아웃해야 한다.
  /// 네트워크 오류는 `true`(fail-open).
  Future<bool> refreshSession();
}
