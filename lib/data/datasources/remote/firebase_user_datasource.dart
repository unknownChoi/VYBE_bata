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
    String? gender,
  }) async {
    logFirebaseAccess(
      file: 'firebase_user_datasource.dart',
      service: 'Firestore(users/$uid)',
      purpose: '본인인증 완료 후 사용자 프로필 저장',
    );
    final ref = _firestore.collection('users').doc(uid);

    // 가입 시각은 **문서를 처음 만들 때만** 쓸 수 있다.
    //
    // ⚠ Rules의 users update 규칙이 createdAt 변경을 막는데 serverTimestamp()는
    //   매번 새 값이라, 이미 있는 문서에 얹으면 permission-denied가 난다.
    //   반대로 create(문서 없음)에는 그 제한이 없다 → 존재 여부를 보고 가른다.
    //   원래는 onUserCreated 트리거가 채우기로 했는데 그 트리거가 실제로
    //   실행되지 않아(2026.08.18 확인) 가입 시각이 통째로 비어 있었다.
    //   트리거에 맡기지 않고 여기서 확정한다.
    // ⚠ 이미 createdAt 없이 만들어진 문서는 앱에서 못 메운다(위 Rules) —
    //   서버 스크립트로 백필해야 한다.
    final exists = (await ref.get()).exists;

    // uid·provider는 트리거와 항상 같은 값이라 diff에 안 잡혀 통과 —
    // 트리거가 실패한 문서도 메워지도록 그대로 둔다.
    await ref.set({
      'uid': uid,
      'provider': provider,
      'name': name,
      'phone': phone,
      'birthDate': birthDate,
      // 알 수 없으면 필드를 아예 쓰지 않는다 (빈 값 = '미입력'과 구분 불가).
      if (gender != null) 'gender': gender,
      'isVerified': true,
      if (!exists) 'createdAt': FieldValue.serverTimestamp(),
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
