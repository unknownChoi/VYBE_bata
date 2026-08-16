import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:vybe/core/utils/firebase_logger.dart';
import 'package:vybe/core/utils/session_utils.dart';
import 'package:vybe/domain/exceptions/account_exceptions.dart';

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
    final result = await _callGuardingDeletion(
      () => callable.call({'accessToken': accessToken}),
    );
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
    final result = await _callGuardingDeletion(
      () => callable.call({'accessToken': accessToken}),
    );
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

  Future<({String customToken, bool isNewUser})> phoneLogin(String phone) async {
    logFirebaseAccess(
      file: 'firebase_auth_datasource.dart',
      service: 'Functions(phoneLogin)',
      purpose: '전화번호 기반 Custom Token 발급',
    );
    final callable = _functions.httpsCallable('phoneLogin');
    final result = await _callGuardingDeletion(
      () => callable.call({'phone': phone}),
    );
    return (
      customToken: result.data['customToken'] as String,
      isNewUser: result.data['isNewUser'] as bool,
    );
  }

  /// 회원 탈퇴 요청. 데이터를 즉시 지우지 않고 30일 보관 후 파기한다.
  /// 반환값은 완전 파기 예정 시각(= 재가입 가능 시점).
  Future<DateTime> requestAccountDeletion(String reason) async {
    logFirebaseAccess(
      file: 'firebase_auth_datasource.dart',
      service: 'Functions(requestAccountDeletion)',
      purpose: '회원 탈퇴 요청 — 데이터 숨김 + 계정 비활성 (30일 후 파기)',
    );
    final callable = _functions.httpsCallable('requestAccountDeletion');
    final result = await callable.call({'reason': reason});
    return DateTime.fromMillisecondsSinceEpoch(result.data['purgeAt'] as int);
  }

  /// 로그인 계열 호출을 감싸 '탈퇴 대기 계정' 거부를 전용 예외로 바꾼다.
  ///
  /// 서버가 `failed-precondition` + `details.purgeAt` 으로 거부하므로,
  /// 화면이 원시 FirebaseFunctionsException 문구 대신 재가입 가능일을
  /// 안내할 수 있게 여기서 변환한다.
  Future<HttpsCallableResult> _callGuardingDeletion(
    Future<HttpsCallableResult> Function() call,
  ) async {
    try {
      return await call();
    } on FirebaseFunctionsException catch (e) {
      if (e.code != 'failed-precondition') rethrow;
      final millis = (e.details is Map) ? e.details['purgeAt'] : null;
      throw AccountPendingDeletionException(
        millis is int ? DateTime.fromMillisecondsSinceEpoch(millis) : null,
      );
    }
  }

  Future<void> signOut() async {
    logFirebaseAccess(
      file: 'firebase_auth_datasource.dart',
      service: 'Auth(signOut)',
      purpose: '로그아웃',
    );
    await _auth.signOut();
  }

  /// 저장된 세션이 서버에서도 아직 살아 있는지 확인한다(ID 토큰 강제 갱신).
  ///
  /// 자동 로그인이라 재로그인 시점이 없어, 다른 기기에서 탈퇴했거나 계정이
  /// 비활성화돼도 로컬 세션만 계속 살아 있을 수 있다.
  ///
  /// - `false` = 서버에서 무효화된 세션 → 호출부가 로그아웃해야 함
  /// - `true`  = 유효. **네트워크 오류·오프라인도 true**(fail-open) —
  ///   연결이 안 된다고 사용자를 로그아웃시키지 않는다.
  Future<bool> refreshSession() async {
    final user = _auth.currentUser;
    if (user == null) return true; // 세션 없음 — 정리할 것도 없다

    logFirebaseAccess(
      file: 'firebase_auth_datasource.dart',
      service: 'Auth(getIdToken refresh)',
      purpose: '저장된 세션이 서버에서 유효한지 확인',
    );
    try {
      await user.getIdToken(true);
      return true;
    } on FirebaseAuthException catch (e) {
      return !isSessionRevokedCode(e.code);
    } catch (_) {
      return true;
    }
  }
}
