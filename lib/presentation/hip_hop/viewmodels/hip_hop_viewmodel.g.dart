// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'hip_hop_viewmodel.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// 힙합 클럽 + 오늘 공연 일정을 병렬 조회해 합친다.

@ProviderFor(HipHopViewModel)
final hipHopViewModelProvider = HipHopViewModelProvider._();

/// 힙합 클럽 + 오늘 공연 일정을 병렬 조회해 합친다.
final class HipHopViewModelProvider
    extends $AsyncNotifierProvider<HipHopViewModel, HipHopData> {
  /// 힙합 클럽 + 오늘 공연 일정을 병렬 조회해 합친다.
  HipHopViewModelProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'hipHopViewModelProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$hipHopViewModelHash();

  @$internal
  @override
  HipHopViewModel create() => HipHopViewModel();
}

String _$hipHopViewModelHash() => r'2fa44a5d8b9a32edecbcf61d22eacf98d9a4365f';

/// 힙합 클럽 + 오늘 공연 일정을 병렬 조회해 합친다.

abstract class _$HipHopViewModel extends $AsyncNotifier<HipHopData> {
  FutureOr<HipHopData> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<AsyncValue<HipHopData>, HipHopData>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<HipHopData>, HipHopData>,
              AsyncValue<HipHopData>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
