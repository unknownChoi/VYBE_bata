import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:vybe/core/utils/firebase_logger.dart';
import 'package:vybe/data/models/folder_model.dart';

class FirebaseFolderDataSource {
  final FirebaseFirestore _firestore;

  FirebaseFolderDataSource() : _firestore = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> _col(String userId) =>
      _firestore.collection('users').doc(userId).collection('folders');

  Stream<List<FolderModel>> watchFolders(String userId) {
    logFirebaseAccess(
      file: 'firebase_folder_datasource.dart',
      service: 'Firestore(users/$userId/folders) [Stream]',
      purpose: '사용자 찜 그룹 목록 실시간 구독',
    );
    return _col(userId)
        .orderBy('order')
        .snapshots()
        .map((s) => s.docs.map(FolderModel.fromFirestore).toList());
  }

  Future<String> addFolder(
    String userId, {
    required String name,
    required String emoji,
    required int order,
  }) async {
    logFirebaseAccess(
      file: 'firebase_folder_datasource.dart',
      service: 'Firestore(users/$userId/folders)',
      purpose: '찜 그룹 생성 (name=$name)',
    );
    final ref = await _col(userId).add({
      'name': name,
      'emoji': emoji,
      'order': order,
      'createdAt': FieldValue.serverTimestamp(),
    });
    return ref.id;
  }

  Future<void> deleteFolder(String userId, String folderId) async {
    logFirebaseAccess(
      file: 'firebase_folder_datasource.dart',
      service: 'Firestore(users/$userId/folders/$folderId)',
      purpose: '찜 그룹 삭제',
    );
    await _col(userId).doc(folderId).delete();
  }
}
