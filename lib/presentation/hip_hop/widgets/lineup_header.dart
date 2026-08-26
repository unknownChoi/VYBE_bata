import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vybe/design_system/colors.dart';
import 'package:vybe/design_system/typography.dart';
import 'package:vybe/presentation/clubs/widgets/club_glass.dart';
import 'package:vybe/presentation/common/filter_chip_style.dart';
import 'package:vybe/presentation/hip_hop/hip_hop_style.dart';
import 'package:vybe/presentation/hip_hop/lineup_models.dart';
import 'package:vybe/presentation/hip_hop/widgets/lineup_dots.dart';

// 오늘의 라인업 상단 — 요약 메타 · 진행중 배너 · 타입 필터.

// ── 인트로 메타 (날짜 · 지역 / N팀) ──
class LineupIntroMeta extends StatelessWidget {
  final int total;
  const LineupIntroMeta({super.key, required this.total});

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    const weekdays = ['월', '화', '수', '목', '금', '토', '일'];
    final dateText = '${now.month}월 ${now.day}일';
    final dayText = '(${weekdays[now.weekday - 1]})';
    const areaText = '모든지역';

    return Padding(
      padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 12.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text.rich(
                TextSpan(
                  text: '$dateText ',
                  style: TextStyle(
                    fontFamily: 'Pretendard',
                    fontSize: 22.sp,
                    height: 26 / 22,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    letterSpacing: 22 * -0.025,
                  ),
                  children: [
                    TextSpan(
                      text: dayText,
                      style: const TextStyle(
                        color: VybeColors.gray500,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 4.h),
              Text(
                areaText,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: VybeTypography.caption.copyWith(
                  height: 15 / 12,
                  color: VybeColors.gray500,
                ),
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '$total팀',
                style: TextStyle(
                  fontFamily: 'Pretendard',
                  fontSize: 20.sp,
                  height: 22 / 20,
                  fontWeight: FontWeight.w800,
                  color: kHipAccent,
                  letterSpacing: 20 * -0.025,
                ),
              ),
              SizedBox(height: 3.h),
              Text(
                '오늘 공연',
                style: VybeTypography.caption.copyWith(
                  fontSize: 11.sp,
                  height: 13 / 11,
                  color: VybeColors.gray500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ── 지금 공연 중 배너 ──
class LineupNowBanner extends StatelessWidget {
  final LineupItem item;
  const LineupNowBanner({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    final meta = lineupTypeMetaOf(item.isDj);
    return GestureDetector(
      onTap: () => openLineupClub(context, item.clubId),
      behavior: HitTestBehavior.opaque,
      child: Container(
      margin: EdgeInsets.fromLTRB(16.w, 4.h, 16.w, 6.h),
      padding: EdgeInsets.all(14.r),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment(-0.87, -0.5),
          end: Alignment(0.87, 0.5),
          colors: [Color(0x29F5B82E), Color(0x0DF5B82E)],
        ),
        borderRadius: BorderRadius.circular(18.r),
        border: Border.all(color: kHipAccent, width: 1.5),
        boxShadow: const [
          BoxShadow(
            color: Color(0x29F5B82E),
            blurRadius: 30,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          // 아바타
          Container(
            width: 54.r,
            height: 54.r,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: item.bg,
              ),
              shape: BoxShape.circle,
              border: Border.all(color: kHipAccent, width: 2),
            ),
            child: Icon(meta.icon, size: 22.r, color: Colors.white.withValues(alpha: 0.92)),
          ),
          SizedBox(width: 13.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const LineupRippleDot(size: 7, color: kHipAccent),
                    SizedBox(width: 6.w),
                    Text(
                      '지금 공연 중',
                      style: VybeTypography.caption.copyWith(
                        fontSize: 11.sp,
                        height: 12 / 11,
                        fontWeight: FontWeight.w800,
                        color: kHipAccent,
                        letterSpacing: 11 * 0.04,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 6.h),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text(
                      item.dj,
                      style: TextStyle(
                        fontFamily: 'Pretendard',
                        fontSize: 20.sp,
                        height: 22 / 20,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                        letterSpacing: 20 * -0.025,
                      ),
                    ),
                    SizedBox(width: 7.w),
                    Flexible(
                      child: Text(
                        '${meta.label} · ${item.club}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: VybeTypography.caption.copyWith(
                          height: 14 / 12,
                          color: VybeColors.gray300,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 6.h),
                Row(
                  children: [
                    Icon(Icons.place_rounded, size: 11.r, color: VybeColors.gray400),
                    SizedBox(width: 5.w),
                    Text(
                      '${item.area} · ${item.time} 시작',
                      style: VybeTypography.caption.copyWith(
                        fontSize: 11.sp,
                        height: 12 / 11,
                        fontWeight: FontWeight.w600,
                        color: VybeColors.gray400,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Icon(Icons.chevron_right_rounded, size: 18.r, color: kHipAccent),
        ],
      ),
      ),
    );
  }
}

// ── 타입 필터 (전체/래퍼/DJ + 시간순) ──
class LineupTypeFilter extends StatelessWidget {
  final String active;
  final Map<String, int> counts;
  final ValueChanged<String> onChange;
  const LineupTypeFilter({super.key, 
    required this.active,
    required this.counts,
    required this.onChange,
  });

  static const _tabs = [
    ('all', '전체'),
    ('rapper', '래퍼'),
    ('dj', 'DJ'),
  ];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(left: 16.w, right: 16.w, bottom: 14.h),
      child: Row(
        children: [
          for (final (key, label) in _tabs) ...[
            if (key != 'all') SizedBox(width: 8.w),
            _chip(key, label),
          ],
          const Spacer(),
          Icon(Icons.schedule_rounded, size: 12.r, color: VybeColors.gray500),
          SizedBox(width: 4.w),
          Text(
            '시간순',
            style: VybeTypography.caption.copyWith(
              height: 14 / 12,
              fontWeight: FontWeight.w600,
              color: VybeColors.gray500,
            ),
          ),
        ],
      ),
    );
  }

  // 칩 외형은 주변 페이지와 같은 글래스 칩 단일 소스. 여기 남는 건 개수 꼬리표뿐.
  Widget _chip(String key, String label) {
    final sel = key == active;
    return VybeGlassFilterChip(
      label: label,
      selected: sel,
      hPadding: 14,
      onTap: () => onChange(key),
      trailing: (fg) => Text(
        '${counts[key]}',
        style: VybeTypography.caption.copyWith(
          fontSize: 11.sp,
          height: 12 / 11,
          fontWeight: FontWeight.w700,
          // 선택 안 된 칩의 개수는 라벨보다 한 단 낮춰 라벨이 먼저 읽히게 한다.
          color: sel ? fg : ClubGlass.t4,
        ),
      ),
    );
  }
}
