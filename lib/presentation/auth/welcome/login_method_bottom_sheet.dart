import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vybe/design_system/colors.dart';

void showLoginMethodBottomSheet(
  BuildContext context, {
  VoidCallback? onIdentityLogin,
}) {
  showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (_) => _VerifySheet(onIdentityLogin: onIdentityLogin),
  );
}

class _VerifySheet extends StatelessWidget {
  final VoidCallback? onIdentityLogin;

  const _VerifySheet({this.onIdentityLogin});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFF1C1C20),
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.only(
        top: 12.h,
        left: 24.w,
        right: 24.w,
        bottom: 40.h,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag handle
          Container(
            width: 36.w,
            height: 4.h,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.18),
              borderRadius: BorderRadius.circular(99.r),
            ),
          ),
          SizedBox(height: 32.h),
          // 19+ icon
          const _IDIcon(),
          SizedBox(height: 18.h),
          // Title
          Text(
            '본인 인증이 필요해요',
            style: TextStyle(
              fontFamily: 'Pretendard',
              fontWeight: FontWeight.w600,
              fontSize: 24.sp,
              letterSpacing: -0.025 * 24,
              height: 26 / 24,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 10.h),
          // Body with colorful VYBE wordmark inline
          Text.rich(
            TextSpan(
              style: TextStyle(
                fontFamily: 'Pretendard',
                fontWeight: FontWeight.w400,
                fontSize: 14.sp,
                letterSpacing: -0.025 * 14,
                color: VybeColors.gray500,
                height: 22 / 14,
              ),
              children: [
                TextSpan(
                  text: 'V',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                TextSpan(
                  text: 'Y',
                  style: TextStyle(
                    color: VybeColors.mainLime500,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                TextSpan(
                  text: 'B',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                TextSpan(
                  text: 'E',
                  style: TextStyle(
                    color: VybeColors.mainPurple500,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const TextSpan(
                  text: '는 19세 이상만 이용할 수 있어요.\n안전한 이용을 위해 본인 인증을 진행해주세요.',
                ),
              ],
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 32.h),
          // CTA — 본인인증으로 시작하기
          GestureDetector(
            onTap: onIdentityLogin,
            child: Container(
              width: double.infinity,
              height: 54.h,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(999.r),
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Positioned(
                    left: 22.w,
                    child: CustomPaint(
                      size: Size(18.r, 18.r),
                      painter: _IDCardIconPainter(),
                    ),
                  ),
                  Text(
                    '본인인증으로 시작하기',
                    style: TextStyle(
                      fontFamily: 'Pretendard',
                      fontWeight: FontWeight.w600,
                      fontSize: 16.sp,
                      letterSpacing: -0.025 * 16,
                      color: const Color(0xFF101013),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: 10.h),
          // Close — 다음에 할게요
          GestureDetector(
            onTap: () => Navigator.of(context).maybePop(),
            child: SizedBox(
              width: double.infinity,
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 10.h),
                child: Text(
                  '다음에 할게요',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'Pretendard',
                    fontWeight: FontWeight.w600,
                    fontSize: 14.sp,
                    letterSpacing: -0.025 * 14,
                    color: VybeColors.gray500,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// 19+ circle badge
// ============================================================

class _IDIcon extends StatelessWidget {
  const _IDIcon();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 72.r,
      height: 72.r,
      child: Stack(
        children: [
          // Circle with gradient + lime border + glow
          Container(
            width: 72.r,
            height: 72.r,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                center: const Alignment(0, -0.3),
                colors: [
                  const Color(0xFFB5FF60).withValues(alpha: 0.22),
                  const Color(0xFF7731FE).withValues(alpha: 0.18),
                ],
                stops: const [0.0, 0.7],
              ),
              border: Border.all(
                color: VybeColors.mainLime500,
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFB5FF60).withValues(alpha: 0.18),
                  blurRadius: 24,
                ),
              ],
            ),
            child: Center(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  ShaderMask(
                    shaderCallback: (bounds) => const LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [VybeColors.mainLime500, VybeColors.mainLime700],
                    ).createShader(bounds),
                    blendMode: BlendMode.srcIn,
                    child: Text(
                      '19',
                      style: TextStyle(
                        fontFamily: 'Pretendard',
                        fontWeight: FontWeight.w800,
                        fontSize: 32.sp,
                        letterSpacing: -0.04 * 32,
                        height: 1,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  Text(
                    '+',
                    style: TextStyle(
                      fontFamily: 'Pretendard',
                      fontWeight: FontWeight.w800,
                      fontSize: 20.sp,
                      height: 1,
                      color: VybeColors.mainLime500,
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Sparkle dots
          Positioned(
            top: 6.r,
            right: 10.r,
            child: Container(
              width: 3.r,
              height: 3.r,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: VybeColors.mainLime500,
              ),
            ),
          ),
          Positioned(
            bottom: 12.r,
            left: 8.r,
            child: Container(
              width: 2.5.r,
              height: 2.5.r,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: VybeColors.mainPurple500,
              ),
            ),
          ),
          Positioned(
            top: 18.r,
            left: 5.r,
            child: Opacity(
              opacity: 0.7,
              child: Container(
                width: 2.r,
                height: 2.r,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: VybeColors.mainLime500,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// ID card icon painter (rect + circle + two lines)
// ============================================================

class _IDCardIconPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final s = size.width / 24;
    final paint = Paint()
      ..color = const Color(0xFF101013)
      ..strokeWidth = 2 * s
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(3 * s, 5 * s, 18 * s, 14 * s),
        Radius.circular(2 * s),
      ),
      paint,
    );
    canvas.drawCircle(Offset(9 * s, 12 * s), 2.5 * s, paint);
    canvas.drawLine(Offset(14 * s, 10 * s), Offset(18 * s, 10 * s), paint);
    canvas.drawLine(Offset(14 * s, 14 * s), Offset(18 * s, 14 * s), paint);
  }

  @override
  bool shouldRepaint(_IDCardIconPainter oldDelegate) => false;
}
