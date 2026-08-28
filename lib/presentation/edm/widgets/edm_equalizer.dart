import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// 이퀄라이저 막대 — '지금 이 셋이 돌고 있다'를 글자 없이 알리는 표시.
///
/// 디자인(edm_renew.jsx `Equalizer`)의 `eq` 키프레임(scaleY .28 → 1, 막대마다
/// 다른 주기·지연)을 컨트롤러 하나 + 막대별 위상차로 근사한다. 막대마다
/// AnimationController를 두면 같은 화면에 수십 개가 떠 프레임을 먹는다.
class EdmEqualizer extends StatefulWidget {
  /// 막대 높이(dp) — `.h` 적용 전.
  final double size;
  final Color color;
  final int bars;

  const EdmEqualizer({
    super.key,
    required this.color,
    this.size = 12,
    this.bars = 3,
  });

  @override
  State<EdmEqualizer> createState() => _EdmEqualizerState();
}

class _EdmEqualizerState extends State<EdmEqualizer>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
  )..repeat();

  // 막대별 위상 — 디자인의 delay(0 / .18 / .36 / .12s)를 한 주기 비율로 옮긴 값.
  static const _phase = [0.0, 0.2, 0.4, 0.13];

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final h = widget.size.h;
    return SizedBox(
      height: h,
      child: AnimatedBuilder(
        animation: _c,
        builder: (_, __) => Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            for (var i = 0; i < widget.bars; i++) ...[
              if (i > 0) SizedBox(width: 2.w),
              SizedBox(
                width: 2.5.w,
                height:
                    h *
                    (0.28 +
                        0.72 *
                            (0.5 -
                                0.5 *
                                    math.cos(
                                      2 *
                                          math.pi *
                                          (_c.value +
                                              _phase[i % _phase.length]),
                                    ))),
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: widget.color,
                    borderRadius: BorderRadius.circular(2.r),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
