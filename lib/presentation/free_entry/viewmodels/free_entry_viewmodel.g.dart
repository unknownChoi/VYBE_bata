// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'free_entry_viewmodel.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// 입장비 무료 클럽 목록.
/// clubs 중 entryFeeMin=0 인 활성 클럽. 지역/정렬 필터는 화면에서 처리.

@ProviderFor(FreeEntryViewModel)
final freeEntryViewModelProvider = FreeEntryViewModelProvider._();

/// 입장비 무료 클럽 목록.
/// clubs 중 entryFeeMin=0 인 활성 클럽. 지역/정렬 필터는 화면에서 처리.
final class FreeEntryViewModelProvider
    extends $AsyncNotifierProvider<FreeEntryViewModel, List<ClubModel>> {
  /// 입장비 무료 클럽 목록.
  /// clubs 중 entryFeeMin=0 인 활성 클럽. 지역/정렬 필터는 화면에서 처리.
  FreeEntryViewModelProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'freeEntryViewModelProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$freeEntryViewModelHash();

  @$internal
  @override
  FreeEntryViewModel create() => FreeEntryViewModel();
}

String _$freeEntryViewModelHash() =>
    r'd1094a18247097c29c9284f4f8dff549714e13f1';

/// 입장비 무료 클럽 목록.
/// clubs 중 entryFeeMin=0 인 활성 클럽. 지역/정렬 필터는 화면에서 처리.

abstract class _$FreeEntryViewModel extends $AsyncNotifier<List<ClubModel>> {
  FutureOr<List<ClubModel>> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<AsyncValue<List<ClubModel>>, List<ClubModel>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<List<ClubModel>>, List<ClubModel>>,
              AsyncValue<List<ClubModel>>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
