import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vybe/design_system/colors.dart';
import 'package:vybe/presentation/clubs/widgets/schedule_shared.dart';
import 'package:vybe/presentation/common/widgets/vybe_glass_button.dart';

/// 공연 일정 전체 페이지(schedule_all.jsx)를 이루는 조각들.

/// 상단 바 — 배경·구분선 없이 리퀴드 글래스 뒤로가기 + 가운데 제목.
class SchedulePageHeader extends StatelessWidget {
  const SchedulePageHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        top: MediaQuery.paddingOf(context).top + 6.h,
        bottom: 12.h,
        left: 8.w,
        right: 8.w,
      ),
      child: Row(
        children: [
          VybeGlassButton(onTap: () => Navigator.of(context).maybePop()),
          Expanded(
            child: Text(
              '공연 일정',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Pretendard',
                fontSize: 16.sp,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
          ),
          // 뒤로가기 버튼과 같은 폭을 오른쪽에 비워 제목이 가운데 오게 한다.
          SizedBox(width: 44.w),
        ],
      ),
    );
  }
}

/// 클럽명 · 지역 + '다가오는 공연' + 안내 한 줄.
class SchedulePageIntro extends StatelessWidget {
  final String clubName;
  final String area;

  const SchedulePageIntro({
    super.key,
    required this.clubName,
    required this.area,
  });

  @override
  Widget build(BuildContext context) {
    final hasMeta = clubName.isNotEmpty || area.isNotEmpty;

    return Padding(
      padding: EdgeInsets.fromLTRB(20.w, 18.h, 20.w, 14.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (hasMeta) ...[
            Row(
              children: [
                Text(clubName, style: _meta),
                if (clubName.isNotEmpty && area.isNotEmpty) const _Dot(),
                Text(area, style: _meta),
              ],
            ),
            SizedBox(height: 8.h),
          ],
          Text(
            '다가오는 공연',
            style: TextStyle(
              fontFamily: 'Pretendard',
              fontSize: 22.sp,
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            '공연이 있는 날만 표시돼요. 라인업은 당일 사정에 따라 변경될 수 있어요.',
            style: TextStyle(
              fontFamily: 'Pretendard',
              fontSize: 12.sp,
              height: 16 / 12,
              color: VybeColors.gray500,
            ),
          ),
        ],
      ),
    );
  }

  TextStyle get _meta => TextStyle(
    fontFamily: 'Pretendard',
    fontSize: 12.sp,
    color: VybeColors.gray500,
  );
}

class _Dot extends StatelessWidget {
  const _Dot();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 6.w),
      child: Container(
        width: 2.r,
        height: 2.r,
        decoration: const BoxDecoration(
          color: VybeColors.gray600,
          shape: BoxShape.circle,
        ),
      ),
    );
  }
}

/// 아티스트 타입 필터 (전체 · 래퍼 · DJ) — 각 칩에 해당 개수를 붙인다.
class SchedulePageFilter extends StatelessWidget {
  /// `all` · `rapper` · `dj` → 개수.
  final Map<String, int> counts;
  final String active;
  final ValueChanged<String> onChange;

  static const _tabs = [('all', '전체'), ('rapper', '래퍼'), ('dj', 'DJ')];

  const SchedulePageFilter({
    super.key,
    required this.counts,
    required this.active,
    required this.onChange,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 18.h),
      child: Row(
        children: [
          for (final (key, label) in _tabs)
            Padding(
              padding: EdgeInsets.only(right: 8.w),
              child: _Chip(
                label: label,
                count: counts[key] ?? 0,
                selected: key == active,
                onTap: () => onChange(key),
              ),
            ),
        ],
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  final String label;
  final int count;
  final bool selected;
  final VoidCallback onTap;

  const _Chip({
    required this.label,
    required this.count,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 34.h,
        padding: EdgeInsets.symmetric(horizontal: 14.w),
        decoration: BoxDecoration(
          color: selected ? VybeColors.mainPurple500 : VybeColors.gray900,
          borderRadius: BorderRadius.circular(999.r),
          border: Border.all(
            color: selected ? Colors.transparent : VybeColors.gray800,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: TextStyle(
                fontFamily: 'Pretendard',
                fontSize: 13.sp,
                fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                color: selected ? Colors.white : VybeColors.gray300,
              ),
            ),
            SizedBox(width: 5.w),
            Text(
              '$count',
              style: TextStyle(
                fontFamily: 'Pretendard',
                fontSize: 11.sp,
                fontWeight: FontWeight.w700,
                color: selected ? Colors.white70 : VybeColors.gray500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// 한 달치 묶음 — `YYYY년 M월 · N일` 헤더 + 날짜 카드들.
class SchedulePageMonthGroup extends StatelessWidget {
  final int month;
  final List<ScheduleDay> days;

  const SchedulePageMonthGroup({
    super.key,
    required this.month,
    required this.days,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 12.h),
            child: Row(
              children: [
                Icon(
                  Icons.calendar_today_outlined,
                  size: 15.r,
                  color: VybeColors.gray400,
                ),
                SizedBox(width: 7.w),
                Text(
                  '${days.first.year}년 $month월',
                  style: TextStyle(
                    fontFamily: 'Pretendard',
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                SizedBox(width: 6.w),
                Text(
                  '· ${days.length}일',
                  style: TextStyle(
                    fontFamily: 'Pretendard',
                    fontSize: 12.sp,
                    color: VybeColors.gray500,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 20.h),
            child: Column(
              children: [
                for (final day in days)
                  Padding(
                    padding: EdgeInsets.only(bottom: 10.h),
                    child: ScheduleDayCard(day: day),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// 하단 '새 공연 소식 알림 받기' 배너.
///
/// ⚠ 푸시 알림 경로가 아직 없어 **표시만** 한다 — 탭 동작을 붙이지 않았다.
class SchedulePageAlertCta extends StatelessWidget {
  static const _accent = Color(0xFFC8A8FF);

  const SchedulePageAlertCta({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(20.w, 4.h, 20.w, 0),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(vertical: 13.h),
        decoration: BoxDecoration(
          color: const Color(0x1F7731FE), // rgba(119,49,254,0.12)
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: const Color(0x667731FE)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.notifications_none_rounded, size: 16.r, color: _accent),
            SizedBox(width: 7.w),
            Text(
              '새 공연 소식 알림 받기',
              style: TextStyle(
                fontFamily: 'Pretendard',
                fontSize: 13.sp,
                fontWeight: FontWeight.w700,
                color: _accent,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// 목록 자리를 대신하는 회색 안내 한 줄 (오류 · 공연 없음).
class SchedulePageMessage extends StatelessWidget {
  final String text;

  const SchedulePageMessage(this.text, {super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 50.h),
      child: Center(
        child: Text(
          text,
          style: TextStyle(
            fontFamily: 'Pretendard',
            fontSize: 14.sp,
            color: VybeColors.gray500,
          ),
        ),
      ),
    );
  }
}
