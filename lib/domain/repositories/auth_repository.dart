import 'package:firebase_auth/firebase_auth.dart';

abstract class AuthRepository {
  Stream<User?> get authStateChanges;
  User? get currentUser;

  Future<({String customToken, bool isNewUser})> kakaoLogin(String accessToken);
  Future<({String customToken, bool isNewUser})> naverLogin(String accessToken);
  Future<UserCredential> signInWithCustomToken(String customToken);
  Future<bool> userExists(String uid);
  Future<bool> checkPhoneDuplicate(String phone);
  Future<bool> verifyIdentity(String impUid);
  Future<void> deleteUser();
  Future<void> signOut();
}
