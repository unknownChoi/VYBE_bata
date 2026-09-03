import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vybe/design_system/colors.dart';
import 'package:vybe/design_system/typography.dart';
import 'package:vybe/presentation/clubs/club_detail_route.dart';
import 'package:vybe/presentation/common/night_clock.dart';
import 'package:vybe/presentation/common/widgets/vybe_aurora.dart';
import 'package:vybe/presentation/common/widgets/vybe_skeleton.dart';
import 'package:vybe/presentation/edm/edm_models.dart';
import 'package:vybe/presentation/edm/widgets/edm_equalizer.dart';
import 'package:vybe/presentation/edm/widgets/edm_set_card.dart';

// EDM 공연 타임라인 조각 — 시각 열 / 레일(선·점) / 셋 카드 한 줄, NOW 마커, 스켈레톤.
//
// EDM 페이지 섹션(`EdmTimetable`)과 전체 일정 페이지(`EdmScheduleScreen`)가
// **같은 타임라인을 그린다**. 복붙으로 나누면 두 화면이 같은 공연을 다르게 그린다.

/// 타임라인 좌측 시각 열 폭(dp). 디자인은 36 이지만 'HH:mm'(13sp·w700)이 딱 맞아
/// 폰트·기기에 따라 한 글자가 밀려 두 줄이 된다. 힙합 라인업(46)과 같은 폭으로 맞췄다.
/// 시각 행·NOW 마커·스켈레톤이 같은 값을 써야 점과 카드가 세로로 안 어긋난다.
const double kEdmTimeColW = 46;

/// 타임라인 한 줄 — 시각 / 레일(선·점) / 셋 카드.
class EdmTimeRow extends StatelessWidget {
  final EdmSet set;
  final NightSlotStatus status;
  final int nowMin;
  final bool first;
  final bool last;
  final bool saved;
  final VoidCallback onSave;

  const EdmTimeRow({
    super.key,
    required this.set,
    required this.status,
    required this.nowMin,
    required this.first,
    required this.last,
    required this.saved,
    required this.onSave,
  });

  @override
  Widget build(BuildContext context) {
    final live = status == NightSlotStatus.live;
    final timeColor = switch (status) {
      NightSlotStatus.live => kEdmHot,
      NightSlotStatus.past => VybeColors.gray600,
      NightSlotStatus.upcoming => Colors.white,
    };
    final dotColor = switch (status) {
      NightSlotStatus.live => kEdmHot,
      NightSlotStatus.past => VybeColors.gray700,
      NightSlotStatus.upcoming => VybeColors.gray500,
    };

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            width: kEdmTimeColW.w,
            child: Padding(
              padding: EdgeInsets.only(top: 13.h),
              child: Text(
                set.time,
                textAlign: TextAlign.right,
                maxLines: 1,
                softWrap: false,
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
          SizedBox(width: 10.w),
          SizedBox(
            width: 13.w,
            child: Stack(
              alignment: Alignment.topCenter,
              children: [
                // 마지막 줄엔 선을 긋지 않는다 — 아래로 이어질 것이 없다.
                if (!last)
                  Positioned(
                    top: first ? 20.h : 0,
                    bottom: 0,
                    child: SizedBox(
                      width: 1.5.w,
                      child: const ColoredBox(color: VybeColors.gray800),
                    ),
                  ),
                if (live) Positioned(top: 14.h, child: const _LiveHalo()),
                Positioned(
                  top: 18.h,
                  child: Container(
                    width: 10.r,
                    height: 10.r,
                    decoration: BoxDecoration(
                      color: dotColor,
                      shape: BoxShape.circle,
                      border: Border.all(color: kVybeInk, width: 2),
                      boxShadow: live
                          ? [BoxShadow(color: kEdmHot, blurRadius: 10.r)]
                          : null,
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: 10.w),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: 12.h),
              child: EdmSetCard(
                set: set,
                status: status,
                nowMin: nowMin,
                saved: saved,
                onSave: onSave,
                onTap: () {
                  if (set.clubId.isNotEmpty)
                    openClubDetail(context, set.clubId);
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// 진행 중 점 뒤에서 숨 쉬는 라임 후광 (디자인 v1 `rgba(181,255,96,.28)`).
class _LiveHalo extends StatefulWidget {
  const _LiveHalo();

  @override
  State<_LiveHalo> createState() => _LiveHaloState();
}

class _LiveHaloState extends State<_LiveHalo>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1800),
  )..repeat(reverse: true);

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: Tween(
        begin: 0.55,
        end: 1.0,
      ).animate(CurvedAnimation(parent: _c, curve: Curves.easeInOut)),
      child: Container(
        width: 18.r,
        height: 18.r,
        decoration: BoxDecoration(
          color: kEdmHot.withValues(alpha: 0.28),
          shape: BoxShape.circle,
        ),
      ),
    );
  }
}

/// 'NOW HH:mm' 마커 — 지금이 타임라인의 어디인지.
class EdmNowMarker extends StatelessWidget {
  final String label;
  const EdmNowMarker({super.key, required this.label});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12.h),
      child: Row(
        children: [
          SizedBox(width: kEdmTimeColW.w),
          SizedBox(width: 10.w),
          SizedBox(
            width: 13.w,
            child: Center(
              child: SizedBox(
                width: 1.5.w,
                height: 24.h,
                child: const ColoredBox(color: VybeColors.gray800),
              ),
            ),
          ),
          SizedBox(width: 10.w),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 9.w, vertical: 4.h),
            decoration: BoxDecoration(
              color: kEdmHot,
              borderRadius: BorderRadius.circular(99.r),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const EdmEqualizer(color: kEdmOnHot, size: 9, bars: 3),
                SizedBox(width: 5.w),
                Text(
                  'NOW $label',
                  style: VybeTypography.caption.copyWith(
                    fontSize: 11.sp,
                    height: 12 / 11,
                    fontWeight: FontWeight.w800,
                    color: kEdmOnHot,
                    fontFeatures: const [FontFeature.tabularFigures()],
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: 8.w),
          const Expanded(child: _DashedLine()),
        ],
      ),
    );
  }
}

class _DashedLine extends StatelessWidget {
  const _DashedLine();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 1.h,
      child: CustomPaint(
        painter: _DashPainter(kEdmHot.withValues(alpha: 0.6)),
        size: Size.infinite,
      ),
    );
  }
}

class _DashPainter extends CustomPainter {
  final Color color;
  const _DashPainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = size.height;
    const dash = 5.0, gap = 5.0;
    for (var x = 0.0; x < size.width; x += dash + gap) {
      canvas.drawLine(
        Offset(x, size.height / 2),
        Offset((x + dash).clamp(0, size.width), size.height / 2),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(_DashPainter old) => old.color != color;
}

/// 타임라인 로딩 자리 — 시각 열 폭을 실제 줄과 맞춰 자리가 안 튄다.
class EdmTimelineSkeleton extends StatelessWidget {
  final int rows;
  const EdmTimelineSkeleton({super.key, this.rows = 3});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Column(
        children: [
          for (var i = 0; i < rows; i++)
            Padding(
              padding: EdgeInsets.only(bottom: 12.h),
              child: Row(
                children: [
                  SizedBox(
                    width: kEdmTimeColW.w,
                    child: VybeSkel(height: 13.h, radius: 4),
                  ),
                  SizedBox(width: 23.w),
                  Expanded(child: VybeSkel(height: 92.h, radius: 14)),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
