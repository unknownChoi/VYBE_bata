import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:vybe/data/models/club_model.dart';
import 'package:vybe/data/repositories/club_repository_impl.dart';

part 'home_nearby_viewmodel.g.dart';

@riverpod
Future<List<ClubModel>> homeNearbyClubs(Ref ref) async {
  final all = await ref.read(clubRepositoryProvider).getClubsByArea('홍대');
  return all.where((c) => c.isVybeRecommended).take(5).toList();
}
