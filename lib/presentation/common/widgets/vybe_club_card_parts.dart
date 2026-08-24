import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vybe/design_system/colors.dart';
import 'package:vybe/design_system/typography.dart';
import 'package:vybe/presentation/common/widgets/vybe_meta_dot.dart';
import 'package:vybe/presentation/common/widgets/vybe_recommend_badge.dart';

/// 사진 위 클럽 카드가 공유하는 조각들 (입장비 무료 · 서비스 음료 · 장르 포스터).
///
/// 세 화면이 같은 줄을 복붙해 쓰고 있어 승격했다. 화면마다 다른 건 줄 간격과
/// 스크림 색뿐이라 파라미터로 받되 **기본값은 원래 화면 값을 유지**한다.

/// 카드 위에 얹는 하단 그라데이션 — 사진 위에서도 글자가 읽히게.
///
/// 기본값은 사진 카드(입장비 무료·서비스 음료) 톤. 장르 포스터처럼 더 어두운
/// 배경을 쓰는 화면은 [colors]·[stops] 를 넘겨 자기 톤을 유지한다.
class VybeCardScrim extends StatelessWidget {
  final List<Color> colors;
  final List<double> stops;

  const VybeCardScrim({
    super.key,
    this.colors = const [
      Color(0xF50C0C0F),
      Color(0x400C0C0F),
      Colors.transparent,
    ],
    this.stops = const [0.14, 0.56, 0.78],
  });

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.bottomCenter,
          end: Alignment.topCenter,
          colors: colors,
          stops: stops,
        ),
      ),
    );
  }
}

/// 카드 제목 줄 — 클럽 이름 + VYBE 추천 뱃지 + 평점.
class VybeClubTitleRow extends StatelessWidget {
  final String name;
  final double rating;

  /// true면 이름 옆에 VYBE 추천 뱃지가 붙는다.
  final bool recommended;

  /// 이름 줄 높이. null이면 타이포 기본값 — 카드가 빽빽할 때만 1.0 을 넘긴다.
  final double? titleHeight;

  /// 평점 뒤에 덧붙일 것 (예: 검색 결과 카드의 `리뷰 12`). null이면 평점에서 끝난다.
  final Widget? trailing;

  const VybeClubTitleRow({
    super.key,
    required this.name,
    required this.rating,
    required this.recommended,
    this.titleHeight,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.baseline,
      textBaseline: TextBaseline.alphabetic,
      children: [
        Flexible(
          child: Text(
            name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: VybeTypography.heading4.copyWith(
              color: Colors.white,
              height: titleHeight,
            ),
          ),
        ),
        if (recommended) ...[
          SizedBox(width: 6.w),
          const VybeRecommendBadge(size: 10),
        ],
        SizedBox(width: 8.w),
        Icon(Icons.star_rounded, size: 12.r, color: VybeColors.mainLime500),
        SizedBox(width: 3.w),
        Text(
          rating.toStringAsFixed(2),
          style: VybeTypography.caption.copyWith(
            fontSize: 12.sp,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
        if (trailing != null) ...[SizedBox(width: 6.w), trailing!],
      ],
    );
  }
}

/// 카드 메타 줄 — 지역 · 거리 · 장르.
class VybeClubMetaRow extends StatelessWidget {
  final String area;

  /// 내 위치 기준 추정 거리(km).
  final double dist;

  final String genre;

  /// 글자 줄 높이. null이면 타이포 기본값.
  final double? lineHeight;

  const VybeClubMetaRow({
    super.key,
    required this.area,
    required this.dist,
    required this.genre,
    this.lineHeight,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(Icons.place_rounded, size: 11.r, color: VybeColors.gray300),
        SizedBox(width: 3.w),
        Text(
          '$area · ${dist.toStringAsFixed(1)}km',
          style: VybeTypography.caption.copyWith(
            fontSize: 12.sp,
            height: lineHeight,
            fontWeight: FontWeight.w600,
            color: VybeColors.gray300,
          ),
        ),
        const VybeMetaDot(),
        Text(
          genre,
          style: VybeTypography.caption.copyWith(
            fontSize: 12.sp,
            height: lineHeight,
            color: VybeColors.gray400,
          ),
        ),
      ],
    );
  }
}

/// 인트로 아래 `{지역} 근처 {n}곳` 한 줄.
class VybeAreaCountLine extends StatelessWidget {
  /// 앞에 굵게 붙는 지역 라벨 ('내 주변' · '홍대').
  final String area;

  /// 필터·정렬을 거친 뒤의 클럽 수.
  final int count;

  const VybeAreaCountLine({super.key, required this.area, required this.count});

  @override
  Widget build(BuildContext context) {
    const strong = TextStyle(color: Colors.white, fontWeight: FontWeight.w700);
    return Text.rich(
      TextSpan(
        style: VybeTypography.caption.copyWith(color: VybeColors.gray400),
        children: [
          TextSpan(text: area, style: strong),
          const TextSpan(text: ' 근처 '),
          TextSpan(text: '$count곳', style: strong),
        ],
      ),
    );
  }
}
