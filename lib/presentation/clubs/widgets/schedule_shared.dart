import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vybe/data/models/performance_model.dart';
import 'package:vybe/design_system/colors.dart';

// 공연 일정 공유 모듈 — 클럽 상세 홈 탭 섹션 + 전체 일정 페이지에서 공용.
// claude.ai/design (schedule.jsx) 기반. UI 모델 + PerformanceModel → UI 매퍼.

// ── 아티스트 타입 메타 ──
class ScheduleActType {
  final String label;
  final Color color; // 텍스트 accent
  final Color bg; // 배지 배경
  final IconData icon;
  const ScheduleActType({
    required this.label,
    required this.color,
    required this.bg,
    required this.icon,
  });
}

const scheduleActTypes = <String, ScheduleActType>{
  'rapper': ScheduleActType(
    label: '래퍼',
    color: Color(0xFFC8A8FF),
    bg: Color(0x2E7731FE), // rgba(119,49,254,0.18)
    icon: Icons.mic_none_rounded,
  ),
  'dj': ScheduleActType(
    label: 'DJ',
    color: Color(0xFF8FB5FF),
    bg: Color(0x2E2B6BFF), // rgba(43,107,255,0.18)
    icon: Icons.album_outlined,
  ),
};

// ── 공연 데이터 ──
class ScheduleAct {
  final String time;
  final String name;
  final String type;
  final bool headline;
  final List<Color> gradient; // 아바타 배경 (135deg)
  const ScheduleAct({
    required this.time,
    required this.name,
    required this.type,
    this.headline = false,
    required this.gradient,
  });
}

class ScheduleDay {
  final int year;
  final int month;
  final int day;
  final String dow;
  final int dday; // 0=오늘, 1=내일, 2=모레, 그 외 D-n
  final List<ScheduleAct> acts;
  const ScheduleDay({
    required this.year,
    required this.month,
    required this.day,
    required this.dow,
    required this.dday,
    required this.acts,
  });

  ScheduleDay copyWithActs(List<ScheduleAct> next) => ScheduleDay(
        year: year,
        month: month,
        day: day,
        dow: dow,
        dday: dday,
        acts: next,
      );
}

// ── PerformanceModel → UI 매퍼 ──

const _dow = ['월', '화', '수', '목', '금', '토', '일'];

// 아바타 배경 그라데이션 팔레트 (135deg). 아티스트명 해시로 결정론적 배정.
const _gradients = <List<Color>>[
  [Color(0xFF7731FE), Color(0xFFFF4D8D)],
  [Color(0xFFFB5607), Color(0xFFFFBE0B)],
  [Color(0xFF3A0CA3), Color(0xFF4361EE)],
  [Color(0xFF4A1E1E), Color(0xFFF72585)],
  [Color(0xFF1B3A3A), Color(0xFF2A9D8F)],
  [Color(0xFF3A2F0A), Color(0xFFF5B82E)],
  [Color(0xFF2A1A3E), Color(0xFF7731FE)],
  [Color(0xFF5A3A1A), Color(0xFFF5B82E)],
];

List<Color> _gradientFor(String name) =>
    _gradients[name.hashCode.abs() % _gradients.length];

/// date 버킷 "YYYYMMDD" → DateTime(자정). 파싱 실패 시 오늘.
DateTime _parseBucket(String date) {
  if (date.length == 8) {
    final y = int.tryParse(date.substring(0, 4));
    final m = int.tryParse(date.substring(4, 6));
    final d = int.tryParse(date.substring(6, 8));
    if (y != null && m != null && d != null) return DateTime(y, m, d);
  }
  final now = DateTime.now();
  return DateTime(now.year, now.month, now.day);
}

/// 공연 목록(시작시각 오름차순 가정)을 날짜별 카드 데이터로 그룹핑.
/// dday·요일은 공연 밤(date 버킷) 기준으로 계산.
List<ScheduleDay> buildScheduleDays(List<PerformanceModel> perfs) {
  final byDate = <String, List<PerformanceModel>>{};
  for (final p in perfs) {
    byDate.putIfAbsent(p.date, () => []).add(p);
  }

  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final keys = byDate.keys.toList()..sort();

  final days = <ScheduleDay>[];
  for (final key in keys) {
    final list = byDate[key]!
      ..sort((a, b) => a.startAt.compareTo(b.startAt));
    final d = _parseBucket(key);
    days.add(ScheduleDay(
      year: d.year,
      month: d.month,
      day: d.day,
      dow: _dow[d.weekday - 1],
      dday: d.difference(today).inDays,
      acts: list
          .map((p) => ScheduleAct(
                time: p.hhmm,
                name: p.artistName,
                type: p.artistType,
                headline: p.isFeatured,
                gradient: _gradientFor(p.artistName),
              ))
          .toList(),
    ));
  }
  return days;
}

// ── 날짜 카드 ──
class ScheduleDayCard extends StatelessWidget {
  final ScheduleDay day;
  const ScheduleDayCard({super.key, required this.day});

  String get _rel {
    switch (day.dday) {
      case 0:
        return '오늘';
      case 1:
        return '내일';
      case 2:
        return '모레';
      default:
        return 'D-${day.dday}';
    }
  }

  @override
  Widget build(BuildContext context) {
    final isToday = day.dday == 0;

    return Container(
      padding: EdgeInsets.all(14.r),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14.r),
        color: isToday ? const Color(0x147731FE) : const Color(0x08FFFFFF),
        border: Border.all(
          color: isToday ? const Color(0x807731FE) : VybeColors.gray800,
        ),
      ),
      child: Opacity(
        opacity: isToday ? 1 : 0.5,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 날짜 타일
            SizedBox(
              width: 42.w,
              child: Column(
                children: [
                  Text(
                    '${day.month}월',
                    style: TextStyle(
                      fontFamily: 'Pretendard',
                      fontSize: 10.sp,
                      fontWeight: FontWeight.w700,
                      color: VybeColors.gray500,
                    ),
                  ),
                  SizedBox(height: 3.h),
                  Text(
                    '${day.day}',
                    style: TextStyle(
                      fontFamily: 'Pretendard',
                      fontSize: 26.sp,
                      height: 28 / 26,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 3.h),
                  Text(
                    day.dow,
                    style: TextStyle(
                      fontFamily: 'Pretendard',
                      fontSize: 11.sp,
                      fontWeight: FontWeight.w700,
                      color: isToday
                          ? const Color(0xFFC8A8FF)
                          : VybeColors.gray400,
                    ),
                  ),
                  SizedBox(height: 5.h),
                  Container(
                    padding:
                        EdgeInsets.symmetric(horizontal: 7.w, vertical: 2.h),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(999.r),
                      color: isToday
                          ? VybeColors.mainLime500
                          : const Color(0x0FFFFFFF),
                    ),
                    child: Text(
                      _rel,
                      style: TextStyle(
                        fontFamily: 'Pretendard',
                        fontSize: 9.sp,
                        height: 11 / 9,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.18,
                        color: isToday
                            ? const Color(0xFF1A1A1A)
                            : VybeColors.gray400,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(width: 12.w),
            // 라인업
            Expanded(
              child: Container(
                padding: EdgeInsets.only(left: 14.w),
                decoration: BoxDecoration(
                  border: Border(
                    left: BorderSide(
                      color: isToday
                          ? const Color(0x407731FE)
                          : VybeColors.gray800,
                    ),
                  ),
                ),
                child: Column(
                  children: [
                    for (var i = 0; i < day.acts.length; i++)
                      _ActRow(act: day.acts[i], first: i == 0),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── 개별 공연(아티스트) 행 ──
class _ActRow extends StatelessWidget {
  final ScheduleAct act;
  final bool first;
  const _ActRow({required this.act, required this.first});

  @override
  Widget build(BuildContext context) {
    final t = scheduleActTypes[act.type]!;
    return Container(
      // 디자인(schedule.jsx): first '0 0 10px', 그 외 '10px 0' — 모든 행 하단 10.
      padding: EdgeInsets.only(top: first ? 0 : 10.h, bottom: 10.h),
      decoration: first
          ? null
          : BoxDecoration(
              border: Border(top: BorderSide(color: VybeColors.gray900)),
            ),
      child: Row(
        children: [
          // 아바타
          Container(
            width: 34.r,
            height: 34.r,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: act.gradient,
              ),
              border: Border.all(color: const Color(0x24FFFFFF)),
            ),
            child: Icon(t.icon, size: 15.r, color: const Color(0xEBFFFFFF)),
          ),
          SizedBox(width: 10.w),
          // 이름 + 배지
          Expanded(
            child: Wrap(
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: 6.w,
              runSpacing: 4.h,
              children: [
                Text(
                  act.name,
                  style: TextStyle(
                    fontFamily: 'Pretendard',
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                _typeBadge(t),
                if (act.headline) _headlineBadge(),
              ],
            ),
          ),
          SizedBox(width: 8.w),
          Text(
            act.time,
            style: TextStyle(
              fontFamily: 'Pretendard',
              fontSize: 12.sp,
              height: 13 / 12,
              fontWeight: FontWeight.w700,
              color: VybeColors.gray400,
            ),
          ),
        ],
      ),
    );
  }

  Widget _typeBadge(ScheduleActType t) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 1.h),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(5.r),
        color: t.bg,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(t.icon, size: 9.r, color: t.color),
          SizedBox(width: 3.w),
          Text(
            t.label,
            style: TextStyle(
              fontFamily: 'Pretendard',
              fontSize: 10.sp,
              height: 11 / 10,
              fontWeight: FontWeight.w700,
              color: t.color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _headlineBadge() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 1.h),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(5.r),
        color: const Color(0x29B5FF60), // rgba(181,255,96,0.16)
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.star_rounded, size: 9.r, color: VybeColors.mainLime500),
          SizedBox(width: 2.w),
          Text(
            '헤드라이너',
            style: TextStyle(
              fontFamily: 'Pretendard',
              fontSize: 9.sp,
              height: 11 / 9,
              fontWeight: FontWeight.w800,
              color: VybeColors.mainLime500,
            ),
          ),
        ],
      ),
    );
  }
}
