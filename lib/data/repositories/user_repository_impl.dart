import 'dart:io';

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:vybe/data/datasources/user_data_source.dart';
import 'package:vybe/data/models/user_model.dart';
import 'package:vybe/domain/repositories/user_repository.dart';

part 'user_repository_impl.g.dart';

@riverpod
UserRepository userRepository(Ref ref) => UserRepositoryImpl(UserDataSource());

class UserRepositoryImpl implements UserRepository {
  final UserDataSource _dataSource;

  UserRepositoryImpl(this._dataSource);

  @override
  Future<UserModel?> getUser(String uid) => _dataSource.getUser(uid);

  @override
  Stream<UserModel?> watchUser(String uid) => _dataSource.watchUser(uid);

  @override
  Future<void> updateUser(String uid, Map<String, dynamic> data) =>
      _dataSource.updateUser(uid, data);

  @override
  Future<void> setUserProfile({
    required String uid,
    required String name,
    required String phone,
    required String birthDate,
    required String provider,
  }) =>
      _dataSource.setUserProfile(
        uid: uid,
        name: name,
        phone: phone,
        birthDate: birthDate,
        provider: provider,
      );

  @override
  Future<bool> isPhoneDuplicate(String phone) =>
      _dataSource.isPhoneDuplicate(phone);

  @override
  Future<String> uploadProfileImage(String uid, File imageFile) =>
      _dataSource.uploadProfileImage(uid, imageFile);
}
