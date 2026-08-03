import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:vybe/presentation/notifications/notification_item.dart';

part 'notification_viewmodel.g.dart';

/// 백엔드 연동 전 로딩 흉내 — 이 시간만큼 스켈레톤을 보여준 뒤 목록을 노출한다.
/// 실연동 시 이 지연 대신 repository 호출로 교체한다.
const _kFakeLoadDelay = Duration(milliseconds: 1100);

/// 알림 화면 상태.
///
/// 목록과 로딩을 따로 둔다 — 본문은 스켈레톤이어도 헤더의 안 읽은 개수는
/// 처음부터 보여야 하기 때문(디자인 NotiGlassApp도 `notis`/`loading` 분리).
class NotificationState {
  final List<NotificationItem> items;
  final bool loading;

  const NotificationState({required this.items, required this.loading});

  int get unreadCount => items.where((n) => !n.read).length;

  NotificationState copyWith({List<NotificationItem>? items, bool? loading}) =>
      NotificationState(
        items: items ?? this.items,
        loading: loading ?? this.loading,
      );
}

/// 알림 목록 + 읽음 처리.
///
/// 화면(위젯)은 상태를 들고 있지 않고 이 ViewModel만 구독한다.
/// autoDispose라 화면을 나가면 상태가 비워져 재진입 시 다시 로딩부터 시작한다.
@riverpod
class NotificationViewModel extends _$NotificationViewModel {
  @override
  NotificationState build() {
    final timer = Timer(
      _kFakeLoadDelay,
      () => state = state.copyWith(loading: false),
    );
    // 로딩 중 화면을 나가면 dispose된 notifier에 state를 쓰게 되므로 취소.
    ref.onDispose(timer.cancel);

    return const NotificationState(items: kDummyNotifications, loading: true);
  }

  void markAllRead() => state = state.copyWith(
        items: [for (final n in state.items) n.copyWith(read: true)],
      );

  void markRead(int id) => state = state.copyWith(
        items: [
          for (final n in state.items) n.id == id ? n.copyWith(read: true) : n,
        ],
      );
}
