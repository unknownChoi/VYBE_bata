// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'club_filter_viewmodel.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// 현재 활성화된 필터 집합을 보관. 칩 탭으로 toggle, 리스트 화면에서 watch.

@ProviderFor(ClubFilterViewModel)
final clubFilterViewModelProvider = ClubFilterViewModelProvider._();

/// 현재 활성화된 필터 집합을 보관. 칩 탭으로 toggle, 리스트 화면에서 watch.
final class ClubFilterViewModelProvider
    extends $NotifierProvider<ClubFilterViewModel, Set<ClubFilter>> {
  /// 현재 활성화된 필터 집합을 보관. 칩 탭으로 toggle, 리스트 화면에서 watch.
  ClubFilterViewModelProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'clubFilterViewModelProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$clubFilterViewModelHash();

  @$internal
  @override
  ClubFilterViewModel create() => ClubFilterViewModel();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(Set<ClubFilter> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<Set<ClubFilter>>(value),
    );
  }
}

String _$clubFilterViewModelHash() =>
    r'7da138265b97afe0db666f56f666efa2b3df3c09';

/// 현재 활성화된 필터 집합을 보관. 칩 탭으로 toggle, 리스트 화면에서 watch.

abstract class _$ClubFilterViewModel extends $Notifier<Set<ClubFilter>> {
  Set<ClubFilter> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<Set<ClubFilter>, Set<ClubFilter>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<Set<ClubFilter>, Set<ClubFilter>>,
              Set<ClubFilter>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}

/// 현재 선택된 정렬 기준. 기본값 추천순.

@ProviderFor(ClubSortViewModel)
final clubSortViewModelProvider = ClubSortViewModelProvider._();

/// 현재 선택된 정렬 기준. 기본값 추천순.
final class ClubSortViewModelProvider
    extends $NotifierProvider<ClubSortViewModel, ClubSort> {
  /// 현재 선택된 정렬 기준. 기본값 추천순.
  ClubSortViewModelProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'clubSortViewModelProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$clubSortViewModelHash();

  @$internal
  @override
  ClubSortViewModel create() => ClubSortViewModel();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ClubSort value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ClubSort>(value),
    );
  }
}

String _$clubSortViewModelHash() => r'60a07f428b91c4b18c2620e4e38a1164ec697c05';

/// 현재 선택된 정렬 기준. 기본값 추천순.

abstract class _$ClubSortViewModel extends $Notifier<ClubSort> {
  ClubSort build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<ClubSort, ClubSort>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<ClubSort, ClubSort>,
              ClubSort,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
