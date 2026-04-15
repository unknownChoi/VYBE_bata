import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vybe/design_system/colors.dart';

/// Vybe 공통 선택 항목
///
/// Figma "Select Item" 컴포넌트 기반
/// 드롭다운 메뉴나 바텀시트 목록에서 사용
///
/// - [label]: 항목 텍스트
/// - [isSelected]: 선택 여부 (배경색 변경)
/// - [onTap]: 탭 콜백
class VybeSelectItem extends StatefulWidget {
  final String label;
  final bool isSelected;
  final VoidCallback? onTap;

  const VybeSelectItem({
    super.key,
    required this.label,
    this.isSelected = false,
    this.onTap,
  });

  @override
  State<VybeSelectItem> createState() => _VybeSelectItemState();
}

class _VybeSelectItemState extends State<VybeSelectItem> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final isHighlighted = widget.isSelected || _isPressed;

    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) {
        setState(() => _isPressed = false);
        widget.onTap?.call();
      },
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 100),
        height: 44.h,
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
        decoration: BoxDecoration(
          color: isHighlighted ? VybeColors.gray700 : Colors.transparent,
          borderRadius: BorderRadius.circular(8.r),
        ),
        child: Align(
          alignment: Alignment.centerLeft,
          child: Text(
            widget.label,
            style: TextStyle(
              fontFamily: 'Pretendard',
              fontWeight: FontWeight.w300,
              fontSize: 20.sp,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}
