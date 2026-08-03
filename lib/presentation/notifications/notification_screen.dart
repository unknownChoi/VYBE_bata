import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vybe/presentation/clubs/widgets/club_glass.dart';
import 'package:vybe/presentation/main_scaffold/main_scaffold.dart'
    show navBarTotalHeight;
import 'package:vybe/presentation/notifications/notification_item.dart';
import 'package:vybe/presentation/notifications/viewmodels/notification_viewmodel.dart';
import 'package:vybe/presentation/notifications/widgets/notification_card.dart';
import 'package:vybe/presentation/notifications/widgets/notification_header.dart';
import 'package:vybe/presentation/notifications/widgets/notification_placeholders.dart';

/// 알림 — 리퀴드 글래스.
///
/// 디자인: notifications_glass.html (notifications_glass_shell.jsx · notifications_glass.jsx).
/// 오로라 배경 + 큰 타이틀 헤더 + 시간 섹션 라벨 + 종류별 색 링을 두른 글래스 카드 목록.
///
/// ⚠ 디자인의 종류 필터 칩(전체/예약·입장/…)은 글래스 개편에서 빠졌다
/// (shell에 NG_FILTERS는 남아 있으나 페이지가 렌더하지 않음) → 여기서도 제외.
class NotificationScreen extends ConsumerWidget {
  const NotificationScreen({super.key});

  /// 카드가 순차로 나타나는 간격 (디자인 animationDelay: index * 45ms).
  static const _kStagger = Duration(milliseconds: 45);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(notificationViewModelProvider);
    final items = state.items;
    final unread = state.unreadCount;
    // 홈 탭 Navigator 위에 push되므로 하단 floating nav가 그대로 떠 있다.
    final bottomPad = 28.h + navBarTotalHeight(context);

    return Scaffold(
      backgroundColor: ClubGlass.ink,
      body: Stack(
        children: [
          const Positioned.fill(child: ClubAurora()),
          CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: NotificationHeader(
                  unread: unread,
                  onReadAll: unread > 0
                      ? () => ref
                          .read(notificationViewModelProvider.notifier)
                          .markAllRead()
                      : null,
                ),
              ),
              if (state.loading)
                const SliverToBoxAdapter(child: NotificationSkeleton())
              else if (items.isEmpty)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.w),
                    child: const NotificationEmpty(label: '알림이 없어요'),
                  ),
                )
              else
                ..._sectionSlivers(ref, items),
              SliverToBoxAdapter(child: SizedBox(height: bottomPad)),
            ],
          ),
        ],
      ),
    );
  }

  /// 시간 섹션(오늘/이번 주/이전)별 라벨 + 카드 목록. 빈 섹션은 통째로 생략.
  List<Widget> _sectionSlivers(WidgetRef ref, List<NotificationItem> items) {
    final slivers = <Widget>[];

    for (final (section, label) in kNotiSections) {
      final rows = items.where((n) => n.section == section).toList();
      if (rows.isEmpty) continue;

      slivers.add(
        SliverToBoxAdapter(
          child: _SectionLabel(label: label, count: rows.length),
        ),
      );
      slivers.add(
        SliverList.builder(
          itemCount: rows.length,
          itemBuilder: (_, i) => Padding(
            // 카드 사이 간격 10px.
            padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 10.h),
            child: NotificationCard(
              noti: rows[i],
              appearDelay: _kStagger * i,
              onRead: () => ref
                  .read(notificationViewModelProvider.notifier)
                  .markRead(rows[i].id),
            ),
          ),
        ),
      );
    }
    return slivers;
  }
}

/// 시간 섹션 라벨 — `오늘 3` + 오른쪽으로 사라지는 헤어라인.
class _SectionLabel extends StatelessWidget {
  final String label;
  final int count;

  const _SectionLabel({required this.label, required this.count});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(20.w, 20.h, 20.w, 10.h),
      child: Row(
        children: [
          Text(
            label,
            style: ClubGlass.caption(
              color: ClubGlass.t2,
              weight: FontWeight.w700,
            ).copyWith(letterSpacing: 12 * 0.04),
          ),
          SizedBox(width: 10.w),
          Text(
            '$count',
            style: ClubGlass.caption(
              color: ClubGlass.t4,
              weight: FontWeight.w600,
            ),
          ),
          SizedBox(width: 10.w),
          const Expanded(child: _FadingHairline()),
        ],
      ),
    );
  }
}

class _FadingHairline extends StatelessWidget {
  const _FadingHairline();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 1,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0x21FFFFFF), Color(0x00FFFFFF)],
        ),
      ),
    );
  }
}
