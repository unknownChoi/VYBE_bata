import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:vybe/data/datasources/remote/firebase_club_datasource.dart';
import 'package:vybe/data/datasources/remote/firebase_vybe_recommendation_datasource.dart';
import 'package:vybe/domain/repositories/vybe_recommendation_repository.dart';

part 'vybe_recommendation_repository_impl.g.dart';

@Riverpod(keepAlive: true)
VybeRecommendationRepository vybeRecommendationRepository(Ref ref) =>
    _VybeRecommendationRepositoryImpl(
      FirebaseVybeRecommendationDataSource(),
      FirebaseClubDataSource(),
    );

class _VybeRecommendationRepositoryImpl
    implements VybeRecommendationRepository {
  final FirebaseVybeRecommendationDataSource _recDataSource;
  final FirebaseClubDataSource _clubDataSource;

  _VybeRecommendationRepositoryImpl(this._recDataSource, this._clubDataSource);

  @override
  Future<List<VybeRecommendedClub>> getActiveRecommendations() async {
    final recs = await _recDataSource.getActiveRecommendations();
    if (recs.isEmpty) return [];

    final clubs = await _clubDataSource.getClubsByIds(
      recs.map((r) => r.clubId).toList(),
    );
    final byId = {for (final c in clubs) c.clubId: c};

    // rank 순서 유지. 클럽이 없거나 비활성이면 제외.
    final result = <VybeRecommendedClub>[];
    for (final r in recs) {
      final club = byId[r.clubId];
      if (club == null || !club.isActive) continue;
      result.add(VybeRecommendedClub(recommendation: r, club: club));
    }
    return result;
  }
}
