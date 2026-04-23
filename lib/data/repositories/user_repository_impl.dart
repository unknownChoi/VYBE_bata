import 'dart:io';

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:vybe/data/datasources/remote/firebase_storage_datasource.dart';
import 'package:vybe/data/datasources/remote/firebase_user_datasource.dart';
import 'package:vybe/data/models/user_model.dart';
import 'package:vybe/domain/repositories/user_repository.dart';

part 'user_repository_impl.g.dart';

@riverpod
UserRepository userRepository(Ref ref) => UserRepositoryImpl(
      FirebaseUserDataSource(),
      FirebaseStorageDataSource(),
    );

class UserRepositoryImpl implements UserRepository {
  final FirebaseUserDataSource _userDataSource;
  final FirebaseStorageDataSource _storageDataSource;

  UserRepositoryImpl(this._userDataSource, this._storageDataSource);

  @override
  Future<UserModel?> getUser(String uid) => _userDataSource.getUser(uid);

  @override
  Stream<UserModel?> watchUser(String uid) => _userDataSource.watchUser(uid);

  @override
  Future<void> updateUser(String uid, Map<String, dynamic> data) =>
      _userDataSource.updateUser(uid, data);

  @override
  Future<void> setUserProfile({
    required String uid,
    required String name,
    required String phone,
    required String birthDate,
    required String provider,
  }) =>
      _userDataSource.setUserProfile(
        uid: uid,
        name: name,
        phone: phone,
        birthDate: birthDate,
        provider: provider,
      );

  @override
  Future<bool> isPhoneDuplicate(String phone) =>
      _userDataSource.isPhoneDuplicate(phone);

  @override
  Future<String> uploadProfileImage(String uid, File imageFile) =>
      _storageDataSource.uploadProfileImage(uid, imageFile);
}
