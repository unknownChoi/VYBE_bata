import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vybe/design_system/colors.dart';
import 'package:vybe/presentation/clubs/performance_schedule_screen.dart';
import 'package:vybe/presentation/clubs/viewmodels/club_schedule_viewmodel.dart';
import 'package:vybe/presentation/clubs/widgets/schedule_shared.dart';
import 'package:vybe/presentation/common/widgets/vybe_skeleton.dart';

// 공연 일정 섹션 — 클럽 상세 홈 탭.
// claude.ai/design club_detail.html (schedule.jsx) 디자인 기반.
// performances 컬렉션 실연동(clubScheduleProvider). 공연 없으면 섹션 숨김.
// 기본 3일 → '더 보기'로 전체 펼침. 전체보기 → PerformanceScheduleScreen.

class PerformanceScheduleSection extends ConsumerStatefulWidget {
  final String clubId;
  final String? clubName;
  final String? area;
  const PerformanceScheduleSection({
    super.key,
    required this.clubId,
    this.clubName,
    this.area,
  });

  @override
  ConsumerState<PerformanceScheduleSection> createState() =>
      _PerformanceScheduleSectionState();
}

class _PerformanceScheduleSectionState
    extends ConsumerState<PerformanceScheduleSection> {
  bool _showAll = false;

  void _openAll() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => PerformanceScheduleScreen(
          clubId: widget.clubId,
          clubName: widget.clubName,
          area: widget.area,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final async = ref.watch(clubScheduleProvider(widget.clubId));
    // 로딩 중엔 스켈레톤, 공연 없으면(또는 에러) 섹션 전체 숨김.
    if (async.isLoading) return const ScheduleSkeleton();
    final days = async.value ?? const <ScheduleDay>[];
    if (days.isEmpty) return const SizedBox.shrink();

    final visible = _showAll ? days : days.take(3).toList();
    final moreCount = days.length - 3;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 24.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _header(),
          SizedBox(height: 4.h),
          Text(
            '공연이 있는 날만 표시돼요 · 앞으로 ${days.length}일 예정',
            style: TextStyle(
              fontFamily: 'Pretendard',
              fontSize: 12.sp,
              height: 16 / 12,
              color: VybeColors.gray500,
            ),
          ),
          SizedBox(height: 14.h),
          ...visible.map(
            (d) => Padding(
              padding: EdgeInsets.only(bottom: 10.h),
              child: ScheduleDayCard(day: d),
            ),
          ),
          if (!_showAll && moreCount > 0)
            GestureDetector(
              onTap: () => setState(() => _showAll = true),
              child: Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(vertical: 11.h),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10.r),
                  border: Border.all(color: VybeColors.gray800),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '공연일 $moreCount일 더 보기',
                      style: TextStyle(
                        fontFamily: 'Pretendard',
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w600,
                        color: VybeColors.gray300,
                      ),
                    ),
                    SizedBox(width: 5.w),
                    Icon(
                      Icons.keyboard_arrow_down_rounded,
                      size: 15.r,
                      color: VybeColors.gray400,
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _header() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          '공연 일정',
          style: TextStyle(
            fontFamily: 'Pretendard',
            fontSize: 18.sp,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
        GestureDetector(
          onTap: _openAll,
          child: Row(
            children: [
              Text(
                '전체보기',
                style: TextStyle(
                  fontFamily: 'Pretendard',
                  fontSize: 12.sp,
                  color: VybeColors.gray500,
                ),
              ),
              Icon(
                Icons.chevron_right_rounded,
                size: 14.r,
                color: VybeColors.gray500,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
