import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:vybe/data/models/club_model.dart';
import 'package:vybe/data/models/search_history_model.dart';
import 'package:vybe/data/repositories/club_repository_impl.dart';
import 'package:vybe/data/repositories/search_history_repository_impl.dart';

part 'search_viewmodel.g.dart';

@riverpod
Future<List<SearchHistoryModel>> searchHistory(Ref ref, String userId) {
  return ref.watch(searchHistoryRepositoryProvider).getSearchHistory(userId);
}

@riverpod
class SearchViewModel extends _$SearchViewModel {
  @override
  AsyncValue<List<ClubModel>> build() => const AsyncData([]);

  Future<void> search(String keyword, {String? userId}) async {
    if (keyword.trim().isEmpty) {
      state = const AsyncData([]);
      return;
    }
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final results =
          await ref.read(clubRepositoryProvider).searchClubs(keyword);
      if (userId != null) {
        await ref
            .read(searchHistoryRepositoryProvider)
            .addSearchHistory(userId, keyword);
        ref.invalidate(searchHistoryProvider(userId));
      }
      return results;
    });
  }

  Future<void> deleteHistory(String userId, String historyId) async {
    await ref
        .read(searchHistoryRepositoryProvider)
        .deleteSearchHistory(userId, historyId);
    ref.invalidate(searchHistoryProvider(userId));
  }

  Future<void> clearHistory(String userId) async {
    await ref
        .read(searchHistoryRepositoryProvider)
        .clearAllSearchHistory(userId);
    ref.invalidate(searchHistoryProvider(userId));
  }

  void clear() => state = const AsyncData([]);
}
