// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'home_notices_viewmodel.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// 홈 공지사항 — 고정 공지 우선 → 최신 게시순 상위 [_kMaxNotices]건.
///
/// 별도 쿼리를 만들지 않고 [noticesProvider]를 그대로 재사용한다. 공지는 몇 건
/// 안 되고, 여기서 캐시를 데워 두면 '전체보기'로 들어간 목록 화면이 추가 read
/// 없이 바로 그려진다. 노출 조건(게시상태·기간)도 그쪽 한 곳에서만 판정된다.

@ProviderFor(homeNotices)
final homeNoticesProvider = HomeNoticesProvider._();

/// 홈 공지사항 — 고정 공지 우선 → 최신 게시순 상위 [_kMaxNotices]건.
///
/// 별도 쿼리를 만들지 않고 [noticesProvider]를 그대로 재사용한다. 공지는 몇 건
/// 안 되고, 여기서 캐시를 데워 두면 '전체보기'로 들어간 목록 화면이 추가 read
/// 없이 바로 그려진다. 노출 조건(게시상태·기간)도 그쪽 한 곳에서만 판정된다.

final class HomeNoticesProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<NoticeModel>>,
          List<NoticeModel>,
          FutureOr<List<NoticeModel>>
        >
    with
        $FutureModifier<List<NoticeModel>>,
        $FutureProvider<List<NoticeModel>> {
  /// 홈 공지사항 — 고정 공지 우선 → 최신 게시순 상위 [_kMaxNotices]건.
  ///
  /// 별도 쿼리를 만들지 않고 [noticesProvider]를 그대로 재사용한다. 공지는 몇 건
  /// 안 되고, 여기서 캐시를 데워 두면 '전체보기'로 들어간 목록 화면이 추가 read
  /// 없이 바로 그려진다. 노출 조건(게시상태·기간)도 그쪽 한 곳에서만 판정된다.
  HomeNoticesProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'homeNoticesProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$homeNoticesHash();

  @$internal
  @override
  $FutureProviderElement<List<NoticeModel>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<NoticeModel>> create(Ref ref) {
    return homeNotices(ref);
  }
}

String _$homeNoticesHash() => r'0b1cedc9368aa5bdf10f52dbaf4d488961bd90f1';
