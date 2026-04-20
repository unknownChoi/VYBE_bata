// TODO: welcome_screen.dart
// 앱 진입 후 최초 표시되는 웰컴(로그인) 화면
// - VYBE 로고 + 태그라인 ("바이브 탈 준비 됐어? 우린 끝냈어!")
// - 카카오 / 네이버 / Apple 소셜 로그인 버튼
// - "다른 방법으로 로그인" 탭 시 LoginMethodBottomSheet 표시
// - _LoginButton: 소셜 로그인 버튼 공통 레이아웃 위젯 (이 파일 전용)
//
// Figma node: (welcome screen)

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_naver_login/flutter_naver_login.dart';
import 'package:flutter_naver_login/interface/types/naver_login_status.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart';
import 'package:vybe/design_system/colors.dart';
import 'package:vybe/design_system/typography.dart';
import 'package:vybe/presentation/auth/identity_verification/identity_verification_screen.dart';
import 'package:vybe/presentation/auth/viewmodels/auth_viewmodel.dart';
import 'package:vybe/presentation/auth/welcome/login_method_bottom_sheet.dart';
import 'package:vybe/presentation/home/home_screen.dart';

class WelcomeScreen extends ConsumerWidget {
  const WelcomeScreen({super.key});

  // Figma 에셋 URL (7일 유효 — 이후 로컬 assets/images/ 로 교체 필요)

  static const _kakaoIconPath = 'assets/icons/auth/social_login_kakao_icon.svg';
  static const _naverIconPath = 'assets/icons/auth/social_login_naver_icon.svg';
  static const _appleIconPath = 'assets/icons/auth/social_login_apple_icon.svg';

  static const _vybeWhiteLogo = 'assets/icons/common/vybe_white_logo.svg';

  Future<void> _onKakaoLogin(BuildContext context, WidgetRef ref) async {
    try {
      OAuthToken token;
      if (await isKakaoTalkInstalled()) {
        token = await UserApi.instance.loginWithKakaoTalk();
      } else {
        token = await UserApi.instance.loginWithKakaoAccount();
      }

      final isNewUser = await ref
          .read(authViewModelProvider.notifier)
          .kakaoLogin(token.accessToken);

      if (!context.mounted) return;

      if (isNewUser) {
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (_) => const IdentityVerificationScreen()),
        );
      } else {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const HomeScreen()),
          (route) => false,
        );
      }
    } catch (e, st) {
      final log = '${DateTime.now()}\n$e\n$st\n\n';
      File('/Users/justinchoi/Desktop/업무/소스코드/vybe_bata/kakao_error.txt')
          .writeAsStringSync(log, mode: FileMode.append);
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    }
  }

  Future<void> _onNaverLogin(BuildContext context, WidgetRef ref) async {
    try {
      final result = await FlutterNaverLogin.logIn();
      if (result.status != NaverLoginStatus.loggedIn) return;

      final accessToken = result.accessToken?.accessToken;
      if (accessToken == null) return;
      final isNewUser = await ref
          .read(authViewModelProvider.notifier)
          .naverLogin(accessToken);

      if (!context.mounted) return;

      if (isNewUser) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const IdentityVerificationScreen()),
        );
      } else {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const HomeScreen()),
          (route) => false,
        );
      }
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
      ),
    );

    return Scaffold(
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          // 로고 + 태그라인
          Positioned(
            left: 40.w,
            top: 202.h,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // VYBE 로고
                SvgPicture.asset(_vybeWhiteLogo),
                SizedBox(height: 44.h),
                // "바이브 탈 준비 됐어?"
                RichText(
                  text: TextSpan(
                    style: TextStyle(
                      fontFamily: 'Pretendard',
                      fontWeight: FontWeight.w700,
                      fontSize: 36.sp,
                      letterSpacing: -0.9,
                    ),
                    children: [
                      TextSpan(
                        text: '바이브',
                        style: TextStyle(color: VybeColors.mainLime500),
                      ),
                      TextSpan(
                        text: ' 탈 준비 됐어?',
                        style: TextStyle(color: Colors.white),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 8.h),
                // "우린 끝냈어!"
                RichText(
                  text: TextSpan(
                    style: TextStyle(
                      fontFamily: 'Pretendard',
                      fontWeight: FontWeight.w700,
                      fontSize: 44.sp,
                      letterSpacing: -1.1,
                    ),
                    children: [
                      TextSpan(
                        text: '우린 ',
                        style: TextStyle(color: Colors.white),
                      ),
                      TextSpan(
                        text: '끝냈어!',
                        style: TextStyle(color: VybeColors.mainPurple500),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // 로그인 버튼 영역
          Positioned(
            left: 24.w,
            right: 24.w,
            top: 563.h,
            child: Column(
              children: [
                _LoginButton(
                  backgroundColor: const Color(0xFFFEE500),
                  icon: SvgPicture.asset(
                    _kakaoIconPath,
                    width: 24.w,
                    height: 22.h,
                  ),
                  label: '카카오 로그인',
                  labelColor: const Color(0xFF191919),
                  onTap: () => _onKakaoLogin(context, ref),
                ),
                SizedBox(height: 12.h),
                _LoginButton(
                  backgroundColor: const Color(0xFF02C75A),
                  icon: SvgPicture.asset(
                    _naverIconPath,
                    width: 20.w,
                    height: 20.h,
                  ),
                  label: '네이버 로그인',
                  labelColor: Colors.white,
                  onTap: () => _onNaverLogin(context, ref),
                ),
                SizedBox(height: 12.h),
                _LoginButton(
                  backgroundColor: Colors.white,
                  icon: SvgPicture.asset(
                    _appleIconPath,
                    width: 20.w,
                    height: 25.h,
                  ),
                  label: 'Apple 로그인',
                  labelColor: const Color(0xFF101013),
                  onTap: () {
                    // TODO: Apple 로그인 연동
                  },
                ),
                SizedBox(height: 24.h),
                GestureDetector(
                  onTap: () => showLoginMethodBottomSheet(
                    context,
                    onIdentityLogin: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const IdentityVerificationScreen(),
                        ),
                      );
                    },
                  ),
                  child: SizedBox(
                    width: double.infinity,
                    child: Text(
                      '다른 방법으로 로그인',
                      textAlign: TextAlign.center,
                      style: VybeTypography.button2.copyWith(
                        color: Color(0xFFB5B5B5), // VybeColors 미정의 색상
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _LoginButton extends StatelessWidget {
  final Color backgroundColor;
  final Widget icon;
  final String label;
  final Color labelColor;
  final VoidCallback onTap;

  const _LoginButton({
    required this.backgroundColor,
    required this.icon,
    required this.label,
    required this.labelColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 48.h,
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(999.r),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            icon,
            SizedBox(width: 40.w),
            Text(
              label,
              style: TextStyle(
                fontFamily: 'Pretendard',
                fontWeight: FontWeight.w600,
                fontSize: 18.sp,
                color: labelColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
