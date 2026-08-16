import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vybe/design_system/colors.dart';
import 'package:vybe/presentation/common/widgets/vybe_underline.dart';

/// 통신사 선택 트리거 필드
///
/// VybeTextField와 동일한 bottom-border 스타일을 사용하되,
/// 실제 텍스트 입력 대신 탭 시 [onTap] 콜백을 통해
/// [CarrierSheet] 바텀시트를 오픈한다.
///
/// - 선택 전 (active): hint 텍스트 (gray600) + 보라색 border
/// - 선택 후 (active): 선택된 통신사 이름 (gray200) + 보라색 border
/// - 비활성 (다른 단계 편집 중): CompletedField로 교체됨 (이 위젯 사용 안 함)
class CarrierDropdownField extends StatelessWidget {
  /// 현재 선택된 통신사 이름. null이면 hint 표시.
  final String? value;

  /// 필드 탭 시 호출 (통신사 바텀시트 오픈)
  final VoidCallback onTap;

  /// 통신사 단계가 현재 활성 단계인지 여부.
  /// VybeTextField의 _isFocused 역할 — true이면 보라색 border, false이면 회색
  final bool isActive;

  const CarrierDropdownField({
    super.key,
    required this.value,
    required this.onTap,
    this.isActive = false,
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

    // VybeTextField와 동일한 규칙:
    // active(포커스 중) 또는 값이 있으면 보라색, 아니면 회색
    final borderColor = (isActive || hasValue)
        ? VybeColors.mainPurple500
        : VybeColors.gray700;

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(0, 4.h, 0, 9.h),
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
          VybeUnderline(color: borderColor, glow: isActive),
        ],
      ),
    );
  }
}
