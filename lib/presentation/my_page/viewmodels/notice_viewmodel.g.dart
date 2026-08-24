// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'notice_viewmodel.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// 공지사항 목록 (고정 공지 우선 → 최신 게시순).
/// 공지는 자주 바뀌지 않아 스트림 대신 단발 조회 + pull-to-refresh(invalidate).

@ProviderFor(notices)
final noticesProvider = NoticesProvider._();

/// 공지사항 목록 (고정 공지 우선 → 최신 게시순).
/// 공지는 자주 바뀌지 않아 스트림 대신 단발 조회 + pull-to-refresh(invalidate).

final class NoticesProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<NoticeModel>>,
          List<NoticeModel>,
          FutureOr<List<NoticeModel>>
        >
    with
        $FutureModifier<List<NoticeModel>>,
        $FutureProvider<List<NoticeModel>> {
  /// 공지사항 목록 (고정 공지 우선 → 최신 게시순).
  /// 공지는 자주 바뀌지 않아 스트림 대신 단발 조회 + pull-to-refresh(invalidate).
  NoticesProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'noticesProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$noticesHash();

  @$internal
  @override
  $FutureProviderElement<List<NoticeModel>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<NoticeModel>> create(Ref ref) {
    return notices(ref);
  }
}

String _$noticesHash() => r'0837b1258b4b75165ad14b1316ba96a95388f6fd';

/// 공지 1건. **배너에서 들어오는 경로 전용** — 목록을 거치지 않아 모델이 없고
/// noticeId만 있다(목록에서 탭한 경우엔 이미 받은 모델을 그대로 쓴다 = 조회 0회).
/// 게시 기간이 지났거나 게시중단이면 datasource가 null을 준다.

@ProviderFor(notice)
final noticeProvider = NoticeFamily._();

/// 공지 1건. **배너에서 들어오는 경로 전용** — 목록을 거치지 않아 모델이 없고
/// noticeId만 있다(목록에서 탭한 경우엔 이미 받은 모델을 그대로 쓴다 = 조회 0회).
/// 게시 기간이 지났거나 게시중단이면 datasource가 null을 준다.

final class NoticeProvider
    extends
        $FunctionalProvider<
          AsyncValue<NoticeModel?>,
          NoticeModel?,
          FutureOr<NoticeModel?>
        >
    with $FutureModifier<NoticeModel?>, $FutureProvider<NoticeModel?> {
  /// 공지 1건. **배너에서 들어오는 경로 전용** — 목록을 거치지 않아 모델이 없고
  /// noticeId만 있다(목록에서 탭한 경우엔 이미 받은 모델을 그대로 쓴다 = 조회 0회).
  /// 게시 기간이 지났거나 게시중단이면 datasource가 null을 준다.
  NoticeProvider._({
    required NoticeFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'noticeProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$noticeHash();

  @override
  String toString() {
    return r'noticeProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<NoticeModel?> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<NoticeModel?> create(Ref ref) {
    final argument = this.argument as String;
    return notice(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is NoticeProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$noticeHash() => r'6a7e201db63566542696bd1c42fc39e2915fb6a9';

/// 공지 1건. **배너에서 들어오는 경로 전용** — 목록을 거치지 않아 모델이 없고
/// noticeId만 있다(목록에서 탭한 경우엔 이미 받은 모델을 그대로 쓴다 = 조회 0회).
/// 게시 기간이 지났거나 게시중단이면 datasource가 null을 준다.

final class NoticeFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<NoticeModel?>, String> {
  NoticeFamily._()
    : super(
        retry: null,
        name: r'noticeProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// 공지 1건. **배너에서 들어오는 경로 전용** — 목록을 거치지 않아 모델이 없고
  /// noticeId만 있다(목록에서 탭한 경우엔 이미 받은 모델을 그대로 쓴다 = 조회 0회).
  /// 게시 기간이 지났거나 게시중단이면 datasource가 null을 준다.

  NoticeProvider call(String noticeId) =>
      NoticeProvider._(argument: noticeId, from: this);

  @override
  String toString() => r'noticeProvider';
}
