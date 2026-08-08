import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vybe/design_system/colors.dart';
import 'package:vybe/design_system/typography.dart';
import 'package:vybe/presentation/hip_hop/hip_hop_style.dart';
import 'package:vybe/presentation/hip_hop/lineup_models.dart';
import 'package:vybe/presentation/hip_hop/widgets/lineup_dots.dart';

// 오늘의 라인업 타임라인 한 줄.

// ── 타임라인 행 ──
class LineupTimelineRow extends StatelessWidget {
  final LineupItem item;
  final int nowMin;
  final bool isFirst;
  final bool isLast;
  final bool isNext;
  const LineupTimelineRow({super.key, 
    required this.item,
    required this.nowMin,
    required this.isFirst,
    required this.isLast,
    required this.isNext,
  });

  @override
  Widget build(BuildContext context) {
    final st = lineupStatusOf(item.time, nowMin);
    final meta = lineupTypeMetaOf(item.isDj);
    final minsLeft = lineupToMinutes(item.time) - nowMin;

    final timeColor = switch (st) {
      LineupStatus.now => kHipAccent,
      LineupStatus.past => VybeColors.gray600,
      LineupStatus.up => VybeColors.gray300,
    };

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 시간
          SizedBox(
            width: 46.w,
            child: Padding(
              padding: EdgeInsets.only(top: 20.h, right: 4.w),
              child: Text(
                item.time,
                textAlign: TextAlign.right,
                style: VybeTypography.caption.copyWith(
                  fontSize: 13.sp,
                  height: 15 / 13,
                  fontWeight: FontWeight.w700,
                  color: timeColor,
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
              ),
            ),
          ),
          // 레일 (세로선 + 점)
          SizedBox(
            width: 24.w,
            child: Stack(
              children: [
                if (!isFirst)
                  Positioned(
                    left: 11.w,
                    top: 0,
                    height: 20.h,
                    child: Container(width: 2.w, color: VybeColors.gray800),
                  ),
                if (!isLast)
                  Positioned(
                    left: 11.w,
                    top: 32.h,
                    bottom: 0,
                    child: Container(width: 2.w, color: VybeColors.gray800),
                  ),
                Positioned(
                  left: 6.w,
                  top: 18.h,
                  child: st == LineupStatus.now
                      ? const LineupRippleDot(size: 12, color: kHipAccent, pulseDot: false)
                      : Container(
                          width: 12.r,
                          height: 12.r,
                          decoration: BoxDecoration(
                            color: st == LineupStatus.past ? VybeColors.gray700 : kHipBg,
                            shape: BoxShape.circle,
                            border: st == LineupStatus.up
                                ? Border.all(color: VybeColors.gray600, width: 2)
                                : null,
                          ),
                        ),
                ),
              ],
            ),
          ),
          // 카드
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: 14.h),
              child: Opacity(
                opacity: st == LineupStatus.past ? 0.5 : 1,
                child: GestureDetector(
                onTap: () => openLineupClub(context, item.clubId),
                behavior: HitTestBehavior.opaque,
                child: Container(
                  padding: EdgeInsets.all(12.r),
                  decoration: st == LineupStatus.now
                      ? BoxDecoration(
                          color: const Color(0x14F5B82E),
                          borderRadius: BorderRadius.circular(16.r),
                          border: Border.all(color: kHipAccent, width: 1.5),
                          boxShadow: const [
                            BoxShadow(
                              color: Color(0x21F5B82E),
                              blurRadius: 24,
                              offset: Offset(0, 6),
                            ),
                          ],
                        )
                      : BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.045),
                          borderRadius: BorderRadius.circular(16.r),
                          border: Border.all(color: VybeColors.gray800),
                        ),
                  child: Row(
                    children: [
                      // 아바타
                      Container(
                        width: 46.r,
                        height: 46.r,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: item.bg,
                          ),
                          shape: BoxShape.circle,
                          border: st == LineupStatus.now
                              ? Border.all(color: kHipAccent, width: 2)
                              : Border.all(color: Colors.white.withValues(alpha: 0.14)),
                        ),
                        child: Icon(meta.icon, size: 20.r, color: Colors.white.withValues(alpha: 0.9)),
                      ),
                      SizedBox(width: 12.w),
                      // 정보
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Flexible(
                                  child: Text(
                                    item.dj,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontFamily: 'Pretendard',
                                      fontSize: 17.sp,
                                      height: 19 / 17,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.white,
                                      letterSpacing: 17 * -0.025,
                                    ),
                                  ),
                                ),
                                SizedBox(width: 7.w),
                                // 타입 뱃지
                                Container(
                                  padding: EdgeInsets.symmetric(horizontal: 7.w, vertical: 2.h),
                                  decoration: BoxDecoration(
                                    color: meta.bg,
                                    borderRadius: BorderRadius.circular(6.r),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(meta.icon, size: 10.r, color: meta.color),
                                      SizedBox(width: 3.w),
                                      Text(
                                        meta.label,
                                        style: VybeTypography.caption.copyWith(
                                          fontSize: 10.sp,
                                          height: 11 / 10,
                                          fontWeight: FontWeight.w700,
                                          color: meta.color,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                if (st == LineupStatus.now) ...[
                                  SizedBox(width: 7.w),
                                  Container(
                                    padding: EdgeInsets.symmetric(horizontal: 7.w, vertical: 2.h),
                                    decoration: BoxDecoration(
                                      color: kHipAccent,
                                      borderRadius: BorderRadius.circular(6.r),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const LineupPulseDot(size: 5, color: kHipOnAccent),
                                        SizedBox(width: 4.w),
                                        Text(
                                          'LIVE',
                                          style: VybeTypography.caption.copyWith(
                                            fontSize: 10.sp,
                                            height: 11 / 10,
                                            fontWeight: FontWeight.w800,
                                            color: kHipOnAccent,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ],
                            ),
                            SizedBox(height: 6.h),
                            Row(
                              children: [
                                Icon(Icons.place_rounded, size: 11.r, color: VybeColors.gray400),
                                SizedBox(width: 5.w),
                                Flexible(
                                  child: Text(
                                    '${item.club} · ${item.area}',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: VybeTypography.caption.copyWith(
                                      height: 13 / 12,
                                      fontWeight: FontWeight.w600,
                                      color: VybeColors.gray400,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 8.h),
                            Wrap(
                              spacing: 5.w,
                              runSpacing: 5.h,
                              crossAxisAlignment: WrapCrossAlignment.center,
                              children: [
                                for (final g in item.genres)
                                  _tagChip('#$g', VybeColors.gray300,
                                      Colors.white.withValues(alpha: 0.09),
                                      weight: FontWeight.w600),
                                if (isNext)
                                  _tagChip('곧 시작 · $minsLeft분 후', kHipAccent,
                                      const Color(0x24F5B82E),
                                      weight: FontWeight.w700),
                                if (st == LineupStatus.past)
                                  _tagChip('공연 종료', VybeColors.gray500,
                                      Colors.white.withValues(alpha: 0.06),
                                      weight: FontWeight.w700),
                              ],
                            ),
                          ],
                        ),
                      ),
                      Icon(
                        Icons.chevron_right_rounded,
                        size: 16.r,
                        color: st == LineupStatus.now ? kHipAccent : VybeColors.gray600,
                      ),
                    ],
                  ),
                ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _tagChip(String text, Color fg, Color bg, {required FontWeight weight}) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 7.w, vertical: 1.h),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(6.r),
      ),
      child: Text(
        text,
        style: VybeTypography.caption.copyWith(
          fontSize: 10.sp,
          height: 13 / 10,
          fontWeight: weight,
          color: fg,
        ),
      ),
    );
  }
}
