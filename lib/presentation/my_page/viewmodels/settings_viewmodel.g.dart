// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'settings_viewmodel.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// 앱 캐시(임시 디렉토리 + 메모리 이미지 캐시) 관리.
/// state = 임시 디렉토리 용량(bytes).

@ProviderFor(CacheManager)
final cacheManagerProvider = CacheManagerProvider._();

/// 앱 캐시(임시 디렉토리 + 메모리 이미지 캐시) 관리.
/// state = 임시 디렉토리 용량(bytes).
final class CacheManagerProvider
    extends $AsyncNotifierProvider<CacheManager, int> {
  /// 앱 캐시(임시 디렉토리 + 메모리 이미지 캐시) 관리.
  /// state = 임시 디렉토리 용량(bytes).
  CacheManagerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'cacheManagerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$cacheManagerHash();

  @$internal
  @override
  CacheManager create() => CacheManager();
}

String _$cacheManagerHash() => r'af245e93beedb97ff18ac565deba7c7d796f9f15';

/// 앱 캐시(임시 디렉토리 + 메모리 이미지 캐시) 관리.
/// state = 임시 디렉토리 용량(bytes).

abstract class _$CacheManager extends $AsyncNotifier<int> {
  FutureOr<int> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<AsyncValue<int>, int>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<int>, int>,
              AsyncValue<int>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
