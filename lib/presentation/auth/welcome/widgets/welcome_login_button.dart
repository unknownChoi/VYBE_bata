import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:vybe/presentation/common/widgets/vybe_spinner.dart';

/// 소셜 로그인 버튼 — 아이콘은 왼쪽 고정, 라벨은 가운데 정렬.
///
/// 라벨을 Row로 이어 붙이지 않고 Stack에 겹치는 이유 — 아이콘 폭이 SDK마다
/// 달라서(카카오 20 · 네이버 14 · Apple 18) Row로 두면 버튼마다 글자 중심이
/// 어긋나 보인다.
class WelcomeLoginButton extends StatelessWidget {
  final Color backgroundColor;
  final String iconPath;
  final double iconSize;
  final String label;
  final Color labelColor;

  /// 이 버튼의 로그인이 진행 중 — 아이콘·라벨 대신 스피너.
  final bool isLoading;

  /// 다른 버튼이 진행 중이라 누를 수 없음 — 흐리게.
  final bool disabled;

  final VoidCallback onTap;

  const WelcomeLoginButton({
    super.key,
    required this.backgroundColor,
    required this.iconPath,
    required this.iconSize,
    required this.label,
    required this.labelColor,
    required this.isLoading,
    required this.disabled,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: disabled ? null : onTap,
      child: AnimatedOpacity(
        // 진행 중인 버튼은 스피너로 이미 상태를 알리므로 흐리게 하지 않는다.
        opacity: disabled && !isLoading ? 0.5 : 1.0,
        duration: const Duration(milliseconds: 200),
        child: Container(
          width: double.infinity,
          height: 54.h,
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(999.r),
          ),
          child: isLoading
              ? Center(child: VybeSpinner(size: 28.r))
              : Stack(
                  alignment: Alignment.center,
                  children: [
                    Positioned(
                      left: 22.w,
                      child: SvgPicture.asset(
                        iconPath,
                        width: iconSize,
                        height: iconSize,
                      ),
                    ),
                    Text(
                      label,
                      style: TextStyle(
                        fontFamily: 'Pretendard',
                        fontWeight: FontWeight.w600,
                        fontSize: 16.sp,
                        letterSpacing: -0.025 * 16,
                        color: labelColor,
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}
