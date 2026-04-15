import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vybe/design_system/colors.dart';

/// 버튼 상태
enum VybeButtonState { defaultState, click, disabled }

/// 버튼 변형
///
/// - [defaultVariant]: 일반 버튼 (rounded 12r)
/// - [special]: 라임 테두리 버튼
/// - [withKeyboard]: 키보드 위 풀 너비 버튼 (radius 없음)
/// - [textButton]: 텍스트 밑줄 버튼
enum VybeButtonVariant { defaultVariant, special, withKeyboard, textButton }

/// Vybe 공통 버튼
///
/// Figma "Button" 컴포넌트 기반
///
/// - [label]: 버튼 텍스트
/// - [onTap]: 탭 콜백 (null이면 disabled 처리)
/// - [variant]: 버튼 변형 (기본: defaultVariant)
class VybeButton extends StatefulWidget {
  final String label;
  final VoidCallback? onTap;
  final VybeButtonVariant variant;

  const VybeButton({
    super.key,
    required this.label,
    required this.onTap,
    this.variant = VybeButtonVariant.defaultVariant,
  });

  @override
  State<VybeButton> createState() => _VybeButtonState();
}

class _VybeButtonState extends State<VybeButton> {
  bool _isPressed = false;

  bool get _isDisabled => widget.onTap == null;

  Color get _backgroundColor {
    if (_isDisabled) return VybeColors.mainPurpleDisabled;
    if (_isPressed) return VybeColors.mainPurple700;
    return VybeColors.mainPurple500;
  }

  Border? get _border {
    if (widget.variant == VybeButtonVariant.special && !_isDisabled) {
      final borderColor = _isPressed ? Colors.white : VybeColors.mainLime500;
      return Border.all(color: borderColor, width: 2);
    }
    return null;
  }

  BorderRadius? get _borderRadius {
    if (widget.variant == VybeButtonVariant.withKeyboard) return null;
    return BorderRadius.circular(12.r);
  }

  @override
  Widget build(BuildContext context) {
    if (widget.variant == VybeButtonVariant.textButton) {
      return GestureDetector(
        onTap: _isDisabled ? null : widget.onTap,
        child: Text(
          widget.label,
          style: TextStyle(
            fontFamily: 'Pretendard',
            fontWeight: FontWeight.w400,
            fontSize: 12.sp,
            height: 14 / 12,
            letterSpacing: 12 * -0.025,
            color: const Color(0xFFD9D9D9),
            decoration: TextDecoration.underline,
            decorationColor: const Color(0xFFD9D9D9),
          ),
        ),
      );
    }

    return GestureDetector(
      onTapDown: _isDisabled ? null : (_) => setState(() => _isPressed = true),
      onTapUp: _isDisabled
          ? null
          : (_) {
              setState(() => _isPressed = false);
              widget.onTap?.call();
            },
      onTapCancel: _isDisabled ? null : () => setState(() => _isPressed = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 100),
        width: double.infinity,
        height: 56.h,
        decoration: BoxDecoration(
          color: _backgroundColor,
          borderRadius: _borderRadius,
          border: _border,
        ),
        alignment: Alignment.center,
        child: Text(
          widget.label,
          style: TextStyle(
            fontFamily: 'Pretendard',
            fontWeight: FontWeight.w500,
            fontSize: 18.sp,
            height: 1,
            letterSpacing: 18 * -0.025,
            color: _isDisabled
                ? Colors.white.withValues(alpha: 0.8)
                : Colors.white,
          ),
        ),
      ),
    );
  }
}
