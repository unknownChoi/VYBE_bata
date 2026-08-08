import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vybe/design_system/colors.dart';
import 'package:vybe/design_system/typography.dart';
import 'package:vybe/presentation/hip_hop/hip_hop_style.dart';

// 힙합 페이지 섹션 헤더 · 지역 필터 칩.

const kHipHopAreas = ['인기순', '홍대', '강남', '압구정', '이태원', '건대'];

// ── 섹션 헤더 ──
class HipHopSectionHead extends StatelessWidget {
  final String title;
  final String sub;
  final bool mapAction;
  final VoidCallback? onMapTap;
  final VoidCallback? onAllTap;
  final double bottomGap;
  const HipHopSectionHead({super.key, 
    required this.title,
    required this.sub,
    this.mapAction = false,
    this.onMapTap,
    this.onAllTap,
    this.bottomGap = 13,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(left: 16.w, right: 16.w, bottom: bottomGap.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontFamily: 'Pretendard',
                    fontSize: 19.sp,
                    height: 22 / 19,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 5.h),
                Text(
                  sub,
                  style: VybeTypography.caption.copyWith(
                    height: 16 / 12,
                    color: VybeColors.gray500,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: 8.w),
          if (mapAction)
            GestureDetector(
              onTap: onMapTap,
              behavior: HitTestBehavior.opaque,
              child: Container(
                height: 30.h,
                padding: EdgeInsets.symmetric(horizontal: 11.w),
                decoration: BoxDecoration(
                  color: VybeColors.gray900,
                  borderRadius: BorderRadius.circular(99.r),
                  border: Border.all(color: VybeColors.gray800),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.place_rounded, size: 13.r, color: kHipAccent),
                    SizedBox(width: 4.w),
                    Text(
                      '지도에서 보기',
                      style: VybeTypography.caption.copyWith(
                        height: 14 / 12,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            GestureDetector(
              onTap: onAllTap,
              behavior: HitTestBehavior.opaque,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '전체',
                    style: VybeTypography.caption.copyWith(
                      height: 14 / 12,
                      fontWeight: FontWeight.w600,
                      color: VybeColors.gray500,
                    ),
                  ),
                  Icon(
                    Icons.chevron_right_rounded,
                    size: 14.r,
                    color: VybeColors.gray500,
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

// ── 지역 필터 ──
class HipHopAreaFilter extends StatelessWidget {
  final String active;
  final ValueChanged<String> onChange;
  const HipHopAreaFilter({super.key, required this.active, required this.onChange});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 34.h,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.only(left: 16.w, right: 16.w),
        itemCount: kHipHopAreas.length,
        separatorBuilder: (_, __) => SizedBox(width: 8.w),
        itemBuilder: (_, i) {
          final s = kHipHopAreas[i];
          final sel = s == active;
          final fg = sel ? kHipOnAccent : VybeColors.gray300;
          return GestureDetector(
            onTap: () => onChange(s),
            child: Container(
              height: 34.h,
              padding: EdgeInsets.symmetric(horizontal: 15.w),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: sel ? kHipAccent : VybeColors.gray900,
                borderRadius: BorderRadius.circular(999.r),
                border: sel ? null : Border.all(color: VybeColors.gray800),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (s != '인기순') ...[
                    Icon(
                      Icons.place_rounded,
                      size: 12.r,
                      color: sel ? kHipOnAccent : VybeColors.gray400,
                    ),
                    SizedBox(width: 5.w),
                  ],
                  Text(
                    s,
                    style: VybeTypography.button2.copyWith(
                      fontWeight: sel ? FontWeight.w700 : FontWeight.w500,
                      color: fg,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
