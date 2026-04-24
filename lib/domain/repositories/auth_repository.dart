abstract class AuthRepository {
  /// 로그인 상태 스트림. null = 비로그인, non-null = uid
  Stream<String?> get authStateChanges;
  String? get currentUid;

  Future<({String customToken, bool isNewUser})> kakaoLogin(String accessToken);
  Future<({String customToken, bool isNewUser})> naverLogin(String accessToken);
  Future<bool> appleLogin({required String identityToken, required String rawNonce});
  Future<void> signInWithCustomToken(String customToken);
  Future<bool> userExists(String uid);
  Future<bool> checkPhoneDuplicate(String phone);
  Future<bool> verifyIdentity(String impUid);
  Future<void> deleteUser();
  Future<void> signOut();
}
