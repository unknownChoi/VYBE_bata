import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vybe/design_system/colors.dart';
import 'package:vybe/design_system/typography.dart';

/// 사진 위에 얹는 「● 영업 중 / 영업 종료」 pill.
///
/// 입장비 무료·서비스 음료 카드가 공유한다.
/// 클럽 상세의 [OpenStatusPill](clubs/widgets/club_glass.dart)과는 별개 —
/// 그쪽은 글래스 카드 위라 색·여백이 다르다.
class VybeOpenNowPill extends StatelessWidget {
  final bool open;

  /// pill 높이. screenutil이 이미 적용된 값을 넘긴다(`32.r` / `32.h`).
  /// 생략하면 `32.r`.
  final double? height;

  const VybeOpenNowPill({super.key, required this.open, this.height});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height ?? 32.r,
      alignment: Alignment.center,
      padding: EdgeInsets.symmetric(horizontal: 11.w),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.45),
        borderRadius: BorderRadius.circular(99.r),
        border: Border.all(
          color: open
              ? VybeColors.mainLime500.withValues(alpha: 0.5)
              : VybeColors.gray700,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6.r,
            height: 6.r,
            decoration: BoxDecoration(
              color: open ? VybeColors.mainLime500 : VybeColors.gray500,
              shape: BoxShape.circle,
            ),
          ),
          SizedBox(width: 5.w),
          Text(
            open ? '영업 중' : '영업 종료',
            style: VybeTypography.caption.copyWith(
              fontSize: 11.sp,
              fontWeight: FontWeight.w700,
              color: open ? VybeColors.mainLime500 : VybeColors.gray400,
            ),
          ),
        ],
      ),
    );
  }
}
