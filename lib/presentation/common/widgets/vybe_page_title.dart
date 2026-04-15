import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vybe/design_system/colors.dart';
import 'package:vybe/presentation/common/widgets/vybe_status_message.dart';

/// Vybe 공통 페이지 타이틀
///
/// Figma "Title" 컴포넌트 기반
/// - [highlightText]: 라임색으로 강조할 앞부분 텍스트
/// - [regularText]: 흰색으로 표시할 뒷부분 텍스트
/// - [caption]: 타이틀 아래 표시할 상태 메시지 (선택)
/// - [captionType]: 상태 메시지 타입 (기본: error)
class VybePageTitle extends StatelessWidget {
  final String highlightText;
  final String regularText;
  final String? caption;
  final VybeStatusType captionType;

  const VybePageTitle({
    super.key,
    required this.highlightText,
    required this.regularText,
    this.caption,
    this.captionType = VybeStatusType.error,
  });

  @override
  Widget build(BuildContext context) {
    final titleStyle = TextStyle(
      fontFamily: 'Pretendard',
      fontWeight: FontWeight.w600,
      fontSize: 24.sp,
      height: 26 / 24,
      letterSpacing: 24 * -0.025,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        RichText(
          text: TextSpan(
            style: titleStyle,
            children: [
              TextSpan(
                text: highlightText,
                style: const TextStyle(color: VybeColors.mainLime500),
              ),
              TextSpan(
                text: regularText,
                style: const TextStyle(color: Colors.white),
              ),
            ],
          ),
        ),
        if (caption != null) ...[
          SizedBox(height: 12.h),
          VybeStatusMessage(message: caption!, type: captionType),
        ],
      ],
    );
  }
}
