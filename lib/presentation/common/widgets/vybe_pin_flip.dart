import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:vybe/design_system/colors.dart';

/// 위치 인식 중 표시하는 지도 핀 3D 플립 (Y축 회전).
///
/// [animation] 0→1 한 바퀴가 360도. 앞면은 [frontColor], 뒷면은 [backColor].
/// 회전 자체는 [animation] 을 소유한 쪽(화면)이 제어한다 — 이 위젯은 그리기만 한다.
class VybePinFlip extends StatelessWidget {
  final Animation<double> animation;

  /// 앞면 색 (화면별 액센트).
  final Color frontColor;

  /// 뒷면 색.
  final Color backColor;

  /// 핀 크기 (.r 적용).
  final double size;

  const VybePinFlip({
    super.key,
    required this.animation,
    required this.frontColor,
    this.backColor = VybeColors.mainPurple500,
    this.size = 13,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, _) {
        final angle = animation.value * 2 * math.pi; // 0 → 360도 반복
        final isFront = math.cos(angle) >= 0;

        return Transform(
          alignment: Alignment.center,
          // 원근감(3D) — setEntry(3,2,..)로 perspective 부여.
          transform: Matrix4.identity()
            ..setEntry(3, 2, 0.0015)
            ..rotateY(angle),
          child: Transform(
            // 뒷면일 때 좌우 반전 보정(아이콘 거울상 방지).
            alignment: Alignment.center,
            transform: Matrix4.identity()..rotateY(isFront ? 0 : math.pi),
            child: SvgPicture.asset(
              'assets/icons/home_screen/loaction_pin.svg',
              width: size.r,
              height: size.r,
              colorFilter: ColorFilter.mode(
                isFront ? frontColor : backColor,
                BlendMode.srcIn,
              ),
            ),
          ),
        );
      },
    );
  }
}
