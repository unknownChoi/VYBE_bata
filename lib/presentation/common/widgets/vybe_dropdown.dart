import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vybe/design_system/colors.dart';

/// Vybe 공통 드롭다운 필드
///
/// Figma "input / variant=dropdown" 컴포넌트 기반
/// 하단 라인(bottom border)만 있는 스타일
///
/// - [hint]: 미선택 시 플레이스홀더
/// - [items]: 선택 가능한 항목 목록 (label 리스트)
/// - [value]: 현재 선택값
/// - [onChanged]: 선택 변경 콜백 (null이면 disabled)
/// - [errorText]: 에러 메시지
class VybeDropdown extends StatelessWidget {
  final String? hint;
  final List<String> items;
  final String? value;
  final ValueChanged<String?>? onChanged;
  final String? errorText;

  const VybeDropdown({
    super.key,
    this.hint,
    required this.items,
    this.value,
    this.onChanged,
    this.errorText,
  });

  bool get _isDisabled => onChanged == null;

  Color get _lineColor {
    if (_isDisabled) return VybeColors.gray700;
    if (errorText != null) return VybeColors.accentRed500;
    return VybeColors.gray700;
  }

  Color get _textColor {
    if (errorText != null) return VybeColors.accentRed700;
    return VybeColors.gray200;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(color: _lineColor, width: 1),
            ),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: value,
              hint: Text(
                hint ?? '',
                style: TextStyle(
                  fontFamily: 'Pretendard',
                  fontWeight: FontWeight.w500,
                  fontSize: 24.sp,
                  height: 26 / 24,
                  letterSpacing: 24 * -0.025,
                  color: VybeColors.gray600,
                ),
              ),
              isExpanded: true,
              icon: Icon(
                Icons.keyboard_arrow_down_rounded,
                color: VybeColors.gray500,
                size: 20.r,
              ),
              dropdownColor: VybeColors.surface,
              style: TextStyle(
                fontFamily: 'Pretendard',
                fontWeight: FontWeight.w500,
                fontSize: 24.sp,
                height: 26 / 24,
                letterSpacing: 24 * -0.025,
                color: _textColor,
              ),
              onChanged: _isDisabled ? null : onChanged,
              items: items.map((item) {
                return DropdownMenuItem<String>(
                  value: item,
                  child: Text(item),
                );
              }).toList(),
            ),
          ),
        ),
        if (errorText != null) ...[
          SizedBox(height: 8.h),
          Text(
            errorText!,
            style: TextStyle(
              fontFamily: 'Pretendard',
              fontWeight: FontWeight.w400,
              fontSize: 12.sp,
              height: 14 / 12,
              letterSpacing: 12 * -0.025,
              color: VybeColors.accentRed500,
            ),
          ),
        ],
      ],
    );
  }
}
