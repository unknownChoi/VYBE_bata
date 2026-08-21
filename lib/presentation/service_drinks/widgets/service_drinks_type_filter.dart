import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vybe/design_system/colors.dart';
import 'package:vybe/design_system/typography.dart';
import 'package:vybe/presentation/common/club_list_sorting.dart';
import 'package:vybe/presentation/service_drinks/service_drinks_style.dart';

/// 음료 종류 가로 필터 칩 줄 (전체 · 양주 · 샴페인 …).
class ServiceDrinksTypeFilter extends StatelessWidget {
  final String active;
  final ValueChanged<String> onChange;

  const ServiceDrinksTypeFilter({
    super.key,
    required this.active,
    required this.onChange,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 50.h,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 8.h),
        itemCount: kDrinkTypes.length,
        separatorBuilder: (_, __) => SizedBox(width: 8.w),
        itemBuilder: (_, i) {
          final type = kDrinkTypes[i];
          return _Chip(
            label: type,
            selected: type == active,
            // '전체'는 종류가 아니라 해제라 술잔 아이콘을 달지 않는다.
            showIcon: type != kFilterAll,
            onTap: () => onChange(type),
          );
        },
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  final String label;
  final bool selected;
  final bool showIcon;
  final VoidCallback onTap;

  const _Chip({
    required this.label,
    required this.selected,
    required this.showIcon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 14.w),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: selected ? kDrinkAccent : VybeColors.gray900,
          borderRadius: BorderRadius.circular(999.r),
          border: selected ? null : Border.all(color: VybeColors.gray800),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (showIcon) ...[
              Icon(
                Icons.liquor_rounded,
                size: 13.r,
                color: selected ? kDrinkInk : kDrinkAccent,
              ),
              SizedBox(width: 4.w),
            ],
            Text(
              label,
              style: VybeTypography.button2.copyWith(
                fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                color: selected ? kDrinkInk : VybeColors.gray300,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
