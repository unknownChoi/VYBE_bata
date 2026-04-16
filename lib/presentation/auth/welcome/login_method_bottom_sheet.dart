// TODO: login_method_bottom_sheet.dart
// "다른 방법으로 로그인" 탭 시 표시되는 바텀시트
// - 본인 인증 필요 안내 메시지 표시
// - 본인인증 로그인 버튼 → IdentityVerificationScreen으로 진입
//
// Figma node: 116-11750

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:vybe/design_system/colors.dart';
import 'package:vybe/design_system/typography.dart';

/// "다른 방법으로 로그인" 탭 시 표시되는 바텀시트
///
/// Figma node: 116:11750
void showLoginMethodBottomSheet(
  BuildContext context, {
  VoidCallback? onIdentityLogin,
}) {
  showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    builder: (_) => _LoginMethodSheet(onIdentityLogin: onIdentityLogin),
  );
}

class _LoginMethodSheet extends StatelessWidget {
  static const _greenCheckPath = 'assets/icons/auth/green_check.svg';
  static const _identityIconPath =
      'assets/icons/auth/login_identity_verification.svg';

  final VoidCallback? onIdentityLogin;

  const _LoginMethodSheet({this.onIdentityLogin});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: VybeColors.gray900,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
      ),
      padding: EdgeInsets.symmetric(horizontal: 26.w, vertical: 64.h),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 아이콘 + 타이틀 + 서브타이틀
          SvgPicture.asset(_greenCheckPath, width: 52.r, height: 52.r),
          SizedBox(height: 24.h),
          Text(
            '본인 인증이 필요합니다.',
            textAlign: TextAlign.center,
            style: VybeTypography.heading3.copyWith(color: Colors.white),
          ),
          SizedBox(height: 24.h),
          Text(
            '19세 이상 사용 가능 서비스 입니다.\n본인 인증을 진행해주세요.',
            textAlign: TextAlign.center,
            style: VybeTypography.button1.copyWith(
              height: 1.5,
              color: const Color(0xFF8F8F8F),
            ),
          ),
          SizedBox(height: 41.h),

          // 본인인증 로그인 버튼
          GestureDetector(
            onTap: onIdentityLogin,
            child: Container(
              height: 48.h,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(999.r),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SvgPicture.asset(
                    _identityIconPath,
                    width: 20.w,
                    height: 25.h,
                  ),
                  SizedBox(width: 40.w),
                  Text(
                    '본인인증 로그인',
                    style: TextStyle(
                      fontFamily: 'Pretendard',
                      fontWeight: FontWeight.w600,
                      fontSize: 18.sp,
                      color: const Color(0xFF333333),
                    ),
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
