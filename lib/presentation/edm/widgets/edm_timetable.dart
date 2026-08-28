import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vybe/design_system/colors.dart';
import 'package:vybe/design_system/typography.dart';
import 'package:vybe/presentation/clubs/club_detail_route.dart';
import 'package:vybe/presentation/common/night_clock.dart';
import 'package:vybe/presentation/common/widgets/vybe_aurora.dart';
import 'package:vybe/presentation/common/widgets/vybe_skeleton.dart';
import 'package:vybe/presentation/edm/edm_models.dart';
import 'package:vybe/presentation/edm/widgets/edm_chrome.dart';
import 'package:vybe/presentation/edm/widgets/edm_equalizer.dart';
import 'package:vybe/presentation/edm/widgets/edm_set_card.dart';

// 타임라인 좌측 시각 열 폭(dp). 디자인은 36 이지만 'HH:mm'(13sp·w700)이 딱 맞아
// 폰트·기기에 따라 한 글자가 밀려 두 줄이 된다. 힙합 라인업(46)과 같은 폭으로 맞췄다.
// 시각 행·NOW 마커·스켈레톤이 같은 값을 써야 점과 카드가 세로로 안 어긋난다.
const double _kTimeColW = 46;

/// 'DJ 타임테이블' 섹션 — 오늘 EDM 공연을 시작 시각순 타임라인으로.
///
/// 세부 장르 칩과 '종료된 공연 접기/펼치기'는 이 섹션 안에서만 쓰는 상태라
/// 화면(EdmScreen)이 아니라 여기가 들고 있는다.
class EdmTimetable extends StatefulWidget {
  final List<EdmSet> sets;
  final bool loading;

  /// 판정 기준 시각 — 화면당 한 번 읽어 목록 전체가 같은 기준을 쓰게 한다.
  final DateTime now;

  final Set<Object> saved;
  final ValueChanged<Object> onSave;

  const EdmTimetable({
    super.key,
    required this.sets,
    required this.loading,
    required this.now,
    required this.saved,
    required this.onSave,
  });

  @override
  State<EdmTimetable> createState() => _EdmTimetableState();
}

class _EdmTimetableState extends State<EdmTimetable> {
  String _style = kEdmAllStyles;
  bool _showPast = false;

  int get _nowMin {
    var h = widget.now.hour;
    if (h < 6) h += 24;
    return h * 60 + widget.now.minute;
  }

  /// 오늘 셋에 실제로 있는 세부 장르만 칩으로 만든다.
  /// 데이터에 없는 장르를 칩으로 걸어 두면 눌러도 늘 0건이다.
  List<String> get _styles {
    final seen = <String>[];
    for (final s in widget.sets) {
      if (s.style.isNotEmpty && !seen.contains(s.style)) seen.add(s.style);
    }
    return seen;
  }

  @override
  Widget build(BuildContext context) {
    final styles = _styles;
    // 선택한 칩이 사라졌으면(데이터 갱신) '전체'로 되돌린다.
    final style = styles.contains(_style) ? _style : kEdmAllStyles;

    final all =
        widget.sets.where((s) => style == kEdmAllStyles || s.style == style).toList()
          ..sort((a, b) => nightMinutes(a.time).compareTo(nightMinutes(b.time)));

    final nowMin = _nowMin;
    NightSlotStatus st(EdmSet s) => nightSlotStatus(s.time, nowMin);

    final past = all.where((s) => st(s) == NightSlotStatus.past).toList();
    final shown = _showPast
        ? all
        : all.where((s) => st(s) != NightSlotStatus.past).toList();

    // NOW 마커는 '이미 시작한 마지막 셋' 아래에 놓는다.
    var markerAfter = -1;
    for (var i = 0; i < shown.length; i++) {
      if (nightMinutes(shown[i].time) <= nowMin) markerAfter = i;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        EdmSectionHead(
          title: 'DJ 타임테이블',
          sub: widget.loading
              ? edmDateLabel(widget.now)
              : '${edmDateLabel(widget.now)} · 공연 ${widget.sets.length}개',
        ),
        if (styles.length >= 2) ...[
          EdmChipRow(
            items: [kEdmAllStyles, ...styles],
            active: style,
            onChange: (s) => setState(() => _style = s),
          ),
          SizedBox(height: 16.h),
        ],
        if (widget.loading)
          const _TimetableSkeleton()
        else if (widget.sets.isEmpty)
          const _Empty(text: '오늘 예정된 EDM 공연이 없어요')
        else ...[
          if (past.isNotEmpty)
            Padding(
              padding: EdgeInsets.only(left: 16.w, right: 16.w, bottom: 12.h),
              child: _PastToggle(
                count: past.length,
                open: _showPast,
                onTap: () => setState(() => _showPast = !_showPast),
              ),
            ),
          if (shown.isEmpty)
            _Empty(text: '$style 셋은 오늘 예정에 없어요')
          else
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              child: Column(
                children: [
                  for (var i = 0; i < shown.length; i++) ...[
                    _TimeRow(
                      set: shown[i],
                      status: st(shown[i]),
                      nowMin: nowMin,
                      first: i == 0,
                      last: i == shown.length - 1,
                      saved: widget.saved.contains(shown[i].id),
                      onSave: () => widget.onSave(shown[i].id),
                    ),
                    if (i == markerAfter && i < shown.length - 1)
                      _NowMarker(label: edmClock(widget.now)),
                  ],
                ],
              ),
            ),
        ],
      ],
    );
  }
}

/// 타임라인 한 줄 — 시각 / 레일(선·점) / 셋 카드.
class _TimeRow extends StatelessWidget {
  final EdmSet set;
  final NightSlotStatus status;
  final int nowMin;
  final bool first;
  final bool last;
  final bool saved;
  final VoidCallback onSave;

  const _TimeRow({
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
      NightSlotStatus.live => kEdmAccentText,
      NightSlotStatus.past => VybeColors.gray600,
      NightSlotStatus.upcoming => Colors.white,
    };
    final dotColor = switch (status) {
      NightSlotStatus.live => kEdmAccent,
      NightSlotStatus.past => VybeColors.gray700,
      NightSlotStatus.upcoming => VybeColors.gray500,
    };

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            width: _kTimeColW.w,
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
                if (live)
                  Positioned(top: 14.h, child: const _LiveHalo()),
                Positioned(
                  top: 18.h,
                  child: Container(
                    width: 10.r,
                    height: 10.r,
                    decoration: BoxDecoration(
                      color: dotColor,
                      shape: BoxShape.circle,
                      border: Border.all(color: kVybeInk, width: 2),
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
                  if (set.clubId.isNotEmpty) openClubDetail(context, set.clubId);
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// 진행 중 점 뒤에서 숨 쉬는 보라 후광.
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
      opacity: Tween(begin: 0.55, end: 1.0).animate(
        CurvedAnimation(parent: _c, curve: Curves.easeInOut),
      ),
      child: Container(
        width: 18.r,
        height: 18.r,
        decoration: BoxDecoration(
          color: kEdmAccent.withValues(alpha: 0.40),
          shape: BoxShape.circle,
        ),
      ),
    );
  }
}

/// 'NOW HH:mm' 마커 — 지금이 타임라인의 어디인지.
class _NowMarker extends StatelessWidget {
  final String label;
  const _NowMarker({required this.label});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12.h),
      child: Row(
        children: [
          SizedBox(width: _kTimeColW.w),
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

class _PastToggle extends StatelessWidget {
  final int count;
  final bool open;
  final VoidCallback onTap;
  const _PastToggle({
    required this.count,
    required this.open,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Container(
          height: 30.h,
          padding: EdgeInsets.symmetric(horizontal: 12.w),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: VybeColors.gray900,
            borderRadius: BorderRadius.circular(99.r),
            border: Border.all(color: VybeColors.gray800),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                open ? '종료된 공연 접기' : '종료된 공연 $count개 보기',
                style: VybeTypography.caption.copyWith(
                  height: 14 / 12,
                  fontWeight: FontWeight.w600,
                  color: VybeColors.gray400,
                ),
              ),
              SizedBox(width: 5.w),
              Icon(
                open
                    ? Icons.keyboard_arrow_up_rounded
                    : Icons.keyboard_arrow_down_rounded,
                size: 15.r,
                color: VybeColors.gray500,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Empty extends StatelessWidget {
  final String text;
  const _Empty({required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 34.h, horizontal: 24.w),
      child: SizedBox(
        width: double.infinity,
        child: Text(
          text,
          textAlign: TextAlign.center,
          style: VybeTypography.body4.copyWith(color: VybeColors.gray500),
        ),
      ),
    );
  }
}

class _TimetableSkeleton extends StatelessWidget {
  const _TimetableSkeleton();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Column(
        children: [
          for (var i = 0; i < 3; i++)
            Padding(
              padding: EdgeInsets.only(bottom: 12.h),
              child: Row(
                children: [
                  SizedBox(
                    width: _kTimeColW.w,
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
