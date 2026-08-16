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

  /// 저장된 세션이 서버에서도 유효한지 확인. `false` 면 로그아웃해야 한다.
  /// 네트워크 오류는 `true`(fail-open).
  Future<bool> refreshSession();
}
