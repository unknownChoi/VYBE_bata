import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vybe/design_system/colors.dart';
import 'package:vybe/design_system/typography.dart';

/// 목록 맨 아래 안내 문구 카드 (아이콘 + 회색 본문).
///
/// "정보가 달라질 수 있으니 방문 전 확인" 류의 면책 안내에 사용.
class VybeFooterNote extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String text;

  /// 아이콘 크기 (.r 적용).
  final double iconSize;

  /// 카드 바깥 여백. 기본값은 좌우 24 · 위 18 · 아래 8.
  final EdgeInsetsGeometry? margin;

  /// 카드 안쪽 여백. 기본값은 좌우 16 · 상하 14.
  final EdgeInsetsGeometry? padding;

  const VybeFooterNote({
    super.key,
    required this.icon,
    required this.iconColor,
    required this.text,
    this.iconSize = 15,
    this.margin,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin ?? EdgeInsets.fromLTRB(24.w, 18.h, 24.w, 8.h),
      padding: padding ??
          EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
      decoration: BoxDecoration(
        color: VybeColors.gray900,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: VybeColors.gray800),
      ),
      child: Row(
        children: [
          Icon(icon, size: iconSize.r, color: iconColor),
          SizedBox(width: 10.w),
          Expanded(
            child: Text(
              text,
              style: VybeTypography.caption
                  .copyWith(color: VybeColors.gray400, height: 17 / 12),
            ),
          ),
        ],
      ),
    );
  }
}
