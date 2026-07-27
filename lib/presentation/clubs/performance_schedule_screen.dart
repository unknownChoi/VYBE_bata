import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vybe/design_system/colors.dart';
import 'package:vybe/presentation/clubs/viewmodels/club_schedule_viewmodel.dart';
import 'package:vybe/presentation/clubs/widgets/schedule_shared.dart';
import 'package:vybe/presentation/common/widgets/vybe_glass_button.dart';

// 공연 일정 전체 페이지 — 클럽 상세 '공연 일정 > 전체보기'에서 진입.
// claude.ai/design schedule_all.html (schedule_all.jsx) 기반.
// performances 컬렉션 실연동. 타입 필터(전체/래퍼/DJ) + 월별 그룹핑 + 알림 CTA.

class PerformanceScheduleScreen extends ConsumerStatefulWidget {
  final String clubId;
  final String? clubName;
  final String? area;
  const PerformanceScheduleScreen({
    super.key,
    required this.clubId,
    this.clubName,
    this.area,
  });

  @override
  ConsumerState<PerformanceScheduleScreen> createState() =>
      _PerformanceScheduleScreenState();
}

class _PerformanceScheduleScreenState
    extends ConsumerState<PerformanceScheduleScreen> {
  String _type = 'all'; // all | rapper | dj

  Map<String, int> _countsOf(List<ScheduleDay> days) {
    int count(bool Function(ScheduleAct) test) =>
        days.fold(0, (n, d) => n + d.acts.where(test).length);
    return {
      'all': count((_) => true),
      'rapper': count((a) => a.type == 'rapper'),
      'dj': count((a) => a.type == 'dj'),
    };
  }

  List<ScheduleDay> _filtered(List<ScheduleDay> days) {
    if (_type == 'all') return days;
    return days
        .map(
          (d) => d.copyWithActs(d.acts.where((a) => a.type == _type).toList()),
        )
        .where((d) => d.acts.isNotEmpty)
        .toList();
  }

  // 월별 그룹
  List<MapEntry<int, List<ScheduleDay>>> _monthsOf(List<ScheduleDay> days) {
    final map = <int, List<ScheduleDay>>{};
    for (final d in days) {
      map.putIfAbsent(d.month, () => []).add(d);
    }
    return map.entries.toList();
  }

  @override
  Widget build(BuildContext context) {
    final clubName = widget.clubName ?? '';
    final area = widget.area ?? '';
    final async = ref.watch(clubScheduleProvider(widget.clubId));

    return Scaffold(
      backgroundColor: VybeColors.background,
      body: Column(
        children: [
          _header(),
          Expanded(
            child: ListView(
              physics: const ClampingScrollPhysics(),
              padding: EdgeInsets.zero,
              children: [
                _intro(clubName, area),
                ...async.when(
                  loading: () => [
                    Padding(
                      padding: EdgeInsets.symmetric(vertical: 60.h),
                      child: const Center(child: CircularProgressIndicator()),
                    ),
                  ],
                  error: (_, __) => [_emptyState('공연 일정을 불러오지 못했어요')],
                  data: (days) => _body(days),
                ),
                _alertCta(),
                Padding(
                  padding: EdgeInsets.fromLTRB(24.w, 16.h, 24.w, 40.h),
                  child: Center(
                    child: Text(
                      '일정은 매장 사정에 따라 변경될 수 있습니다.',
                      style: TextStyle(
                        fontFamily: 'Pretendard',
                        fontSize: 11.sp,
                        height: 16 / 11,
                        color: VybeColors.gray600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _body(List<ScheduleDay> days) {
    final counts = _countsOf(days);
    final months = _monthsOf(_filtered(days));
    return [
      _filter(counts),
      if (months.isEmpty)
        _emptyState('해당하는 공연이 없어요')
      else
        ...months.map((m) => _monthGroup(m.key, m.value)),
    ];
  }

  Widget _emptyState(String text) {
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

  // ── 헤더 ── (배경·구분선 없음, 리퀴드 글래스 뒤로가기 버튼)
  Widget _header() {
    return Padding(
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 6.h,
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
          SizedBox(width: 44.w),
        ],
      ),
    );
  }

  // ── 인트로 ──
  Widget _intro(String clubName, String area) {
    return Padding(
      padding: EdgeInsets.fromLTRB(20.w, 18.h, 20.w, 14.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (clubName.isNotEmpty || area.isNotEmpty) ...[
            Row(
              children: [
                Text(
                  clubName,
                  style: TextStyle(
                    fontFamily: 'Pretendard',
                    fontSize: 12.sp,
                    color: VybeColors.gray500,
                  ),
                ),
                if (clubName.isNotEmpty && area.isNotEmpty)
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 6.w),
                    child: Container(
                      width: 2.r,
                      height: 2.r,
                      decoration: const BoxDecoration(
                        color: VybeColors.gray600,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                Text(
                  area,
                  style: TextStyle(
                    fontFamily: 'Pretendard',
                    fontSize: 12.sp,
                    color: VybeColors.gray500,
                  ),
                ),
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

  // ── 타입 필터 ──
  Widget _filter(Map<String, int> counts) {
    const tabs = [('all', '전체'), ('rapper', '래퍼'), ('dj', 'DJ')];
    return Padding(
      padding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 18.h),
      child: Row(
        children: [
          for (final (key, label) in tabs)
            Padding(
              padding: EdgeInsets.only(right: 8.w),
              child: _filterChip(key, label, counts[key] ?? 0),
            ),
        ],
      ),
    );
  }

  Widget _filterChip(String key, String label, int count) {
    final on = _type == key;
    return GestureDetector(
      onTap: () => setState(() => _type = key),
      child: Container(
        height: 34.h,
        padding: EdgeInsets.symmetric(horizontal: 14.w),
        decoration: BoxDecoration(
          color: on ? VybeColors.mainPurple500 : VybeColors.gray900,
          borderRadius: BorderRadius.circular(999.r),
          border: Border.all(
            color: on ? Colors.transparent : VybeColors.gray800,
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
                fontWeight: on ? FontWeight.w700 : FontWeight.w500,
                color: on ? Colors.white : VybeColors.gray300,
              ),
            ),
            SizedBox(width: 5.w),
            Text(
              '$count',
              style: TextStyle(
                fontFamily: 'Pretendard',
                fontSize: 11.sp,
                fontWeight: FontWeight.w700,
                color: on ? Colors.white70 : VybeColors.gray500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── 월 그룹 ──
  Widget _monthGroup(int month, List<ScheduleDay> days) {
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
                for (final d in days)
                  Padding(
                    padding: EdgeInsets.only(bottom: 10.h),
                    child: ScheduleDayCard(day: d),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── 알림 CTA ──
  Widget _alertCta() {
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
            Icon(
              Icons.notifications_none_rounded,
              size: 16.r,
              color: const Color(0xFFC8A8FF),
            ),
            SizedBox(width: 7.w),
            Text(
              '새 공연 소식 알림 받기',
              style: TextStyle(
                fontFamily: 'Pretendard',
                fontSize: 13.sp,
                fontWeight: FontWeight.w700,
                color: const Color(0xFFC8A8FF),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
