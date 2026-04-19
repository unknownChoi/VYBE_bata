import 'dart:io';

import 'package:vybe/data/models/user_model.dart';

abstract class UserRepository {
  Future<UserModel?> getUser(String uid);
  Stream<UserModel?> watchUser(String uid);
  Future<void> updateUser(String uid, Map<String, dynamic> data);
  Future<bool> isPhoneDuplicate(String phone);
  Future<String> uploadProfileImage(String uid, File imageFile);
}
