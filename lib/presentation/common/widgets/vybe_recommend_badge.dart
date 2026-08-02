import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// VYBE 추천 클럽 뱃지 — 앱 전역 단일 디자인.
///
/// 기준 디자인은 주변 탭 지도 상세 시트 뱃지(보라 그라데이션 + 라임 테두리 + 흰 글씨).
/// 화면마다 [size]로 크기만 조절하고 색·모양·문구는 바꾸지 않는다.
/// (그라데이션 값은 `NearbyGlass.activeChip`과 동일 — common이 nearby를 참조할 수 없어 복제)
class VybeRecommendBadge extends StatelessWidget {
  /// 라벨 폰트 크기(sp). 아이콘·패딩·간격이 여기에 비례한다.
  final double size;

  /// 폭이 좁은 카드용 — 텍스트 없이 아이콘만.
  final bool iconOnly;

  const VybeRecommendBadge({super.key, this.size = 10, this.iconOnly = false});

  static const _gradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xF27731FE), Color(0xB3622ACF)],
  );
  static const _borderColor = Color(0x80B5FF60);

  @override
  Widget build(BuildContext context) {
    final iconSize = size.r;
    final padH = iconOnly ? size * 0.45 : size * 0.9;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: padH.w, vertical: (size * 0.4).h),
      decoration: BoxDecoration(
        gradient: _gradient,
        borderRadius: BorderRadius.circular(999.r),
        border: Border.all(color: _borderColor),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SvgPicture.asset(
            'assets/icons/common/club_card/vybe_recommend.svg',
            width: iconSize,
            height: iconSize,
          ),
          if (!iconOnly) ...[
            SizedBox(width: (size * 0.4).w),
            Text(
              'VYBE 추천',
              style: TextStyle(
                fontFamily: 'Pretendard',
                fontSize: size.sp,
                height: (size + 1) / size,
                fontWeight: FontWeight.w800,
                color: Colors.white,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
