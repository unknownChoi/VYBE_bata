import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:vybe/data/datasources/remote/firebase_auth_datasource.dart';
import 'package:vybe/domain/repositories/auth_repository.dart';

part 'auth_repository_impl.g.dart';

@riverpod
AuthRepository authRepository(Ref ref) =>
    AuthRepositoryImpl(FirebaseAuthDataSource());

class AuthRepositoryImpl implements AuthRepository {
  final FirebaseAuthDataSource _dataSource;

  AuthRepositoryImpl(this._dataSource);

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
  Future<String> signInAnonymously() => _dataSource.signInAnonymously();

  @override
  Future<void> deleteUser() => _dataSource.deleteUser();

  @override
  Future<void> signOut() => _dataSource.signOut();
}
