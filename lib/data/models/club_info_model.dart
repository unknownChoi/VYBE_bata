import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'club_info_model.freezed.dart';

@freezed
abstract class ClubInfoModel with _$ClubInfoModel {
  const ClubInfoModel._();

  const factory ClubInfoModel({
    @Default([]) List<Map<String, dynamic>> nearbySubways,
    @Default('') String openChatUrl,
    @Default([]) List<String> cautions,

    /// 편의시설 키 목록 (예: ["parking","restroom"]).
    /// 라벨·아이콘 대응은 앱의 `ClubFacility` — 여기엔 영문 키만 저장한다.
    @Default([]) List<String> facilities,
    required DateTime updatedAt,
  }) = _ClubInfoModel;

  factory ClubInfoModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ClubInfoModel(
      nearbySubways: (data['nearbySubways'] as List? ?? [])
          .map((e) => Map<String, dynamic>.from(e as Map))
          .toList(),
      openChatUrl: data['openChatUrl'] as String? ?? '',
      cautions: List<String>.from(data['cautions'] as List? ?? []),
      facilities: List<String>.from(data['facilities'] as List? ?? []),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }
}
