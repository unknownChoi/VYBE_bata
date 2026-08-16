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
  Future<bool> checkPhoneDuplicate(String phone) =>
      _dataSource.checkPhoneDuplicate(phone);

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

  @override
  Future<bool> refreshSession() => _dataSource.refreshSession();
}
