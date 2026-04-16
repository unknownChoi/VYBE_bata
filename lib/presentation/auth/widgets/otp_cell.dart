// TODO: otp_cell.dart
// 인증번호 입력 화면에서 사용하는 단일 OTP 셀 위젯
// - 6개의 셀이 Row로 나열되어 6자리 인증번호를 시각적으로 표현
// - 포커스 및 오류/만료 상태에 따라 테두리 색상이 변경됨

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vybe/design_system/colors.dart';

/// 인증번호 입력 셀 하나
///
/// [digit]: 표시할 숫자 문자 (비어있으면 빈 칸)
/// [borderColor]: 셀 테두리 색상 (transparent이면 테두리 없음)
class OtpCell extends StatelessWidget {
  final String digit;
  final Color borderColor;

  const OtpCell({
    super.key,
    required this.digit,
    required this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 43.w,
      height: 46.h,
      decoration: BoxDecoration(
        color: VybeColors.gray800,
        borderRadius: BorderRadius.circular(6.r),
        // borderColor가 transparent이면 테두리를 그리지 않아 성능 절약
        border: borderColor != Colors.transparent
            ? Border.all(color: borderColor, width: 1)
            : null,
      ),
      alignment: Alignment.center,
      child: Text(
        digit,
        style: TextStyle(
          fontFamily: 'Pretendard',
          fontWeight: FontWeight.w500,
          fontSize: 24.sp,
          height: 1,
          letterSpacing: 24 * -0.025,
          color: VybeColors.gray200,
        ),
      ),
    );
  }
}
