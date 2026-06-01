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

@ProviderFor(SearchViewModel)
final searchViewModelProvider = SearchViewModelProvider._();

final class SearchViewModelProvider
    extends $NotifierProvider<SearchViewModel, AsyncValue<List<ClubModel>>> {
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
  Override overrideWithValue(AsyncValue<List<ClubModel>> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AsyncValue<List<ClubModel>>>(value),
    );
  }
}

String _$searchViewModelHash() => r'7769da4444db8923ba07d5e1adf15e7cc556b70e';

abstract class _$SearchViewModel
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
