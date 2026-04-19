import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'club_info_model.freezed.dart';

@freezed
abstract class ClubInfoModel with _$ClubInfoModel {
  const ClubInfoModel._();

  const factory ClubInfoModel({
    required String operatingHours,
    required String parking,
    required String dressCode,
    required String ageLimit,
    required List<String> sns,
    required DateTime updatedAt,
  }) = _ClubInfoModel;

  factory ClubInfoModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ClubInfoModel(
      operatingHours: data['operatingHours'] as String? ?? '',
      parking: data['parking'] as String? ?? '',
      dressCode: data['dressCode'] as String? ?? '',
      ageLimit: data['ageLimit'] as String? ?? '',
      sns: List<String>.from(data['sns'] as List? ?? []),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }
}
