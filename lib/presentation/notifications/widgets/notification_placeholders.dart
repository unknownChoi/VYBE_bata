import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vybe/design_system/colors.dart';
import 'package:vybe/design_system/typography.dart';
import 'package:vybe/presentation/clubs/widgets/club_glass.dart';
import 'package:vybe/presentation/common/widgets/vybe_glass_surface.dart';
import 'package:vybe/presentation/common/widgets/vybe_shimmer.dart';
import 'package:vybe/presentation/notifications/widgets/noti_glass.dart';

/// 알림이 하나도 없을 때 (디자인 NGEmpty).
class NotificationEmpty extends StatelessWidget {
  final String label;

  const NotificationEmpty({super.key, required this.label});

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: 34,
      margin: EdgeInsets.only(top: 14.h),
      child: Column(
        children: [
          Container(
            width: 74.r,
            height: 74.r,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: VybeColors.mainPurple500.withValues(alpha: 0.16),
              shape: BoxShape.circle,
              border: Border.all(
                color: VybeColors.mainPurple500.withValues(alpha: 0.30),
              ),
            ),
            child: Icon(
              Icons.notifications_none_rounded,
              size: 30.r,
              color: const Color(0x80FFFFFF),
            ),
          ),
          SizedBox(height: 13.h),
          Text(
            label,
            style: VybeTypography.heading4
                .copyWith(color: Colors.white, fontWeight: FontWeight.w700),
          ),
          SizedBox(height: 13.h),
          Text(
            '새로운 소식이 오면\n여기에서 가장 먼저 알려드릴게요',
            textAlign: TextAlign.center,
            style: VybeTypography.body4
                .copyWith(color: ClubGlass.t3, height: 20 / 14),
          ),
        ],
      ),
    );
  }
}

/// 목록 로딩 스켈레톤 (디자인 NGSkeleton) — 섹션 라벨 + 카드 4장.
class NotificationSkeleton extends StatelessWidget {
  const NotificationSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(16.w, 4.h, 16.w, 24.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(4.w, 20.h, 4.w, 10.h),
            child: VybeShimmerBox(width: 54.w, height: 12.h, radius: 6.r),
          ),
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
      radius: NotiGlass.cardRadius,
      child: Padding(
        padding: EdgeInsets.all(NotiGlass.cardPad.r),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            VybeShimmerBox(width: 44.r, height: 44.r, radius: 14.r),
            SizedBox(width: 12.w),
            Expanded(
              child: Padding(
                padding: EdgeInsets.only(top: 3.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 제목 한 줄 + 본문 두 줄.
                    VybeShimmerBox(widthFactor: 0.62, height: 13.h, radius: 6.r),
                    SizedBox(height: 8.h),
                    VybeShimmerBox(widthFactor: 0.92, height: 10.h, radius: 6.r),
                    SizedBox(height: 8.h),
                    VybeShimmerBox(widthFactor: 0.45, height: 10.h, radius: 6.r),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
