import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vybe/design_system/colors.dart';

/// 리퀴드 글래스 원형 아이콘 버튼.
///
/// 뒤로가기·공유 등 오버레이 버튼에 사용. 뒤 배경을 블러 처리(BackdropFilter)해
/// 유리 너머로 비치는 질감을 만들고, 누르면 살짝 줄어들며 하이라이트가 강해진다.
/// 기본 아이콘은 뒤로가기.
class VybeGlassButton extends StatefulWidget {
  final VoidCallback onTap;
  final IconData icon;

  /// 유리 원 지름 (.r 적용).
  final double size;

  /// 아이콘 크기 (.r 적용).
  final double iconSize;

  /// 탭 영역 크기 (.w/.h 적용).
  final double hitSize;

  const VybeGlassButton({
    super.key,
    required this.onTap,
    this.icon = Icons.arrow_back_ios_new_rounded,
    this.size = 38,
    this.iconSize = 19,
    this.hitSize = 44,
  });

  @override
  State<VybeGlassButton> createState() => _VybeGlassButtonState();
}

class _VybeGlassButtonState extends State<VybeGlassButton> {
  bool _pressed = false;

  void _setPressed(bool v) {
    if (v != _pressed) setState(() => _pressed = v);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: (_) => _setPressed(true),
      onTapUp: (_) => _setPressed(false),
      onTapCancel: () => _setPressed(false),
      onTap: widget.onTap,
      child: SizedBox(
        width: widget.hitSize.w,
        height: widget.hitSize.h,
        child: Center(
          // 눌리면 살짝 줄어들며(액체가 눌리는 느낌) 글래스 하이라이트 강해짐.
          child: AnimatedScale(
            scale: _pressed ? 0.86 : 1.0,
            duration: const Duration(milliseconds: 140),
            curve: Curves.easeOut,
            child: ClipOval(
              child: BackdropFilter(
                filter: ImageFilter.blur(
                  sigmaX: _pressed ? 18 : 12,
                  sigmaY: _pressed ? 18 : 12,
                ),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 160),
                  curve: Curves.easeOut,
                  width: widget.size.r,
                  height: widget.size.r,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    // 유리 질감 — 위는 밝게, 아래는 어둡게 (광택 그라데이션).
                    // 눌리면 전체적으로 더 밝아져 액체가 빛나는 느낌.
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Colors.white.withValues(alpha: _pressed ? 0.45 : 0.28),
                        Colors.white.withValues(alpha: _pressed ? 0.18 : 0.08),
                      ],
                    ),
                    border: Border.all(
                      color:
                          Colors.white.withValues(alpha: _pressed ? 0.55 : 0.35),
                      width: 1,
                    ),
                    boxShadow: [
                      // 눌리면 라임 글로우 살짝 — 액체 글래스 반응.
                      BoxShadow(
                        color: _pressed
                            ? VybeColors.mainLime500.withValues(alpha: 0.30)
                            : Colors.black.withValues(alpha: 0.18),
                        blurRadius: _pressed ? 14 : 8,
                        spreadRadius: _pressed ? 1 : 0,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Icon(widget.icon,
                      size: widget.iconSize.r, color: Colors.white),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
