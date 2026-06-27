import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:vybe/data/repositories/vybe_recommendation_repository_impl.dart';
import 'package:vybe/domain/repositories/vybe_recommendation_repository.dart';

part 'vybe_recommend_viewmodel.g.dart';

/// vybe 추천 페이지 데이터. rank 오름차순 활성 추천 목록.
/// 첫 항목(rank 1) = featured 히어로, 나머지 = 순위 리스트.
@riverpod
class VybeRecommendViewModel extends _$VybeRecommendViewModel {
  @override
  Future<List<VybeRecommendedClub>> build() {
    return ref
        .watch(vybeRecommendationRepositoryProvider)
        .getActiveRecommendations();
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref
          .read(vybeRecommendationRepositoryProvider)
          .getActiveRecommendations(),
    );
  }
}
