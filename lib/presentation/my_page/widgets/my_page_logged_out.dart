import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vybe/core/navigation/swipe_back_page_route.dart';
import 'package:vybe/design_system/colors.dart';
import 'package:vybe/design_system/typography.dart';
import 'package:vybe/presentation/auth/welcome/welcome_screen.dart';
import 'package:vybe/presentation/common/renew/renew_glass.dart';
import 'package:vybe/presentation/common/renew/renew_icons.dart';
import 'package:vybe/presentation/my_page/widgets/my_page_common.dart';

/// 비로그인 마이페이지 — 안내 + 로그인 버튼.
class MyPageLoggedOutView extends StatelessWidget {
  const MyPageLoggedOutView({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const MyGlassTile(icon: RenewIcons.user, size: 72, radius: 22),
          SizedBox(height: 18.h),
          Text('로그인이 필요해요', style: RenewGlass.title()),
          SizedBox(height: 8.h),
          Text(
            '로그인하고 리뷰·찜 목록을 관리해 보세요',
            style: RenewGlass.body(color: RenewGlass.t4),
          ),
          SizedBox(height: 24.h),
          GestureDetector(
            // 로그인은 탭 안이 아니라 루트에 띄운다 — 성공 시 AuthGate가
            // 루트를 갈아 끼우므로 탭 Navigator 안에 있으면 안 된다.
            onTap: () => Navigator.of(
              context,
              rootNavigator: true,
            ).push(SwipeBackPageRoute(builder: (_) => const WelcomeScreen())),
            child: Container(
              height: 48.h,
              padding: EdgeInsets.symmetric(horizontal: 34.w),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: VybeColors.mainPurple500,
                borderRadius: BorderRadius.circular(999.r),
              ),
              child: Text(
                '로그인하기',
                style: VybeTypography.button1.copyWith(
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
