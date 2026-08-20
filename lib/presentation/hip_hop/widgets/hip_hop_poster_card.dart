import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vybe/design_system/colors.dart';
import 'package:vybe/design_system/typography.dart';
import 'package:vybe/presentation/common/widgets/vybe_recommend_badge.dart';
import 'package:vybe/presentation/common/widgets/vybe_skeleton.dart';
import 'package:vybe/presentation/hip_hop/hip_hop_gradients.dart';
import 'package:vybe/presentation/hip_hop/hip_hop_style.dart';
import 'package:vybe/presentation/hip_hop/hip_hop_view_models.dart';

// 힙합 포스터 카드 — 클럽 + 오늘 라인업 머지 결과.

// ── 포스터 카드 ──
class HipHopPosterCard extends StatelessWidget {
  final HipHopClub club;
  final bool saved;
  final VoidCallback onSave;
  final VoidCallback onTap;
  const HipHopPosterCard({
    super.key,
    required this.club,
    required this.saved,
    required this.onSave,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          gradient: hipHopSlideGradient(club.bg),
          borderRadius: BorderRadius.circular(16.r),
        ),
        // ⚠ 테두리는 자식 위(foregroundDecoration)에. decoration 에 두면 자식이
        // 바깥 라운드렉트로 클립되면서 코너 호에서 선을 덮어, 직선부만 남고
        // 모서리가 끊긴 것처럼 보인다. (CLAUDE.md '라운드 카드에 테두리' 참고)
        foregroundDecoration: BoxDecoration(
          border: Border.all(color: VybeColors.gray800),
          borderRadius: BorderRadius.circular(16.r),
        ),
        child: Stack(
          fit: StackFit.expand,
          children: [
            // 클럽 썸네일(없으면 그라데이션만).
            if (club.thumbnailUrl.isNotEmpty)
              Positioned.fill(
                child: SkeletonImage(
                  url: club.thumbnailUrl,
                  fit: BoxFit.cover,
                  minSkeleton: const Duration(seconds: 1),
                ),
              ),
            const Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    center: Alignment(0.4, -0.76),
                    radius: 0.9,
                    colors: [Color(0x33FFFFFF), Color(0x00FFFFFF)],
                    stops: [0.0, 0.55],
                  ),
                ),
              ),
            ),
            const Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [
                      Color(0xF20A090B),
                      Color(0x330A090B),
                      Color(0x000A090B),
                    ],
                    stops: [0.16, 0.56, 0.80],
                  ),
                ),
              ),
            ),
            // 영업 상태.
            Positioned(
              top: 11.h,
              left: 11.w,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.42),
                  borderRadius: BorderRadius.circular(99.r),
                  border: Border.all(
                    color: club.open
                        ? VybeColors.mainLime500.withValues(alpha: 0.5)
                        : VybeColors.gray700,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 5.r,
                      height: 5.r,
                      decoration: BoxDecoration(
                        color: club.open
                            ? VybeColors.mainLime500
                            : VybeColors.gray500,
                        shape: BoxShape.circle,
                      ),
                    ),
                    SizedBox(width: 5.w),
                    Text(
                      club.open ? '영업중' : '영업종료',
                      style: VybeTypography.caption.copyWith(
                        fontSize: 10.sp,
                        height: 11 / 10,
                        fontWeight: FontWeight.w700,
                        color: club.open
                            ? VybeColors.mainLime500
                            : VybeColors.gray400,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // 찜.
            Positioned(
              top: 8.h,
              right: 8.w,
              child: GestureDetector(
                onTap: onSave,
                behavior: HitTestBehavior.opaque,
                child: Container(
                  width: 30.r,
                  height: 30.r,
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.42),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    saved
                        ? Icons.favorite_rounded
                        : Icons.favorite_border_rounded,
                    size: 15.r,
                    color: saved ? VybeColors.mainPurple500 : Colors.white,
                  ),
                ),
              ),
            ),
            // 본문.
            Positioned(
              left: 12.w,
              right: 12.w,
              bottom: 12.h,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (club.live) ...[
                    Container(
                      margin: EdgeInsets.only(bottom: 8.h),
                      padding: EdgeInsets.symmetric(
                        horizontal: 8.w,
                        vertical: 3.h,
                      ),
                      decoration: BoxDecoration(
                        color: kHipAccent.withValues(alpha: 0.18),
                        borderRadius: BorderRadius.circular(7.r),
                        border: Border.all(
                          color: kHipAccent.withValues(alpha: 0.36),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.mic_none_rounded,
                            size: 11.r,
                            color: kHipAccent,
                          ),
                          SizedBox(width: 4.w),
                          Text(
                            '${club.lineup} LIVE',
                            style: VybeTypography.caption.copyWith(
                              fontSize: 10.sp,
                              height: 11 / 10,
                              fontWeight: FontWeight.w700,
                              color: kHipAccent,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Flexible(
                        child: Text(
                          club.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontFamily: 'Pretendard',
                            fontSize: 18.sp,
                            height: 20 / 18,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      // VYBE 추천 뱃지 — 클럽 이름 옆.
                      if (club.vybe) ...[
                        SizedBox(width: 6.w),
                        const VybeRecommendBadge(size: 10),
                      ],
                      SizedBox(width: 6.w),
                      Icon(
                        Icons.star_rounded,
                        size: 11.r,
                        color: VybeColors.mainLime500,
                      ),
                      SizedBox(width: 2.w),
                      Text(
                        club.rating.toStringAsFixed(2),
                        style: VybeTypography.caption.copyWith(
                          fontSize: 11.sp,
                          height: 12 / 11,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 5.h),
                  Row(
                    children: [
                      Icon(
                        Icons.place_rounded,
                        size: 10.r,
                        color: VybeColors.gray400,
                      ),
                      SizedBox(width: 4.w),
                      Text(
                        '${club.area} · ${club.dist.toStringAsFixed(1)}km',
                        style: VybeTypography.caption.copyWith(
                          fontSize: 11.sp,
                          height: 12 / 11,
                          fontWeight: FontWeight.w600,
                          color: VybeColors.gray400,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8.h),
                  Wrap(
                    spacing: 5.w,
                    runSpacing: 5.h,
                    children: club.styles
                        .map(
                          (t) => Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 7.w,
                              vertical: 1.h,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.09),
                              borderRadius: BorderRadius.circular(6.r),
                            ),
                            child: Text(
                              '#$t',
                              style: VybeTypography.caption.copyWith(
                                fontSize: 10.sp,
                                height: 13 / 10,
                                fontWeight: FontWeight.w600,
                                color: VybeColors.gray300,
                              ),
                            ),
                          ),
                        )
                        .toList(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
