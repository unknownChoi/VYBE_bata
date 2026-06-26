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

/// 입력 중 연관 검색어(클럽 제안). 디바운스는 호출측(화면)에서 처리.
/// searchClubsPage(평점순 상위 8개)를 재사용 — 추가 인프라 없음.
@riverpod
class SearchSuggestionViewModel extends _$SearchSuggestionViewModel {
  @override
  AsyncValue<List<ClubModel>> build() => const AsyncData([]);

  Future<void> fetch(String keyword) async {
    final q = keyword.trim();
    if (q.length < 2) {
      state = const AsyncData([]);
      return;
    }
    state = await AsyncValue.guard(() async {
      final page = await ref
          .read(clubRepositoryProvider)
          .searchClubsPage(q, pageSize: 8);
      return page.clubs;
    });
  }

  void clear() => state = const AsyncData([]);
}

/// 검색 결과 + 페이지네이션 상태 (평점순 서버 페이지네이션).
class SearchResults {
  final List<ClubModel> clubs;
  final Object? cursor;
  final bool hasMore;
  final bool loadingMore;

  const SearchResults({
    required this.clubs,
    required this.cursor,
    required this.hasMore,
    required this.loadingMore,
  });

  static const empty = SearchResults(
    clubs: [],
    cursor: null,
    hasMore: false,
    loadingMore: false,
  );

  SearchResults copyWith({
    List<ClubModel>? clubs,
    Object? cursor,
    bool? hasMore,
    bool? loadingMore,
  }) {
    return SearchResults(
      clubs: clubs ?? this.clubs,
      cursor: cursor ?? this.cursor,
      hasMore: hasMore ?? this.hasMore,
      loadingMore: loadingMore ?? this.loadingMore,
    );
  }
}

@riverpod
class SearchViewModel extends _$SearchViewModel {
  static const int _pageSize = 10;
  String _keyword = '';

  @override
  AsyncValue<SearchResults> build() => const AsyncData(SearchResults.empty);

  Future<void> search(String keyword, {String? userId}) async {
    _keyword = keyword.trim();
    if (_keyword.isEmpty) {
      state = const AsyncData(SearchResults.empty);
      return;
    }
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final page = await ref
          .read(clubRepositoryProvider)
          .searchClubsPage(_keyword, pageSize: _pageSize);
      return SearchResults(
        clubs: page.clubs,
        cursor: page.cursor,
        hasMore: page.hasMore,
        loadingMore: false,
      );
    });

    // 검색 기록 저장은 부가기능 — 실패해도 검색 결과를 막지 않음.
    if (userId != null && state.hasValue) {
      try {
        await ref
            .read(searchHistoryRepositoryProvider)
            .addSearchHistory(userId, _keyword);
        if (ref.mounted) ref.invalidate(searchHistoryProvider(userId));
      } catch (e) {
        // ignore: avoid_print
        print('[Search] 검색기록 저장 실패(무시): $e');
      }
    }
  }

  /// 다음 페이지(10개) 추가 로드.
  Future<void> loadMore() async {
    final cur = state.value;
    if (cur == null || !cur.hasMore || cur.loadingMore) return;

    state = AsyncData(cur.copyWith(loadingMore: true));
    try {
      final page = await ref.read(clubRepositoryProvider).searchClubsPage(
            _keyword,
            cursor: cur.cursor,
            pageSize: _pageSize,
          );
      state = AsyncData(cur.copyWith(
        clubs: [...cur.clubs, ...page.clubs],
        cursor: page.cursor,
        hasMore: page.hasMore,
        loadingMore: false,
      ));
    } catch (_) {
      state = AsyncData(cur.copyWith(loadingMore: false));
    }
  }

  Future<void> deleteHistory(String userId, String historyId) async {
    await ref
        .read(searchHistoryRepositoryProvider)
        .deleteSearchHistory(userId, historyId);
    if (!ref.mounted) return;
    ref.invalidate(searchHistoryProvider(userId));
  }

  Future<void> clearHistory(String userId) async {
    await ref
        .read(searchHistoryRepositoryProvider)
        .clearAllSearchHistory(userId);
    if (!ref.mounted) return;
    ref.invalidate(searchHistoryProvider(userId));
  }

  void clear() => state = const AsyncData(SearchResults.empty);
}
