import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vybe/design_system/colors.dart';
import 'package:vybe/design_system/typography.dart';
import 'package:vybe/presentation/common/widgets/vybe_shimmer.dart';

// VYBE 추천 로딩 · 빈 목록 · 오류 상태.

// ── 빈 상태 ──
class RecommendEmptyView extends StatelessWidget {
  const RecommendEmptyView({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 40.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.auto_awesome, size: 36.r, color: VybeColors.gray700),
            SizedBox(height: 14.h),
            Text('이번 주 추천이 아직 준비 중이에요',
                textAlign: TextAlign.center,
                style: VybeTypography.body3.copyWith(color: VybeColors.gray400)),
          ],
        ),
      ),
    );
  }
}

// ── 에러 상태 ──
class RecommendErrorView extends StatelessWidget {
  const RecommendErrorView({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 40.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline_rounded,
                size: 36.r, color: VybeColors.gray700),
            SizedBox(height: 14.h),
            Text('추천을 불러오지 못했어요',
                textAlign: TextAlign.center,
                style: VybeTypography.body3.copyWith(color: VybeColors.gray400)),
          ],
        ),
      ),
    );
  }
}

// ── 스켈레톤 ──
class RecommendSkeleton extends StatelessWidget {
  const RecommendSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    final top = MediaQuery.paddingOf(context).top;
    return SingleChildScrollView(
      physics: const NeverScrollableScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(24.w, top + 60.h, 24.w, 26.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                VybeShimmerBox(width: 120.w, height: 28.h, radius: 999.r),
                SizedBox(height: 14.h),
                VybeShimmerBox(width: 280.w, height: 30.h, radius: 8.r),
                SizedBox(height: 14.h),
                VybeShimmerBox(width: 200.w, height: 18.h, radius: 6.r),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 0),
            child: Column(
              children: [
                VybeShimmerBox(
                    width: double.infinity, height: 230.h, radius: 20.r),
                SizedBox(height: 16.h),
                VybeShimmerBox(width: double.infinity, height: 14.h, radius: 6.r),
                SizedBox(height: 12.h),
                VybeShimmerBox(width: double.infinity, height: 46.h, radius: 13.r),
              ],
            ),
          ),
          for (var i = 0; i < 3; i++)
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  VybeShimmerBox(width: 22.w, height: 24.h, radius: 6.r),
                  SizedBox(width: 14.w),
                  VybeShimmerBox(width: 84.r, height: 84.r, radius: 12.r),
                  SizedBox(width: 14.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        VybeShimmerBox(width: 120.w, height: 14.h, radius: 6.r),
                        SizedBox(height: 9.h),
                        VybeShimmerBox(width: 180.w, height: 11.h, radius: 6.r),
                        SizedBox(height: 9.h),
                        VybeShimmerBox(width: 240.w, height: 11.h, radius: 6.r),
                      ],
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
