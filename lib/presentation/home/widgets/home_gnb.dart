import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:vybe/core/navigation/swipe_back_page_route.dart';
import 'package:vybe/design_system/colors.dart';
import 'package:vybe/presentation/common/widgets/vybe_glass_button.dart';
import 'package:vybe/presentation/notifications/notification_screen.dart';

class HomeGnb extends StatelessWidget {
  final VoidCallback? onSearchTap;
  final bool scrolled;

  const HomeGnb({super.key, this.onSearchTap, this.scrolled = false});

  @override
  Widget build(BuildContext context) {
    final top = MediaQuery.paddingOf(context).top;

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
                  VybeGlassButton(
                    icon: Icons.search_rounded,
                    onTap: onSearchTap ?? () {},
                    size: 36,
                    iconSize: 20,
                    hitSize: 40,
                  ),
                  SizedBox(width: 4.w),
                  Stack(
                    clipBehavior: Clip.none,
                    children: [
                      VybeGlassButton(
                        icon: Icons.notifications_none_rounded,
                        onTap: () => Navigator.of(context).push(
                          SwipeBackPageRoute(
                            builder: (_) => const NotificationScreen(),
                          ),
                        ),
                        size: 36,
                        iconSize: 20,
                        hitSize: 40,
                      ),
                      Positioned(
                        top: 8.r,
                        right: 8.r,
                        child: IgnorePointer(
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
                      ),
                    ],
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
