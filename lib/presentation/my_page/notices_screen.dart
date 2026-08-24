import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vybe/core/navigation/swipe_back_page_route.dart';
import 'package:vybe/data/models/notice_model.dart';
import 'package:vybe/design_system/colors.dart';
import 'package:vybe/presentation/clubs/widgets/club_glass.dart';
import 'package:vybe/presentation/common/widgets/vybe_aurora.dart';
import 'package:vybe/presentation/my_page/notice_detail_screen.dart';
import 'package:vybe/presentation/my_page/viewmodels/notice_viewmodel.dart';
import 'package:vybe/presentation/my_page/widgets/notice_card.dart';
import 'package:vybe/presentation/my_page/widgets/notice_glass.dart';
import 'package:vybe/presentation/my_page/widgets/notices_header.dart';
import 'package:vybe/presentation/my_page/widgets/notices_states.dart';

// ============================================================
// 공지사항 목록 (마이페이지 → 계정 → 공지사항)
//
// 디자인: notice_glass.html (notice_glass.jsx · notifications_glass_shell.jsx).
// 오로라 배경 + 큰 타이틀 헤더(운영팀 배지) + 글래스 카드 목록.
// 고정 공지는 카테고리 색 링·틴트로 강조, 나머지는 옅은 유리.
//
// notices 컬렉션 읽기 전용. 작성/수정은 어드민 페이지 전용.
// 정렬(고정 우선 → 최신 게시순)은 datasource에서 끝난 상태로 받는다.
// ============================================================

/// 카드가 순차로 나타나는 간격 (디자인 animationDelay: index * 45ms).
const _kStagger = Duration(milliseconds: 45);

class NoticesScreen extends ConsumerWidget {
  const NoticesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final noticesAsync = ref.watch(noticesProvider);
    final bottomPad = 30.h + MediaQuery.paddingOf(context).bottom;

    return Scaffold(
      backgroundColor: ClubGlass.ink,
      body: Stack(
        children: [
          const Positioned.fill(child: VybeAurora()),
          RefreshIndicator(
            color: VybeColors.mainLime500,
            backgroundColor: ClubGlass.ink,
            onRefresh: () async => ref.invalidate(noticesProvider),
            child: CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: [
                const SliverToBoxAdapter(child: NoticesHeader()),
                ...noticesAsync.when(
                  loading: () => [
                    const SliverToBoxAdapter(child: NoticesSkeleton()),
                  ],
                  error: (_, __) => [
                    const SliverToBoxAdapter(
                      child: NoticesMessage('공지사항을 불러오지 못했어요'),
                    ),
                  ],
                  data: (notices) => notices.isEmpty
                      ? [const SliverToBoxAdapter(child: NoticesEmpty())]
                      : _listSlivers(context, notices),
                ),
                SliverToBoxAdapter(child: SizedBox(height: bottomPad)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// 공지 탭 → 상세. 광고 글도 같은 화면을 쓴다 — 홈 배너가 보내는 곳과 같은 공지 상세다.
  /// 바텀 nav는 이 화면에 들어올 때 이미 내려가 있어 여기선 평범하게 push한다.
  void _open(BuildContext context, NoticeModel notice) {
    Navigator.of(context).push(
      SwipeBackPageRoute<void>(
        builder: (_) => NoticeDetailScreen(notice: notice),
      ),
    );
  }

  List<Widget> _listSlivers(BuildContext context, List<NoticeModel> notices) {
    return [
      SliverList.builder(
        itemCount: notices.length,
        itemBuilder: (context, i) => Padding(
          // 카드 사이 간격 10px.
          padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 10.h),
          child: NoticeCard(
            notice: notices[i],
            appearDelay: _kStagger * i,
            onTap: () => _open(context, notices[i]),
          ),
        ),
      ),
      SliverToBoxAdapter(
        child: Padding(
          padding: EdgeInsets.fromLTRB(20.w, 22.h, 20.w, 6.h),
          child: const NoticeLockNote(),
        ),
      ),
    ];
  }
}
