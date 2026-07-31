// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'search_trend_repository_impl.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(searchTrendRepository)
final searchTrendRepositoryProvider = SearchTrendRepositoryProvider._();

final class SearchTrendRepositoryProvider
    extends
        $FunctionalProvider<
          SearchTrendRepository,
          SearchTrendRepository,
          SearchTrendRepository
        >
    with $Provider<SearchTrendRepository> {
  SearchTrendRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'searchTrendRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$searchTrendRepositoryHash();

  @$internal
  @override
  $ProviderElement<SearchTrendRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  SearchTrendRepository create(Ref ref) {
    return searchTrendRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SearchTrendRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SearchTrendRepository>(value),
    );
  }
}

String _$searchTrendRepositoryHash() =>
    r'9fc86a769ab97760b4a19c7de74efc21e0c457b9';
