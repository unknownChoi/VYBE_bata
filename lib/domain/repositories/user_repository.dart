import 'dart:io';

import 'package:vybe/data/models/user_model.dart';

abstract class UserRepository {
  Future<UserModel?> getUser(String uid);
  Stream<UserModel?> watchUser(String uid);
  Future<void> updateUser(String uid, Map<String, dynamic> data);
  Future<void> setUserProfile({
    required String uid,
    required String name,
    required String phone,
    required String birthDate,
    required String provider,

    /// 'male' | 'female'. 알 수 없으면 null — 필드를 쓰지 않는다.
    String? gender,
  });
  Future<bool> isPhoneDuplicate(String phone);
  Future<String> uploadProfileImage(String uid, File imageFile);
}
