import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

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
        'updatedAt': FieldValue.serverTimestamp(),
      };
}
