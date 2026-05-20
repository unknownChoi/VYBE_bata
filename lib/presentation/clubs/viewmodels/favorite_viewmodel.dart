import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:vybe/data/repositories/favorite_repository_impl.dart';

part 'favorite_viewmodel.g.dart';

/// 유저 찜 clubId Set — 스트림 1번으로 전체 찜 상태 관리
@riverpod
Stream<Set<String>> favoritedClubIds(Ref ref, String userId) {
  return ref
      .watch(favoriteRepositoryProvider)
      .watchUserFavorites(userId)
      .map((list) => list.map((f) => f.clubId).toSet());
}

/// 낙관적 오버라이드: clubId → true(찜) / false(찜취소)
/// 스트림 업데이트 전까지 UI에 즉시 반영하기 위해 사용
@riverpod
class FavoriteViewModel extends _$FavoriteViewModel {
  @override
  Map<String, bool> build() => {};

  Future<void> toggleFavorite(
      String userId, String clubId, bool currentIsFav) async {
    // 낙관적 UI 즉시 반영
    state = {...state, clubId: !currentIsFav};

    final repo = ref.read(favoriteRepositoryProvider);
    try {
      if (currentIsFav) {
        await repo.removeFavorite(userId, clubId);
      } else {
        await repo.addFavorite(userId, clubId);
      }
    } catch (_) {
      // 실패 시 롤백
      if (ref.mounted) {
        final reverted = Map<String, bool>.from(state)..remove(clubId);
        state = reverted;
      }
      return;
    }

    // 스트림이 업데이트되면 낙관적 오버라이드 제거
    if (ref.mounted) {
      final cleared = Map<String, bool>.from(state)..remove(clubId);
      state = cleared;
    }
  }
}
