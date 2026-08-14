import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vybe/core/utils/number_format.dart';
import 'package:vybe/data/models/operating_hours.dart';
import 'package:vybe/design_system/colors.dart';
import 'package:vybe/presentation/clubs/widgets/subway_line_badge.dart';
import 'package:vybe/presentation/common/widgets/vybe_glass_button.dart';

/// 클럽 상세 리퀴드 글래스 공통 요소.
///
/// 디자인: club_glass_shell.jsx (CG 토큰 · GCard · GHead · GlassRound) 기준.
/// CSS `blur(18px)` ≈ Flutter `ImageFilter.blur(sigma 9)`.

// ============================================================================
// 토큰
// ============================================================================

class ClubGlass {
  ClubGlass._();

  /// 최하단 배경색 (CG.ink)
  static const Color ink = Color(0xFF0E0D12);

  /// 글래스 카드 채움 — rgba(120,120,128,0.16)
  static const Color cardFill = Color(0x29787880);

  /// 글래스 카드 테두리 — rgba(255,255,255,0.10)
  static const Color cardBorder = Color(0x1AFFFFFF);

  /// 타일(작은 버튼·칩) 채움 — rgba(255,255,255,0.07)
  static const Color tileFill = Color(0x12FFFFFF);

  /// 타일 테두리 — rgba(255,255,255,0.12)
  static const Color tileBorder = Color(0x1FFFFFFF);

  /// 상·하단 바 채움 — rgba(14,13,18,0.55)
  static const Color barFill = Color(0x8C0E0D12);

  /// 구분선 — rgba(255,255,255,0.09)
  static const Color hair = Color(0x17FFFFFF);

  // 텍스트 계조 (CG.t1 ~ t4)
  static const Color t1 = Colors.white;
  static const Color t2 = Color(0xD1FFFFFF); // 0.82
  static const Color t3 = Color(0xADFFFFFF); // 0.68
  static const Color t4 = VybeColors.gray500;

  /// 보라 계열 강조 텍스트 (태그·'오늘' 뱃지)
  static const Color accentLavender = Color(0xFFC8A8FF);

  /// 링크 텍스트 (전화·인스타)
  static const Color link = Color(0xFF8FB5FF);

  /// 찜 상태 색 (CG_SAVED)
  static const Color saved = VybeColors.mainPurple500;

  /// 지하철 9호선 라인 컬러 (CG_LINE9)
  static const Color line9 = Color(0xFF8B4513);

  static const double blurSigma = 9;

  static TextStyle title() => TextStyle(
    fontFamily: 'Pretendard',
    fontSize: 16.sp,
    fontWeight: FontWeight.w700,
    color: t1,
  );

  static TextStyle body({Color color = t2, double size = 14}) => TextStyle(
    fontFamily: 'Pretendard',
    fontSize: size.sp,
    height: 20 / 14,
    color: color,
  );

  static TextStyle caption({
    Color color = t3,
    double size = 12,
    double lineHeight = 14,
    FontWeight weight = FontWeight.w400,
  }) => TextStyle(
    fontFamily: 'Pretendard',
    fontSize: size.sp,
    height: lineHeight / size,
    fontWeight: weight,
    color: color,
  );
}

// ============================================================================
// 배경 (CG_AURORA + 그레인 대신 단순 글로우)
// ============================================================================

/// 클럽 상세 오로라 배경. 좌상단 보라 · 우상단 라임 · 우하단 보라 글로우.
class ClubAurora extends StatelessWidget {
  const ClubAurora({super.key});

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF120F1A), VybeColors.background, Color(0xFF0D0C11)],
          stops: [0.0, 0.38, 1.0],
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: 300.h,
            child: const DecoratedBox(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment(-0.92, -0.96),
                  radius: 1.35,
                  colors: [Color(0x4D7731FE), Color(0x00000000)],
                  stops: [0.0, 0.62],
                ),
              ),
            ),
          ),
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: 420.h,
            child: const DecoratedBox(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment(1, -0.56),
                  radius: 1.3,
                  colors: [Color(0x1AB5FF60), Color(0x00000000)],
                  stops: [0.0, 0.64],
                ),
              ),
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            height: 380.h,
            child: const DecoratedBox(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment(0.64, 0.92),
                  radius: 1.4,
                  colors: [Color(0x247731FE), Color(0x00000000)],
                  stops: [0.0, 0.68],
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
// 카드 (GCard)
// ============================================================================

/// 리퀴드 글래스 카드. 좌상단에서 번지는 하이라이트 + 블러 + 그림자.
class GlassCard extends StatelessWidget {
  final Widget child;

  /// CSS px 기준 내부 여백 (`.r` 적용). 0이면 내부에서 직접 padding 관리.
  final double padding;
  final double radius;

  /// 기본 글래스 톤 대신 쓸 채움색 (예: 이용 안내 보라 카드).
  final Color? fill;
  final Color? border;
  final EdgeInsetsGeometry? margin;

  const GlassCard({
    super.key,
    required this.child,
    this.padding = 18,
    this.radius = 20,
    this.fill,
    this.border,
    this.margin,
  });

  @override
  Widget build(BuildContext context) {
    final r = BorderRadius.circular(radius.r);

    return Container(
      margin: margin,
      decoration: BoxDecoration(
        borderRadius: r,
        boxShadow: [
          BoxShadow(
            color: const Color(0x5C000000),
            blurRadius: 30.r,
            offset: Offset(0, 10.h),
          ),
        ],
      ),
      // 테두리는 하이라이트 레이어 위에 그려야 선이 죽지 않는다.
      foregroundDecoration: BoxDecoration(
        borderRadius: r,
        border: Border.all(color: border ?? ClubGlass.cardBorder),
      ),
      child: ClipRRect(
        borderRadius: r,
        child: BackdropFilter(
          filter: ui.ImageFilter.blur(
            sigmaX: ClubGlass.blurSigma,
            sigmaY: ClubGlass.blurSigma,
          ),
          // 채움색과 하이라이트는 레이어를 반드시 나눈다 — 하나의
          // BoxDecoration에 color·gradient를 같이 주면 gradient shader가
          // color를 덮어써서 카드 배경(감싸는 도형)이 통째로 사라진다.
          child: ColoredBox(
            color: fill ?? ClubGlass.cardFill,
            child: Stack(
              fit: StackFit.passthrough,
              children: [
                // GCard 내부 오버레이 — 좌상단에서 번지는 하이라이트
                const Positioned.fill(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: RadialGradient(
                        center: Alignment(-0.76, -1),
                        radius: 1.1,
                        colors: [Color(0x1AFFFFFF), Color(0x00FFFFFF)],
                        stops: [0.0, 0.58],
                      ),
                    ),
                  ),
                ),
                // inset 0 1px 0 rgba(255,255,255,0.16) — 상단 1px 하이라이트
                const Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  height: 1,
                  child: ColoredBox(color: Color(0x29FFFFFF)),
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
// 섹션 헤더 (GHead)
// ============================================================================

/// 카드 상단 제목 + 보조설명 + 우측 액션(전체보기).
class GlassSectionHead extends StatelessWidget {
  final String title;
  final String? sub;
  final String actionLabel;
  final VoidCallback? onAction;

  /// 헤더 아래 여백. 디자인 기본 14px.
  final double bottomGap;

  const GlassSectionHead({
    super.key,
    required this.title,
    this.sub,
    this.actionLabel = '전체보기',
    this.onAction,
    this.bottomGap = 14,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: bottomGap.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(title, style: ClubGlass.title()),
                if (sub != null) ...[
                  SizedBox(height: 4.h),
                  Text(
                    sub!,
                    style: ClubGlass.caption(color: ClubGlass.t4),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),
          if (onAction != null)
            GestureDetector(
              onTap: onAction,
              behavior: HitTestBehavior.opaque,
              child: Padding(
                padding: EdgeInsets.only(left: 12.w),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(actionLabel, style: ClubGlass.caption()),
                    Icon(
                      Icons.chevron_right_rounded,
                      size: 14.r,
                      color: const Color(0x80FFFFFF),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// ============================================================================
// 원형 글래스 버튼 (GlassRound)
// ============================================================================

/// 히어로 위에 뜨는 원형 글래스 버튼 (뒤로가기·공유·찜).
class GlassRoundButton extends StatelessWidget {
  final Widget child;
  final VoidCallback? onTap;
  final double size;

  const GlassRoundButton({
    super.key,
    required this.child,
    this.onTap,
    this.size = 38,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: ClipOval(
        child: BackdropFilter(
          filter: ui.ImageFilter.blur(sigmaX: 7, sigmaY: 7),
          child: Container(
            width: size.r,
            height: size.r,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              // rgba(20,18,26,0.42)
              color: const Color(0x6B14121A),
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0x29FFFFFF)),
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}

/// 원형 글래스 타일 (CG.tile) — 아이콘 하나를 담는 작은 유리 원.
///
/// 검색 pill 우측 아이콘 자리(주변 GNB · 검색 화면)와 헤더 원형 버튼(알림)이 공유한다.
/// 탭 동작은 호출측에서 감싼다 — 히트 영역이 화면마다 달라서.
class GlassCircleTile extends StatelessWidget {
  final Widget child;

  /// 지름 (CSS px, `.r` 적용).
  final double size;

  /// 뒤 배경 블러. null이면 블러 없이 채움만 (이미 블러된 유리 위에 올릴 때).
  final double? blurSigma;

  const GlassCircleTile({
    super.key,
    required this.child,
    this.size = 34,
    this.blurSigma,
  });

  @override
  Widget build(BuildContext context) {
    final tile = Container(
      width: size.r,
      height: size.r,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: ClubGlass.tileFill,
        shape: BoxShape.circle,
        border: Border.all(color: ClubGlass.tileBorder),
      ),
      child: child,
    );

    if (blurSigma == null) return tile;
    return ClipOval(
      child: BackdropFilter(
        filter: ui.ImageFilter.blur(sigmaX: blurSigma!, sigmaY: blurSigma!),
        child: tile,
      ),
    );
  }
}

// ============================================================================
// 작은 조각들
// ============================================================================

/// 영업중/영업종료 pill. 영업중이면 라임, 영업종료면 레드.
class OpenStatusPill extends StatelessWidget {
  final bool isOpen;

  const OpenStatusPill({super.key, required this.isOpen});

  @override
  Widget build(BuildContext context) {
    final color = isOpen ? VybeColors.mainLime500 : VybeColors.accentRed500;
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 9.w, vertical: 3.h),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(999.r),
        border: Border.all(color: color.withValues(alpha: 0.28)),
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
            isOpen ? '영업중' : '영업종료',
            style: ClubGlass.caption(color: color, weight: FontWeight.w700),
          ),
        ],
      ),
    );
  }
}

/// 영업 상태 + 오늘 영업 시간 한 줄. 예) `영업중 · 22:00 - 06:00`
///
/// 남은 시각("02:00에 영업 종료")이 아니라 오늘 영업 시간을 그대로 보여준다.
/// 정기휴무면 시간 대신 '오늘 휴무'.
class OpenHoursLine extends StatelessWidget {
  final DayHours today;

  const OpenHoursLine({super.key, required this.today});

  @override
  Widget build(BuildContext context) {
    final isOpen = today.isCurrentlyOpen;
    final String? hours;
    if (!today.isOpen) {
      hours = '오늘 휴무';
    } else if (today.open != null && today.close != null) {
      hours = '${today.open} - ${today.close}';
    } else {
      hours = null;
    }

    return Row(
      children: [
        Text(
          isOpen ? '영업중' : '영업종료',
          style: ClubGlass.body(
            color: isOpen ? VybeColors.mainLime500 : VybeColors.accentRed500,
          ).copyWith(fontWeight: FontWeight.w700),
        ),
        if (hours != null) ...[
          SizedBox(width: 7.w),
          const GlassDot(),
          SizedBox(width: 7.w),
          Flexible(
            child: Text(
              hours,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: ClubGlass.body(),
            ),
          ),
        ],
      ],
    );
  }
}

/// 요일별 영업시간 표. 오늘 줄은 흰색 + '오늘' 뱃지, 정기휴무는 레드.
///
/// 홈 탭(접었다 펴는 영업시간)과 매장 정보 탭(상시 노출)이 같은 표를 쓴다.
/// 줄 간격만 화면마다 달라 [rowGap]으로 받는다.
class WeekHoursTable extends StatelessWidget {
  final OperatingHours hours;

  /// 줄 사이 간격(px, `.h` 적용).
  final double rowGap;

  const WeekHoursTable({super.key, required this.hours, this.rowGap = 8});

  static const _labels = ['월', '화', '수', '목', '금', '토', '일'];

  @override
  Widget build(BuildContext context) {
    final week = [
      hours.mon,
      hours.tue,
      hours.wed,
      hours.thu,
      hours.fri,
      hours.sat,
      hours.sun,
    ];
    final todayIndex = DateTime.now().weekday - 1;

    return Column(
      children: [
        for (var i = 0; i < week.length; i++)
          Padding(
            padding: EdgeInsets.only(
              bottom: i == week.length - 1 ? 0 : rowGap.h,
            ),
            child: Row(
              children: [
                SizedBox(
                  width: 16.w,
                  child: Text(
                    _labels[i],
                    style: ClubGlass.caption(
                      color: i == todayIndex ? Colors.white : ClubGlass.t3,
                      weight: i == todayIndex
                          ? FontWeight.w700
                          : FontWeight.w400,
                    ),
                  ),
                ),
                SizedBox(width: 12.w),
                Text(
                  week[i].isOpen
                      ? '${week[i].open} - ${week[i].close}'
                      : '정기휴무',
                  style: ClubGlass.caption(
                    color: !week[i].isOpen
                        ? VybeColors.accentRed500
                        : i == todayIndex
                        ? Colors.white
                        : ClubGlass.t3,
                    weight: i == todayIndex || !week[i].isOpen
                        ? FontWeight.w600
                        : FontWeight.w400,
                  ),
                ),
                if (i == todayIndex) ...[
                  SizedBox(width: 8.w),
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 7.w,
                      vertical: 2.h,
                    ),
                    decoration: BoxDecoration(
                      color: VybeColors.mainPurple500.withValues(alpha: 0.22),
                      borderRadius: BorderRadius.circular(5.r),
                    ),
                    child: Text(
                      '오늘',
                      style: ClubGlass.caption(
                        color: ClubGlass.accentLavender,
                        size: 10,
                        lineHeight: 12,
                        weight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
      ],
    );
  }
}

/// 호선 배지 + `역명에서 N m` 한 줄. `clubs/{id}/info.nearbySubways` 원소를 받는다.
class SubwayStationLine extends StatelessWidget {
  final Map<String, dynamic> subway;

  const SubwayStationLine({super.key, required this.subway});

  @override
  Widget build(BuildContext context) {
    final lines = List<String>.from(subway['lines'] as List? ?? const []);
    return Row(
      children: [
        if (lines.isNotEmpty) ...[
          SubwayLineBadge(line: lines.first),
          SizedBox(width: 6.w),
        ],
        Flexible(
          child: Text(
            subwayLabel(subway) ?? '',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: ClubGlass.caption(),
          ),
        ),
      ],
    );
  }
}

/// 지하철역 표기 — `상수역에서 422m`. 역명이 없으면 null.
String? subwayLabel(Map<String, dynamic>? subway) {
  if (subway == null) return null;
  final station = subway['stationName'] as String? ?? '';
  if (station.isEmpty) return null;
  final distance = (subway['distanceM'] as num?)?.toInt() ?? 0;
  return distance > 0 ? '$station에서 ${distance}m' : station;
}

/// 입장료 표기 — 둘 다 0이면 '무료', 같으면 단일가, 다르면 범위.
String formatEntryFee({required int min, required int max}) {
  if (min == 0 && max == 0) return '무료';
  if (min == max) return '${formatThousands(min)}원';
  return '${formatThousands(min)} ~ ${formatThousands(max)}원';
}

/// 가운데 점 구분자 (· 대신 쓰는 2px 원).
class GlassDot extends StatelessWidget {
  final double size;
  final Color color;

  const GlassDot({super.key, this.size = 2, this.color = ClubGlass.t4});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size.r,
      height: size.r,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }
}

/// 카드 안 항목 구분선 (CG.hair).
class GlassHairline extends StatelessWidget {
  const GlassHairline({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(height: 1, color: ClubGlass.hair);
  }
}

/// 아이콘 + 본문 한 줄 (CGRow). 매장 정보·상세 정보 카드에서 사용.
class GlassInfoRow extends StatelessWidget {
  final IconData icon;
  final Widget child;
  final bool last;

  const GlassInfoRow({
    super.key,
    required this.icon,
    required this.child,
    this.last = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 13.h),
      decoration: BoxDecoration(
        border: last
            ? null
            : const Border(bottom: BorderSide(color: ClubGlass.hair)),
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

/// 더보기 / 전부 봤어요 푸터 버튼 (리뷰·사진 탭 공통).
class GlassMoreButton extends StatelessWidget {
  final String label;
  final VoidCallback? onTap;

  const GlassMoreButton({super.key, required this.label, this.onTap});

  @override
  Widget build(BuildContext context) {
    if (onTap == null) {
      return Center(
        child: Text(
          label,
          style: ClubGlass.caption(color: ClubGlass.t4, lineHeight: 16),
        ),
      );
    }
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(vertical: 14.h),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: ClubGlass.tileFill,
          borderRadius: BorderRadius.circular(14.r),
          border: Border.all(color: ClubGlass.tileBorder),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontFamily: 'Pretendard',
            fontSize: 14.sp,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}

/// 탭 콘텐츠 공통 패딩 (CGT_PAD: 16px 16px 28px, 카드 사이 14px).
///
/// 상세 페이지는 MainScaffold 탭 Navigator 안에서 열려 하단 탭바가 그대로 떠 있다.
/// 마지막 카드가 탭바에 가리지 않도록 바 높이(64) + 바깥 여백(12) + 세이프에어리어를
/// 하단 패딩에 더한다.
EdgeInsets glassTabPadding(BuildContext context) => EdgeInsets.fromLTRB(
  16.w,
  16.h,
  16.w,
  28.h + 76.h + MediaQuery.paddingOf(context).bottom,
);

/// 카드 사이 간격 (14px).
Widget glassGap() => SizedBox(height: 14.h);

/// 주변 클럽 카드 썸네일 한 변 (정사각, `.w` 적용).
/// 스켈레톤도 같은 값을 써야 로딩 → 콘텐츠 전환에서 높이가 안 튄다.
const double kNearbyThumbSize = 134;

/// 주변 클럽 카드 이름 + 지역·장르 두 줄이 차지할 높이 (`.h` 적용).
const double kNearbyTextBlock = 44;

/// 상단 블러 바 (sticky 칩 줄 배경).
class GlassBar extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final bool border;

  /// 상단에도 hairline을 그린다 (찜 툴바처럼 위아래 선이 다 있는 바).
  final bool topBorder;

  const GlassBar({
    super.key,
    required this.child,
    required this.padding,
    this.border = true,
    this.topBorder = false,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRect(
      child: BackdropFilter(
        filter: ui.ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            color: ClubGlass.barFill,
            border: Border(
              top: topBorder
                  ? const BorderSide(color: ClubGlass.hair)
                  : BorderSide.none,
              bottom: border
                  ? const BorderSide(color: ClubGlass.hair)
                  : BorderSide.none,
            ),
          ),
          child: child,
        ),
      ),
    );
  }
}

/// 글래스 상단바 — 뒤로가기 + 가운데 정렬 제목.
///
/// 제목을 정확히 가운데 두려면 좌우 폭이 같아야 해서, 오른쪽에 뒤로가기와 같은
/// 크기의 빈 칸을 둔다([trailing]을 주면 그 자리에 들어간다).
class GlassTopBar extends StatelessWidget {
  final String title;

  /// 뒤로가기 동작. 기본값은 현재 라우트 pop.
  final VoidCallback? onBack;

  /// 오른쪽 액션. 없으면 제목 중앙 정렬용 빈 칸.
  final Widget? trailing;

  /// 뒤로가기 버튼 지름 (= 오른쪽 빈 칸 폭).
  static const double _buttonSize = 34;

  const GlassTopBar({
    super.key,
    required this.title,
    this.onBack,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return GlassBar(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
      child: Row(
        children: [
          VybeGlassButton(
            onTap: onBack ?? () => Navigator.of(context).maybePop(),
            size: _buttonSize,
            iconSize: 15,
            hitSize: _buttonSize,
          ),
          Expanded(
            child: Text(
              title,
              textAlign: TextAlign.center,
              style: ClubGlass.title(),
            ),
          ),
          SizedBox(width: _buttonSize.r, child: trailing),
        ],
      ),
    );
  }
}

/// 라임 채움 / 글래스 아웃라인 토글 칩 (사진 필터 · 메뉴 카테고리).
class GlassFilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const GlassFilterChip({
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
          color: selected ? VybeColors.mainLime500 : const Color(0x14FFFFFF),
          borderRadius: BorderRadius.circular(999.r),
          border: Border.all(
            color: selected ? VybeColors.mainLime500 : ClubGlass.tileBorder,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontFamily: 'Pretendard',
            fontSize: 14.sp,
            fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
            color: selected ? ClubGlass.ink : ClubGlass.t2,
          ),
        ),
      ),
    );
  }
}
