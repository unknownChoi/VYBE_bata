import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vybe/core/navigation/swipe_back_page_route.dart';
import 'package:vybe/data/models/notice_model.dart';
import 'package:vybe/design_system/colors.dart';
import 'package:vybe/presentation/common/renew/renew_glass.dart';
import 'package:vybe/presentation/common/widgets/vybe_fade_in_up.dart';
import 'package:vybe/presentation/common/widgets/vybe_skeleton.dart';
import 'package:vybe/presentation/home/viewmodels/home_notices_viewmodel.dart';
import 'package:vybe/presentation/home/widgets/home_section_head.dart';
import 'package:vybe/presentation/my_page/notice_detail_screen.dart';
import 'package:vybe/presentation/my_page/notices_screen.dart';

/// 홈 공지사항 — 낮은 톤 글래스 카드 한 장에 상위 3건을 hairline으로 나눠 담는다.
///
/// 디자인 `home.jsx > NoticeSection`.
/// 카드를 건당 쌓지 않는 이유 — 글래스 카드를 겹겹이 올리면 배경이 탁해져
/// 본문이 안 읽힌다(마이페이지 메뉴와 같은 판단).
class HomeNotices extends ConsumerWidget {
  const HomeNotices({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final noticesAsync = ref.watch(homeNoticesProvider);

    return Padding(
      padding: EdgeInsets.fromLTRB(0, 20.h, 0, 8.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          HomeSectionHead(
            title: '공지사항',
            onAction: () => Navigator.of(context).push(
              SwipeBackPageRoute<void>(builder: (_) => const NoticesScreen()),
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 24.w),
            child: noticesAsync.when(
              data: (notices) => notices.isEmpty
                  ? const _NoticeCardShell(
                      child: HomeSectionMessage(text: '등록된 공지가 없어요', height: 64),
                    )
                  : _NoticeCardShell(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: List.generate(notices.length, (i) {
                          return VybeFadeInUp(
                            delay: Duration(milliseconds: 45 * i),
                            child: _NoticeRow(
                              notice: notices[i],
                              // 첫 줄 위에는 구분선을 두지 않는다 (카드 테두리와 겹침).
                              divider: i > 0,
                              onTap: () => _open(context, notices[i]),
                            ),
                          );
                        }),
                      ),
                    ),
              loading: () => const _NoticeCardShell(child: _Skeleton()),
              error: (_, __) => const _NoticeCardShell(
                child: HomeSectionMessage(text: '공지사항을 불러오지 못했어요', height: 64),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 공지 탭 → 상세. 광고 글도 같은 화면을 쓴다 — 홈 배너가 보내는 곳과 같은 공지 상세다.
  /// (공지 목록 화면 `NoticesScreen._open`과 같은 규칙)
  void _open(BuildContext context, NoticeModel notice) {
    Navigator.of(context).push(
      SwipeBackPageRoute<void>(
        builder: (_) => NoticeDetailScreen(notice: notice),
      ),
    );
  }
}

/// 공지 묶음을 감싸는 낮은 톤 글래스 카드 (내부 여백은 행이 직접 가진다).
class _NoticeCardShell extends StatelessWidget {
  final Widget child;

  const _NoticeCardShell({required this.child});

  @override
  Widget build(BuildContext context) {
    return RenewGlassCard(quiet: true, padding: 0, child: child);
  }
}

class _NoticeRow extends StatelessWidget {
  final NoticeModel notice;
  final bool divider;
  final VoidCallback onTap;

  const _NoticeRow({
    required this.notice,
    required this.divider,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final badge = _badgeTone(notice.category);

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
        decoration: divider
            ? const BoxDecoration(
                border: Border(top: BorderSide(color: RenewGlass.hair)),
              )
            : null,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 7.w, vertical: 2.h),
                  decoration: BoxDecoration(
                    color: badge.fill,
                    borderRadius: BorderRadius.circular(6.r),
                  ),
                  child: Text(
                    notice.categoryLabel,
                    style: _metaText.copyWith(
                      fontWeight: FontWeight.w600,
                      color: badge.text,
                    ),
                  ),
                ),
                if (notice.isNew) ...[
                  SizedBox(width: 8.w),
                  Text(
                    'NEW',
                    style: _metaText.copyWith(
                      fontWeight: FontWeight.w700,
                      color: VybeColors.mainLime500,
                    ),
                  ),
                ],
                const Spacer(),
                Text(
                  notice.dateLabel,
                  style: RenewGlass.caption(size: 11, lineHeight: 16),
                ),
              ],
            ),
            SizedBox(height: 6.h),
            Text(
              notice.title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: RenewGlass.body(
                color: RenewGlass.t1,
                weight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// 카테고리 배지 색. 문서에 정의된 5종(공지·업데이트·이벤트·점검·광고) 전부 채운다 —
/// 디자인에는 3종만 나와 있지만 나머지가 오면 색이 비어 배지가 안 보인다.
({Color fill, Color text}) _badgeTone(String category) => switch (category) {
  'update' => (fill: const Color(0x387731FE), text: RenewGlass.lavender),
  'event' => (
    fill: const Color(0x24B5FF60),
    text: VybeColors.mainLime500,
  ),
  'maint' => (fill: const Color(0x24FFD166), text: const Color(0xFFFFD166)),
  'ad' => (fill: const Color(0x2460A5FA), text: const Color(0xFF8FB5FF)),
  _ => (fill: const Color(0x1AFFFFFF), text: RenewGlass.t2),
};

/// 배지·NEW·날짜 공통 — 10.5px는 .sp 반올림에서 뭉개져 11px로 올린다.
final _metaText = TextStyle(
  fontFamily: 'Pretendard',
  fontSize: 11.sp,
  height: 16 / 11,
  letterSpacing: 11 * -0.025,
);

class _Skeleton extends StatelessWidget {
  const _Skeleton();

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(3, (i) {
        return Container(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
          decoration: i > 0
              ? const BoxDecoration(
                  border: Border(top: BorderSide(color: RenewGlass.hair)),
                )
              : null,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  VybeSkel(width: 38.w, height: 16.h),
                  const Spacer(),
                  VybeSkel(width: 56.w, height: 12.h),
                ],
              ),
              SizedBox(height: 8.h),
              VybeSkel(width: 180.w, height: 14.h),
            ],
          ),
        );
      }),
    );
  }
}
