// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'club_list_viewmodel.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// 활성 클럽 목록 실시간 스트림

@ProviderFor(clubList)
final clubListProvider = ClubListProvider._();

/// 활성 클럽 목록 실시간 스트림

final class ClubListProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<ClubModel>>,
          List<ClubModel>,
          Stream<List<ClubModel>>
        >
    with $FutureModifier<List<ClubModel>>, $StreamProvider<List<ClubModel>> {
  /// 활성 클럽 목록 실시간 스트림
  ClubListProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'clubListProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$clubListHash();

  @$internal
  @override
  $StreamProviderElement<List<ClubModel>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<ClubModel>> create(Ref ref) {
    return clubList(ref);
  }
}

String _$clubListHash() => r'ddc8dcfe47fe13c74d2d6cdb8995d78a29920a56';

/// 키워드 검색

@ProviderFor(ClubSearchViewModel)
final clubSearchViewModelProvider = ClubSearchViewModelProvider._();

/// 키워드 검색
final class ClubSearchViewModelProvider
    extends
        $NotifierProvider<ClubSearchViewModel, AsyncValue<List<ClubModel>>> {
  /// 키워드 검색
  ClubSearchViewModelProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'clubSearchViewModelProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$clubSearchViewModelHash();

  @$internal
  @override
  ClubSearchViewModel create() => ClubSearchViewModel();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AsyncValue<List<ClubModel>> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AsyncValue<List<ClubModel>>>(value),
    );
  }
}

String _$clubSearchViewModelHash() =>
    r'2ca6c8bea9de84d65713b5c9b278ef8d2dc9a97b';

/// 키워드 검색

abstract class _$ClubSearchViewModel
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
