// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'vybe_recommend_viewmodel.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// vybe 추천 페이지 데이터. rank 오름차순 활성 추천 목록.
/// 첫 항목(rank 1) = featured 히어로, 나머지 = 순위 리스트.

@ProviderFor(VybeRecommendViewModel)
final vybeRecommendViewModelProvider = VybeRecommendViewModelProvider._();

/// vybe 추천 페이지 데이터. rank 오름차순 활성 추천 목록.
/// 첫 항목(rank 1) = featured 히어로, 나머지 = 순위 리스트.
final class VybeRecommendViewModelProvider
    extends
        $AsyncNotifierProvider<
          VybeRecommendViewModel,
          List<VybeRecommendedClub>
        > {
  /// vybe 추천 페이지 데이터. rank 오름차순 활성 추천 목록.
  /// 첫 항목(rank 1) = featured 히어로, 나머지 = 순위 리스트.
  VybeRecommendViewModelProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'vybeRecommendViewModelProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$vybeRecommendViewModelHash();

  @$internal
  @override
  VybeRecommendViewModel create() => VybeRecommendViewModel();
}

String _$vybeRecommendViewModelHash() =>
    r'4c7165eb8455c1d94fab26f166171b9183219db0';

/// vybe 추천 페이지 데이터. rank 오름차순 활성 추천 목록.
/// 첫 항목(rank 1) = featured 히어로, 나머지 = 순위 리스트.

abstract class _$VybeRecommendViewModel
    extends $AsyncNotifier<List<VybeRecommendedClub>> {
  FutureOr<List<VybeRecommendedClub>> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref =
        this.ref
            as $Ref<
              AsyncValue<List<VybeRecommendedClub>>,
              List<VybeRecommendedClub>
            >;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<
                AsyncValue<List<VybeRecommendedClub>>,
                List<VybeRecommendedClub>
              >,
              AsyncValue<List<VybeRecommendedClub>>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
