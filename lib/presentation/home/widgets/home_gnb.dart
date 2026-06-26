import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:vybe/presentation/notifications/notification_screen.dart';

class HomeGnb extends StatelessWidget {
  final VoidCallback? onSearchTap;

  const HomeGnb({super.key, this.onSearchTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 10.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          SvgPicture.asset(
            'assets/icons/common/vybe_white_logo.svg',
            height: 20.h,
          ),
          Row(
            children: [
              GestureDetector(
                onTap: onSearchTap,
                child: SvgPicture.asset(
                  'assets/icons/home_screen/search.svg',
                  width: 24.r,
                  height: 24.r,
                  colorFilter: const ColorFilter.mode(
                    Colors.white,
                    BlendMode.srcIn,
                  ),
                ),
              ),
              SizedBox(width: 12.w),
              GestureDetector(
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const NotificationScreen(),
                  ),
                ),
                child: SvgPicture.asset(
                  'assets/icons/home_screen/notification.svg',
                  width: 24.r,
                  height: 24.r,
                  colorFilter: const ColorFilter.mode(
                    Colors.white,
                    BlendMode.srcIn,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
