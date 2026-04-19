import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:vybe/data/models/favorite_model.dart';
import 'package:vybe/data/repositories/favorite_repository_impl.dart';

part 'favorite_viewmodel.g.dart';

/// 유저 찜 목록 실시간 스트림
@riverpod
Stream<List<FavoriteModel>> favoriteList(Ref ref, String userId) {
  return ref.watch(favoriteRepositoryProvider).watchUserFavorites(userId);
}

/// 특정 클럽 찜 여부
@riverpod
Future<bool> isFavorite(Ref ref, String userId, String clubId) {
  return ref.watch(favoriteRepositoryProvider).isFavorite(userId, clubId);
}

@riverpod
class FavoriteViewModel extends _$FavoriteViewModel {
  @override
  AsyncValue<void> build() => const AsyncData(null);

  Future<void> toggleFavorite(String userId, String clubId) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final repo = ref.read(favoriteRepositoryProvider);
      final already = await repo.isFavorite(userId, clubId);
      if (already) {
        await repo.removeFavorite(userId, clubId);
      } else {
        await repo.addFavorite(userId, clubId);
      }
      ref.invalidate(isFavoriteProvider(userId, clubId));
    });
  }
}
