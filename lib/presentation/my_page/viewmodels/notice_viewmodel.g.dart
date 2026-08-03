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
