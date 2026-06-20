// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'nearby_viewmodel.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(NearbyViewModel)
final nearbyViewModelProvider = NearbyViewModelProvider._();

final class NearbyViewModelProvider
    extends $AsyncNotifierProvider<NearbyViewModel, List<ClubModel>> {
  NearbyViewModelProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'nearbyViewModelProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$nearbyViewModelHash();

  @$internal
  @override
  NearbyViewModel create() => NearbyViewModel();
}

String _$nearbyViewModelHash() => r'c5b5e94d3b160c2c9fd738b51a345c2c0ec053ec';

abstract class _$NearbyViewModel extends $AsyncNotifier<List<ClubModel>> {
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

/// 마지막 조회 중심 좌표. 거리순 정렬의 기준점.

@ProviderFor(NearbyCenter)
final nearbyCenterProvider = NearbyCenterProvider._();

/// 마지막 조회 중심 좌표. 거리순 정렬의 기준점.
final class NearbyCenterProvider
    extends $NotifierProvider<NearbyCenter, ({double lat, double lng})> {
  /// 마지막 조회 중심 좌표. 거리순 정렬의 기준점.
  NearbyCenterProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'nearbyCenterProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$nearbyCenterHash();

  @$internal
  @override
  NearbyCenter create() => NearbyCenter();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(({double lat, double lng}) value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<({double lat, double lng})>(value),
    );
  }
}

String _$nearbyCenterHash() => r'4d338a08620d161b3f85b7c78fe031d9d972f4df';

/// 마지막 조회 중심 좌표. 거리순 정렬의 기준점.

abstract class _$NearbyCenter extends $Notifier<({double lat, double lng})> {
  ({double lat, double lng}) build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref =
        this.ref
            as $Ref<({double lat, double lng}), ({double lat, double lng})>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<
                ({double lat, double lng}),
                ({double lat, double lng})
              >,
              ({double lat, double lng}),
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}

/// 지역 클러스터에서 선택한 area. null이면 전체. 바텀시트 리스트 필터용.

@ProviderFor(SelectedArea)
final selectedAreaProvider = SelectedAreaProvider._();

/// 지역 클러스터에서 선택한 area. null이면 전체. 바텀시트 리스트 필터용.
final class SelectedAreaProvider
    extends $NotifierProvider<SelectedArea, String?> {
  /// 지역 클러스터에서 선택한 area. null이면 전체. 바텀시트 리스트 필터용.
  SelectedAreaProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'selectedAreaProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$selectedAreaHash();

  @$internal
  @override
  SelectedArea create() => SelectedArea();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(String? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<String?>(value),
    );
  }
}

String _$selectedAreaHash() => r'b1940aa393ad0319ce1f5a28d9dcfa8e87f1faf4';

/// 지역 클러스터에서 선택한 area. null이면 전체. 바텀시트 리스트 필터용.

abstract class _$SelectedArea extends $Notifier<String?> {
  String? build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<String?, String?>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<String?, String?>,
              String?,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
