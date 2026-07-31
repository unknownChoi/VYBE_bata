// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'search_viewmodel.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(searchHistory)
final searchHistoryProvider = SearchHistoryFamily._();

final class SearchHistoryProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<SearchHistoryModel>>,
          List<SearchHistoryModel>,
          FutureOr<List<SearchHistoryModel>>
        >
    with
        $FutureModifier<List<SearchHistoryModel>>,
        $FutureProvider<List<SearchHistoryModel>> {
  SearchHistoryProvider._({
    required SearchHistoryFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'searchHistoryProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$searchHistoryHash();

  @override
  String toString() {
    return r'searchHistoryProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<List<SearchHistoryModel>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<SearchHistoryModel>> create(Ref ref) {
    final argument = this.argument as String;
    return searchHistory(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is SearchHistoryProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$searchHistoryHash() => r'93326966c04cac442b2b88200a14c159d5c12ad1';

final class SearchHistoryFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<List<SearchHistoryModel>>, String> {
  SearchHistoryFamily._()
    : super(
        retry: null,
        name: r'searchHistoryProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  SearchHistoryProvider call(String userId) =>
      SearchHistoryProvider._(argument: userId, from: this);

  @override
  String toString() => r'searchHistoryProvider';
}

/// 입력 중 연관 검색어(클럽 제안). 디바운스는 호출측(화면)에서 처리.
/// searchClubsPage(평점순 상위 8개)를 재사용 — 추가 인프라 없음.

@ProviderFor(SearchSuggestionViewModel)
final searchSuggestionViewModelProvider = SearchSuggestionViewModelProvider._();

/// 입력 중 연관 검색어(클럽 제안). 디바운스는 호출측(화면)에서 처리.
/// searchClubsPage(평점순 상위 8개)를 재사용 — 추가 인프라 없음.
final class SearchSuggestionViewModelProvider
    extends
        $NotifierProvider<
          SearchSuggestionViewModel,
          AsyncValue<List<ClubModel>>
        > {
  /// 입력 중 연관 검색어(클럽 제안). 디바운스는 호출측(화면)에서 처리.
  /// searchClubsPage(평점순 상위 8개)를 재사용 — 추가 인프라 없음.
  SearchSuggestionViewModelProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'searchSuggestionViewModelProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$searchSuggestionViewModelHash();

  @$internal
  @override
  SearchSuggestionViewModel create() => SearchSuggestionViewModel();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AsyncValue<List<ClubModel>> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AsyncValue<List<ClubModel>>>(value),
    );
  }
}

String _$searchSuggestionViewModelHash() =>
    r'fac260fd4c1fc3d83a5afddbd572c7369862bbf3';

/// 입력 중 연관 검색어(클럽 제안). 디바운스는 호출측(화면)에서 처리.
/// searchClubsPage(평점순 상위 8개)를 재사용 — 추가 인프라 없음.

abstract class _$SearchSuggestionViewModel
    extends $Notifier<AsyncValue<List<ClubModel>>> {
  AsyncValue<List<ClubModel>> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref =
        this.ref
            as $Ref<AsyncValue<List<ClubModel>>, AsyncValue<List<ClubModel>>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<
                AsyncValue<List<ClubModel>>,
                AsyncValue<List<ClubModel>>
              >,
              AsyncValue<List<ClubModel>>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}

@ProviderFor(SearchViewModel)
final searchViewModelProvider = SearchViewModelProvider._();

final class SearchViewModelProvider
    extends $NotifierProvider<SearchViewModel, AsyncValue<SearchResults>> {
  SearchViewModelProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'searchViewModelProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$searchViewModelHash();

  @$internal
  @override
  SearchViewModel create() => SearchViewModel();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AsyncValue<SearchResults> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AsyncValue<SearchResults>>(value),
    );
  }
}

String _$searchViewModelHash() => r'37daae098769e97d11d9088065c05d5cacd1471c';

abstract class _$SearchViewModel extends $Notifier<AsyncValue<SearchResults>> {
  AsyncValue<SearchResults> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref =
        this.ref as $Ref<AsyncValue<SearchResults>, AsyncValue<SearchResults>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<SearchResults>, AsyncValue<SearchResults>>,
              AsyncValue<SearchResults>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
