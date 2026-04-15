import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vybe/design_system/colors.dart';

/// Vybe 공통 체크박스
///
/// Figma "Frame103 / Rectangle23" 컴포넌트 기반
/// - 미선택: 회색(#8F8F8F) 테두리 박스
/// - 선택: 라임(mainLime500) 테두리 + 라임 체크마크
///
/// - [value]: 체크 상태
/// - [onChanged]: 상태 변경 콜백 (null이면 disabled)
/// - [label]: 우측 레이블 텍스트 (선택)
class VybeCheckbox extends StatelessWidget {
  final bool value;
  final ValueChanged<bool>? onChanged;
  final String? label;

  const VybeCheckbox({
    super.key,
    required this.value,
    required this.onChanged,
    this.label,
  });

  bool get _isDisabled => onChanged == null;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _isDisabled ? null : () => onChanged!(!value),
      behavior: HitTestBehavior.opaque,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _CheckboxBox(value: value),
          if (label != null) ...[
            SizedBox(width: 12.w),
            Text(
              label!,
              style: TextStyle(
                fontFamily: 'Pretendard',
                fontWeight: FontWeight.w500,
                fontSize: 20.sp,
                color: _isDisabled ? VybeColors.gray600 : VybeColors.gray200,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _CheckboxBox extends StatelessWidget {
  final bool value;

  const _CheckboxBox({required this.value});

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      width: 16.r,
      height: 16.r,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(2.r),
        border: Border.all(
          color: value ? VybeColors.mainLime500 : const Color(0xFF8F8F8F),
          width: 1,
        ),
      ),
      child: value
          ? Icon(
              Icons.check_rounded,
              size: 11.r,
              color: VybeColors.mainLime500,
            )
          : null,
    );
  }
}
