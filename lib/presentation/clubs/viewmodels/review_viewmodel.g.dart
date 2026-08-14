// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'review_viewmodel.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// 클럽 리뷰 목록 실시간 스트림

@ProviderFor(reviewList)
final reviewListProvider = ReviewListFamily._();

/// 클럽 리뷰 목록 실시간 스트림

final class ReviewListProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<ReviewModel>>,
          List<ReviewModel>,
          Stream<List<ReviewModel>>
        >
    with
        $FutureModifier<List<ReviewModel>>,
        $StreamProvider<List<ReviewModel>> {
  /// 클럽 리뷰 목록 실시간 스트림
  ReviewListProvider._({
    required ReviewListFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'reviewListProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$reviewListHash();

  @override
  String toString() {
    return r'reviewListProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $StreamProviderElement<List<ReviewModel>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<ReviewModel>> create(Ref ref) {
    final argument = this.argument as String;
    return reviewList(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is ReviewListProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$reviewListHash() => r'e4c36c3fa2aba33ffcb8cda8c0d5ca531312c479';

/// 클럽 리뷰 목록 실시간 스트림

final class ReviewListFamily extends $Family
    with $FunctionalFamilyOverride<Stream<List<ReviewModel>>, String> {
  ReviewListFamily._()
    : super(
        retry: null,
        name: r'reviewListProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// 클럽 리뷰 목록 실시간 스트림

  ReviewListProvider call(String clubId) =>
      ReviewListProvider._(argument: clubId, from: this);

  @override
  String toString() => r'reviewListProvider';
}

@ProviderFor(ReviewViewModel)
final reviewViewModelProvider = ReviewViewModelProvider._();

final class ReviewViewModelProvider
    extends $NotifierProvider<ReviewViewModel, AsyncValue<void>> {
  ReviewViewModelProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'reviewViewModelProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$reviewViewModelHash();

  @$internal
  @override
  ReviewViewModel create() => ReviewViewModel();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AsyncValue<void> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AsyncValue<void>>(value),
    );
  }
}

String _$reviewViewModelHash() => r'5e353ed282b76ed52d61b7779a25bb1643b3cf5e';

abstract class _$ReviewViewModel extends $Notifier<AsyncValue<void>> {
  AsyncValue<void> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<AsyncValue<void>, AsyncValue<void>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<void>, AsyncValue<void>>,
              AsyncValue<void>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
