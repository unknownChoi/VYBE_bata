// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'edm_viewmodel.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// EDM 클럽 + 오늘 공연 일정을 병렬 조회해 합친다.

@ProviderFor(EdmViewModel)
final edmViewModelProvider = EdmViewModelProvider._();

/// EDM 클럽 + 오늘 공연 일정을 병렬 조회해 합친다.
final class EdmViewModelProvider
    extends $AsyncNotifierProvider<EdmViewModel, EdmData> {
  /// EDM 클럽 + 오늘 공연 일정을 병렬 조회해 합친다.
  EdmViewModelProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'edmViewModelProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$edmViewModelHash();

  @$internal
  @override
  EdmViewModel create() => EdmViewModel();
}

String _$edmViewModelHash() => r'6d4d8dedced0a5bbfd245fd5928eaed04d6afcce';

/// EDM 클럽 + 오늘 공연 일정을 병렬 조회해 합친다.

abstract class _$EdmViewModel extends $AsyncNotifier<EdmData> {
  FutureOr<EdmData> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<AsyncValue<EdmData>, EdmData>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<EdmData>, EdmData>,
              AsyncValue<EdmData>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
