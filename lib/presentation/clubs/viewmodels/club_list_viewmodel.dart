import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:vybe/data/models/club_model.dart';
import 'package:vybe/data/repositories/club_repository_impl.dart';

part 'club_list_viewmodel.g.dart';

/// 활성 클럽 목록 실시간 스트림
@riverpod
Stream<List<ClubModel>> clubList(Ref ref) {
  return ref.watch(clubRepositoryProvider).watchActiveClubs();
}

/// 키워드 검색
@riverpod
class ClubSearchViewModel extends _$ClubSearchViewModel {
  @override
  AsyncValue<List<ClubModel>> build() => const AsyncData([]);

  Future<void> search(String keyword) async {
    if (keyword.trim().isEmpty) {
      state = const AsyncData([]);
      return;
    }
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref.read(clubRepositoryProvider).searchClubs(keyword),
    );
  }

  void clear() => state = const AsyncData([]);
}
