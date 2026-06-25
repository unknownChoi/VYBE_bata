// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'saved_viewmodel.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// 찜한 클럽 목록 (favorites 스트림 → 각 클럽 fetch).

@ProviderFor(savedClubs)
final savedClubsProvider = SavedClubsProvider._();

/// 찜한 클럽 목록 (favorites 스트림 → 각 클럽 fetch).

final class SavedClubsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<SavedEntry>>,
          List<SavedEntry>,
          Stream<List<SavedEntry>>
        >
    with $FutureModifier<List<SavedEntry>>, $StreamProvider<List<SavedEntry>> {
  /// 찜한 클럽 목록 (favorites 스트림 → 각 클럽 fetch).
  SavedClubsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'savedClubsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$savedClubsHash();

  @$internal
  @override
  $StreamProviderElement<List<SavedEntry>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<SavedEntry>> create(Ref ref) {
    return savedClubs(ref);
  }
}

String _$savedClubsHash() => r'f485400baa63766708c2dac5b5217f95b366f963';

/// 사용자 찜 그룹 목록.

@ProviderFor(savedFolders)
final savedFoldersProvider = SavedFoldersProvider._();

/// 사용자 찜 그룹 목록.

final class SavedFoldersProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<FolderModel>>,
          List<FolderModel>,
          Stream<List<FolderModel>>
        >
    with
        $FutureModifier<List<FolderModel>>,
        $StreamProvider<List<FolderModel>> {
  /// 사용자 찜 그룹 목록.
  SavedFoldersProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'savedFoldersProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$savedFoldersHash();

  @$internal
  @override
  $StreamProviderElement<List<FolderModel>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<FolderModel>> create(Ref ref) {
    return savedFolders(ref);
  }
}

String _$savedFoldersHash() => r'71dd26150421091bdbe16c5471590a30a1d0c239';

/// 찜 화면 동작(그룹 생성/삭제, 찜 해제, 그룹 이동).

@ProviderFor(SavedActions)
final savedActionsProvider = SavedActionsProvider._();

/// 찜 화면 동작(그룹 생성/삭제, 찜 해제, 그룹 이동).
final class SavedActionsProvider extends $NotifierProvider<SavedActions, void> {
  /// 찜 화면 동작(그룹 생성/삭제, 찜 해제, 그룹 이동).
  SavedActionsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'savedActionsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$savedActionsHash();

  @$internal
  @override
  SavedActions create() => SavedActions();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(void value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<void>(value),
    );
  }
}

String _$savedActionsHash() => r'c72fa98d8d7bf39dc22f56d2cb33a8f3368e09e5';

/// 찜 화면 동작(그룹 생성/삭제, 찜 해제, 그룹 이동).

abstract class _$SavedActions extends $Notifier<void> {
  void build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<void, void>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<void, void>,
              void,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
