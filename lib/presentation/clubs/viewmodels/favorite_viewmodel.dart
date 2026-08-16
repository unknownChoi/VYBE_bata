import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:vybe/core/providers/auth_providers.dart';
import 'package:vybe/core/utils/firebase_guard.dart';
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

/// 화면이 실제로 그릴 찜 clubId Set.
///
/// Firestore 스트림([favoritedClubIds])에 낙관적 오버라이드([FavoriteViewModel])를
/// 덮어 만든 값 — 서버 반영 전에도 하트가 즉시 바뀐다.
/// 비로그인이면 항상 빈 Set.
///
/// 찜 목록을 보여주는 화면은 이 provider 하나만 watch 하면 된다.
@riverpod
Set<String> mergedFavoriteIds(Ref ref) {
  final uid = ref.watch(currentUidProvider);
  if (uid == null) return const <String>{};

  final streamIds =
      ref.watch(favoritedClubIdsProvider(uid)).asData?.value ?? <String>{};
  final optimistic = ref.watch(favoriteViewModelProvider);

  return Set<String>.from(streamIds)
    ..addAll(optimistic.entries.where((e) => e.value).map((e) => e.key))
    ..removeAll(optimistic.entries.where((e) => !e.value).map((e) => e.key));
}

/// 낙관적 오버라이드: clubId → true(찜) / false(찜취소)
/// 스트림 업데이트 전까지 UI에 즉시 반영하기 위해 사용
@riverpod
class FavoriteViewModel extends _$FavoriteViewModel {
  @override
  Map<String, bool> build() => {};

  /// 찜 토글. 같은 클럽 요청이 진행 중이면 **아무것도 하지 않는다**.
  ///
  /// 가드가 없으면 두 가지로 깨진다.
  /// - **반대 방향 연타** — 추가가 서버 ack를 기다리는 동안 들어온 해제가
  ///   별도 왕복을 만든다. 해제의 where 쿼리가 아직 커밋 안 된 문서를 못 봐서
  ///   0건 삭제로 끝나고, DB는 찜 상태인데 유저의 마지막 의도는 해제가 된다.
  /// - **같은 프레임 연타** — 호출부가 `isFavorited`를 build 시점 값으로
  ///   캡처하므로 리빌드 전 두 번 누르면 둘 다 추가로 들어가고,
  ///   `addFavorite`이 랜덤 doc id라 문서가 2개 생겨 `favoriteCount`가 부푼다.
  ///
  /// 낙관적 오버라이드까지 통째로 [FirebaseGuard.dedupe] 안에 두는 이유 —
  /// 밖에 두면 무시된 탭이 하트만 뒤집어 놓고 요청은 안 나가서 화면이
  /// 한 번 깜빡였다가 스트림 값으로 되돌아온다.
  Future<void> toggleFavorite(String userId, String clubId, bool currentIsFav) {
    return FirebaseGuard.dedupe<void>('favorite:$userId:$clubId', () async {
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
    });
  }
}
