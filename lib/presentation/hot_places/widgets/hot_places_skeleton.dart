import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vybe/design_system/colors.dart';
import 'package:vybe/design_system/typography.dart';
import 'package:vybe/presentation/common/widgets/vybe_shimmer.dart';
import 'package:vybe/presentation/hot_places/widgets/hot_places_list_row.dart';

// 핫플레이스 로딩 스켈레톤 · 하단 안내.

// ── 푸터 안내 ──
class HotPlacesFooter extends StatelessWidget {
  const HotPlacesFooter({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(20.w, 18.h, 20.w, 8.h),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
        decoration: BoxDecoration(
          color: VybeColors.gray900,
          borderRadius: BorderRadius.circular(14.r),
          border: Border.all(color: VybeColors.gray800),
        ),
        child: Row(
          children: [
            const HotFlameIcon(size: 15),
            SizedBox(width: 10.w),
            Expanded(
              child: Text(
                '순위는 실시간 방문자 수와 혼잡도를 반영해 10분마다 갱신돼요.',
                style: VybeTypography.caption.copyWith(height: 17 / 12, color: VybeColors.gray400),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── 스켈레톤 ──
class HotPlacesSkeleton extends StatelessWidget {
  const HotPlacesSkeleton({super.key});
  @override
  Widget build(BuildContext context) {
    return ListView(
      physics: const NeverScrollableScrollPhysics(),
      children: [
        Padding(
          padding: EdgeInsets.fromLTRB(24.w, 20.h, 24.w, 18.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              VybeShimmerBox(widthFactor: 0.75, height: 28.h, radius: 6.r),
              SizedBox(height: 12.h),
              VybeShimmerBox(width: 150.w, height: 26.h, radius: 999.r),
            ],
          ),
        ),
        Padding(
          padding: EdgeInsets.fromLTRB(16.w, 10.h, 16.w, 12.h),
          child: Row(
            children: [
              for (final w in [52.0, 60.0, 60.0, 70.0, 56.0]) ...[
                VybeShimmerBox(width: w.w, height: 34.h, radius: 999.r),
                SizedBox(width: 8.w),
              ],
            ],
          ),
        ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 6.h),
          child: IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(flex: 58, child: VybeShimmerBox(height: 188.h, radius: 16.r)),
                SizedBox(width: 10.w),
                Expanded(
                  flex: 42,
                  child: Column(
                    children: [
                      VybeShimmerBox(height: 89.h, radius: 16.r),
                      SizedBox(height: 10.h),
                      VybeShimmerBox(height: 89.h, radius: 16.r),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        for (var i = 0; i < 3; i++)
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 14.h),
            child: Row(
              children: [
                VybeShimmerBox(width: 20.w, height: 20.h, radius: 6.r),
                SizedBox(width: 13.w),
                VybeShimmerBox(width: 72.w, height: 72.h, radius: 12.r),
                SizedBox(width: 13.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      VybeShimmerBox(widthFactor: 0.45, height: 14.h, radius: 6.r),
                      SizedBox(height: 9.h),
                      VybeShimmerBox(widthFactor: 0.75, height: 11.h, radius: 6.r),
                      SizedBox(height: 9.h),
                      VybeShimmerBox(widthFactor: 1, height: 5.h, radius: 99.r),
                    ],
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}
