import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:vybe/data/models/club_model.dart';
import 'package:vybe/data/models/search_history_model.dart';
import 'package:vybe/data/models/search_trend_model.dart';
import 'package:vybe/data/repositories/club_repository_impl.dart';
import 'package:vybe/data/repositories/search_history_repository_impl.dart';
import 'package:vybe/data/repositories/search_trend_repository_impl.dart';

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

  /// 검색어 전체 매칭 수(로드된 페이지 수와 무관). 메타 행 "검색결과 N" 표시용.
  final int totalCount;

  const SearchResults({
    required this.clubs,
    required this.cursor,
    required this.hasMore,
    required this.loadingMore,
    this.totalCount = 0,
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
    int? totalCount,
  }) {
    return SearchResults(
      clubs: clubs ?? this.clubs,
      cursor: cursor ?? this.cursor,
      hasMore: hasMore ?? this.hasMore,
      loadingMore: loadingMore ?? this.loadingMore,
      totalCount: totalCount ?? this.totalCount,
    );
  }
}

@riverpod
class SearchViewModel extends _$SearchViewModel {
  static const int _pageSize = 10;
  String _keyword = '';

  @override
  AsyncValue<SearchResults> build() => const AsyncData(SearchResults.empty);

  Future<void> search(
    String keyword, {
    String? userId,
    SearchSource source = SearchSource.input,
  }) async {
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
        totalCount: page.totalCount,
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
        debugPrint('[Search] 검색기록 저장 실패(무시): $e');
      }
      logSearch(userId: userId, keyword: _keyword, source: source);
    }
  }

  /// 인기 검색어 집계용 로그 기록. 부가기능이라 await 하지 않고 실패도 무시한다.
  ///
  /// [SearchViewModel.search]를 거치지 않는 유입(지도 모드 제출, 연관 검색어에서
  /// 클럽 상세로 직행)에서는 화면이 직접 호출한다.
  void logSearch({
    required String userId,
    required String keyword,
    required SearchSource source,
  }) {
    ref
        .read(searchTrendRepositoryProvider)
        .logSearch(userId: userId, keyword: keyword, source: source)
        .catchError((Object e) {
      debugPrint('[Search] 검색로그 기록 실패(무시): $e');
    });
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
        totalCount: page.totalCount,
      ));
    } catch (_) {
      state = AsyncData(cur.copyWith(loadingMore: false));
    }
  }

  /// 최근 검색어 개별 삭제 → 목록 갱신.
  Future<void> deleteHistory(String userId, String historyId) async {
    // 검색 화면은 이 VM을 watch하지 않고 read로만 호출한다 → autoDispose가
    // await 사이에 VM을 버리면 아래 invalidate가 실행되지 않아(ref.mounted=false)
    // Firestore에선 지워졌는데 칩은 그대로 남는다. 작업 동안만 살려둔다.
    final link = ref.keepAlive();
    try {
      await ref
          .read(searchHistoryRepositoryProvider)
          .deleteSearchHistory(userId, historyId);
      ref.invalidate(searchHistoryProvider(userId));
    } finally {
      link.close();
    }
  }

  /// 최근 검색어 전체 삭제. 성공 여부를 반환한다 (화면에서 토스트 문구 분기용).
  Future<bool> clearHistory(String userId) async {
    // deleteHistory와 같은 이유로 작업 동안 VM을 살려둔다.
    final link = ref.keepAlive();
    try {
      await ref
          .read(searchHistoryRepositoryProvider)
          .clearAllSearchHistory(userId);
      ref.invalidate(searchHistoryProvider(userId));
      return true;
    } catch (e) {
      debugPrint('[Search] 검색기록 전체 삭제 실패: $e');
      return false;
    } finally {
      link.close();
    }
  }

  void clear() => state = const AsyncData(SearchResults.empty);
}
