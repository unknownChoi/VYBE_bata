import 'dart:io';

import 'package:vybe/data/models/terms_agreement.dart';
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

    /// 약관 동의 기록. 키는 `LegalDoc.name` + `kAgreementAge19`.
    /// null(재로그인)이면 이미 저장된 기록을 그대로 둔다.
    Map<String, TermsAgreementInput>? agreements,
  });

  /// 동의 항목 하나만 바꾼다(설정 화면의 마케팅 수신 켬/끔).
  /// [key] 는 `LegalDoc.name`, [version] 은 그 문서의 개정일.
  /// 다른 항목의 동의 시각은 건드리지 않는다.
  Future<void> setAgreement({
    required String uid,
    required String key,
    required bool agreed,
    required String version,
  });
  Future<bool> isPhoneDuplicate(String phone);
  Future<String> uploadProfileImage(String uid, File imageFile);
}
