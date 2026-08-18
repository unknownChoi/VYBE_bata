import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:vybe/core/navigation/swipe_back_page_route.dart';
import 'package:vybe/design_system/colors.dart';
import 'package:vybe/presentation/common/widgets/vybe_glass_button.dart';
import 'package:vybe/presentation/notifications/notification_screen.dart';

/// 홈 상단 바 로고의 위치·크기(디자인 px).
///
/// 스플래시 퇴장 애니메이션이 로고를 **정확히 이 자리로** 날려 보낸 뒤 사라진다
/// ([VybeSplash.logoLanding]). 값이 어긋나면 착지 순간 로고가 한 칸 튀므로
/// 상수 하나를 양쪽이 같이 본다.
const kHomeGnbHPadding = 20.0;
const kHomeGnbTopGap = 6.0;
const kHomeGnbLogoHeight = 22.0;

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
          padding: EdgeInsets.fromLTRB(
            kHomeGnbHPadding.w,
            top + kHomeGnbTopGap.h,
            kHomeGnbHPadding.w,
            10.h,
          ),
          decoration: BoxDecoration(
            // 구분선 없음 — 블러 + 배경 농도만으로 본문과 나눈다.
            color: scrolled
                ? VybeColors.background.withValues(alpha: 0.82)
                : Colors.transparent,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              SvgPicture.asset(
                'assets/icons/common/vybe_white_logo.svg',
                height: kHomeGnbLogoHeight.h,
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
