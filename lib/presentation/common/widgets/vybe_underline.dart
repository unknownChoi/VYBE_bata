import 'dart:ui' as ui;

import 'package:flutter/material.dart';

/// 입력 필드 밑줄 1px + (활성 시) 같은 색 언더글로우.
///
/// 디자인 `SVUnderline` (`signup_verify_parts.jsx`).
/// 글로우는 블러된 복사본을 겹친 것 — 라인 자체는 늘 1px이라 포커스가
/// 옮겨가도 필드 높이가 흔들리지 않는다.
class VybeUnderline extends StatelessWidget {
  final Color color;

  /// 언더글로우 표시 여부 (보통 포커스 중 && 에러 아님).
  final bool glow;

  const VybeUnderline({super.key, required this.color, this.glow = false});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 1,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned.fill(
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              color: color,
            ),
          ),
          Positioned.fill(
            child: IgnorePointer(
              child: AnimatedOpacity(
                duration: const Duration(milliseconds: 200),
                opacity: glow ? 0.9 : 0,
                child: ImageFiltered(
                  imageFilter: ui.ImageFilter.blur(sigmaX: 2, sigmaY: 2),
                  child: ColoredBox(color: color),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
