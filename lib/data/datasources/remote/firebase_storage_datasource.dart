import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:vybe/core/utils/firebase_logger.dart';

class FirebaseStorageDataSource {
  final FirebaseStorage _storage;

  FirebaseStorageDataSource() : _storage = FirebaseStorage.instance;

  Future<String> uploadProfileImage(String uid, File imageFile) async {
    logFirebaseAccess(
      file: 'firebase_storage_datasource.dart',
      service: 'Storage(users/$uid/profile.jpg)',
      purpose: '프로필 이미지 업로드',
    );
    final ref = _storage.ref('users/$uid/profile.jpg');
    await ref.putFile(imageFile);
    return ref.getDownloadURL();
  }
}
