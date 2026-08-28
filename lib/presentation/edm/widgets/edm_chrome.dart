import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vybe/design_system/colors.dart';
import 'package:vybe/design_system/typography.dart';
import 'package:vybe/presentation/common/filter_chip_style.dart';

// EDM 페이지 섹션 헤더 · 필터 칩 줄 · 우측 액션 pill.

/// 지역 필터 항목 — 디자인(edm_renew.jsx `AREAS`) 그대로.
const kEdmAreas = ['추천순', '홍대', '강남', '압구정', '이태원', '건대'];

/// 장르(세부 스타일) 필터의 '전체' 항목.
const kEdmAllStyles = '전체';

/// 섹션 헤더 — 제목 + 부제 + (선택) 우측 액션.
class EdmSectionHead extends StatelessWidget {
  final String title;
  final String sub;

  /// 우측에 붙는 것(지도 pill 등). null이면 제목만.
  final Widget? right;

  final double bottomGap;

  const EdmSectionHead({
    super.key,
    required this.title,
    required this.sub,
    this.right,
    this.bottomGap = 14,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(left: 16.w, right: 16.w, bottom: bottomGap.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontFamily: 'Pretendard',
                    fontSize: 20.sp,
                    height: 23 / 20,
                    letterSpacing: 20 * -0.025,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 6.h),
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
          if (right != null) ...[SizedBox(width: 12.w), right!],
        ],
      ),
    );
  }
}

/// 섹션 헤더 우측 pill (지도에서 보기 등).
class EdmHeadAction extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color iconColor;
  final VoidCallback onTap;

  const EdmHeadAction({
    super.key,
    required this.label,
    required this.icon,
    required this.iconColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        height: 30.h,
        padding: EdgeInsets.symmetric(horizontal: 11.w),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: VybeColors.gray900,
          borderRadius: BorderRadius.circular(99.r),
          border: Border.all(color: VybeColors.gray800),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 13.r, color: iconColor),
            SizedBox(width: 4.w),
            Text(
              label,
              style: VybeTypography.caption.copyWith(
                height: 14 / 12,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// 가로 스크롤 필터 칩 줄. 칩 한 알의 외형은 앱 공용([VybeGlassFilterChip]).
class EdmChipRow extends StatelessWidget {
  final List<String> items;
  final String active;
  final ValueChanged<String> onChange;

  /// 라벨 앞 아이콘. [iconExcept] 와 같은 항목에는 안 붙인다.
  final IconData? icon;
  final String? iconExcept;

  const EdmChipRow({
    super.key,
    required this.items,
    required this.active,
    required this.onChange,
    this.icon,
    this.iconExcept,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 34.h,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        itemCount: items.length,
        separatorBuilder: (_, __) => SizedBox(width: 8.w),
        itemBuilder: (_, i) {
          final label = items[i];
          return VybeGlassFilterChip(
            label: label,
            selected: label == active,
            icon: label == iconExcept ? null : icon,
            iconSize: 12,
            hPadding: 15,
            onTap: () => onChange(label),
          );
        },
      ),
    );
  }
}
