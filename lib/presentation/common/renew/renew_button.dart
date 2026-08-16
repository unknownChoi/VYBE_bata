import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vybe/design_system/colors.dart';
import 'package:vybe/presentation/common/renew/renew_glass.dart';
import 'package:vybe/presentation/common/widgets/vybe_liquid_press.dart';

/// [RenewButton] 색 변형 (디자인 VButton `variant`).
enum RenewButtonVariant {
  /// 보라 채움 — 주 동작(전화 문의).
  filled,

  /// 유리 타일 — 보조 동작(길찾기 · 더 보기).
  quiet,

  /// 라임 채움 — 강조 동작(리뷰 작성하기).
  lime,

  /// 붉은 채움 — 되돌릴 수 없는 동작(회원 탈퇴).
  danger,
}

/// 리뉴얼 디자인 버튼 (VButton) — 56.h · radius 12.
///
/// 누름 반응(확대 + 렌즈)은 [VybeLiquidPress], 색 전환만 여기서 한다.
///
/// 공통 [VybeButton]은 보라 단일 톤 + 풀와이드 고정이라 디자인의
/// quiet/lime 변형과 아이콘 슬롯을 표현할 수 없어 화면 전용으로 둔다.
class RenewButton extends StatefulWidget {
  final String label;
  final VoidCallback? onTap;
  final RenewButtonVariant variant;
  final IconData? icon;

  const RenewButton({
    super.key,
    required this.label,
    required this.onTap,
    this.variant = RenewButtonVariant.filled,
    this.icon,
  });

  @override
  State<RenewButton> createState() => _RenewButtonState();
}

class _RenewButtonState extends State<RenewButton> {
  bool _pressed = false;

  void _setPressed(bool v) {
    if (v != _pressed) setState(() => _pressed = v);
  }

  Color get _background {
    switch (widget.variant) {
      case RenewButtonVariant.quiet:
        return _pressed ? const Color(0x1FFFFFFF) : RenewGlass.tileFill;
      case RenewButtonVariant.lime:
        return _pressed ? VybeColors.mainLime700 : VybeColors.mainLime500;
      case RenewButtonVariant.filled:
        return _pressed ? VybeColors.mainPurple700 : VybeColors.mainPurple500;
      case RenewButtonVariant.danger:
        return _pressed
            ? VybeColors.accentRed500.withValues(alpha: 0.75)
            : VybeColors.accentRed500;
    }
  }

  Color get _foreground =>
      widget.variant == RenewButtonVariant.lime ? RenewGlass.ink : Colors.white;

  @override
  Widget build(BuildContext context) {
    final fg = _foreground;

    return VybeLiquidPress(
      onTap: widget.onTap,
      borderRadius: BorderRadius.circular(12.r),
      onPressChanged: _setPressed,
      // 라임 채움 위에서는 흰 렌즈가 날아가 보여 어두운 잉크로 반전한다.
      lensColor: widget.variant == RenewButtonVariant.lime
          ? RenewGlass.ink
          : Colors.white,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 340),
        height: 56.h,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: _background,
          borderRadius: BorderRadius.circular(12.r),
          border: widget.variant == RenewButtonVariant.quiet
              ? Border.all(color: RenewGlass.tileBorder)
              : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (widget.icon != null) ...[
              Icon(widget.icon, size: 19.r, color: fg),
              SizedBox(width: 8.w),
            ],
            Flexible(
              child: Text(
                widget.label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontFamily: 'Pretendard',
                  fontWeight: FontWeight.w500,
                  fontSize: 18.sp,
                  height: 1,
                  letterSpacing: 18 * -0.025,
                  color: fg,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// 목록 하단 `N개 더 보기` / `모두 봤어요` (디자인 VButton quiet ↔ caption).
class RenewMoreButton extends StatelessWidget {
  final String label;
  final VoidCallback? onTap;

  const RenewMoreButton({super.key, required this.label, this.onTap});

  @override
  Widget build(BuildContext context) {
    if (onTap == null) {
      return Center(child: Text(label, style: RenewGlass.caption()));
    }
    return SizedBox(
      width: double.infinity,
      child: RenewButton(
        label: label,
        onTap: onTap,
        variant: RenewButtonVariant.quiet,
      ),
    );
  }
}
