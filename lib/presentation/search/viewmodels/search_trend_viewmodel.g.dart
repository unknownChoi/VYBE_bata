// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'search_trend_viewmodel.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// 실시간 인기 검색어 스냅샷.
///
/// 서버 갱신 주기는 2시간(20:00~09:00은 1시간)이라 세션 중 재조회 의미가 적다
/// → keepAlive. 강제 갱신이 필요하면 invalidate.

@ProviderFor(searchTrends)
final searchTrendsProvider = SearchTrendsProvider._();

/// 실시간 인기 검색어 스냅샷.
///
/// 서버 갱신 주기는 2시간(20:00~09:00은 1시간)이라 세션 중 재조회 의미가 적다
/// → keepAlive. 강제 갱신이 필요하면 invalidate.

final class SearchTrendsProvider
    extends
        $FunctionalProvider<
          AsyncValue<SearchTrendSnapshot>,
          SearchTrendSnapshot,
          FutureOr<SearchTrendSnapshot>
        >
    with
        $FutureModifier<SearchTrendSnapshot>,
        $FutureProvider<SearchTrendSnapshot> {
  /// 실시간 인기 검색어 스냅샷.
  ///
  /// 서버 갱신 주기는 2시간(20:00~09:00은 1시간)이라 세션 중 재조회 의미가 적다
  /// → keepAlive. 강제 갱신이 필요하면 invalidate.
  SearchTrendsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'searchTrendsProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$searchTrendsHash();

  @$internal
  @override
  $FutureProviderElement<SearchTrendSnapshot> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<SearchTrendSnapshot> create(Ref ref) {
    return searchTrends(ref);
  }
}

String _$searchTrendsHash() => r'84ffe8aca573ec9d6d73f45691fd03ef56d7175c';

/// 인기 해시태그. 서버 갱신 주기 4시간(20:00~09:00은 1시간).

@ProviderFor(popularHashtags)
final popularHashtagsProvider = PopularHashtagsProvider._();

/// 인기 해시태그. 서버 갱신 주기 4시간(20:00~09:00은 1시간).

final class PopularHashtagsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<SearchHashtagModel>>,
          List<SearchHashtagModel>,
          FutureOr<List<SearchHashtagModel>>
        >
    with
        $FutureModifier<List<SearchHashtagModel>>,
        $FutureProvider<List<SearchHashtagModel>> {
  /// 인기 해시태그. 서버 갱신 주기 4시간(20:00~09:00은 1시간).
  PopularHashtagsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'popularHashtagsProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$popularHashtagsHash();

  @$internal
  @override
  $FutureProviderElement<List<SearchHashtagModel>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<SearchHashtagModel>> create(Ref ref) {
    return popularHashtags(ref);
  }
}

String _$popularHashtagsHash() => r'9c9ee9da7f29fdea47a755e2fca39b049575cdd4';
