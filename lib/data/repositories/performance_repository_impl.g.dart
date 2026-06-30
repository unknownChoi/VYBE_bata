// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'performance_repository_impl.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(performanceRepository)
final performanceRepositoryProvider = PerformanceRepositoryProvider._();

final class PerformanceRepositoryProvider
    extends
        $FunctionalProvider<
          PerformanceRepository,
          PerformanceRepository,
          PerformanceRepository
        >
    with $Provider<PerformanceRepository> {
  PerformanceRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'performanceRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$performanceRepositoryHash();

  @$internal
  @override
  $ProviderElement<PerformanceRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  PerformanceRepository create(Ref ref) {
    return performanceRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(PerformanceRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<PerformanceRepository>(value),
    );
  }
}

String _$performanceRepositoryHash() =>
    r'12f84374088abefb10fc7c4dc5871a56d7ce2313';
