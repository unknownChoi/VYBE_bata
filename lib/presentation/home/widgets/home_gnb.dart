import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:vybe/design_system/colors.dart';
import 'package:vybe/presentation/notifications/notification_screen.dart';

class HomeGnb extends StatelessWidget {
  final VoidCallback? onSearchTap;
  final bool scrolled;

  const HomeGnb({super.key, this.onSearchTap, this.scrolled = false});

  @override
  Widget build(BuildContext context) {
    final top = MediaQuery.of(context).padding.top;

    return ClipRect(
      child: BackdropFilter(
        filter: scrolled
            ? ImageFilter.blur(sigmaX: 18, sigmaY: 18)
            : ImageFilter.blur(sigmaX: 0, sigmaY: 0),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: EdgeInsets.fromLTRB(20.w, top + 6.h, 20.w, 10.h),
          decoration: BoxDecoration(
            color: scrolled
                ? VybeColors.background.withValues(alpha: 0.82)
                : Colors.transparent,
            border: Border(
              bottom: BorderSide(
                color: scrolled ? VybeColors.gray900 : Colors.transparent,
              ),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              SvgPicture.asset(
                'assets/icons/common/vybe_white_logo.svg',
                height: 22.h,
              ),
              Row(
                children: [
                  _IconBtn(
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
                  SizedBox(width: 4.w),
                  _IconBtn(
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const NotificationScreen(),
                      ),
                    ),
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        SvgPicture.asset(
                          'assets/icons/home_screen/notification.svg',
                          width: 24.r,
                          height: 24.r,
                          colorFilter: const ColorFilter.mode(
                            Colors.white,
                            BlendMode.srcIn,
                          ),
                        ),
                        Positioned(
                          top: 1.r,
                          right: 1.r,
                          child: Container(
                            width: 7.r,
                            height: 7.r,
                            decoration: BoxDecoration(
                              color: VybeColors.mainPurple500,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: VybeColors.background,
                                width: 1.5,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _IconBtn extends StatelessWidget {
  final Widget child;
  final VoidCallback? onTap;
  const _IconBtn({required this.child, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 40.w,
        height: 40.h,
        child: Center(child: child),
      ),
    );
  }
}
