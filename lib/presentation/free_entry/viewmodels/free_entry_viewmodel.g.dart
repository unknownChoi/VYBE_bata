// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'free_entry_viewmodel.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// 무료입장 클럽 목록 — 상시 무료 + 시간대 무료를 모두 담는다.
///
/// clubs 중 `isFreeEntry=true` 인 활성 클럽. 지역/정렬 필터와 '지금 무료' 판정은
/// 화면에서 처리한다 (요일 × 시:분 판정은 서버 쿼리로 못 좁힌다).

@ProviderFor(FreeEntryViewModel)
final freeEntryViewModelProvider = FreeEntryViewModelProvider._();

/// 무료입장 클럽 목록 — 상시 무료 + 시간대 무료를 모두 담는다.
///
/// clubs 중 `isFreeEntry=true` 인 활성 클럽. 지역/정렬 필터와 '지금 무료' 판정은
/// 화면에서 처리한다 (요일 × 시:분 판정은 서버 쿼리로 못 좁힌다).
final class FreeEntryViewModelProvider
    extends $AsyncNotifierProvider<FreeEntryViewModel, List<ClubModel>> {
  /// 무료입장 클럽 목록 — 상시 무료 + 시간대 무료를 모두 담는다.
  ///
  /// clubs 중 `isFreeEntry=true` 인 활성 클럽. 지역/정렬 필터와 '지금 무료' 판정은
  /// 화면에서 처리한다 (요일 × 시:분 판정은 서버 쿼리로 못 좁힌다).
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

/// 무료입장 클럽 목록 — 상시 무료 + 시간대 무료를 모두 담는다.
///
/// clubs 중 `isFreeEntry=true` 인 활성 클럽. 지역/정렬 필터와 '지금 무료' 판정은
/// 화면에서 처리한다 (요일 × 시:분 판정은 서버 쿼리로 못 좁힌다).

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
