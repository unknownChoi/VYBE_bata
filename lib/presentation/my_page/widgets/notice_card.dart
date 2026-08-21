import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vybe/data/models/notice_model.dart';
import 'package:vybe/presentation/clubs/widgets/club_glass.dart';
import 'package:vybe/presentation/common/widgets/vybe_fade_in_up.dart';
import 'package:vybe/presentation/common/widgets/vybe_glass_surface.dart';
import 'package:vybe/presentation/my_page/widgets/notice_glass.dart';

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
              if (pinned)
                Positioned.fill(child: GlassTintOverlay(tint: c.tint)),
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
          style: ClubGlass.caption(
            color: ClubGlass.t4,
            size: 11,
            lineHeight: 12,
          ),
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
