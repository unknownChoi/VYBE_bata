import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:vybe/design_system/colors.dart';

class NearbyGnb extends StatelessWidget {
  final VoidCallback? onSearchTap;

  const NearbyGnb({
    super.key,
    this.onSearchTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(height: 8.h),
        _buildSearchBar(),
      ],
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 8.h),
      child: _SearchBar(onTap: onSearchTap),
    );
  }
}

class _SearchBar extends StatelessWidget {
  final VoidCallback? onTap;

  const _SearchBar({this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(999.r),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
          child: Container(
            height: 44.h,
            decoration: BoxDecoration(
              color: const Color(0xD9101013),
              borderRadius: BorderRadius.circular(999.r),
              border: Border.all(color: VybeColors.gray800, width: 1),
            ),
            padding: EdgeInsets.symmetric(horizontal: 14.w),
            child: Row(
              children: [
                SvgPicture.asset(
                  'assets/icons/common/search.svg',
                  width: 18.r,
                  height: 18.r,
                  colorFilter: const ColorFilter.mode(
                    VybeColors.gray500,
                    BlendMode.srcIn,
                  ),
                ),
                SizedBox(width: 8.w),
                Expanded(
                  child: Text(
                    '홍대 / 클럽 이름 검색',
                    style: TextStyle(
                      fontFamily: 'Pretendard',
                      fontWeight: FontWeight.w400,
                      fontSize: 14.sp,
                      height: 16 / 14,
                      letterSpacing: 14 * -0.025,
                      color: VybeColors.gray600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

