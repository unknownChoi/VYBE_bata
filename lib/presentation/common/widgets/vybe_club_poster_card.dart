import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vybe/design_system/colors.dart';
import 'package:vybe/design_system/typography.dart';
import 'package:vybe/presentation/common/widgets/vybe_club_card_parts.dart';
import 'package:vybe/presentation/common/widgets/vybe_recommend_badge.dart';
import 'package:vybe/presentation/common/widgets/vybe_skeleton.dart';

/// 장르 페이지(힙합 · EDM …) 2열 그리드의 포스터 카드 1장.
///
/// 사진 위에 `영업 상태`(좌상) · `찜`(우상) · `LIVE·추천 뱃지 + 이름/평점/지역/태그`(하단)를
/// 얹는다. 두 번째 화면(EDM)이 같은 카드를 쓰게 되면서 힙합 전용에서 승격했다 —
/// 화면마다 다른 건 액센트 색과 LIVE 아이콘뿐이라 그 둘만 파라미터로 받고
/// **기본값은 원래(힙합) 값을 유지**한다.
///
/// 조각을 나눠 둔 이유는 하나의 `build`가 200줄을 넘어가면 어느 Positioned가
/// 어느 요소인지 눈으로 못 쫓기 때문.
class VybeClubPosterCard extends StatelessWidget {
  final VybeClubPoster club;
  final bool saved;
  final VoidCallback onSave;
  final VoidCallback onTap;

  /// LIVE 뱃지 색. 화면 포인트 색을 넘긴다.
  final Color accent;

  /// LIVE 뱃지 아이콘 — 힙합은 마이크, EDM은 번개.
  final IconData liveIcon;

  const VybeClubPosterCard({
    super.key,
    required this.club,
    required this.saved,
    required this.onSave,
    required this.onTap,
    this.accent = VybeColors.mainLime500,
    this.liveIcon = Icons.mic_none_rounded,
  });

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(16.r);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          gradient: vybePosterGradient(club.bg),
          borderRadius: radius,
        ),
        // ⚠ 테두리는 자식 위(foregroundDecoration)에. decoration 에 두면 자식이
        // 바깥 라운드렉트로 클립되면서 코너 호에서 선을 덮어, 직선부만 남고
        // 모서리가 끊긴 것처럼 보인다. (CLAUDE.md '라운드 카드에 테두리' 참고)
        foregroundDecoration: BoxDecoration(
          border: Border.all(color: VybeColors.gray800),
          borderRadius: radius,
        ),
        child: Stack(
          fit: StackFit.expand,
          children: [
            // 클럽 썸네일(없으면 그라데이션만).
            if (club.thumbnailUrl.isNotEmpty)
              Positioned.fill(
                child: SkeletonImage(
                  url: club.thumbnailUrl,
                  fit: BoxFit.cover,
                  minSkeleton: const Duration(seconds: 1),
                ),
              ),
            const _Sheen(),
            const Positioned.fill(
              child: VybeCardScrim(
                colors: [
                  Color(0xF20A090B),
                  Color(0x330A090B),
                  Color(0x000A090B),
                ],
                stops: [0.16, 0.56, 0.80],
              ),
            ),
            Positioned(
              top: 11.h,
              left: 11.w,
              child: _OpenPill(open: club.open),
            ),
            Positioned(
              top: 8.h,
              right: 8.w,
              child: _SaveButton(saved: saved, onTap: onSave),
            ),
            Positioned(
              left: 12.w,
              right: 12.w,
              bottom: 12.h,
              child: _Body(club: club, accent: accent, liveIcon: liveIcon),
            ),
          ],
        ),
      ),
    );
  }
}

/// 포스터 카드 배경 fallback 그라데이션 — 150deg 근사(디자인 색/순서 유지, 각도만 근사).
LinearGradient vybePosterGradient(List<Color> colors) => LinearGradient(
  begin: const Alignment(-0.5, -0.87),
  end: const Alignment(0.5, 0.87),
  colors: colors,
);

/// 포스터 카드 1장이 그리는 값 — 클럽 + (있으면) 오늘 라인업을 머지한 결과.
class VybeClubPoster {
  final String id;
  final String name;
  final String area;
  final double dist;
  final double rating;
  final int reviews;
  final List<String> styles;

  /// 오늘 헤드라이너 이름. [live] 가 false면 안 쓰인다.
  final String lineup;

  /// 오늘 이 클럽에 공연이 있는지 — LIVE 뱃지 노출 여부.
  final bool live;
  final bool open;
  final String thumbnailUrl;
  final List<Color> bg;

  /// isVybeRecommended — VYBE 추천 뱃지 노출.
  final bool vybe;

  const VybeClubPoster({
    required this.id,
    required this.name,
    required this.area,
    required this.dist,
    required this.rating,
    required this.reviews,
    required this.styles,
    required this.lineup,
    required this.live,
    required this.open,
    required this.thumbnailUrl,
    required this.bg,
    required this.vybe,
  });
}

/// 좌상단에서 번지는 흰 광택 — 포스터가 인쇄물처럼 보이게 한다.
class _Sheen extends StatelessWidget {
  const _Sheen();

  @override
  Widget build(BuildContext context) {
    return const Positioned.fill(
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: RadialGradient(
            center: Alignment(0.4, -0.76),
            radius: 0.9,
            colors: [Color(0x33FFFFFF), Color(0x00FFFFFF)],
            stops: [0.0, 0.55],
          ),
        ),
      ),
    );
  }
}

class _OpenPill extends StatelessWidget {
  final bool open;
  const _OpenPill({required this.open});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.42),
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
            width: 5.r,
            height: 5.r,
            decoration: BoxDecoration(
              color: open ? VybeColors.mainLime500 : VybeColors.gray500,
              shape: BoxShape.circle,
            ),
          ),
          SizedBox(width: 5.w),
          Text(
            open ? '영업중' : '영업종료',
            style: VybeTypography.caption.copyWith(
              fontSize: 10.sp,
              height: 11 / 10,
              fontWeight: FontWeight.w700,
              color: open ? VybeColors.mainLime500 : VybeColors.gray400,
            ),
          ),
        ],
      ),
    );
  }
}

class _SaveButton extends StatelessWidget {
  final bool saved;
  final VoidCallback onTap;
  const _SaveButton({required this.saved, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        width: 30.r,
        height: 30.r,
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.42),
          shape: BoxShape.circle,
        ),
        child: Icon(
          saved ? Icons.favorite_rounded : Icons.favorite_border_rounded,
          size: 15.r,
          color: saved ? VybeColors.mainPurple500 : Colors.white,
        ),
      ),
    );
  }
}

/// 카드 하단 본문 — LIVE 뱃지 · 이름/평점 · 지역/거리 · 스타일 태그.
class _Body extends StatelessWidget {
  final VybeClubPoster club;
  final Color accent;
  final IconData liveIcon;
  const _Body({
    required this.club,
    required this.accent,
    required this.liveIcon,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (club.live || club.vybe)
          _BadgeRow(club: club, accent: accent, liveIcon: liveIcon),
        _TitleRow(club: club),
        SizedBox(height: 5.h),
        _PlaceRow(area: club.area, dist: club.dist),
        SizedBox(height: 8.h),
        _StyleTags(styles: club.styles),
      ],
    );
  }
}

/// LIVE · VYBE 추천 뱃지 줄 — 이름 위.
///
/// 뱃지를 이름 옆(`_TitleRow`)에 두면 2열 그리드의 좁은 카드에서 pill 이 고정폭이라
/// `Flexible` 인 이름이 0 까지 눌려 통째로 사라진다. 그래서 이름 위 줄로 올린다.
/// 둘 다 있으면 `Wrap` 이 폭에 따라 알아서 줄을 나눈다.
class _BadgeRow extends StatelessWidget {
  final VybeClubPoster club;
  final Color accent;
  final IconData liveIcon;
  const _BadgeRow({
    required this.club,
    required this.accent,
    required this.liveIcon,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8.h),
      child: Wrap(
        spacing: 5.w,
        runSpacing: 5.h,
        children: [
          if (club.live)
            _LiveBadge(lineup: club.lineup, accent: accent, icon: liveIcon),
          if (club.vybe) const VybeRecommendBadge(size: 10),
        ],
      ),
    );
  }
}

/// `{아티스트} LIVE` — 오늘 이 클럽에서 공연이 있을 때만.
class _LiveBadge extends StatelessWidget {
  final String lineup;
  final Color accent;
  final IconData icon;
  const _LiveBadge({
    required this.lineup,
    required this.accent,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
      decoration: BoxDecoration(
        color: accent.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(7.r),
        border: Border.all(color: accent.withValues(alpha: 0.36)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 11.r, color: accent),
          SizedBox(width: 4.w),
          Text(
            '$lineup LIVE',
            style: VybeTypography.caption.copyWith(
              fontSize: 10.sp,
              height: 11 / 10,
              fontWeight: FontWeight.w700,
              color: accent,
            ),
          ),
        ],
      ),
    );
  }
}

/// 이름 · 평점. baseline 정렬을 유지해야 글자 밑선이 맞는다.
class _TitleRow extends StatelessWidget {
  final VybeClubPoster club;
  const _TitleRow({required this.club});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.baseline,
      textBaseline: TextBaseline.alphabetic,
      children: [
        Flexible(
          child: Text(
            club.name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontFamily: 'Pretendard',
              fontSize: 18.sp,
              height: 20 / 18,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
        ),
        SizedBox(width: 6.w),
        Icon(Icons.star_rounded, size: 11.r, color: VybeColors.mainLime500),
        SizedBox(width: 2.w),
        Text(
          club.rating.toStringAsFixed(2),
          style: VybeTypography.caption.copyWith(
            fontSize: 11.sp,
            height: 12 / 11,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
      ],
    );
  }
}

class _PlaceRow extends StatelessWidget {
  final String area;
  final double dist;
  const _PlaceRow({required this.area, required this.dist});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(Icons.place_rounded, size: 10.r, color: VybeColors.gray400),
        SizedBox(width: 4.w),
        Text(
          '$area · ${dist.toStringAsFixed(1)}km',
          style: VybeTypography.caption.copyWith(
            fontSize: 11.sp,
            height: 12 / 11,
            fontWeight: FontWeight.w600,
            color: VybeColors.gray400,
          ),
        ),
      ],
    );
  }
}

/// `#트랩 #붐뱁` — clubs.genreStyles.
class _StyleTags extends StatelessWidget {
  final List<String> styles;
  const _StyleTags({required this.styles});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 5.w,
      runSpacing: 5.h,
      children: [
        for (final style in styles)
          Container(
            padding: EdgeInsets.symmetric(horizontal: 7.w, vertical: 1.h),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.09),
              borderRadius: BorderRadius.circular(6.r),
            ),
            child: Text(
              '#$style',
              style: VybeTypography.caption.copyWith(
                fontSize: 10.sp,
                height: 13 / 10,
                fontWeight: FontWeight.w600,
                color: VybeColors.gray300,
              ),
            ),
          ),
      ],
    );
  }
}
