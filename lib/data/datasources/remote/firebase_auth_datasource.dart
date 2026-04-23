import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';

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
    final callable = _functions.httpsCallable('kakaoLogin');
    final result = await callable.call({'accessToken': accessToken});
    return (
      customToken: result.data['customToken'] as String,
      isNewUser: result.data['isNewUser'] as bool,
    );
  }

  Future<({String customToken, bool isNewUser})> naverLogin(
      String accessToken) async {
    final callable = _functions.httpsCallable('naverLogin');
    final result = await callable.call({'accessToken': accessToken});
    return (
      customToken: result.data['customToken'] as String,
      isNewUser: result.data['isNewUser'] as bool,
    );
  }

  Future<void> signInWithCustomToken(String customToken) async {
    await _auth.signInWithCustomToken(customToken);
  }

  Future<bool> userExists(String uid) async {
    final doc = await _firestore.collection('users').doc(uid).get();
    return doc.exists;
  }

  Future<bool> checkPhoneDuplicate(String phone) async {
    final callable = _functions.httpsCallable('checkPhoneDuplicate');
    final result = await callable.call({'phone': phone});
    return result.data['isDuplicate'] as bool;
  }

  Future<bool> verifyIdentity(String impUid) async {
    final callable = _functions.httpsCallable('verifyIdentity');
    final result = await callable.call({'impUid': impUid});
    return result.data['verified'] as bool;
  }

  Future<void> deleteUser() async {
    final callable = _functions.httpsCallable('deleteUser');
    await callable.call();
  }

  Future<void> signOut() => _auth.signOut();
}
