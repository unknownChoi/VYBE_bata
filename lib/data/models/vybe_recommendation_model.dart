import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'vybe_recommendation_model.freezed.dart';

/// vybe 추천 페이지 큐레이션 항목.
/// clubs 컬렉션을 참조(clubId)하고, 페이지 전용 에디토리얼 필드만 보관한다.
/// 클럽 기본 정보(이름/평점/영업시간 등)는 clubId로 clubs에서 조인해 사용.
@freezed
abstract class VybeRecommendationModel with _$VybeRecommendationModel {
  const VybeRecommendationModel._();

  const factory VybeRecommendationModel({
    required String recId,
    required String clubId,
    required int rank, // 1 = featured(NO.1 PICK)
    required int match, // VYBE 매치 %
    required String reason, // 큐레이터 노트
    @Default([]) List<String> tags, // 큐레이션 태그 override(비면 club.tags 사용)
    required DateTime weekOf, // 주간 식별(매주 화요일 업데이트)
    required bool isActive, // 노출 여부
    required DateTime createdAt,
  }) = _VybeRecommendationModel;

  factory VybeRecommendationModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return VybeRecommendationModel(
      recId: data['recId'] as String? ?? doc.id,
      clubId: data['clubId'] as String? ?? '',
      rank: (data['rank'] as num?)?.toInt() ?? 0,
      match: (data['match'] as num?)?.toInt() ?? 0,
      reason: data['reason'] as String? ?? '',
      tags: List<String>.from(data['tags'] as List? ?? []),
      weekOf: (data['weekOf'] as Timestamp?)?.toDate() ?? DateTime.now(),
      isActive: data['isActive'] as bool? ?? false,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }
}
