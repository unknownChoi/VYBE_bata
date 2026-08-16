import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:vybe/core/utils/firebase_logger.dart';
import 'package:vybe/data/models/user_model.dart';

class FirebaseUserDataSource {
  final FirebaseFirestore _firestore;

  FirebaseUserDataSource() : _firestore = FirebaseFirestore.instance;

  Future<UserModel?> getUser(String uid) async {
    logFirebaseAccess(
      file: 'firebase_user_datasource.dart',
      service: 'Firestore(users/$uid)',
      purpose: '사용자 정보 조회',
    );
    final doc = await _firestore.collection('users').doc(uid).get();
    if (!doc.exists) return null;
    return UserModel.fromFirestore(doc);
  }

  Stream<UserModel?> watchUser(String uid) {
    logFirebaseAccess(
      file: 'firebase_user_datasource.dart',
      service: 'Firestore(users/$uid) [Stream]',
      purpose: '사용자 정보 실시간 구독',
    );
    return _firestore
        .collection('users')
        .doc(uid)
        .snapshots()
        .map((doc) => doc.exists ? UserModel.fromFirestore(doc) : null);
  }

  Future<void> updateUser(String uid, Map<String, dynamic> data) async {
    logFirebaseAccess(
      file: 'firebase_user_datasource.dart',
      service: 'Firestore(users/$uid)',
      purpose: '사용자 정보 업데이트',
    );
    await _firestore.collection('users').doc(uid).update({
      ...data,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> setUserProfile({
    required String uid,
    required String name,
    required String phone,
    required String birthDate,
    required String provider,
  }) async {
    logFirebaseAccess(
      file: 'firebase_user_datasource.dart',
      service: 'Firestore(users/$uid)',
      purpose: '본인인증 완료 후 사용자 프로필 저장',
    );
    // ⚠ createdAt은 여기서 쓰지 않는다 — Rules의 users update 규칙이
    //   uid/provider/createdAt 변경을 막는데, serverTimestamp()는 매번 새 값이라
    //   문서가 이미 있으면(=onUserCreated 트리거가 로그인 직후 만들어 둔 경우)
    //   permission-denied가 난다. createdAt은 onUserCreated가 채운다.
    //   uid·provider는 트리거와 항상 같은 값이라 diff에 안 잡혀 통과 —
    //   트리거가 실패한 문서도 메워지도록 그대로 둔다.
    await _firestore.collection('users').doc(uid).set({
      'uid': uid,
      'provider': provider,
      'name': name,
      'phone': phone,
      'birthDate': birthDate,
      'isVerified': true,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  Future<bool> isPhoneDuplicate(String phone) async {
    logFirebaseAccess(
      file: 'firebase_user_datasource.dart',
      service: 'Firestore(users) [where phone=$phone]',
      purpose: '전화번호 중복 확인',
    );
    final snapshot = await _firestore
        .collection('users')
        .where('phone', isEqualTo: phone)
        .limit(1)
        .get();
    return snapshot.docs.isNotEmpty;
  }
}
