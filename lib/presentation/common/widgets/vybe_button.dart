import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vybe/design_system/colors.dart';
import 'package:vybe/presentation/common/widgets/vybe_liquid_press.dart';

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

  // special variant border 그라데이션 (타이틀 텍스트와 동일)
  static const _borderGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      VybeColors.mainLime500, // lime
      Color(0xFFC8E77F),
      Color(0xFFDACA9E),
      Color(0xFFFF9EDB), // pink
      Color(0xFFDD82E4),
      Color(0xFFBB67ED),
      Color(0xFF994CF5),
      VybeColors.mainPurple500, // purple
    ],
    stops: [0.0, 0.142, 0.285, 0.569, 0.677, 0.785, 0.892, 1.0],
  );

  BorderRadius? get _borderRadius {
    if (widget.variant == VybeButtonVariant.withKeyboard) return null;
    return BorderRadius.circular(12.r);
  }

  Widget get _labelText => Text(
        widget.label,
        style: TextStyle(
          fontFamily: 'Pretendard',
          fontWeight: FontWeight.w500,
          fontSize: 18.sp,
          height: 1,
          letterSpacing: 18 * -0.025,
          color: _isDisabled ? Colors.white.withValues(alpha: 0.8) : Colors.white,
        ),
      );

  /// 누름 반응(1.045배 확대 + 손가락 따라오는 렌즈)은 [VybeLiquidPress] 담당,
  /// 배경색 전환만 여기서 한다.
  Widget _wrapGesture(Widget child) => VybeLiquidPress(
        onTap: _isDisabled ? null : widget.onTap,
        borderRadius: _borderRadius ?? BorderRadius.zero,
        onPressChanged: (v) => setState(() => _isPressed = v),
        child: child,
      );

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

    // special variant: 그라데이션 border를 외부 컨테이너로 구현
    if (widget.variant == VybeButtonVariant.special) {
      return _wrapGesture(
        AnimatedContainer(
          duration: const Duration(milliseconds: 340),
          width: double.infinity,
          height: 56.h,
          decoration: BoxDecoration(
            gradient: _isDisabled ? null : _borderGradient,
            color: _isDisabled ? VybeColors.mainPurpleDisabled : null,
            borderRadius: _borderRadius,
          ),
          padding: const EdgeInsets.all(2), // border 두께
          child: Container(
            decoration: BoxDecoration(
              color: _isPressed ? VybeColors.mainPurple700 : VybeColors.mainPurple500,
              borderRadius: BorderRadius.circular(10.r),
            ),
            alignment: Alignment.center,
            child: _labelText,
          ),
        ),
      );
    }

    return _wrapGesture(
      AnimatedContainer(
        duration: const Duration(milliseconds: 340),
        width: double.infinity,
        height: 56.h,
        decoration: BoxDecoration(
          color: _backgroundColor,
          borderRadius: _borderRadius,
        ),
        alignment: Alignment.center,
        child: _labelText,
      ),
    );
  }
}
