// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'my_page_viewmodel.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// 내가 작성한 리뷰 목록 (collectionGroup 스트림 → 클럽 정보 조인).

@ProviderFor(myReviews)
final myReviewsProvider = MyReviewsProvider._();

/// 내가 작성한 리뷰 목록 (collectionGroup 스트림 → 클럽 정보 조인).

final class MyReviewsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<MyReviewEntry>>,
          List<MyReviewEntry>,
          Stream<List<MyReviewEntry>>
        >
    with
        $FutureModifier<List<MyReviewEntry>>,
        $StreamProvider<List<MyReviewEntry>> {
  /// 내가 작성한 리뷰 목록 (collectionGroup 스트림 → 클럽 정보 조인).
  MyReviewsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'myReviewsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$myReviewsHash();

  @$internal
  @override
  $StreamProviderElement<List<MyReviewEntry>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<MyReviewEntry>> create(Ref ref) {
    return myReviews(ref);
  }
}

String _$myReviewsHash() => r'afa3878e34bc82f098877b2bd1aa0aff4b9ed23f';

/// 마이페이지 동작 (리뷰 삭제).

@ProviderFor(MyPageActions)
final myPageActionsProvider = MyPageActionsProvider._();

/// 마이페이지 동작 (리뷰 삭제).
final class MyPageActionsProvider
    extends $NotifierProvider<MyPageActions, void> {
  /// 마이페이지 동작 (리뷰 삭제).
  MyPageActionsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'myPageActionsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$myPageActionsHash();

  @$internal
  @override
  MyPageActions create() => MyPageActions();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(void value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<void>(value),
    );
  }
}

String _$myPageActionsHash() => r'5f4235fe08d3abc2ae507aed0e325ca315d3de66';

/// 마이페이지 동작 (리뷰 삭제).

abstract class _$MyPageActions extends $Notifier<void> {
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
