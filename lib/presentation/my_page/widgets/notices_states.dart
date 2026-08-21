import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vybe/design_system/typography.dart';
import 'package:vybe/presentation/clubs/widgets/club_glass.dart';
import 'package:vybe/presentation/common/widgets/vybe_glass_surface.dart';
import 'package:vybe/presentation/common/widgets/vybe_shimmer.dart';
import 'package:vybe/presentation/my_page/widgets/notice_glass.dart';

/// 공지 목록의 로딩·오류·빈 상태 화면.

/// 목록 로딩 스켈레톤 — 실제 카드와 같은 유리 껍데기 위에 shimmer 블록.
/// 로딩 → 목록 전환에서 레이아웃이 튀지 않도록 카드 높이를 맞춘다.
class NoticesSkeleton extends StatelessWidget {
  const NoticesSkeleton({super.key});

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

class NoticesMessage extends StatelessWidget {
  final String text;

  const NoticesMessage(this.text, {super.key});

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

class NoticesEmpty extends StatelessWidget {
  const NoticesEmpty({super.key});

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
              style: VybeTypography.heading4.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w700,
              ),
            ),
            SizedBox(height: 13.h),
            Text(
              '새로운 소식이 생기면\n여기에 가장 먼저 올려드릴게요',
              textAlign: TextAlign.center,
              style: VybeTypography.body4.copyWith(
                color: ClubGlass.t3,
                height: 20 / 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
