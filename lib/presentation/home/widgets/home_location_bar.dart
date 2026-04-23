import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:vybe/design_system/colors.dart';
import 'package:vybe/design_system/typography.dart';

class HomeLocationBar extends StatelessWidget {
  const HomeLocationBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 10.h),
      child: Row(
        children: [
          SvgPicture.asset(
            'assets/icons/home_screen/loaction_pin.svg',
            width: 16.r,
            height: 16.r,
            colorFilter: const ColorFilter.mode(
              VybeColors.gray200,
              BlendMode.srcIn,
            ),
          ),
          SizedBox(width: 4.w),
          Text(
            '내 주변 검색',
            style: VybeTypography.body3.copyWith(color: VybeColors.gray200),
          ),
        ],
      ),
    );
  }
}
