import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vybe/design_system/colors.dart';
import 'package:vybe/design_system/typography.dart';
import 'package:vybe/presentation/common/night_clock.dart';
import 'package:vybe/presentation/edm/edm_models.dart';
import 'package:vybe/presentation/edm/widgets/edm_chrome.dart';
import 'package:vybe/presentation/edm/widgets/edm_time_row.dart';

/// 또렷하게 보여줄 줄 수. 디자인(edm_renew_v1.jsx) `clear = shown.slice(0, 3)`.
const int _kClearRows = 3;

/// 그 아래 흐리게 비치는 줄 수. 디자인 `faded = shown.slice(3, 5)`.
const int _kPeekRows = 2;

/// 흐린 미리보기 칸 높이(dp). 디자인 `height: 128`.
const double _kPeekH = 128;

/// 'DJ 공연 일정' 섹션 — 오늘 EDM 공연을 시작 시각순 타임라인으로.
///
/// 디자인(edm_renew_v1.jsx `Schedule`) 기준. 앞의 [_kClearRows]줄만 또렷하게 보여주고
/// 다음 [_kPeekRows]줄은 흐리게 깔아 '더 있다'를 말한 뒤, 그 위에 **전체보기**를 얹는다.
/// 종료된 공연은 이 섹션에서 빠진다 — 전체 일정 페이지가 전부 보여준다.
class EdmTimetable extends StatelessWidget {
  final List<EdmSet> sets;
  final bool loading;

  /// 판정 기준 시각 — 화면당 한 번 읽어 목록 전체가 같은 기준을 쓰게 한다.
  final DateTime now;

  final Set<Object> saved;
  final ValueChanged<Object> onSave;

  /// 전체보기 — 공연 전체 일정 페이지로.
  final VoidCallback onSeeAll;

  const EdmTimetable({
    super.key,
    required this.sets,
    required this.loading,
    required this.now,
    required this.saved,
    required this.onSave,
    required this.onSeeAll,
  });

  int get _nowMin {
    var h = now.hour;
    if (h < 6) h += 24;
    return h * 60 + now.minute;
  }

  @override
  Widget build(BuildContext context) {
    final all = [...sets]
      ..sort((a, b) => nightMinutes(a.time).compareTo(nightMinutes(b.time)));

    final nowMin = _nowMin;
    NightSlotStatus st(EdmSet s) => nightSlotStatus(s.time, nowMin);

    // ⚠ 라벨이 '곳'이라 **클럽 수**를 센다. 진행 중인 셋 수를 그대로 쓰면
    // 한 클럽에서 두 셋이 겹칠 때 두 곳이라고 말하게 된다.
    final liveVenues = all
        .where((s) => st(s) == NightSlotStatus.live)
        .map((s) => s.clubId.isEmpty ? s.id : s.clubId)
        .toSet()
        .length;

    final left = all.where((s) => st(s) != NightSlotStatus.past).toList();
    final clear = left.take(_kClearRows).toList();
    final peek = left.skip(_kClearRows).take(_kPeekRows).toList();

    // 섹션이 못 보여준 공연 수 — 종료된 공연도 여기 들어간다.
    final hidden = all.length - clear.length;

    // NOW 마커는 '이미 시작한 마지막 셋' 아래에 놓는다.
    var markerAfter = -1;
    for (var i = 0; i < clear.length; i++) {
      if (nightMinutes(clear[i].time) <= nowMin) markerAfter = i;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        EdmSectionHead(
          title: 'DJ 공연 일정',
          sub: loading
              ? edmDateLabel(now)
              : '${edmDateLabel(now)} · 공연 ${sets.length}개',
          // 0곳이면 pill 자체를 뺀다 — 강조색으로 '0'을 말하면 눈만 끈다.
          right: !loading && liveVenues > 0
              ? EdmLivePill(count: liveVenues)
              : null,
        ),
        if (loading)
          const EdmTimelineSkeleton()
        else if (sets.isEmpty)
          const _Empty(text: '오늘 예정된 EDM 공연이 없어요')
        else ...[
          if (clear.isEmpty)
            const _Empty(text: '오늘 남은 EDM 공연이 없어요')
          else
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              child: Column(
                children: [
                  for (var i = 0; i < clear.length; i++) ...[
                    EdmTimeRow(
                      set: clear[i],
                      status: st(clear[i]),
                      nowMin: nowMin,
                      first: i == 0,
                      last: peek.isEmpty && i == clear.length - 1,
                      saved: saved.contains(clear[i].id),
                      onSave: () => onSave(clear[i].id),
                    ),
                    if (i == markerAfter &&
                        (i < clear.length - 1 || peek.isNotEmpty))
                      EdmNowMarker(label: edmClock(now)),
                  ],
                  if (peek.isNotEmpty)
                    _Peek(
                      rows: peek,
                      nowMin: nowMin,
                      statusOf: st,
                      total: all.length,
                      onTap: onSeeAll,
                    ),
                ],
              ),
            ),
          // ⚠ 미리보기 줄이 없어도 갈 길은 남겨 둔다 — 디자인은 흐린 줄 위에만
          // 전체보기를 얹지만, 밤이 깊어 남은 공연이 3개 이하가 되면 그 버튼이
          // 통째로 사라져 **종료된 공연을 다시 볼 방법이 없어진다**.
          if (peek.isEmpty && hidden > 0)
            Padding(
              padding: EdgeInsets.only(top: clear.isEmpty ? 0 : 4.h),
              child: Center(
                child: _SeeAllPill(total: all.length, onTap: onSeeAll),
              ),
            ),
        ],
      ],
    );
  }
}

/// 흐리게 비치는 다음 줄들 + 그 위에 얹은 전체보기.
///
/// ⚠ 디자인은 잉크(#101013) 그라데이션을 **덮어서** 아래를 지우지만, 이 앱 배경은
/// 평평한 잉크가 아니라 오로라라 그렇게 하면 칸 끝에 색 경계가 생긴다.
/// 같은 알파 램프를 [BlendMode.dstIn] 마스크로 뒤집어 **줄이 스스로 투명해지게** 한다.
class _Peek extends StatelessWidget {
  final List<EdmSet> rows;
  final int nowMin;
  final NightSlotStatus Function(EdmSet) statusOf;
  final int total;
  final VoidCallback onTap;

  const _Peek({
    required this.rows,
    required this.nowMin,
    required this.statusOf,
    required this.total,
    required this.onTap,
  });

  // 디자인 overlay 알파(0 / .5 / .9 / 1)를 남는 알파로 뒤집은 값.
  static const _fade = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color(0xFFFFFFFF),
      Color(0x80FFFFFF),
      Color(0x1AFFFFFF),
      Color(0x00FFFFFF),
    ],
    stops: [0, 0.34, 0.70, 0.94],
  );

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: _kPeekH.h,
      child: Stack(
        children: [
          Positioned.fill(
            // 흐린 줄은 '더 있다'는 신호일 뿐 — 탭도 스크린리더도 받지 않는다.
            child: IgnorePointer(
              child: ExcludeSemantics(
                child: ShaderMask(
                  blendMode: BlendMode.dstIn,
                  shaderCallback: _fade.createShader,
                  // ⚠ ClipRect 가 ShaderMask 안에 있어야 한다 — 마스크 밖으로
                  //   삐져나간 그림이 있으면 dstIn 합성 결과가 어긋난다.
                  child: ClipRect(
                    child: OverflowBox(
                      alignment: Alignment.topCenter,
                      minHeight: 0,
                      maxHeight: double.infinity,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          for (var i = 0; i < rows.length; i++)
                            Opacity(
                              opacity: (0.62 - i * 0.30).clamp(0.0, 1.0),
                              child: ImageFiltered(
                                imageFilter: ui.ImageFilter.blur(
                                  sigmaX: 2.4 + i * 3.6,
                                  sigmaY: 2.4 + i * 3.6,
                                ),
                                child: EdmTimeRow(
                                  set: rows[i],
                                  status: statusOf(rows[i]),
                                  nowMin: nowMin,
                                  first: false,
                                  last: i == rows.length - 1,
                                  saved: false,
                                  onSave: () {},
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          Positioned.fill(
            child: Center(
              child: _SeeAllPill(total: total, onTap: onTap),
            ),
          ),
        ],
      ),
    );
  }
}

/// `전체보기 N ›` — 공연 전체 일정 페이지로 가는 보라 pill.
class _SeeAllPill extends StatelessWidget {
  final int total;
  final VoidCallback onTap;

  const _SeeAllPill({required this.total, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        height: 38.h,
        padding: EdgeInsets.symmetric(horizontal: 18.w),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: kEdmAccent,
          borderRadius: BorderRadius.circular(99.r),
          boxShadow: [
            BoxShadow(
              color: kEdmAccent.withValues(alpha: 0.42),
              blurRadius: 20.r,
              offset: Offset(0, 6.h),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '전체보기',
              style: VybeTypography.button2.copyWith(
                fontSize: 14.sp,
                height: 16 / 14,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
            SizedBox(width: 6.w),
            Text(
              '$total',
              style: VybeTypography.caption.copyWith(
                fontSize: 12.sp,
                height: 13 / 12,
                fontWeight: FontWeight.w600,
                color: Colors.white.withValues(alpha: 0.62),
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
            ),
            SizedBox(width: 6.w),
            Icon(Icons.chevron_right_rounded, size: 15.r, color: Colors.white),
          ],
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
