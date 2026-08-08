import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

// 라인업 진행중 표시용 점 애니메이션 (펄스 · 파형 링).

// ── 펄스 점 (opacity 깜빡임) ──
class LineupPulseDot extends StatefulWidget {
  final double size;
  final Color color;
  const LineupPulseDot({super.key, required this.size, required this.color});

  @override
  State<LineupPulseDot> createState() => _LineupPulseDotState();
}

class _LineupPulseDotState extends State<LineupPulseDot>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1300),
  )..repeat(reverse: true);

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: Tween(begin: 1.0, end: 0.35)
          .animate(CurvedAnimation(parent: _c, curve: Curves.easeInOut)),
      child: Container(
        width: widget.size.r,
        height: widget.size.r,
        decoration: BoxDecoration(color: widget.color, shape: BoxShape.circle),
      ),
    );
  }
}

// ── 파형 점 — 점에서 링이 바깥으로 퍼지며 사라짐 ──
// 디자인 ring keyframes: scale(1)→scale(2.8), opacity 0.75→0.12(70%)→0, 1.6s ease-out 무한.
// pulseDot=true면 중앙 점도 opacity 펄스(배너), false면 고정 점(타임라인).
class LineupRippleDot extends StatefulWidget {
  final double size;
  final Color color;
  final bool pulseDot;
  const LineupRippleDot({super.key, 
    required this.size,
    required this.color,
    this.pulseDot = true,
  });

  @override
  State<LineupRippleDot> createState() => _LineupRippleDotState();
}

class _LineupRippleDotState extends State<LineupRippleDot>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1600),
  )..repeat();

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  // 디자인 ring 곡선: 0%→70% 구간 0.75→0.12, 70%→100% 구간 0.12→0.
  double _ringOpacity(double t) => t < 0.7
      ? 0.75 - (0.75 - 0.12) * (t / 0.7)
      : 0.12 * (1 - (t - 0.7) / 0.3);

  @override
  Widget build(BuildContext context) {
    final size = widget.size.r;
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.center,
        children: [
          // 퍼지는 링.
          AnimatedBuilder(
            animation: _c,
            builder: (_, __) {
              final t = Curves.easeOut.transform(_c.value);
              final scale = 1 + t * 1.8; // scale(1) → scale(2.8)
              return Opacity(
                opacity: _ringOpacity(t).clamp(0.0, 1.0),
                child: Container(
                  width: size * scale,
                  height: size * scale,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: widget.color, width: 1.5),
                  ),
                ),
              );
            },
          ),
          // 중앙 점.
          if (widget.pulseDot)
            LineupPulseDot(size: widget.size, color: widget.color)
          else
            // 링 방출 주기에 맞춰 점이 부풀었다 가라앉는 강조 (scale 1 → 1.25 → 1).
            AnimatedBuilder(
              animation: _c,
              builder: (_, __) => Transform.scale(
                scale: 1 + 0.25 * math.sin(math.pi * _c.value),
                child: Container(
                  width: size,
                  height: size,
                  decoration: BoxDecoration(
                    color: widget.color,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
