// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'service_drinks_viewmodel.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// 서비스 음료(무료 제공) 클럽 목록.
/// clubs 중 serviceDrink.isOffered=true 인 활성 클럽. 종류/위치/정렬 필터는 화면에서 처리.

@ProviderFor(ServiceDrinksViewModel)
final serviceDrinksViewModelProvider = ServiceDrinksViewModelProvider._();

/// 서비스 음료(무료 제공) 클럽 목록.
/// clubs 중 serviceDrink.isOffered=true 인 활성 클럽. 종류/위치/정렬 필터는 화면에서 처리.
final class ServiceDrinksViewModelProvider
    extends $AsyncNotifierProvider<ServiceDrinksViewModel, List<ClubModel>> {
  /// 서비스 음료(무료 제공) 클럽 목록.
  /// clubs 중 serviceDrink.isOffered=true 인 활성 클럽. 종류/위치/정렬 필터는 화면에서 처리.
  ServiceDrinksViewModelProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'serviceDrinksViewModelProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$serviceDrinksViewModelHash();

  @$internal
  @override
  ServiceDrinksViewModel create() => ServiceDrinksViewModel();
}

String _$serviceDrinksViewModelHash() =>
    r'bb19a148fc451b1dd8ed49d2bfc9aba9fe7b30f2';

/// 서비스 음료(무료 제공) 클럽 목록.
/// clubs 중 serviceDrink.isOffered=true 인 활성 클럽. 종류/위치/정렬 필터는 화면에서 처리.

abstract class _$ServiceDrinksViewModel
    extends $AsyncNotifier<List<ClubModel>> {
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
