import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vybe/design_system/colors.dart';
import 'package:vybe/design_system/typography.dart';

/// 이미 입력 완료된 필드를 disabled 스타일로 표시하는 위젯
///
/// [IdentityVerificationScreen]에서 단계가 진행될수록 이전 필드들이
/// 최신순으로 활성 입력 필드 아래에 쌓인다.
/// 활성 입력 필드와 동일한 bottom-border 레이아웃을 유지하되,
/// 텍스트 색상을 gray600으로 낮춰 비활성임을 나타낸다.
class CompletedField extends StatelessWidget {
  /// 필드 레이블 (예: '이름', '생년월일', '전화번호', '통신사')
  final String label;

  /// 표시할 값 (포맷 적용 후 문자열)
  final String value;

  const CompletedField({
    super.key,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 레이블 — VybeTypography.caption: Regular 12sp ✓
        Text(
          label,
          style: VybeTypography.caption.copyWith(color: VybeColors.gray600),
        ),
        SizedBox(height: 8.h),

        // 입력값 — 24sp Medium (VybeTypography 미정의 → 하드코딩)
        // gray700 bottom border로 비활성 상태를 시각적으로 구분
        Container(
          width: double.infinity,
          decoration: const BoxDecoration(
            border: Border(
              bottom: BorderSide(color: VybeColors.gray700, width: 1),
            ),
          ),
          padding: EdgeInsets.symmetric(vertical: 4.h),
          child: Text(
            value,
            style: TextStyle(
              fontFamily: 'Pretendard',
              fontWeight: FontWeight.w500,
              fontSize: 24.sp,
              height: 26 / 24,
              letterSpacing: 24 * -0.025,
              color: VybeColors.gray600, // 비활성 색상
            ),
          ),
        ),
      ],
    );
  }
}
