import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:vybe/data/datasources/remote/firebase_auth_datasource.dart';
import 'package:vybe/data/datasources/remote/social_auth_datasource.dart';
import 'package:vybe/domain/repositories/auth_repository.dart';

part 'auth_repository_impl.g.dart';

@riverpod
AuthRepository authRepository(Ref ref) =>
    AuthRepositoryImpl(FirebaseAuthDataSource(), SocialAuthDataSource());

class AuthRepositoryImpl implements AuthRepository {
  final FirebaseAuthDataSource _dataSource;
  final SocialAuthDataSource _socialDataSource;

  AuthRepositoryImpl(this._dataSource, this._socialDataSource);

  @override
  Stream<String?> get authStateChanges =>
      _dataSource.authStateChanges.map((user) => user?.uid);

  @override
  String? get currentUid => _dataSource.currentUser?.uid;

  @override
  Future<({String customToken, bool isNewUser})> kakaoLogin(
          String accessToken) =>
      _dataSource.kakaoLogin(accessToken);

  @override
  Future<({String customToken, bool isNewUser})> naverLogin(
          String accessToken) =>
      _dataSource.naverLogin(accessToken);

  @override
  Future<void> signInWithCustomToken(String customToken) =>
      _dataSource.signInWithCustomToken(customToken);

  @override
  Future<bool> userExists(String uid) => _dataSource.userExists(uid);

  @override
  Future<PhoneAccountResult> checkPhoneAccount(String phone, String method) =>
      _dataSource.checkPhoneAccount(phone, method);

  @override
  Future<bool> verifyIdentity(String impUid) =>
      _dataSource.verifyIdentity(impUid);

  @override
  Future<({String customToken, bool isNewUser})> phoneLogin(String phone) =>
      _dataSource.phoneLogin(phone);

  /// Firebase 세션과 소셜 SDK 세션을 **함께** 정리한다.
  /// 소셜 세션이 남으면 재로그인 때 계정 선택 없이 직전 계정으로 붙는다.
  @override
  Future<void> signOut() async {
    await _socialDataSource.signOutAll();
    await _dataSource.signOut();
  }

  /// 탈퇴 요청이 성공하면 **곧바로 로그아웃까지** 한다.
  /// 서버가 Auth 계정을 disabled 로 바꿔 세션이 이미 무효인데, 로컬 세션과
  /// 소셜 SDK 세션이 남아 있으면 앱이 로그인 상태처럼 굴다가 조회마다 실패한다.
  @override
  Future<DateTime> requestAccountDeletion(String reason) async {
    final purgeAt = await _dataSource.requestAccountDeletion(reason);
    await signOut();
    return purgeAt;
  }

  @override
  Future<bool> refreshSession() => _dataSource.refreshSession();
}
