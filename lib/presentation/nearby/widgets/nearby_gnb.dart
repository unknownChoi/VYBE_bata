import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:vybe/design_system/colors.dart';
import 'package:vybe/presentation/search/widgets/filter_chip_bar.dart';

class NearbyGnb extends StatelessWidget {
  final VoidCallback? onSearchTap;
  final VoidCallback? onBackTap;

  const NearbyGnb({super.key, this.onSearchTap, this.onBackTap});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildTopBar(),
        const FilterChipBar(hasBackground: true),
      ],
    );
  }

  Widget _buildTopBar() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 10.h),
      child: Row(
        children: [
          _CircleIconButton(
            onTap: onBackTap,
            child: SvgPicture.asset(
              'assets/icons/common/arrow_back.svg',
              width: 13.r,
              height: 22.r,
              colorFilter: const ColorFilter.mode(
                Colors.white,
                BlendMode.srcIn,
              ),
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(child: _SearchBar(onTap: onSearchTap)),
        ],
      ),
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
      child: Container(
        height: 42.h,
        decoration: BoxDecoration(
          color: VybeColors.gray800,
          borderRadius: BorderRadius.circular(999.r),
        ),
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        child: Row(
          children: [
            Expanded(
              child: Text(
                '클럽 이름, 지역으로 검색',
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
            SizedBox(width: 8.w),
            SvgPicture.asset(
              'assets/icons/common/search.svg',
              width: 18.r,
              height: 18.r,
              colorFilter: const ColorFilter.mode(
                VybeColors.gray500,
                BlendMode.srcIn,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CircleIconButton extends StatelessWidget {
  final Widget child;
  final VoidCallback? onTap;

  const _CircleIconButton({required this.child, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 36.r,
        height: 36.r,
        decoration: BoxDecoration(
          color: VybeColors.surface,
          shape: BoxShape.circle,
        ),
        child: Center(child: child),
      ),
    );
  }
}
