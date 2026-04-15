import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vybe/design_system/colors.dart';

/// 통신사 선택 트리거 필드
///
/// VybeTextField와 동일한 bottom-border 스타일을 사용하되,
/// 실제 텍스트 입력 대신 탭 시 [onTap] 콜백을 통해
/// [CarrierSheet] 바텀시트를 오픈한다.
///
/// - 선택 전: hint 텍스트 (gray600) + 하단 화살표 아이콘
/// - 선택 후: 선택된 통신사 이름 (gray200) + 하단 화살표 아이콘
class CarrierDropdownField extends StatelessWidget {
  /// 현재 선택된 통신사 이름. null이면 hint 표시.
  final String? value;

  /// 필드 탭 시 호출 (통신사 바텀시트 오픈)
  final VoidCallback onTap;

  const CarrierDropdownField({
    super.key,
    required this.value,
    required this.onTap,
  });

  /// 상태에 따른 텍스트 스타일 반환
  ///
  /// VybeTypography에 24sp Medium이 없으므로 하드코딩
  static TextStyle _textStyle(Color color) => TextStyle(
        fontFamily: 'Pretendard',
        fontWeight: FontWeight.w500,
        fontSize: 24.sp,
        height: 26 / 24,
        letterSpacing: 24 * -0.025,
        color: color,
      );

  @override
  Widget build(BuildContext context) {
    final bool hasValue = value != null;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: const BoxDecoration(
          border: Border(
            bottom: BorderSide(color: VybeColors.gray700, width: 1),
          ),
        ),
        padding: EdgeInsets.symmetric(vertical: 4.h),
        child: Row(
          children: [
            Expanded(
              child: Text(
                hasValue ? value! : '통신사를 선택해주세요.',
                style: _textStyle(
                  // 선택된 경우 gray200, 미선택이면 gray600 (hint 색상)
                  hasValue ? VybeColors.gray200 : VybeColors.gray600,
                ),
              ),
            ),
            // 드롭다운 방향 표시 아이콘
            Icon(
              Icons.keyboard_arrow_down_rounded,
              color: VybeColors.gray500,
              size: 20.r,
            ),
          ],
        ),
      ),
    );
  }
}
