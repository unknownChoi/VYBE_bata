import 'package:vybe/data/models/club_model.dart';
import 'package:vybe/data/models/vybe_recommendation_model.dart';

/// 큐레이션(VybeRecommendationModel) + 클럽 기본정보(ClubModel) 조인 결과.
/// presentation 레이어는 이 엔티티만 소비한다.
class VybeRecommendedClub {
  final VybeRecommendationModel recommendation;
  final ClubModel club;

  const VybeRecommendedClub({
    required this.recommendation,
    required this.club,
  });

  int get rank => recommendation.rank;
  int get match => recommendation.match;
  String get reason => recommendation.reason;
  bool get isFeatured => recommendation.rank == 1;

  /// 큐레이션 태그 override가 있으면 그것, 없으면 클럽 태그.
  List<String> get tags =>
      recommendation.tags.isNotEmpty ? recommendation.tags : club.tags;

  bool get isOpen => club.operatingHours.today.isCurrentlyOpen;
}

abstract interface class VybeRecommendationRepository {
  /// 활성 추천 목록(rank 오름차순). featured = rank 1.
  Future<List<VybeRecommendedClub>> getActiveRecommendations();
}
