import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vybe/design_system/colors.dart';
import 'package:vybe/design_system/typography.dart';
import 'package:vybe/presentation/service_drinks/service_drinks_style.dart';

/// 화면 상단 인트로 — 제목 + '지금 제공 중' pill + `{지역} 근처 {n}곳`.
class ServiceDrinksIntro extends StatelessWidget {
  /// 필터·정렬을 거친 뒤의 클럽 수 (전체 수가 아니다).
  final int count;

  /// 위치 칩에 표시 중인 지역 라벨.
  final String loc;

  const ServiceDrinksIntro({
    super.key,
    required this.count,
    required this.loc,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(24.w, 20.h, 24.w, 14.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text.rich(
            TextSpan(
              style: TextStyle(
                fontFamily: 'Pretendard',
                fontSize: 27.sp,
                height: 33 / 27,
                fontWeight: FontWeight.w700,
                color: Colors.white,
                letterSpacing: 27 * -0.025,
              ),
              children: const [
                TextSpan(text: '내 주변에서 '),
                TextSpan(text: '무료 음료', style: TextStyle(color: kDrinkAccent)),
                TextSpan(text: '\n주는 클럽'),
              ],
            ),
          ),
          SizedBox(height: 9.h),
          Row(
            children: [
              const _NowServingPill(),
              SizedBox(width: 7.w),
              _CountLine(loc: loc, count: count),
            ],
          ),
        ],
      ),
    );
  }
}

class _NowServingPill extends StatelessWidget {
  const _NowServingPill();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: kDrinkAccent.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(999.r),
        border: Border.all(color: kDrinkAccent.withValues(alpha: 0.4)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 7.r,
            height: 7.r,
            decoration: const BoxDecoration(
              color: kDrinkAccent,
              shape: BoxShape.circle,
            ),
          ),
          SizedBox(width: 5.w),
          Text(
            '지금 제공 중',
            style: VybeTypography.caption.copyWith(
              height: 14 / 12,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}

class _CountLine extends StatelessWidget {
  final String loc;
  final int count;
  const _CountLine({required this.loc, required this.count});

  @override
  Widget build(BuildContext context) {
    const strong = TextStyle(
      color: Colors.white,
      fontWeight: FontWeight.w700,
    );
    return Text.rich(
      TextSpan(
        style: VybeTypography.caption.copyWith(color: VybeColors.gray400),
        children: [
          TextSpan(text: loc, style: strong),
          const TextSpan(text: ' 근처 '),
          TextSpan(text: '$count곳', style: strong),
        ],
      ),
    );
  }
}
