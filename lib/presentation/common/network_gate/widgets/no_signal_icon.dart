import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vybe/design_system/colors.dart';
import 'package:vybe/presentation/common/widgets/vybe_aurora.dart';

/// 디자인 원본 좌표계(`network_error.jsx` 의 svg viewBox 88x72).
const double _kViewW = 88;
const double _kViewH = 72;

/// 아이콘이 차지하는 정사각 박스(디자인 88x88).
const double _kBoxSize = 88;

/// 뒤에 깔리는 붉은 헤일로 지름(디자인 168).
const double _kHaloSize = 168;

/// 헤일로 맥박 한 주기(디자인 `neHalo 1.1s`).
const Duration _kHaloPeriod = Duration(milliseconds: 1100);

/// 신호 없음 아이콘 — 전파 아크가 위로 갈수록 흐려지고 사선으로 끊긴다.
///
/// [retrying] 이면 사선(끊김 표시)이 사라지고 붉은 헤일로가 맥박한다 =
/// "지금 다시 잡아 보는 중".
class NoSignalIcon extends StatefulWidget {
  final bool retrying;

  const NoSignalIcon({super.key, this.retrying = false});

  @override
  State<NoSignalIcon> createState() => _NoSignalIconState();
}

class _NoSignalIconState extends State<NoSignalIcon>
    with SingleTickerProviderStateMixin {
  late final AnimationController _halo;

  @override
  void initState() {
    super.initState();
    _halo = AnimationController(vsync: this, duration: _kHaloPeriod ~/ 2);
    if (widget.retrying) _halo.repeat(reverse: true);
  }

  @override
  void didUpdateWidget(NoSignalIcon oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.retrying == oldWidget.retrying) return;
    if (widget.retrying) {
      _halo.repeat(reverse: true);
    } else {
      _halo.stop();
      _halo.value = 0;
    }
  }

  @override
  void dispose() {
    _halo.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final box = _kBoxSize.w;

    return SizedBox(
      width: box,
      height: box,
      // 헤일로가 박스보다 크다 — 잘리면 원이 각지게 보인다.
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.center,
        children: [
          Positioned(
            // 디자인: left 50% / top 58% 를 중심으로 한 원.
            top: box * 0.58 - _kHaloSize.w / 2,
            child: FadeTransition(
              opacity: Tween<double>(begin: 0.6, end: 1).animate(_halo),
              child: ScaleTransition(
                scale: Tween<double>(begin: 1, end: 1.12).animate(_halo),
                child: Container(
                  width: _kHaloSize.w,
                  height: _kHaloSize.w,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        VybeColors.accentRed500.withValues(alpha: 0.14),
                        VybeColors.accentRed500.withValues(alpha: 0),
                      ],
                      stops: const [0, 0.68],
                    ),
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            top: 8.h,
            child: CustomPaint(
              size: Size(box, box * _kViewH / _kViewW),
              painter: _NoSignalPainter(crossed: !widget.retrying),
            ),
          ),
        ],
      ),
    );
  }
}

class _NoSignalPainter extends CustomPainter {
  /// 끊김 사선을 그릴지. 재시도 중에는 뺀다.
  final bool crossed;

  const _NoSignalPainter({required this.crossed});

  @override
  void paint(Canvas canvas, Size size) {
    // 디자인 좌표(88x72)를 그대로 쓰고 캔버스만 늘린다.
    canvas.save();
    canvas.scale(size.width / _kViewW);

    const center = Offset(44, 62);

    // 위로 갈수록 흐려지는 반원 3겹. 맨 바깥은 점선(4-9)이라 더 멀어 보인다.
    _arc(canvas, center, 34, 0.10, dashed: true);
    _arc(canvas, center, 24, 0.22);
    _arc(canvas, center, 14, 0.42);

    canvas.drawCircle(
      const Offset(44, 61),
      4.5,
      Paint()..color = Colors.white.withValues(alpha: 0.62),
    );

    if (crossed) {
      // 잉크색을 먼저 굵게 깔아 아크를 파낸 뒤 그 홈에 빨간 선을 얹는다.
      _slash(canvas, kVybeInk, 9);
      _slash(canvas, VybeColors.accentRed500, 4);
    }

    canvas.restore();
  }

  void _arc(
    Canvas canvas,
    Offset center,
    double radius,
    double opacity, {
    bool dashed = false,
  }) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4.5
      ..strokeCap = StrokeCap.round
      ..color = Colors.white.withValues(alpha: opacity);

    final path = Path()
      ..addArc(Rect.fromCircle(center: center, radius: radius), math.pi, math.pi);

    canvas.drawPath(dashed ? _dash(path, 4, 9) : path, paint);
  }

  void _slash(Canvas canvas, Color color, double width) {
    canvas.drawLine(
      const Offset(20, 70),
      const Offset(68, 20),
      Paint()
        ..color = color
        ..strokeWidth = width
        ..strokeCap = StrokeCap.round,
    );
  }

  /// CSS `strokeDasharray` 대응 — 그린 길이 [on], 띄운 길이 [off] 를 반복한다.
  Path _dash(Path source, double on, double off) {
    final result = Path();
    for (final ui.PathMetric metric in source.computeMetrics()) {
      var distance = 0.0;
      while (distance < metric.length) {
        final end = math.min(distance + on, metric.length);
        result.addPath(metric.extractPath(distance, end), Offset.zero);
        distance = end + off;
      }
    }
    return result;
  }

  @override
  bool shouldRepaint(_NoSignalPainter oldDelegate) =>
      oldDelegate.crossed != crossed;
}
