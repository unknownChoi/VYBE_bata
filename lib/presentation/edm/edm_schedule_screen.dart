import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vybe/core/providers/location_providers.dart';
import 'package:vybe/data/models/club_model.dart';
import 'package:vybe/data/models/performance_model.dart';
import 'package:vybe/design_system/colors.dart';
import 'package:vybe/design_system/typography.dart';
import 'package:vybe/presentation/common/night_clock.dart';
import 'package:vybe/presentation/common/widgets/vybe_aurora.dart';
import 'package:vybe/presentation/edm/edm_models.dart';
import 'package:vybe/presentation/edm/viewmodels/edm_viewmodel.dart';
import 'package:vybe/presentation/edm/widgets/edm_chrome.dart';
import 'package:vybe/presentation/edm/widgets/edm_time_row.dart';

/// DJ 공연 전체 일정 — EDM 페이지 'DJ 공연 일정 > 전체보기'에서 진입.
///
/// claude.ai/design `edm_schedule.html`(edm_schedule.jsx) 기반. 수치는 디자인(393 기준) 값 그대로.
/// 데이터는 EDM 페이지와 **같은** [edmViewModelProvider] — 뒤 화면이 살아 있어
/// 캐시를 그대로 쓴다(추가 Firestore read 0).
///
/// 섹션과 다른 점은 **종료된 공연도 그린다**는 것 하나. 섹션이 앞 3줄만 보여주고
/// 나머지를 여기로 넘기므로, 여기서도 접으면 볼 방법이 없어진다.
///
/// ⚠ 디자인의 세부 장르 칩(GENRES)은 뺐다 — `clubs.genreStyles`가 2026.09.01에
/// 삭제돼 필터로 쓸 실 데이터가 없다. 되살리려면 실 조사 데이터가 먼저다.
class EdmScheduleScreen extends ConsumerStatefulWidget {
  /// EDM 페이지에서 이미 하트를 누른 것들 — 넘어오자마자 같은 상태로 보이게 한다.
  final Set<Object> saved;

  /// 부모(EDM 페이지)에도 전달 — 뒤로 갔을 때 하트가 어긋나지 않게.
  final ValueChanged<Object> onSave;

  const EdmScheduleScreen({
    super.key,
    required this.saved,
    required this.onSave,
  });

  @override
  ConsumerState<EdmScheduleScreen> createState() => _EdmScheduleScreenState();
}

class _EdmScheduleScreenState extends ConsumerState<EdmScheduleScreen> {
  // 넘어온 값으로 시작한다. 이 화면이 다시 빌드되려면 자기 상태가 필요하고
  // (pushed 라우트는 부모 setState로 다시 그려지지 않는다), 부모에도 같이 알린다.
  late final Set<Object> _saved = {...widget.saved};

  void _toggleSave(Object id) {
    setState(() {
      _saved.contains(id) ? _saved.remove(id) : _saved.add(id);
    });
    widget.onSave(id);
  }

  @override
  Widget build(BuildContext context) {
    // 플로팅 바텀 nav(MainScaffold) 가림 방지용 하단 여백.
    final bottomPad = MediaQuery.paddingOf(context).bottom + 90.h;

    final async = ref.watch(edmViewModelProvider);
    final data = async.asData?.value;
    final loading = async.isLoading && data == null;

    final perfs = data?.performances ?? const <PerformanceModel>[];
    final clubById = data?.clubById ?? const <String, ClubModel>{};

    final me = ref.watch(userLocationProvider);
    final origin = (lat: me.lat, lng: me.lng);

    // ⚠ 판정 시각은 화면당 한 번. 카드마다 DateTime.now()를 다시 읽으면
    // 같은 목록 안에서 NOW 마커와 카드 상태가 따로 논다.
    final now = DateTime.now();
    var nowMin = now.hour;
    if (nowMin < 6) nowMin += 24;
    nowMin = nowMin * 60 + now.minute;

    final all = [
      for (final p in perfs) edmSetFrom(p, clubById[p.clubId], origin: origin),
    ]..sort((a, b) => nightMinutes(a.time).compareTo(nightMinutes(b.time)));

    NightSlotStatus st(EdmSet s) => nightSlotStatus(s.time, nowMin);

    final liveVenues = all
        .where((s) => st(s) == NightSlotStatus.live)
        .map((s) => s.clubId.isEmpty ? s.id : s.clubId)
        .toSet()
        .length;

    var markerAfter = -1;
    for (var i = 0; i < all.length; i++) {
      if (nightMinutes(all[i].time) <= nowMin) markerAfter = i;
    }

    return Scaffold(
      backgroundColor: kVybeInk,
      body: SizedBox.expand(
        child: Stack(
          children: [
            const Positioned.fill(child: IgnorePointer(child: VybeAurora())),
            Positioned.fill(
              child: Column(
                children: [
                  _Header(
                    count: all.length,
                    dateLabel: edmDateLabel(now),
                    liveVenues: loading ? 0 : liveVenues,
                    loading: loading,
                  ),
                  Expanded(
                    child: ListView(
                      physics: const ClampingScrollPhysics(),
                      padding: EdgeInsets.only(bottom: bottomPad),
                      children: [
                        if (loading)
                          Padding(
                            padding: EdgeInsets.only(top: 18.h),
                            child: const EdmTimelineSkeleton(rows: 5),
                          )
                        else if (async.hasError)
                          const _Message('공연 일정을 불러오지 못했어요')
                        else if (all.isEmpty)
                          const _Message('오늘 예정된 EDM 공연이 없어요')
                        else
                          Padding(
                            padding: EdgeInsets.fromLTRB(16.w, 18.h, 16.w, 0),
                            child: Column(
                              children: [
                                for (var i = 0; i < all.length; i++) ...[
                                  EdmTimeRow(
                                    set: all[i],
                                    status: st(all[i]),
                                    nowMin: nowMin,
                                    first: i == 0,
                                    last: i == all.length - 1,
                                    saved: _saved.contains(all[i].id),
                                    onSave: () => _toggleSave(all[i].id),
                                  ),
                                  if (i == markerAfter && i < all.length - 1)
                                    EdmNowMarker(label: edmClock(now)),
                                ],
                              ],
                            ),
                          ),
                        Padding(
                          padding: EdgeInsets.fromLTRB(16.w, 10.h, 16.w, 34.h),
                          child: Text(
                            '공연 정보는 클럽 사정에 따라 변경될 수 있어요',
                            textAlign: TextAlign.center,
                            style: VybeTypography.caption.copyWith(
                              fontSize: 11.5.sp,
                              height: 14 / 11.5,
                              color: VybeColors.gray600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// 스크롤 밖 고정 머리 — 뒤로가기 줄 + '오늘 밤 공연 N개' + 진행 중 pill.
class _Header extends StatelessWidget {
  final int count;
  final String dateLabel;
  final int liveVenues;
  final bool loading;

  const _Header({
    required this.count,
    required this.dateLabel,
    required this.liveVenues,
    required this.loading,
  });

  @override
  Widget build(BuildContext context) {
    final top = MediaQuery.paddingOf(context).top;
    return ClipRect(
      child: BackdropFilter(
        filter: ui.ImageFilter.blur(sigmaX: 16, sigmaY: 16),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: kVybeInk.withValues(alpha: 0.94),
            border: const Border(bottom: BorderSide(color: VybeColors.gray900)),
          ),
          child: Padding(
            padding: EdgeInsets.only(top: top),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  height: 52.h,
                  child: Row(
                    children: [
                      SizedBox(width: 8.w),
                      // 바가 이미 불투명해 유리 원 버튼(VybeGlassButton)은 겉돈다 —
                      // 디자인대로 아이콘만. 40x40 이라 탭 타겟은 그대로 확보된다.
                      GestureDetector(
                        onTap: () => Navigator.of(context).maybePop(),
                        behavior: HitTestBehavior.opaque,
                        child: SizedBox(
                          width: 40.w,
                          height: 40.h,
                          child: Icon(
                            Icons.arrow_back_ios_new_rounded,
                            size: 20.r,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      SizedBox(width: 4.w),
                      Text(
                        'DJ 공연 일정',
                        style: TextStyle(
                          fontFamily: 'Pretendard',
                          fontSize: 17.sp,
                          height: 20 / 17,
                          letterSpacing: 17 * -0.025,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: EdgeInsets.fromLTRB(16.w, 4.h, 16.w, 14.h),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              loading ? '오늘 밤 공연' : '오늘 밤 공연 $count개',
                              style: TextStyle(
                                fontFamily: 'Pretendard',
                                fontSize: 22.sp,
                                height: 25 / 22,
                                letterSpacing: 22 * -0.02,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                            SizedBox(height: 6.h),
                            Text(
                              dateLabel,
                              style: VybeTypography.caption.copyWith(
                                height: 16 / 12,
                                color: VybeColors.gray500,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (liveVenues > 0) ...[
                        SizedBox(width: 12.w),
                        EdmLivePill(count: liveVenues),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Message extends StatelessWidget {
  final String text;
  const _Message(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 44.h, horizontal: 24.w),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: VybeTypography.body4.copyWith(color: VybeColors.gray500),
      ),
    );
  }
}
