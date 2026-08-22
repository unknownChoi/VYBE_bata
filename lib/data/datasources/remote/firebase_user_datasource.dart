import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:vybe/core/utils/firebase_logger.dart';
import 'package:vybe/data/datasources/remote/firestore_paths.dart';
import 'package:vybe/data/models/terms_agreement.dart';
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
    final doc = await _firestore
        .collection(FirestorePaths.users)
        .doc(uid)
        .get();
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
        .collection(FirestorePaths.users)
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
    await _firestore.collection(FirestorePaths.users).doc(uid).update({
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
    Map<String, TermsAgreementInput>? agreements,
  }) async {
    logFirebaseAccess(
      file: 'firebase_user_datasource.dart',
      service: 'Firestore(users/$uid)',
      purpose: '본인인증 완료 후 사용자 프로필 저장',
    );
    final ref = _firestore.collection(FirestorePaths.users).doc(uid);

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
      // 약관 동의 기록 — 가입(신규 프로필 저장) 때만 넘어온다.
      // 재로그인 경로는 null 이라 이미 저장된 기록을 건드리지 않는다.
      //
      // ⚠ agreedAt 은 **중첩 map 안의** serverTimestamp 다. Firestore 는
      //   중첩 map 안의 sentinel 은 허용하지만 **배열 안은 거부**한다 —
      //   항목을 list 로 바꾸지 말 것.
      if (agreements != null)
        'agreements': {
          for (final e in agreements.entries)
            e.key: {
              'agreed': e.value.agreed,
              'version': e.value.version,
              'agreedAt': FieldValue.serverTimestamp(),
            },
        },
      if (!exists) 'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  /// 약관 동의 기록 **한 건만** 갈아 끼운다 — 설정 화면의 마케팅 수신 켬/끔.
  ///
  /// ⚠ 점 표기(`agreements.marketing`)를 쓰는 이유 — [setUserProfile] 처럼
  ///   `agreements` map 을 통째로 얹으면 손대지 않은 항목의 `agreedAt` 까지
  ///   새 `serverTimestamp` 로 덮여 '동의한 시각'이 오늘로 밀린다.
  ///   필수 약관 동의 시각은 분쟁 시 근거라 절대 흔들면 안 된다.
  ///
  /// 철회(`agreed: false`)도 같은 자리에 기록한다 — 값만 남고 이력은 안 남는다
  /// ([TermsAgreement] 주석 참고).
  Future<void> setAgreement({
    required String uid,
    required String key,
    required bool agreed,
    required String version,
  }) async {
    logFirebaseAccess(
      file: 'firebase_user_datasource.dart',
      service: 'Firestore(users/$uid) [agreements.$key]',
      purpose: '약관 동의 항목 변경(마케팅 수신 동의 켬/끔)',
    );
    await _firestore.collection(FirestorePaths.users).doc(uid).update({
      // 중첩 map 안의 serverTimestamp 는 허용된다(배열 안만 거부).
      'agreements.$key': {
        'agreed': agreed,
        'version': version,
        'agreedAt': FieldValue.serverTimestamp(),
      },
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<bool> isPhoneDuplicate(String phone) async {
    logFirebaseAccess(
      file: 'firebase_user_datasource.dart',
      service: 'Firestore(users) [where phone=$phone]',
      purpose: '전화번호 중복 확인',
    );
    final snapshot = await _firestore
        .collection(FirestorePaths.users)
        .where('phone', isEqualTo: phone)
        .limit(1)
        .get();
    return snapshot.docs.isNotEmpty;
  }
}
