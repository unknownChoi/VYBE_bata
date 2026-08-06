import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vybe/core/navigation/swipe_back_page_route.dart';
import 'package:vybe/data/models/notice_model.dart';
import 'package:vybe/design_system/colors.dart';
import 'package:vybe/design_system/typography.dart';
import 'package:vybe/presentation/clubs/widgets/club_glass.dart';
import 'package:vybe/presentation/common/widgets/vybe_fade_in_up.dart';
import 'package:vybe/presentation/common/widgets/vybe_glass_button.dart';
import 'package:vybe/presentation/common/widgets/vybe_glass_surface.dart';
import 'package:vybe/presentation/common/widgets/vybe_shimmer.dart';
import 'package:vybe/presentation/my_page/notice_detail_screen.dart';
import 'package:vybe/presentation/my_page/viewmodels/notice_viewmodel.dart';
import 'package:vybe/presentation/promotion/promotion_detail_screen.dart';
import 'package:vybe/presentation/my_page/widgets/notice_glass.dart';

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
    final bottomPad = 30.h + MediaQuery.of(context).padding.bottom;

    return Scaffold(
      backgroundColor: ClubGlass.ink,
      body: Stack(
        children: [
          const Positioned.fill(child: ClubAurora()),
          RefreshIndicator(
            color: VybeColors.mainLime500,
            backgroundColor: ClubGlass.ink,
            onRefresh: () async => ref.invalidate(noticesProvider),
            child: CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: [
                const SliverToBoxAdapter(child: _Header()),
                ...noticesAsync.when(
                  loading: () => [
                    const SliverToBoxAdapter(child: _Skeleton()),
                  ],
                  error: (_, __) => [
                    const SliverToBoxAdapter(
                      child: _Message('공지사항을 불러오지 못했어요'),
                    ),
                  ],
                  data: (notices) => notices.isEmpty
                      ? [const SliverToBoxAdapter(child: _Empty())]
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

  /// 공지 탭 → 상세. 단, 프로모션이 연결된 공지(광고)는 공지 본문을 거치지 않고
  /// 배너와 같은 광고 페이지로 바로 보낸다 — 같은 내용을 두 번 보게 하지 않으려고.
  /// 바텀 nav는 이 화면에 들어올 때 이미 내려가 있어 여기선 평범하게 push한다.
  void _open(BuildContext context, NoticeModel notice) {
    Navigator.of(context).push(
      SwipeBackPageRoute<void>(
        builder: (_) => notice.opensPromotion
            ? PromotionDetailScreen(promotionId: notice.promotionId)
            : NoticeDetailScreen(notice: notice),
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

/// 헤더 — 원형 글래스 뒤로가기 + '공지사항' + `vybe 운영팀`이 전하는 소식.
class _Header extends StatelessWidget {
  const _Header();

  @override
  Widget build(BuildContext context) {
    final top = MediaQuery.of(context).padding.top;

    return Padding(
      padding: EdgeInsets.fromLTRB(16.w, top + 8.h, 16.w, 18.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 앱 공통 리퀴드 글래스 버튼 (누르면 줄어들며 라임 글로우).
          VybeGlassButton(
            onTap: () => Navigator.of(context).maybePop(),
            size: 38,
            iconSize: 17,
            hitSize: 42,
          ),
          SizedBox(height: 18.h),
          Text(
            '공지사항',
            style: VybeTypography.heading1.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w800,
            ),
          ),
          SizedBox(height: 6.h),
          Row(
            children: [
              const NoticeTeamPill(),
              SizedBox(width: 7.w),
              Text(
                '이 전하는 소식',
                style: VybeTypography.body4.copyWith(color: ClubGlass.t3),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// 공지 1건 카드 (디자인 NCRow). 고정 공지는 카테고리 색으로 강조된다.
class NoticeCard extends StatelessWidget {
  final NoticeModel notice;
  final VoidCallback onTap;
  final Duration appearDelay;

  const NoticeCard({
    super.key,
    required this.notice,
    required this.onTap,
    this.appearDelay = Duration.zero,
  });

  @override
  Widget build(BuildContext context) {
    final c = noticeCatStyleOf(notice.category);
    final pinned = notice.isPinned;

    return VybeFadeInUp(
      delay: appearDelay,
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: VybeGlassSurface(
          radius: kNoticeCardRadius,
          fill: pinned ? ClubGlass.cardFill : VybeGlassSurface.quietFill,
          border: pinned ? c.ring : VybeGlassSurface.quietBorder,
          blurSigma: pinned ? ClubGlass.blurSigma : VybeGlassSurface.quietBlur,
          elevated: pinned,
          // 틴트·하이라이트는 여백 바깥(카드 전체)에 깔려야 해서 Stack이 padding을 감싼다.
          child: Stack(
            children: [
              if (pinned) Positioned.fill(child: GlassTintOverlay(tint: c.tint)),
              GlassTopHighlight(strong: pinned),
              Padding(
                padding: EdgeInsets.all(kNoticeCardPad.r),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _badgeRow(c),
                    SizedBox(height: 9.h),
                    _titleRow(pinned),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _badgeRow(NoticeCatStyle c) {
    return Row(
      children: [
        if (notice.isPinned) ...[
          const NoticeImportantPill(),
          SizedBox(width: 7.w),
        ],
        NoticeCategoryPill(style: c),
        const Spacer(),
        Text(
          notice.dateLabel,
          style: ClubGlass.caption(color: ClubGlass.t4, size: 11, lineHeight: 12),
        ),
      ],
    );
  }

  Widget _titleRow(bool pinned) {
    // 미리보기는 본문 첫 줄만 (디자인 body.split('\n')[0]).
    final preview = notice.content.split('\n').first.trim();

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      notice.title,
                      style: TextStyle(
                        fontFamily: 'Pretendard',
                        fontSize: 14.5.sp,
                        height: 21 / 14.5,
                        letterSpacing: 14.5 * -0.025,
                        fontWeight: pinned ? FontWeight.w700 : FontWeight.w600,
                        color: pinned ? Colors.white : ClubGlass.t2,
                      ),
                    ),
                  ),
                  if (notice.isNew) ...[
                    SizedBox(width: 7.w),
                    Padding(
                      padding: EdgeInsets.only(top: 2.h),
                      child: const NoticeNewBadge(),
                    ),
                  ],
                ],
              ),
              if (preview.isNotEmpty) ...[
                SizedBox(height: 5.h),
                Text(
                  preview,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: ClubGlass.caption(
                    color: ClubGlass.t4,
                    size: 12,
                    lineHeight: 18,
                  ),
                ),
              ],
            ],
          ),
        ),
        SizedBox(width: 8.w),
        Padding(
          padding: EdgeInsets.only(top: 5.h),
          child: Icon(
            Icons.chevron_right_rounded,
            size: 16.r,
            color: const Color(0x80FFFFFF),
          ),
        ),
      ],
    );
  }
}

/// 목록 로딩 스켈레톤 — 실제 카드와 같은 유리 껍데기 위에 shimmer 블록.
/// 로딩 → 목록 전환에서 레이아웃이 튀지 않도록 카드 높이를 맞춘다.
class _Skeleton extends StatelessWidget {
  const _Skeleton();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Column(
        children: [
          for (var i = 0; i < 4; i++) ...[
            if (i > 0) SizedBox(height: 10.h),
            const _SkeletonCard(),
          ],
        ],
      ),
    );
  }
}

class _SkeletonCard extends StatelessWidget {
  const _SkeletonCard();

  @override
  Widget build(BuildContext context) {
    return VybeGlassSurface.quiet(
      radius: kNoticeCardRadius,
      child: Padding(
        padding: EdgeInsets.all(kNoticeCardPad.r),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 배지 행 (카테고리 pill + 날짜).
            Row(
              children: [
                VybeShimmerBox(width: 52.w, height: 20.h, radius: 999.r),
                const Spacer(),
                VybeShimmerBox(width: 60.w, height: 12.h, radius: 6.r),
              ],
            ),
            SizedBox(height: 11.h),
            // 제목 + 미리보기 한 줄.
            VybeShimmerBox(widthFactor: 0.72, height: 14.h, radius: 6.r),
            SizedBox(height: 8.h),
            VybeShimmerBox(widthFactor: 0.92, height: 11.h, radius: 6.r),
          ],
        ),
      ),
    );
  }
}

class _Message extends StatelessWidget {
  final String text;

  const _Message(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 60.h, horizontal: 20.w),
      child: Center(
        child: Text(
          text,
          style: VybeTypography.body4.copyWith(color: ClubGlass.t3),
        ),
      ),
    );
  }
}

class _Empty extends StatelessWidget {
  const _Empty();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: GlassCard(
        padding: 34,
        child: Column(
          children: [
            Container(
              width: 74.r,
              height: 74.r,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: const Color(0x2E7731FE), // rgba(119,49,254,0.18)
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0x4D7731FE)),
              ),
              child: Icon(
                Icons.campaign_outlined,
                size: 30.r,
                color: const Color(0x80FFFFFF),
              ),
            ),
            SizedBox(height: 13.h),
            Text(
              '등록된 공지가 없어요',
              style: VybeTypography.heading4
                  .copyWith(color: Colors.white, fontWeight: FontWeight.w700),
            ),
            SizedBox(height: 13.h),
            Text(
              '새로운 소식이 생기면\n여기에 가장 먼저 올려드릴게요',
              textAlign: TextAlign.center,
              style: VybeTypography.body4
                  .copyWith(color: ClubGlass.t3, height: 20 / 14),
            ),
          ],
        ),
      ),
    );
  }
}
