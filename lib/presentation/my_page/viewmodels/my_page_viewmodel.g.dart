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

/// 정렬·필터 선택 상태 (화면 표시 전용 — 저장하지 않는다).

@ProviderFor(MyReviewFilterController)
final myReviewFilterControllerProvider = MyReviewFilterControllerProvider._();

/// 정렬·필터 선택 상태 (화면 표시 전용 — 저장하지 않는다).
final class MyReviewFilterControllerProvider
    extends $NotifierProvider<MyReviewFilterController, MyReviewFilter> {
  /// 정렬·필터 선택 상태 (화면 표시 전용 — 저장하지 않는다).
  MyReviewFilterControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'myReviewFilterControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$myReviewFilterControllerHash();

  @$internal
  @override
  MyReviewFilterController create() => MyReviewFilterController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(MyReviewFilter value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<MyReviewFilter>(value),
    );
  }
}

String _$myReviewFilterControllerHash() =>
    r'df9d6dd151dea420e83dda8873830b47b60448a9';

/// 정렬·필터 선택 상태 (화면 표시 전용 — 저장하지 않는다).

abstract class _$MyReviewFilterController extends $Notifier<MyReviewFilter> {
  MyReviewFilter build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<MyReviewFilter, MyReviewFilter>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<MyReviewFilter, MyReviewFilter>,
              MyReviewFilter,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}

/// 화면에 실제로 그릴 목록 — 원본 스트림에 정렬·필터를 얹은 것.
///
/// 원본([myReviews])은 그대로 남겨 둔다 — 헤더의 전체 개수는 필터와 무관하다.

@ProviderFor(visibleMyReviews)
final visibleMyReviewsProvider = VisibleMyReviewsProvider._();

/// 화면에 실제로 그릴 목록 — 원본 스트림에 정렬·필터를 얹은 것.
///
/// 원본([myReviews])은 그대로 남겨 둔다 — 헤더의 전체 개수는 필터와 무관하다.

final class VisibleMyReviewsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<MyReviewEntry>>,
          AsyncValue<List<MyReviewEntry>>,
          AsyncValue<List<MyReviewEntry>>
        >
    with $Provider<AsyncValue<List<MyReviewEntry>>> {
  /// 화면에 실제로 그릴 목록 — 원본 스트림에 정렬·필터를 얹은 것.
  ///
  /// 원본([myReviews])은 그대로 남겨 둔다 — 헤더의 전체 개수는 필터와 무관하다.
  VisibleMyReviewsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'visibleMyReviewsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$visibleMyReviewsHash();

  @$internal
  @override
  $ProviderElement<AsyncValue<List<MyReviewEntry>>> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  AsyncValue<List<MyReviewEntry>> create(Ref ref) {
    return visibleMyReviews(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AsyncValue<List<MyReviewEntry>> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AsyncValue<List<MyReviewEntry>>>(
        value,
      ),
    );
  }
}

String _$visibleMyReviewsHash() => r'279c74846753a5a1079f8e5e6988e603f9102d96';
