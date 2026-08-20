import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vybe/core/utils/number_format.dart';
import 'package:vybe/data/models/club_model.dart';
import 'package:vybe/data/models/free_entry_policy.dart';
import 'package:vybe/data/models/free_entry_timeline.dart';
import 'package:vybe/data/models/operating_hours.dart';
import 'package:vybe/design_system/colors.dart';
import 'package:vybe/design_system/typography.dart';
import 'package:vybe/presentation/common/renew/renew_glass.dart';
import 'package:vybe/presentation/common/renew/renew_icons.dart';

/// 클럽 상세 리뉴얼 · **시간대별 무료입장** 섹션 (디자인 `club_renew_free.jsx`).
///
/// 구성 — 남은 시간 카운트다운 헤드 / 시간대별 입장비 도형 / 조건 한 줄 /
/// 요일별 무료입장 시간(접힘).
///
/// 디자인과 다른 점(사유):
/// - 데모의 21:14 고정 시계 대신 **실제 시각**으로 1초마다 센다.
/// - 도형의 요금 칸은 데모의 하드코딩 요금표가 아니라
///   `operatingHours` × `freeEntry.windows` × `entryFeeMin` 조합
///   ([buildFreeEntryTimeline])으로 만든다. Firestore 에 시간대별 요금표는 없다.
/// - **'무료 시간 시작 전 알림 받기' 버튼은 뺐다** — 앱에 푸시 알림 경로가 아직
///   없어서 눌러도 아무 일이 없는 버튼이 된다. 알림이 붙으면 그때 넣는다.
/// - 디자인의 '만석 시 조기 마감'·'신분증 지참' 두 줄은 대응 필드가 없어 뺐다.
///   조건 문구는 `freeEntry.condition` 하나만 쓴다.
///
/// ⚠ **`freeEntry.type == 'timed'` 클럽에서, 무료 시작이 가까울 때만 그려진다**
/// — [maybeBuild] 참고.
class RenewFreeEntrySection extends StatefulWidget {
  final ClubModel club;

  const RenewFreeEntrySection({super.key, required this.club});

  /// 무료 시작 **이 시간 전부터** 섹션을 띄운다.
  ///
  /// 무료가 여섯 시간 뒤인데 카운트다운을 큼직하게 띄워 두면 홈 탭 첫 자리를
  /// 종일 차지하면서 정작 볼 일이 없다. 무료 시간이 눈앞일 때만 자리를 준다.
  static const Duration leadTime = Duration(hours: 1);

  /// 보여 줄 게 있을 때만 위젯을 만든다. 없으면 null → 호출부가 섹션을 뺀다.
  ///
  /// 안 그리는 경우 —
  /// - `none` — 무료입장이 아예 없다.
  /// - `always` — **상시 무료라 나눌 시간대가 없다.** 카운트다운도 도형도
  ///   보여 줄 게 없어(영업시간 전체가 한 칸) 섹션이 자리만 차지한다.
  ///   '무료'라는 사실은 매장 정보 입장료 행([RenewFeeRow])이 이미 알린다.
  /// - `timed` 인데 쓸 수 있는 창이 하나도 없을 때 — 제목만 뜨고 알맹이가 빈다.
  /// - `timed` 인데 다음 무료 시작이 [leadTime] 보다 멀 때.
  ///
  /// ⚠ **판정은 화면을 만드는 시점 한 번**이다. 이미 떠 있는 섹션은 무료 시간이
  /// 끝나도 그대로 두고 헤드만 '다음 무료입장'으로 바뀐다 — 보고 있는 화면에서
  /// 섹션이 통째로 사라지면 스크롤 위치가 튀고, 방금 본 정보를 다시 찾게 된다.
  /// 다시 숨기는 건 다음 진입 때.
  static Widget? maybeBuild(ClubModel club, {DateTime? now}) {
    final policy = club.freeEntry;
    if (!policy.isTimed) return null;
    if (!policy.windows.any((w) => w.isValid)) return null;

    final at = now ?? DateTime.now();
    final status = policy.statusAt(at);
    // 진행 중이면 남은 시간이 곧 알맹이라 무조건 띄운다.
    if (status.isFreeNow) return RenewFreeEntrySection(club: club);

    final untilNext = status.untilNextFrom(at);
    if (untilNext == null || untilNext > leadTime) return null;
    return RenewFreeEntrySection(club: club);
  }

  @override
  State<RenewFreeEntrySection> createState() => _RenewFreeEntrySectionState();
}

class _RenewFreeEntrySectionState extends State<RenewFreeEntrySection> {
  /// 1초마다 흐르는 현재 시각. 카운트다운·도형 마커만 여기 붙는다 —
  /// 카드 전체를 매초 다시 그리면 글래스 블러까지 매초 다시 계산된다.
  final _tick = ValueNotifier<DateTime>(DateTime.now());

  Timer? _timer;
  bool _weekOpen = false;

  /// 이 시각을 넘기면 상태(무료 중 ↔ 예정)가 바뀌므로 카드를 다시 만든다.
  DateTime? _boundary;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) => _onTick());
  }

  @override
  void dispose() {
    _timer?.cancel();
    _tick.dispose();
    super.dispose();
  }

  void _onTick() {
    final now = DateTime.now();
    _tick.value = now;
    final boundary = _boundary;
    if (boundary != null && !now.isBefore(boundary)) {
      // 창이 열리거나 닫혔다 → 헤드 문구·도형 구간이 통째로 바뀐다.
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final club = widget.club;
    final policy = club.freeEntry;
    final now = _tick.value;
    final status = policy.statusAt(now);

    // 도형은 "지금 이야기하고 있는 회차"를 그린다 —
    // 무료 중이면 지금 회차, 아니면 다음 무료가 있는 회차.
    final anchor = status.isFreeNow ? now : (status.nextStartsAt ?? now);
    final timeline = buildFreeEntryTimeline(
      hours: club.operatingHours,
      policy: policy,
      normalFee: club.entryFeeMin,
      at: anchor,
    );

    // 영업 중일 때만 '지금 무료'로 부른다 — 문 닫은 클럽의 '지금 무료'는 거짓이다.
    final openNow =
        timeline?.contains(now) ?? club.operatingHours.dayAt(now).isOpenAt(now);
    final live = status.isFreeNow && openNow;

    _boundary = status.activeEndsAt ?? status.nextStartsAt;

    final head = _headFor(club, status, live: live, now: now);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RenewSectionHead(
          title: '시간대별 무료입장',
          sub: timeline == null ? null : _sessionLabel(timeline.start, now),
        ),
        RenewGlassCard(
          fill: live
              ? VybeColors.mainLime500.withValues(alpha: 0.10)
              : RenewGlass.cardFill,
          border: live
              ? VybeColors.mainLime500.withValues(alpha: 0.34)
              : RenewGlass.cardBorder,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _Head(head: head, live: live, tick: _tick),
              if (timeline != null) ...[
                SizedBox(height: 16.h),
                _FeeTimelineBar(
                  timeline: timeline,
                  tick: _tick,
                  feeMax: club.entryFeeMax,
                ),
              ],
              SizedBox(height: 16.h),
              const _Hairline(),
              SizedBox(height: 12.h),
              _ConditionRow(text: _conditionText(club)),
              SizedBox(height: 12.h),
              _WeekToggle(
                open: _weekOpen,
                onTap: () => setState(() => _weekOpen = !_weekOpen),
              ),
              AnimatedSize(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
                alignment: Alignment.topCenter,
                child: _weekOpen
                    ? Padding(
                        padding: EdgeInsets.only(top: 12.h),
                        child: _FreeWeekTable(
                          hours: club.operatingHours,
                          policy: policy,
                        ),
                      )
                    : const SizedBox(width: double.infinity),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// 조건 문구 — 등록된 게 없으면 이 기능이 어떻게 동작하는지만 알린다
  /// (클럽별 조건을 지어내지 않는다).
  String _conditionText(ClubModel club) {
    final condition = club.freeEntryLabel;
    return condition.isNotEmpty ? condition : '무료 시간 안에 입장한 경우에만 적용돼요';
  }

  _HeadData _headFor(
    ClubModel club,
    FreeEntryStatus status, {
    required bool live,
    required DateTime now,
  }) {
    final endsAt = status.activeEndsAt;
    if (status.isFreeNow && endsAt != null) {
      return _HeadData(
        // 창은 열렸는데 영업 전이면 '지금'이라 부르지 않는다.
        key: live ? '지금 무료입장 중' : '무료입장 시간대',
        value: '${_hhmm(endsAt)}까지',
        sub: '남은 시간',
        big: null,
        countdownTo: endsAt,
      );
    }

    final startsAt = status.nextStartsAt;
    if (startsAt != null) {
      final isToday = _isSameDay(startsAt, now);
      return _HeadData(
        key: isToday ? '오늘 무료입장 예정' : '다음 무료입장',
        value: isToday
            ? '${_hhmm(startsAt)} 시작'
            : '${_weekdayLabel(startsAt.weekday)} ${_hhmm(startsAt)} 시작',
        sub: '시작까지',
        big: null,
        countdownTo: startsAt,
      );
    }

    // 창이 전부 깨진 값일 때만 여기 온다 (maybeBuild 가 대부분 걸러낸다).
    return _HeadData(
      key: '무료입장 시간 없음',
      value: '예정된 무료 시간이 없어요',
      sub: '현재 입장료',
      big: _feeLabel(club.entryFeeMin, club.entryFeeMax),
      countdownTo: null,
    );
  }
}

/// 헤드 4칸 — 왼쪽 위/아래(상태·시각), 오른쪽 위/아래(라벨·큰 숫자).
class _HeadData {
  final String key;
  final String value;
  final String sub;

  /// 큰 숫자 자리에 고정 문구를 쓸 때. [countdownTo] 가 있으면 무시된다.
  final String? big;

  /// 큰 숫자 자리를 카운트다운으로 채울 목표 시각.
  final DateTime? countdownTo;

  const _HeadData({
    required this.key,
    required this.value,
    required this.sub,
    required this.big,
    required this.countdownTo,
  });
}

class _Head extends StatelessWidget {
  final _HeadData head;
  final bool live;
  final ValueNotifier<DateTime> tick;

  const _Head({required this.head, required this.live, required this.tick});

  @override
  Widget build(BuildContext context) {
    final accent = live ? VybeColors.mainLime500 : RenewGlass.t1;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  if (live) ...[const _PulseDot(size: 6), SizedBox(width: 6.w)],
                  Flexible(
                    child: Text(
                      head.key,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: VybeTypography.button2.copyWith(
                        color: live ? VybeColors.mainLime500 : RenewGlass.t3,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 7.h),
              Text(
                head.value,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: VybeTypography.heading3.copyWith(color: RenewGlass.t1),
              ),
            ],
          ),
        ),
        SizedBox(width: 12.w),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(head.sub, style: RenewGlass.caption(lineHeight: 14)),
            SizedBox(height: 4.h),
            // 남은 시간은 초 단위로 흐른다 — 이 텍스트만 매초 다시 그린다.
            _BigValue(head: head, tick: tick, color: accent),
          ],
        ),
      ],
    );
  }
}

class _BigValue extends StatelessWidget {
  final _HeadData head;
  final ValueNotifier<DateTime> tick;
  final Color color;

  const _BigValue({
    required this.head,
    required this.tick,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final style = TextStyle(
      fontFamily: 'Pretendard',
      fontSize: 26.sp,
      height: 30 / 26,
      fontWeight: FontWeight.w700,
      letterSpacing: 26 * -0.03,
      color: color,
      // 숫자 폭이 매초 달라지면 글자가 떨린다.
      fontFeatures: const [FontFeature.tabularFigures()],
    );

    final target = head.countdownTo;
    if (target == null) return Text(head.big ?? '', style: style);

    return ValueListenableBuilder<DateTime>(
      valueListenable: tick,
      builder: (_, now, __) {
        final left = target.difference(now);
        return Text(
          formatFreeCountdown(left.isNegative ? Duration.zero : left),
          style: style,
        );
      },
    );
  }
}

// ============================================================================
// 시간대별 입장비 도형
// ============================================================================

/// 회차를 요금 구간으로 나눈 가로 막대 + 현재 시각 마커 + 아래 시각 눈금.
///
/// 칸 너비는 **실제 길이 비례**다. 다만 15분짜리 칸이 1/32 폭이 되면 요금 글자가
/// 통째로 잘리므로 최소 폭([_minSlotWidth])을 보장하고 모자란 만큼을 넓은 칸에서
/// 뗀다. 마커 위치도 **같은 너비 배열**로 계산해 칸 경계와 어긋나지 않게 한다.
class _FeeTimelineBar extends StatelessWidget {
  final FreeEntryTimeline timeline;
  final ValueNotifier<DateTime> tick;

  /// `entryFeeMax` — 최소가와 다르면 요금 칸을 `10,000원~` 으로 쓴다.
  final int feeMax;

  const _FeeTimelineBar({
    required this.timeline,
    required this.tick,
    required this.feeMax,
  });

  static const double _gap = 3;
  static const double _minSlotWidth = 52;
  static const double _barHeight = 46;

  @override
  Widget build(BuildContext context) {
    final slots = timeline.slots;
    if (slots.isEmpty) return const SizedBox.shrink();

    return LayoutBuilder(
      builder: (context, constraints) {
        final gap = _gap.w;
        final available = constraints.maxWidth - gap * (slots.length - 1);
        if (available <= 0) return const SizedBox.shrink();

        final widths = _slotWidths(
          [for (final s in slots) s.minutes],
          available,
          _minSlotWidth.w,
        );

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: _barHeight.h,
              child: ValueListenableBuilder<DateTime>(
                valueListenable: tick,
                builder: (_, now, __) => Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Row(
                      children: [
                        for (var i = 0; i < slots.length; i++) ...[
                          if (i > 0) SizedBox(width: gap),
                          SizedBox(
                            width: widths[i],
                            child: _SlotBlock(
                              slot: slots[i],
                              current: slots[i].contains(now),
                              feeMax: feeMax,
                            ),
                          ),
                        ],
                      ],
                    ),
                    ..._marker(slots, widths, gap, now),
                  ],
                ),
              ),
            ),
            SizedBox(height: 7.h),
            _TimeAxis(slots: slots, widths: widths, gap: gap),
          ],
        );
      },
    );
  }

  /// 지금 시각 세로선. 회차 밖이면 아무것도 그리지 않는다.
  List<Widget> _marker(
    List<FeeSlot> slots,
    List<double> widths,
    double gap,
    DateTime now,
  ) {
    var x = 0.0;
    for (var i = 0; i < slots.length; i++) {
      final slot = slots[i];
      if (slot.contains(now)) {
        final within = slot.minutes <= 0
            ? 0.0
            : now.difference(slot.start).inSeconds / (slot.minutes * 60);
        final left = x + widths[i] * within;
        return [
          Positioned(
            left: left - 1.w,
            top: -7.h,
            bottom: -7.h,
            child: const _NowMarker(),
          ),
        ];
      }
      x += widths[i] + gap;
    }
    return const [];
  }
}

/// 길이 비례 너비 — 최소 폭에 걸리는 칸을 고정하고 나머지를 다시 나눈다.
///
/// 밖으로 뺀 이유는 테스트 때문이 아니라 마커 계산이 **같은 배열**을 써야 해서다.
List<double> _slotWidths(List<int> minutes, double available, double minWidth) {
  final n = minutes.length;
  if (n == 0) return const [];
  // 최소 폭조차 못 주는 좁은 화면 — 그냥 균등 분할한다.
  if (available <= minWidth * n) return List.filled(n, available / n);

  final pinned = List.filled(n, false);
  final widths = List.filled(n, 0.0);

  var changed = true;
  while (changed) {
    changed = false;
    var rest = available;
    var restMinutes = 0;
    for (var i = 0; i < n; i++) {
      if (pinned[i]) {
        rest -= minWidth;
      } else {
        restMinutes += minutes[i];
      }
    }
    for (var i = 0; i < n; i++) {
      if (pinned[i]) {
        widths[i] = minWidth;
        continue;
      }
      widths[i] = restMinutes <= 0 ? rest / n : rest * minutes[i] / restMinutes;
      if (widths[i] < minWidth) {
        pinned[i] = true;
        changed = true;
      }
    }
  }
  return widths;
}

/// 요금 칸 하나 — 무료는 라임 채움, 유료는 타일. 지금 칸이 아니면 살짝 흐리다.
class _SlotBlock extends StatelessWidget {
  final FeeSlot slot;
  final bool current;
  final int feeMax;

  const _SlotBlock({
    required this.slot,
    required this.current,
    required this.feeMax,
  });

  @override
  Widget build(BuildContext context) {
    final free = slot.isFree;
    final radius = BorderRadius.circular(10.r);

    return Opacity(
      opacity: free || current ? 1 : 0.62,
      child: Container(
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: free ? VybeColors.mainLime500 : RenewGlass.tileFill,
          borderRadius: radius,
          boxShadow: free
              ? [
                  BoxShadow(
                    color: VybeColors.mainLime500.withValues(alpha: 0.22),
                    blurRadius: 18.r,
                    offset: Offset(0, 6.h),
                  ),
                ]
              : null,
        ),
        // 테두리만 자식 위로 — decoration 에 두면 클립된 자식이 코너 호에서
        // 선을 덮는다(그림자는 칸 뒤라 decoration 에 그대로 둔다).
        foregroundDecoration: BoxDecoration(
          borderRadius: radius,
          border: Border.all(
            color: free ? VybeColors.mainLime500 : RenewGlass.tileBorder,
          ),
        ),
        child: Stack(
          fit: StackFit.expand,
          children: [
            // 무료 칸 광택 (디자인 linear-gradient 128deg)
            if (free)
              const DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0x6BFFFFFF), Color(0x00FFFFFF)],
                    stops: [0, 0.52],
                  ),
                ),
              ),
            Center(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 4.w),
                child: Text(
                  free ? '무료' : _feeLabel(slot.fee, feeMax),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontFamily: 'Pretendard',
                    fontSize: (free ? 13 : 12).sp,
                    height: 1,
                    fontWeight: free ? FontWeight.w700 : FontWeight.w600,
                    letterSpacing: (free ? 13 : 12) * -0.025,
                    color: free
                        ? RenewGlass.ink
                        : current
                        ? RenewGlass.t1
                        : RenewGlass.t4,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// 도형 아래 시각 눈금 — 칸마다 시작 시각, 마지막 칸은 끝 시각도.
class _TimeAxis extends StatelessWidget {
  final List<FeeSlot> slots;
  final List<double> widths;
  final double gap;

  const _TimeAxis({
    required this.slots,
    required this.widths,
    required this.gap,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        for (var i = 0; i < slots.length; i++) ...[
          if (i > 0) SizedBox(width: gap),
          SizedBox(
            width: widths[i],
            child: Stack(
              children: [
                Text(
                  _hhmm(slots[i].start),
                  style: RenewGlass.caption(
                    size: 11,
                    lineHeight: 14,
                    color: slots[i].isFree ? RenewGlass.t2 : RenewGlass.t4,
                    weight: slots[i].isFree ? FontWeight.w600 : FontWeight.w400,
                  ),
                ),
                if (i == slots.length - 1)
                  Positioned(
                    right: 0,
                    child: Text(
                      _hhmm(slots[i].end),
                      style: RenewGlass.caption(size: 11, lineHeight: 14),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}

/// 현재 시각 세로선 + 위쪽 점.
class _NowMarker extends StatelessWidget {
  const _NowMarker();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 8.w,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.topCenter,
        children: [
          Center(
            child: Container(
              width: 2.w,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(99.r),
                boxShadow: [
                  BoxShadow(
                    color: Colors.white.withValues(alpha: 0.7),
                    blurRadius: 10.r,
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            top: -3.h,
            child: Container(
              width: 8.r,
              height: 8.r,
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// 카드 아랫부분
// ============================================================================

class _Hairline extends StatelessWidget {
  const _Hairline();

  @override
  Widget build(BuildContext context) => const SizedBox(
    height: 1,
    width: double.infinity,
    child: ColoredBox(color: RenewGlass.hair),
  );
}

class _ConditionRow extends StatelessWidget {
  final String text;

  const _ConditionRow({required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(top: 1.h, right: 8.w),
          child: Icon(
            Icons.info_outline_rounded,
            size: 14.r,
            color: RenewGlass.t4,
          ),
        ),
        Expanded(child: Text(text, style: RenewGlass.caption(lineHeight: 17))),
      ],
    );
  }
}

class _WeekToggle extends StatelessWidget {
  final bool open;
  final VoidCallback onTap;

  const _WeekToggle({required this.open, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Row(
        children: [
          Expanded(
            child: Text(
              '요일별 무료입장 시간',
              style: VybeTypography.button2.copyWith(color: RenewGlass.t3),
            ),
          ),
          AnimatedRotation(
            turns: open ? 0.5 : 0,
            duration: const Duration(milliseconds: 220),
            child: const RenewChevron(size: 15),
          ),
        ],
      ),
    );
  }
}

/// 요일별 무료입장 시간 — 휴무일은 레드, 무료 창이 없는 영업일은 회색.
class _FreeWeekTable extends StatelessWidget {
  final OperatingHours hours;
  final FreeEntryPolicy policy;

  const _FreeWeekTable({required this.hours, required this.policy});

  @override
  Widget build(BuildContext context) {
    final todayIndex = DateTime.now().weekday - 1;

    return Column(
      children: [
        for (var i = 0; i < 7; i++)
          Padding(
            padding: EdgeInsets.only(bottom: i == 6 ? 0 : 9.h),
            child: _row(i + 1, i == todayIndex),
          ),
      ],
    );
  }

  Widget _row(int weekday, bool today) {
    final day = hours.dayOf(weekday);
    final closed = !day.isOpen;

    final ranges = closed
        ? const <String>[]
        : [
            for (final w in policy.windows)
              if (w.isValid && w.startsOnWeekday(weekday)) w.rangeLabel,
          ];

    final text = closed
        ? '정기휴무'
        : ranges.isEmpty
        ? '무료입장 없음'
        : ranges.join(' · ');
    final color = closed
        ? VybeColors.accentRed500
        : ranges.isEmpty
        ? RenewGlass.t4
        : today
        ? VybeColors.mainLime500
        : RenewGlass.t3;

    return Row(
      children: [
        SizedBox(
          width: 18.w,
          child: Text(
            _weekdayLabel(weekday),
            style: RenewGlass.caption(
              color: today ? RenewGlass.t1 : RenewGlass.t3,
              lineHeight: 15,
              weight: today ? FontWeight.w600 : FontWeight.w400,
            ),
          ),
        ),
        SizedBox(width: 12.w),
        Flexible(
          child: Text(
            text,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: RenewGlass.caption(
              color: color,
              lineHeight: 15,
              weight: today || closed ? FontWeight.w600 : FontWeight.w400,
            ),
          ),
        ),
        if (today) ...[
          const Spacer(),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
            decoration: BoxDecoration(
              color: VybeColors.mainPurple500.withValues(alpha: 0.22),
              borderRadius: BorderRadius.circular(6.r),
            ),
            child: Text(
              '오늘',
              style: RenewGlass.caption(
                color: RenewGlass.lavender,
                size: 10,
                lineHeight: 12,
                weight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ],
    );
  }
}

// ============================================================================
// 매장 정보 '입장료' 행 (디자인 VRFeeLine)
// ============================================================================

/// 매장 정보 카드의 입장료 행. 무료 정책이 있으면 pill + 무료 시간 한 줄이 붙는다.
///
/// 무료 정책이 없는 클럽에서는 원래대로 `입장료 20,000원` 한 줄만 나온다.
class RenewFeeRow extends StatefulWidget {
  final ClubModel club;

  const RenewFeeRow({super.key, required this.club});

  @override
  State<RenewFeeRow> createState() => _RenewFeeRowState();
}

class _RenewFeeRowState extends State<RenewFeeRow> {
  Timer? _timer;
  DateTime _now = DateTime.now();

  @override
  void initState() {
    super.initState();
    // 행 하나짜리 표기라 초 단위가 필요 없다 — 분마다만 다시 판정한다.
    if (widget.club.freeEntry.hasFreeEntry) {
      _timer = Timer.periodic(
        const Duration(seconds: 30),
        (_) => setState(() => _now = DateTime.now()),
      );
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final club = widget.club;
    final policy = club.freeEntry;
    final feeText = _feeLabel(club.entryFeeMin, club.entryFeeMax);

    final feeLine = Row(
      children: [
        Text('입장료 ', style: RenewGlass.body(lineHeight: 20)),
        Flexible(
          child: Text(
            feeText,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: RenewGlass.body(
              color: RenewGlass.t1,
              lineHeight: 20,
              weight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );

    if (!policy.hasFreeEntry) return feeLine;

    final status = policy.statusAt(_now);
    final openNow = club.operatingHours.dayAt(_now).isOpenAt(_now);
    final live = status.isFreeNow && openNow;
    final window = status.active ?? status.next;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Flexible(child: feeLine),
            SizedBox(width: 8.w),
            _FreePill(live: live, label: _pillLabel(policy, status, live)),
          ],
        ),
        if (window != null || policy.isAlways) ...[
          SizedBox(height: 4.h),
          Text(
            _subLine(club, policy, window),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: RenewGlass.caption(lineHeight: 17),
          ),
        ],
      ],
    );
  }

  String _pillLabel(FreeEntryPolicy policy, FreeEntryStatus status, bool live) {
    if (live) return '지금 무료';
    if (policy.isAlways) return '상시 무료';
    final next = status.nextStartsAt;
    return next == null ? '무료입장' : '${_hhmm(next)} 무료';
  }

  String _subLine(
    ClubModel club,
    FreeEntryPolicy policy,
    FreeEntryWindow? window,
  ) {
    if (policy.isAlways) return '영업 시간 내내 무료입장';
    final range = window?.rangeLabel ?? '';
    final normal = club.entryFeeMin > 0
        ? ' · 이후 ${formatThousands(club.entryFeeMin)}원부터'
        : '';
    return '$range 무료$normal';
  }
}

/// 라임 pill — 지금 무료면 채움, 아니면 아웃라인.
class _FreePill extends StatelessWidget {
  final bool live;
  final String label;

  const _FreePill({required this.live, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 9.w, vertical: 3.h),
      decoration: BoxDecoration(
        color: live
            ? VybeColors.mainLime500
            : VybeColors.mainLime500.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(999.r),
        border: live
            ? null
            : Border.all(color: VybeColors.mainLime500.withValues(alpha: 0.28)),
      ),
      child: Text(
        label,
        style: RenewGlass.caption(
          color: live ? RenewGlass.ink : VybeColors.mainLime500,
          size: 11,
          lineHeight: 14,
          weight: live ? FontWeight.w700 : FontWeight.w600,
        ),
      ),
    );
  }
}

/// 맥박치는 점 (디자인 `vfPulse` 1.4s).
class _PulseDot extends StatefulWidget {
  final double size;

  const _PulseDot({this.size = 6});

  @override
  State<_PulseDot> createState() => _PulseDotState();
}

class _PulseDotState extends State<_PulseDot>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1400),
  )..repeat(reverse: true);

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: Tween<double>(begin: 1, end: 0.35).animate(_c),
      child: ScaleTransition(
        scale: Tween<double>(begin: 1, end: 0.8).animate(_c),
        child: Container(
          width: widget.size.r,
          height: widget.size.r,
          decoration: const BoxDecoration(
            color: VybeColors.mainLime500,
            shape: BoxShape.circle,
          ),
        ),
      ),
    );
  }
}

// ============================================================================
// 포맷터
// ============================================================================

const _kWeekdayLabels = ['월', '화', '수', '목', '금', '토', '일'];

String _weekdayLabel(int weekday) => _kWeekdayLabels[(weekday - 1) % 7];

String _hhmm(DateTime t) =>
    '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';

bool _isSameDay(DateTime a, DateTime b) =>
    a.year == b.year && a.month == b.month && a.day == b.day;

/// 요금 칸 라벨 — 0원이면 '무료', 상한이 다르면 `10,000원~`.
String _feeLabel(int fee, int feeMax) {
  if (fee <= 0) return '무료';
  return feeMax > fee
      ? '${formatThousands(fee)}원~'
      : '${formatThousands(fee)}원';
}

/// 도형이 그리는 회차가 언제인지 — `오늘 · 목요일`.
String _sessionLabel(DateTime sessionStart, DateTime now) {
  final today = DateTime(now.year, now.month, now.day);
  final start = DateTime(
    sessionStart.year,
    sessionStart.month,
    sessionStart.day,
  );
  final days = start.difference(today).inDays;
  final weekday = '${_weekdayLabel(sessionStart.weekday)}요일';

  if (days == 0) return '오늘 · $weekday';
  if (days == 1) return '내일 · $weekday';
  if (days == -1) return '어제 · $weekday';
  return '${sessionStart.month}월 ${sessionStart.day}일 · $weekday';
}

/// 남은 시간 표기 — 하루 이상이면 `2일 3시간`, 한 시간 이상이면 `1시간 05분`,
/// 그 안쪽은 `07:42` 처럼 초까지 센다 (디자인 VF_LEFT).
String formatFreeCountdown(Duration left) {
  if (left.inDays >= 1) return '${left.inDays}일 ${left.inHours % 24}시간';
  if (left.inHours >= 1) {
    return '${left.inHours}시간 ${(left.inMinutes % 60).toString().padLeft(2, '0')}분';
  }
  return '${left.inMinutes.toString().padLeft(2, '0')}:'
      '${(left.inSeconds % 60).toString().padLeft(2, '0')}';
}
