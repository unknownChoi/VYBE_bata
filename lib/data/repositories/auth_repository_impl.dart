import 'package:firebase_auth/firebase_auth.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:vybe/data/datasources/auth_data_source.dart';
import 'package:vybe/domain/repositories/auth_repository.dart';

part 'auth_repository_impl.g.dart';

@riverpod
AuthRepository authRepository(Ref ref) => AuthRepositoryImpl(AuthDataSource());

class AuthRepositoryImpl implements AuthRepository {
  final AuthDataSource _dataSource;

  AuthRepositoryImpl(this._dataSource);

  @override
  Stream<User?> get authStateChanges => _dataSource.authStateChanges;

  @override
  User? get currentUser => _dataSource.currentUser;

  @override
  Future<({String customToken, bool isNewUser})> kakaoLogin(
          String accessToken) =>
      _dataSource.kakaoLogin(accessToken);

  @override
  Future<({String customToken, bool isNewUser})> naverLogin(
          String accessToken) =>
      _dataSource.naverLogin(accessToken);

  @override
  Future<UserCredential> signInWithCustomToken(String customToken) =>
      _dataSource.signInWithCustomToken(customToken);

  @override
  Future<bool> userExists(String uid) => _dataSource.userExists(uid);

  @override
  Future<bool> verifyIdentity(String impUid) =>
      _dataSource.verifyIdentity(impUid);

  @override
  Future<void> deleteUser() => _dataSource.deleteUser();

  @override
  Future<void> signOut() => _dataSource.signOut();
}
