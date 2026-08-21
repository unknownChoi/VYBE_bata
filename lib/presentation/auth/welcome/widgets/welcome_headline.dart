import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:vybe/design_system/colors.dart';

/// Welcome 상단 — 로고 + `바이브 탈 준비 됐어? / 우린 끝냈어!`.
class WelcomeHeadline extends StatelessWidget {
  static const _logoAsset = 'assets/icons/common/vybe_white_logo.svg';

  /// 스플래시 로고가 착지할 자리. 루트 진입일 때만 준다.
  final Key? logoKey;

  const WelcomeHeadline({super.key, this.logoKey});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SvgPicture.asset(_logoAsset, key: logoKey, height: 44.h),
        SizedBox(height: 20.h),
        RichText(
          text: TextSpan(
            style: _line1,
            children: const [
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
        SizedBox(height: 6.h),
        Row(
          children: [
            Text('우린 ', style: _line2),
            // '끝냈어!'만 보라 그라데이션 — ShaderMask는 자식 전체를 물들이므로
            // 앞 글자와 같은 Text에 넣을 수 없다.
            ShaderMask(
              shaderCallback: (bounds) => const LinearGradient(
                colors: [VybeColors.mainPurple500, Color(0xFFB377FF)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ).createShader(bounds),
              blendMode: BlendMode.srcIn,
              child: Text('끝냈어!', style: _line2),
            ),
          ],
        ),
      ],
    );
  }

  TextStyle get _line1 => TextStyle(
    fontFamily: 'Pretendard',
    fontWeight: FontWeight.w700,
    fontSize: 28.sp,
    letterSpacing: -0.025 * 28,
    height: 30 / 28,
  );

  TextStyle get _line2 => TextStyle(
    fontFamily: 'Pretendard',
    fontWeight: FontWeight.w700,
    fontSize: 42.sp,
    letterSpacing: -0.025 * 42,
    height: 46 / 42,
    color: Colors.white,
  );
}
