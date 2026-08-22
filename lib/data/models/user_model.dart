import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:vybe/data/models/terms_agreement.dart';

part 'user_model.freezed.dart';

@freezed
abstract class UserModel with _$UserModel {
  const UserModel._();

  const factory UserModel({
    required String uid,
    required String name,
    required String phone,
    required String birthDate,

    /// 'male' | 'female' — 미입력이면 빈 문자열
    required String gender,
    required String profileImageUrl,
    required String provider,
    required bool isVerified,

    /// 약관 동의 기록. 키는 `LegalDoc.name` + [kAgreementAge19].
    /// 동의 기록 도입(2026.08.22) 전에 가입한 유저는 빈 map.
    required Map<String, TermsAgreement> agreements,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _UserModel;

  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return UserModel(
      uid: data['uid'] as String? ?? doc.id,
      name: data['name'] as String? ?? '',
      phone: data['phone'] as String? ?? '',
      birthDate: data['birthDate'] as String? ?? '',
      gender: data['gender'] as String? ?? '',
      profileImageUrl: data['profileImageUrl'] as String? ?? '',
      provider: data['provider'] as String? ?? '',
      isVerified: data['isVerified'] as bool? ?? false,
      agreements: parseAgreements(data['agreements']),
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() => {
    'uid': uid,
    'name': name,
    'phone': phone,
    'birthDate': birthDate,
    'gender': gender,
    'profileImageUrl': profileImageUrl,
    'provider': provider,
    'isVerified': isVerified,
    // agreements 는 일부러 뺐다 — 이 map 을 통째로 다시 쓰면 nested
    // serverTimestamp 가 매번 새로 찍혀 '동의한 시각'이 프로필 저장 시각으로
    // 덮인다. 동의 기록은 setUserProfile 이 가입 때 한 번만 쓴다.
    'updatedAt': FieldValue.serverTimestamp(),
  };
}
