import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:vybe/data/models/user_model.dart';

class UserDataSource {
  final FirebaseFirestore _firestore;
  final FirebaseStorage _storage;

  UserDataSource()
      : _firestore = FirebaseFirestore.instance,
        _storage = FirebaseStorage.instance;

  Future<UserModel?> getUser(String uid) async {
    final doc = await _firestore.collection('users').doc(uid).get();
    if (!doc.exists) return null;
    return UserModel.fromFirestore(doc);
  }

  Stream<UserModel?> watchUser(String uid) {
    return _firestore
        .collection('users')
        .doc(uid)
        .snapshots()
        .map((doc) => doc.exists ? UserModel.fromFirestore(doc) : null);
  }

  Future<void> updateUser(String uid, Map<String, dynamic> data) async {
    await _firestore.collection('users').doc(uid).update({
      ...data,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<bool> isPhoneDuplicate(String phone) async {
    final snapshot = await _firestore
        .collection('users')
        .where('phone', isEqualTo: phone)
        .limit(1)
        .get();
    return snapshot.docs.isNotEmpty;
  }

  Future<String> uploadProfileImage(String uid, File imageFile) async {
    final ref = _storage.ref('users/$uid/profile.jpg');
    await ref.putFile(imageFile);
    return ref.getDownloadURL();
  }
}
