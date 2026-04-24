import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:vybe/design_system/colors.dart';
import 'package:vybe/design_system/typography.dart';

class ResultGnb extends StatelessWidget {
  final String query;
  final VoidCallback? onBack;

  const ResultGnb({super.key, required this.query, this.onBack});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 10.h),
      child: Row(
        children: [
          GestureDetector(
            onTap: onBack ?? () => Navigator.of(context).pop(),
            behavior: HitTestBehavior.opaque,
            child: SvgPicture.asset(
              'assets/icons/common/arrow_back.svg',
              width: 24.r,
              height: 24.r,
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Container(
              height: 44.h,
              decoration: BoxDecoration(
                color: VybeColors.gray800,
                borderRadius: BorderRadius.circular(999.r),
              ),
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      query,
                      style: VybeTypography.body4
                          .copyWith(color: Colors.white),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  SvgPicture.asset(
                    'assets/icons/common/search.svg',
                    width: 18.r,
                    height: 18.r,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
