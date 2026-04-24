import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:vybe/core/utils/firebase_logger.dart';

class FirebaseAuthDataSource {
  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;
  final FirebaseFunctions _functions;

  FirebaseAuthDataSource()
      : _auth = FirebaseAuth.instance,
        _firestore = FirebaseFirestore.instance,
        _functions = FirebaseFunctions.instance;

  Stream<User?> get authStateChanges => _auth.authStateChanges();
  User? get currentUser => _auth.currentUser;

  Future<({String customToken, bool isNewUser})> kakaoLogin(
      String accessToken) async {
    logFirebaseAccess(
      file: 'firebase_auth_datasource.dart',
      service: 'Functions(kakaoLogin)',
      purpose: '카카오 accessToken → Firebase Custom Token 발급',
    );
    final callable = _functions.httpsCallable('kakaoLogin');
    final result = await callable.call({'accessToken': accessToken});
    return (
      customToken: result.data['customToken'] as String,
      isNewUser: result.data['isNewUser'] as bool,
    );
  }

  Future<({String customToken, bool isNewUser})> naverLogin(
      String accessToken) async {
    logFirebaseAccess(
      file: 'firebase_auth_datasource.dart',
      service: 'Functions(naverLogin)',
      purpose: '네이버 accessToken → Firebase Custom Token 발급',
    );
    final callable = _functions.httpsCallable('naverLogin');
    final result = await callable.call({'accessToken': accessToken});
    return (
      customToken: result.data['customToken'] as String,
      isNewUser: result.data['isNewUser'] as bool,
    );
  }

  Future<void> signInWithCustomToken(String customToken) async {
    logFirebaseAccess(
      file: 'firebase_auth_datasource.dart',
      service: 'Auth(signInWithCustomToken)',
      purpose: 'Custom Token으로 Firebase 로그인',
    );
    await _auth.signInWithCustomToken(customToken);
  }

  Future<bool> userExists(String uid) async {
    logFirebaseAccess(
      file: 'firebase_auth_datasource.dart',
      service: 'Firestore(users/$uid)',
      purpose: '신규/기존 유저 여부 확인',
    );
    final doc = await _firestore.collection('users').doc(uid).get();
    return doc.exists;
  }

  Future<bool> checkPhoneDuplicate(String phone) async {
    logFirebaseAccess(
      file: 'firebase_auth_datasource.dart',
      service: 'Functions(checkPhoneDuplicate)',
      purpose: '전화번호 중복 가입 여부 확인',
    );
    final callable = _functions.httpsCallable('checkPhoneDuplicate');
    final result = await callable.call({'phone': phone});
    return result.data['isDuplicate'] as bool;
  }

  Future<bool> verifyIdentity(String impUid) async {
    logFirebaseAccess(
      file: 'firebase_auth_datasource.dart',
      service: 'Functions(verifyIdentity)',
      purpose: '본인인증 결과 검증',
    );
    final callable = _functions.httpsCallable('verifyIdentity');
    final result = await callable.call({'impUid': impUid});
    return result.data['verified'] as bool;
  }

  Future<void> deleteUser() async {
    logFirebaseAccess(
      file: 'firebase_auth_datasource.dart',
      service: 'Functions(deleteUser)',
      purpose: '회원탈퇴 (Auth + Firestore + Storage 일괄 삭제)',
    );
    final callable = _functions.httpsCallable('deleteUser');
    await callable.call();
  }

  Future<bool> appleLogin({
    required String identityToken,
    required String rawNonce,
  }) async {
    logFirebaseAccess(
      file: 'firebase_auth_datasource.dart',
      service: 'Auth(signInWithCredential - apple)',
      purpose: 'Apple 자격증명으로 Firebase 로그인',
    );
    final credential = OAuthProvider('apple.com').credential(
      idToken: identityToken,
      rawNonce: rawNonce,
    );
    final userCredential = await _auth.signInWithCredential(credential);
    return userCredential.additionalUserInfo?.isNewUser ?? false;
  }

  Future<void> signOut() async {
    logFirebaseAccess(
      file: 'firebase_auth_datasource.dart',
      service: 'Auth(signOut)',
      purpose: '로그아웃',
    );
    await _auth.signOut();
  }
}
