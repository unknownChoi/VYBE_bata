import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vybe/design_system/colors.dart';

// 리뷰 작성 화면 글래스 토큰 · 카드 · 오로라 배경.

// 글래스 톤 (디자인 RG_GLASS / RG_TILE)
const kReviewGlassFill = Color(0x29787880); // rgba(120,120,128,0.16)

const kReviewGlassBorder = Color(0x1AFFFFFF); // rgba(255,255,255,0.10)

const kReviewTileFill = Color(0x14FFFFFF); // rgba(255,255,255,0.08)

const kReviewTileBorder = Color(0x1FFFFFFF); // rgba(255,255,255,0.12)

const kReviewBarFill = Color(0x8C0E0D12); // rgba(14,13,18,0.55)

const kReviewInk = Color(0xFF0E0D12);

/// 리퀴드 글래스 카드 (디자인 RG_GLASS + 좌상단 하이라이트).
class ReviewGlassCard extends StatelessWidget {
  final Widget child;
  final double padding;
  final double radius;

  const ReviewGlassCard({super.key, required this.child, this.padding = 18, this.radius = 20});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(radius.r),
        boxShadow: [
          BoxShadow(
            color: const Color(0x5C000000),
            blurRadius: 30.r,
            offset: Offset(0, 10.h),
          ),
        ],
      ),
      // 테두리는 하이라이트 위에 그린다.
      foregroundDecoration: BoxDecoration(
        borderRadius: BorderRadius.circular(radius.r),
        border: Border.all(color: kReviewGlassBorder),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(radius.r),
        child: BackdropFilter(
          // CSS blur(18px) ≈ sigma 9.
          filter: ui.ImageFilter.blur(sigmaX: 9, sigmaY: 9),
          // 채움색과 하이라이트는 레이어를 나눈다 — 한 BoxDecoration에
          // color·gradient를 같이 주면 gradient가 color를 덮어 카드가 사라진다.
          child: ColoredBox(
            color: kReviewGlassFill,
            child: Stack(
              fit: StackFit.passthrough,
              children: [
                // 좌상단에서 번지는 유리 하이라이트.
                const Positioned.fill(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: RadialGradient(
                        center: Alignment(-0.76, -1),
                        radius: 1.1,
                        colors: [Color(0x1AFFFFFF), Color(0x00FFFFFF)],
                        stops: [0.0, 0.58],
                      ),
                    ),
                  ),
                ),
                const Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  height: 1,
                  child: ColoredBox(color: Color(0x29FFFFFF)),
                ),
                Padding(padding: EdgeInsets.all(padding.r), child: child),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// 사진 추가 버튼의 점선 테두리 (Flutter 기본 Border에 dashed가 없어 직접 그림).
class ReviewDashedBorderPainter extends CustomPainter {
  final double radius;

  const ReviewDashedBorderPainter({required this.radius});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color =
          const Color(0x38FFFFFF) // rgba(255,255,255,0.22)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    final path = Path()
      ..addRRect(
        RRect.fromRectAndRadius(Offset.zero & size, Radius.circular(radius)),
      );

    const dash = 4.0;
    const space = 3.0;
    for (final metric in path.computeMetrics()) {
      var distance = 0.0;
      while (distance < metric.length) {
        final end = (distance + dash).clamp(0.0, metric.length);
        canvas.drawPath(metric.extractPath(distance, end), paint);
        distance = end + space;
      }
    }
  }

  @override
  bool shouldRepaint(ReviewDashedBorderPainter oldDelegate) =>
      oldDelegate.radius != radius;
}

/// 리뷰 작성 페이지 배경 (디자인 RG_AURORA).
class ReviewAurora extends StatelessWidget {
  const ReviewAurora({super.key});

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF120F1A), VybeColors.background, Color(0xFF0E0D12)],
          stops: [0.0, 0.34, 1.0],
        ),
      ),
      child: Stack(
        children: [
          // 좌상단 보라 글로우
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: 260.h,
            child: const DecoratedBox(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment(-0.88, -1),
                  radius: 1.3,
                  colors: [Color(0x577731FE), Color(0x00000000)],
                  stops: [0.0, 0.6],
                ),
              ),
            ),
          ),
          // 우상단 라임 글로우
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: 240.h,
            child: const DecoratedBox(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment(1, -0.88),
                  radius: 1.3,
                  colors: [Color(0x21B5FF60), Color(0x00000000)],
                  stops: [0.0, 0.62],
                ),
              ),
            ),
          ),
          // 우하단 보라 글로우
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            height: 340.h,
            child: const DecoratedBox(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment(0.6, 0.88),
                  radius: 1.4,
                  colors: [Color(0x247731FE), Color(0x00000000)],
                  stops: [0.0, 0.66],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
