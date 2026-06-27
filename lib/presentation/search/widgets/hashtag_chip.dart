import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vybe/design_system/colors.dart';
import 'package:vybe/design_system/typography.dart';

class HashtagChip extends StatelessWidget {
  final String label;
  final VoidCallback? onTap;

  const HashtagChip({super.key, required this.label, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 13.w, vertical: 8.h),
        decoration: BoxDecoration(
          color: VybeColors.mainPurple500.withValues(alpha: 0.10),
          borderRadius: BorderRadius.circular(999.r),
          border: Border.all(
            color: VybeColors.mainPurple500.withValues(alpha: 0.32),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '#',
              style: VybeTypography.body4.copyWith(
                color: VybeColors.mainLime700,
                fontWeight: FontWeight.w700,
              ),
            ),
            SizedBox(width: 2.w),
            Text(
              label,
              style: VybeTypography.body4.copyWith(
                color: VybeColors.gray200,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
