import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vybe/design_system/colors.dart';
import 'package:vybe/design_system/typography.dart';
import 'package:vybe/presentation/hot_places/hot_places_models.dart';
// ── 지역 필터 ──
class HotPlacesAreaFilter extends StatelessWidget {
  final String active;
  final bool scrolled;
  final ValueChanged<String> onChange;
  const HotPlacesAreaFilter({super.key, required this.active, required this.scrolled, required this.onChange});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: scrolled ? VybeColors.background.withValues(alpha: 0.92) : Colors.transparent,
      padding: EdgeInsets.fromLTRB(16.w, 10.h, 16.w, 12.h),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            for (final a in kHotAreas) ...[
              _HotPlacesChip(label: a, selected: a == active, onTap: () => onChange(a)),
              if (a != kHotAreas.last) SizedBox(width: 8.w),
            ],
          ],
        ),
      ),
    );
  }
}

class _HotPlacesChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const _HotPlacesChip({required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final isNear = label == '내 주변';
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: EdgeInsets.only(
          left: isNear ? 11.w : 16.w,
          right: 16.w,
          top: 8.h,
          bottom: 8.h,
        ),
        decoration: BoxDecoration(
          color: selected ? Colors.white : VybeColors.gray900,
          borderRadius: BorderRadius.circular(999.r),
          border: selected ? null : Border.all(color: VybeColors.gray800),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isNear) ...[
              Icon(Icons.place, size: 13.r, color: selected ? Colors.black : kHotAccent),
              SizedBox(width: 4.w),
            ],
            Text(
              label,
              style: VybeTypography.button2.copyWith(
                fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                color: selected ? Colors.black : VybeColors.gray300,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
