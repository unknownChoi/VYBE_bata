import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:vybe/design_system/colors.dart';

/// 상태 메시지 타입
enum VybeStatusType { defaultState, warn, success, error }

/// Vybe 공통 상태 메시지
///
/// Figma "Status Message" 컴포넌트 기반
///
/// - [message]: 표시할 메시지 텍스트
/// - [type]: 메시지 타입 (기본: defaultState)
class VybeStatusMessage extends StatelessWidget {
  final String message;
  final VybeStatusType type;

  const VybeStatusMessage({
    super.key,
    required this.message,
    this.type = VybeStatusType.defaultState,
  });

  Color get _textColor => switch (type) {
        VybeStatusType.error => VybeColors.accentRed500,
        VybeStatusType.success => VybeColors.accentBlue500,
        _ => VybeColors.gray500,
      };

  Widget? get _icon {
    final iconSize = 12.r;
    return switch (type) {
      VybeStatusType.warn => SvgPicture.asset(
          'assets/icons/auth/age_limit_19.svg',
          width: iconSize,
          height: iconSize,
        ),
      VybeStatusType.error => Icon(
          Icons.error_rounded,
          size: iconSize,
          color: VybeColors.accentRed500,
        ),
      VybeStatusType.success => Icon(
          Icons.check_circle_rounded,
          size: iconSize,
          color: VybeColors.accentBlue500,
        ),
      _ => null,
    };
  }

  @override
  Widget build(BuildContext context) {
    final icon = _icon;
    final textStyle = TextStyle(
      fontFamily: 'Pretendard',
      fontWeight: FontWeight.w400,
      fontSize: 12.sp,
      height: 14 / 12,
      letterSpacing: 12 * -0.025,
      color: _textColor,
    );

    if (icon == null) {
      return Text(message, style: textStyle);
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        icon,
        SizedBox(width: 4.w),
        Text(message, style: textStyle),
      ],
    );
  }
}
