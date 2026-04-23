import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vybe/design_system/colors.dart';
import 'package:vybe/design_system/typography.dart';

class HashtagChip extends StatelessWidget {
  final String label;

  const HashtagChip({super.key, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 24.h,
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: VybeColors.gray900,
        borderRadius: BorderRadius.circular(999.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '# ',
            style: VybeTypography.body4.copyWith(color: VybeColors.mainLime500),
          ),
          Text(
            label,
            style: VybeTypography.body4.copyWith(color: VybeColors.gray400),
          ),
        ],
      ),
    );
  }
}
