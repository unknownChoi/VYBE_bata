import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vybe/design_system/colors.dart';
import 'package:vybe/design_system/typography.dart';

/// 클럽 상세 **리뉴얼** 공통 토큰 · 글래스 프리미티브.
///
/// 디자인: club_detail_renew.html (`club_renew_shell.jsx` + `tokens.jsx`).
/// CSS `blur(Npx)` ≈ Flutter `ImageFilter.blur(sigma N/2)`.
///
/// 기존 `club_glass.dart`(구 상세)와 값이 달라 별도 토큰으로 둔다 —
/// 구 화면을 그대로 두라는 요구가 있어 공유하면 한쪽만 바꿀 수 없다.
class RenewGlass {
  RenewGlass._();

  /// 페이지 좌우 여백 (디자인 PAGE_H).
  static const double pagePad = 24;

  /// 섹션 사이 간격 (디자인 SP.xxxl).
  static const double sectionGap = 32;

  // ── 표면 ──
  /// 최하단 배경색 (VR.ink)
  static const Color ink = Color(0xFF0E0D12);

  /// 카드 채움 — rgba(120,120,128,0.16)
  static const Color cardFill = Color(0x29787880);

  /// 카드 테두리 — rgba(255,255,255,0.10)
  static const Color cardBorder = Color(0x1AFFFFFF);

  /// 낮은 톤 카드 채움 — rgba(120,120,128,0.08)
  static const Color quietFill = Color(0x14787880);

  /// 낮은 톤 카드 테두리 — rgba(255,255,255,0.06)
  static const Color quietBorder = Color(0x0FFFFFFF);

  /// 타일(칩·작은 버튼) 채움 — rgba(255,255,255,0.07)
  static const Color tileFill = Color(0x12FFFFFF);

  /// 타일 테두리 — rgba(255,255,255,0.12)
  static const Color tileBorder = Color(0x1FFFFFFF);

  /// 상·하단 바 채움 — rgba(14,13,18,0.55)
  static const Color barFill = Color(0x8C0E0D12);

  /// 구분선 — rgba(255,255,255,0.09)
  static const Color hair = Color(0x17FFFFFF);

  // ── 텍스트 계조 (VR.t1~t4) ──
  static const Color t1 = Colors.white;
  static const Color t2 = Color(0xD1FFFFFF); // 0.82
  static const Color t3 = Color(0xADFFFFFF); // 0.68
  static const Color t4 = VybeColors.gray500;

  /// 태그·'오늘' 뱃지·전체보기 링크
  static const Color lavender = Color(0xFFC8A8FF);

  /// 전화·인스타 링크
  static const Color link = Color(0xFF8FB5FF);

  // ── 블러 ──
  static const double cardBlur = 9; // CSS blur(18px)
  static const double quietBlur = 7; // CSS blur(14px)
  static const double barBlur = 10; // CSS blur(20px)

  /// 섹션 제목 (TYPO.h4)
  static TextStyle title() => VybeTypography.heading4.copyWith(color: t1);

  /// 본문 (TYPO.body4). 디자인이 행간을 자주 덮어써 [lineHeight]로 받는다.
  static TextStyle body({
    Color color = t2,
    double lineHeight = 16,
    FontWeight? weight,
  }) => VybeTypography.body4.copyWith(
    color: color,
    height: lineHeight / 14,
    fontWeight: weight,
  );

  /// 보조 문구 (TYPO.caption — 행간만 디자인 값으로 덮어씀).
  static TextStyle caption({
    Color color = t4,
    double size = 12,
    double lineHeight = 16,
    FontWeight weight = FontWeight.w400,
  }) => TextStyle(
    fontFamily: 'Pretendard',
    fontSize: size.sp,
    height: lineHeight / size,
    fontWeight: weight,
    letterSpacing: size * -0.025,
    color: color,
  );
}

// ============================================================================
// 배경 (VR.aurora)
// ============================================================================

/// 리뉴얼 오로라 배경 — 좌상단 보라 · 우상단 라임 · 우하단 보라 3겹.
///
/// CSS는 타원 radial-gradient지만 Flutter [RadialGradient]는 원이라
/// 가로·세로 반지름의 평균으로 근사한다.
class RenewAurora extends StatelessWidget {
  const RenewAurora({super.key});

  @override
  Widget build(BuildContext context) {
    return const ColoredBox(
      color: RenewGlass.ink,
      child: Stack(
        children: [
          // radial(120% 80% at 0% 0%, rgba(119,49,254,0.50), transparent 72%)
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment(-1, -1),
                  radius: 1.5,
                  colors: [Color(0x807731FE), Color(0x007731FE)],
                  stops: [0.0, 0.72],
                ),
              ),
            ),
          ),
          // radial(110% 80% at 100% 2%, rgba(181,255,96,0.26), transparent 74%)
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment(1, -0.96),
                  radius: 1.42,
                  colors: [Color(0x42B5FF60), Color(0x00B5FF60)],
                  stops: [0.0, 0.74],
                ),
              ),
            ),
          ),
          // radial(120% 90% at 88% 100%, rgba(119,49,254,0.34), transparent 76%)
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment(0.76, 1),
                  radius: 1.55,
                  colors: [Color(0x577731FE), Color(0x007731FE)],
                  stops: [0.0, 0.76],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// 카드 (VGlass)
// ============================================================================

/// 리퀴드 글래스 카드. 상단 1px 하이라이트 + 블러 + (기본 톤일 때) 그림자.
class RenewGlassCard extends StatelessWidget {
  final Widget child;

  /// 낮은 톤 — quietFill/quietBorder + 그림자 없음.
  final bool quiet;

  /// CSS px 기준 모서리·내부 여백.
  final double radius;
  final double padding;

  /// 기본 톤에서 그림자를 뺄 때 false.
  final bool elevated;

  /// 기본 톤 대신 쓸 채움·테두리 (이용 안내 보라 카드).
  final Color? fill;
  final Color? border;

  const RenewGlassCard({
    super.key,
    required this.child,
    this.quiet = false,
    this.radius = 19,
    this.padding = 16,
    this.elevated = true,
    this.fill,
    this.border,
  });

  @override
  Widget build(BuildContext context) {
    final r = BorderRadius.circular(radius.r);
    final blur = quiet ? RenewGlass.quietBlur : RenewGlass.cardBlur;

    return Container(
      decoration: BoxDecoration(
        borderRadius: r,
        boxShadow: (!quiet && elevated)
            ? [
                BoxShadow(
                  color: const Color(0x5C000000), // 0 10px 30px rgba(0,0,0,.36)
                  blurRadius: 30.r,
                  offset: Offset(0, 10.h),
                ),
              ]
            : null,
      ),
      // 테두리는 하이라이트 위에 그려야 선이 죽지 않는다.
      foregroundDecoration: BoxDecoration(
        borderRadius: r,
        border: Border.all(
          color:
              border ??
              (quiet ? RenewGlass.quietBorder : RenewGlass.cardBorder),
        ),
      ),
      child: ClipRRect(
        borderRadius: r,
        child: BackdropFilter(
          filter: ui.ImageFilter.blur(sigmaX: blur, sigmaY: blur),
          // 채움색과 하이라이트는 레이어를 나눈다 — 한 BoxDecoration에
          // color·gradient를 같이 주면 gradient가 color를 덮어써 배경이 사라진다.
          child: ColoredBox(
            color: fill ?? (quiet ? RenewGlass.quietFill : RenewGlass.cardFill),
            child: Stack(
              fit: StackFit.passthrough,
              children: [
                // 상단 1px 하이라이트 (기본 0.18 / quiet 0.08)
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  height: 1,
                  child: ColoredBox(
                    color: quiet
                        ? const Color(0x14FFFFFF)
                        : const Color(0x2EFFFFFF),
                  ),
                ),
                Padding(padding: EdgeInsets.all(padding.r), child: child),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ============================================================================
// 바 (탭바 · 칩 줄 · 하단 액션바 공통 배경)
// ============================================================================

/// barFill + blur + 위/아래 hairline 을 가진 가로 바.
class RenewBar extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final bool topBorder;
  final bool bottomBorder;

  const RenewBar({
    super.key,
    required this.child,
    required this.padding,
    this.topBorder = false,
    this.bottomBorder = true,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRect(
      child: BackdropFilter(
        filter: ui.ImageFilter.blur(
          sigmaX: RenewGlass.barBlur,
          sigmaY: RenewGlass.barBlur,
        ),
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            color: RenewGlass.barFill,
            border: Border(
              top: topBorder
                  ? const BorderSide(color: RenewGlass.hair)
                  : BorderSide.none,
              bottom: bottomBorder
                  ? const BorderSide(color: RenewGlass.hair)
                  : BorderSide.none,
            ),
          ),
          child: child,
        ),
      ),
    );
  }
}

/// 가로 스크롤 rail을 화면 양끝까지 흘려보낸다 (디자인 `margin: 0 -24`).
///
/// 탭 콘텐츠는 좌우 24 패딩 안에 있는데 rail만 그 밖으로 넘쳐야 해서,
/// 화면 폭만큼 넓은 [OverflowBox]를 씌우고 안쪽 리스트가 다시 24를 준다.
class RenewEdgeBleed extends StatelessWidget {
  final double height;
  final Widget child;

  const RenewEdgeBleed({super.key, required this.height, required this.child});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      child: OverflowBox(
        maxWidth: MediaQuery.sizeOf(context).width,
        alignment: Alignment.center,
        child: child,
      ),
    );
  }
}

// ============================================================================
// 섹션 헤더 (VHead)
// ============================================================================

/// `제목 [보조문구]  ...  [액션 >]` 한 줄. 아래 여백 12.
class RenewSectionHead extends StatelessWidget {
  final String title;
  final String? sub;
  final String actionLabel;
  final VoidCallback? onAction;

  const RenewSectionHead({
    super.key,
    required this.title,
    this.sub,
    this.actionLabel = '전체보기',
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.baseline,
        textBaseline: TextBaseline.alphabetic,
        children: [
          Flexible(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              mainAxisSize: MainAxisSize.min,
              children: [
                Flexible(
                  child: Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: RenewGlass.title(),
                  ),
                ),
                if (sub != null && sub!.isNotEmpty) ...[
                  SizedBox(width: 8.w),
                  Flexible(
                    child: Text(
                      sub!,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: RenewGlass.caption(),
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (onAction != null) ...[
            SizedBox(width: 12.w),
            GestureDetector(
              onTap: onAction,
              behavior: HitTestBehavior.opaque,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    actionLabel,
                    style: VybeTypography.button2.copyWith(
                      color: RenewGlass.lavender,
                    ),
                  ),
                  Icon(
                    Icons.chevron_right_rounded,
                    size: 15.r,
                    color: RenewGlass.lavender,
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ============================================================================
// 작은 조각들
// ============================================================================

/// 메타 구분점 (VDot) — 3px gray600.
class RenewDot extends StatelessWidget {
  final double size;
  const RenewDot({super.key, this.size = 3});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size.r,
      height: size.r,
      decoration: const BoxDecoration(
        color: VybeColors.gray600,
        shape: BoxShape.circle,
      ),
    );
  }
}

/// `홍대 · 힙합 · 0.4km` 처럼 점으로 이어지는 메타 줄 (VMeta).
class RenewMetaRow extends StatelessWidget {
  final List<String> items;
  const RenewMetaRow({super.key, required this.items});

  @override
  Widget build(BuildContext context) {
    final visible = items.where((e) => e.isNotEmpty).toList();
    return Row(
      children: [
        for (var i = 0; i < visible.length; i++) ...[
          if (i > 0) ...[
            SizedBox(width: 6.w),
            const RenewDot(),
            SizedBox(width: 6.w),
          ],
          Flexible(
            child: Text(
              visible[i],
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: RenewGlass.body(color: RenewGlass.t3),
            ),
          ),
        ],
      ],
    );
  }
}

/// 영업중/영업종료 pill (VStatusPill). 영업중 라임 · 영업종료 레드.
class RenewStatusPill extends StatelessWidget {
  final bool isOpen;

  /// 기본 문구 대신 쓸 라벨 (예: `영업중 · 02:00 종료`).
  final String? label;

  const RenewStatusPill({super.key, required this.isOpen, this.label});

  @override
  Widget build(BuildContext context) {
    final color = isOpen ? VybeColors.mainLime500 : VybeColors.accentRed500;
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: color.withValues(alpha: isOpen ? 0.14 : 0.13),
        borderRadius: BorderRadius.circular(999.r),
        border: Border.all(
          color: color.withValues(alpha: isOpen ? 0.30 : 0.28),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 5.r,
            height: 5.r,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          SizedBox(width: 5.w),
          Text(
            label ?? (isOpen ? '영업중' : '영업종료'),
            style: RenewGlass.caption(
              color: color,
              size: 11,
              lineHeight: 11,
              weight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

/// 라임 채움 / 글래스 아웃라인 토글 칩 (VRChip).
class RenewChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const RenewChip({
    super.key,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        padding: EdgeInsets.symmetric(horizontal: 15.w, vertical: 8.h),
        decoration: BoxDecoration(
          color: selected ? VybeColors.mainLime500 : RenewGlass.tileFill,
          borderRadius: BorderRadius.circular(999.r),
          border: Border.all(
            color: selected ? VybeColors.mainLime500 : RenewGlass.tileBorder,
          ),
        ),
        child: Text(
          label,
          style: VybeTypography.button2.copyWith(
            fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
            color: selected ? RenewGlass.ink : RenewGlass.t2,
          ),
        ),
      ),
    );
  }
}

/// 아이콘 + 본문 한 줄 (VRToday/VRDetailInfo 카드 내부 행).
class RenewInfoRow extends StatelessWidget {
  final IconData icon;
  final Widget child;
  final bool last;

  const RenewInfoRow({
    super.key,
    required this.icon,
    required this.child,
    this.last = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 12.h),
      decoration: BoxDecoration(
        border: last
            ? null
            : const Border(bottom: BorderSide(color: RenewGlass.hair)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.only(top: 1.h, right: 12.w),
            child: Icon(icon, size: 17.r, color: const Color(0x8CFFFFFF)),
          ),
          Expanded(child: child),
        ],
      ),
    );
  }
}

/// 목록 맨 아래 안내 문구 (VFooterNote).
class RenewFooterNote extends StatelessWidget {
  final String text;
  const RenewFooterNote({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 15.w, vertical: 13.h),
      decoration: BoxDecoration(
        color: const Color(0x0AFFFFFF), // rgba(255,255,255,0.04)
        borderRadius: BorderRadius.circular(13.r),
        border: Border.all(color: RenewGlass.hair),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.only(top: 1.h, right: 9.w),
            child: Icon(
              Icons.info_outline_rounded,
              size: 14.r,
              color: RenewGlass.t4,
            ),
          ),
          Expanded(
            child: Text(text, style: RenewGlass.caption(lineHeight: 18)),
          ),
        ],
      ),
    );
  }
}

/// 별 하나 (VRStar). 채움/빈 상태를 색으로 구분한다.
class RenewStar extends StatelessWidget {
  final double size;
  final Color color;
  final bool half;

  const RenewStar({
    super.key,
    this.size = 14,
    this.color = VybeColors.mainLime500,
    this.half = false,
  });

  @override
  Widget build(BuildContext context) {
    return Icon(
      half ? Icons.star_half_rounded : Icons.star_rounded,
      size: size.r,
      color: color,
    );
  }
}

/// 0~5 별점 줄. [rating] 기준으로 채움/반쪽/빈 별을 그린다.
class RenewStarRow extends StatelessWidget {
  final double rating;
  final double size;
  final double gap;

  const RenewStarRow({
    super.key,
    required this.rating,
    this.size = 12,
    this.gap = 1,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (i) {
        final filled = rating >= i + 1;
        final half = !filled && rating >= i + 0.5;
        return Padding(
          padding: EdgeInsets.only(right: i == 4 ? 0 : gap.w),
          child: RenewStar(
            size: size,
            half: half,
            color: (filled || half)
                ? VybeColors.mainLime500
                : const Color(0x2EFFFFFF), // rgba(255,255,255,0.18)
          ),
        );
      }),
    );
  }
}
