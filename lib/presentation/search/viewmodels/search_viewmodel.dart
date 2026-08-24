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

/// 연관 검색어(검색엔진) 결과 + 그 결과가 어느 검색어의 것인지.
///
/// 검색어를 같이 들고 다니는 이유 — 화면이 "지금 입력된 검색어로 엔진이 이미
/// 돌았는지"를 알아야 그 전까지 엔터(검색 실행)를 막을 수 있다.
/// 목록만 들고 있으면 이전 검색어의 결과와 구분이 안 된다.
class SearchSuggestions {
  /// 이 결과가 속한 검색어(trim). 빈 문자열이면 아직 아무것도 조회하지 않은 상태.
  final String keyword;
  final List<ClubModel> clubs;

  /// [keyword]로 엔진이 도는 중.
  final bool loading;

  const SearchSuggestions({
    required this.keyword,
    required this.clubs,
    required this.loading,
  });

  static const empty = SearchSuggestions(
    keyword: '',
    clubs: [],
    loading: false,
  );

  /// [query]로 엔진이 이미 돌아 결과가 확정된 상태인지.
  /// 실패해서 빈 목록으로 확정된 경우도 true — 조회가 끝났다는 뜻이다.
  bool isSettledFor(String query) => !loading && keyword == query;
}

/// 입력 중 연관 검색어(클럽 제안). 디바운스는 호출측(화면)에서 처리.
/// searchClubsPage(관련도순 상위 8개)를 재사용 — 추가 인프라 없음.
@riverpod
class SearchSuggestionViewModel extends _$SearchSuggestionViewModel {
  /// 연관 검색어 노출 개수.
  static const int _suggestionCount = 8;

  @override
  SearchSuggestions build() => SearchSuggestions.empty;

  Future<void> fetch(String keyword) async {
    final q = keyword.trim();
    // 2자 미만은 엔진을 태우지 않는다 — 조회한 셈 치고 **확정** 상태로 둔다.
    // 안 그러면 한 글자 검색어가 영영 '대기 중'이라 엔터가 먹통이 된다.
    if (q.length < 2) {
      state = SearchSuggestions(keyword: q, clubs: const [], loading: false);
      return;
    }
    state = SearchSuggestions(keyword: q, clubs: const [], loading: true);

    List<ClubModel> clubs;
    try {
      final page = await ref
          .read(clubRepositoryProvider)
          .searchClubsPage(q, pageSize: _suggestionCount);
      // 조합 중 자모('홍대 ㅇ')는 엔진이 못 걸러 후보를 넉넉히 받아 온 뒤
      // repository가 초성으로 거른다 → 여기서 목록 길이를 다시 제한한다.
      clubs = page.clubs.take(_suggestionCount).toList();
    } catch (e) {
      // 실패해도 **확정**으로 끝낸다 — 엔진이 죽었다고 검색 자체를 막으면
      // 사용자가 결과 화면에 영영 못 간다.
      debugPrint('[Search] 연관 검색어 조회 실패(무시): $e');
      clubs = const [];
    }
    // 응답 전에 화면을 떠나면 autoDispose로 provider가 이미 버려진다 → 결과 폐기.
    if (!ref.mounted) return;
    // 그 사이 다른 검색어로 다시 조회했으면 늦게 온 응답이 최신을 덮지 않게 버린다.
    if (state.keyword != q) return;
    state = SearchSuggestions(keyword: q, clubs: clubs, loading: false);
  }

  void clear() => state = SearchSuggestions.empty;
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
    final result = await AsyncValue.guard(() async {
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
    // 응답 전에 화면을 떠나면 autoDispose로 VM이 이미 버려진다 → 결과 폐기.
    if (!ref.mounted) return;
    // 그 사이 다른 검색어로 다시 검색했으면 늦게 온 응답은 버린다
    // (먼저 던진 요청이 늦게 도착해 최신 결과를 덮어쓰는 것 방지).
    if (_keyword != keyword.trim()) return;
    state = result;

    // 검색 기록 저장은 부가기능 — 실패해도 검색 결과를 막지 않음.
    if (userId != null && result.hasValue) {
      try {
        await ref
            .read(searchHistoryRepositoryProvider)
            .addSearchHistory(userId, _keyword);
        if (ref.mounted) ref.invalidate(searchHistoryProvider(userId));
      } catch (e) {
        debugPrint('[Search] 검색기록 저장 실패(무시): $e');
      }
      // logSearch도 ref를 쓴다 — 버려진 뒤면 호출 자체가 던진다.
      if (ref.mounted) {
        logSearch(userId: userId, keyword: _keyword, source: source);
      }
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
      if (!ref.mounted) return;
      state = AsyncData(cur.copyWith(
        clubs: [...cur.clubs, ...page.clubs],
        cursor: page.cursor,
        hasMore: page.hasMore,
        loadingMore: false,
        totalCount: page.totalCount,
      ));
    } catch (_) {
      if (!ref.mounted) return;
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
