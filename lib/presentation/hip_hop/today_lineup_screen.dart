import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vybe/core/navigation/swipe_back_page_route.dart';
import 'package:vybe/data/models/club_model.dart';
import 'package:vybe/data/models/performance_model.dart';
import 'package:vybe/design_system/colors.dart';
import 'package:vybe/design_system/typography.dart';
import 'package:vybe/presentation/clubs/club_detail_screen.dart';
import 'package:vybe/presentation/common/widgets/vybe_glass_button.dart';
import 'package:vybe/presentation/common/widgets/vybe_skeleton.dart';
import 'package:vybe/presentation/hip_hop/hip_hop_gradients.dart';
import 'package:vybe/presentation/hip_hop/viewmodels/hip_hop_viewmodel.dart';

// 오늘의 라인업 — 힙합 페이지 '오늘의 공연 아티스트' 전체 보기.
// claude.ai/design today_lineup.html 디자인 기반. 수치는 디자인(393 기준) 값 그대로.
// 데이터: hipHopViewModelProvider(오늘 performances + 힙합 클럽) 실연동.

// hip-hop accent (gold)
const Color _hip = Color(0xFFF5B82E);
const Color _onHip = Color(0xFF2A1E04);
const Color _bg = Color(0xFF0D0A0C);
// DJ 타입 텍스트 (다크 위 가독 보라)
const Color _djText = Color(0xFFB79CFF);

// 라인업 표시 모델.
class _LineupItem {
  final String id;
  final String clubId; // 상세 페이지 이동용
  final String dj;
  final String club;
  final String area;
  final String time; // "HH:mm"
  final bool isDj; // true=DJ(disc), false=래퍼(mic)
  final List<String> genres;
  final List<Color> bg;
  const _LineupItem({
    required this.id,
    required this.clubId,
    required this.dj,
    required this.club,
    required this.area,
    required this.time,
    required this.isDj,
    required this.genres,
    required this.bg,
  });
}

// 오늘 공연(performance) + 클럽 → 라인업 표시 모델.
// genres = 클럽 세부 장르(genreStyles) 조인, bg = clubId 해시 그라데이션.
_LineupItem _fromPerf(PerformanceModel p, ClubModel? club) => _LineupItem(
  id: p.performanceId,
  clubId: p.clubId,
  dj: p.artistName,
  club: p.clubName,
  area: p.clubArea,
  time: p.hhmm,
  isDj: p.isDj,
  genres: (club?.genreStyles ?? const []).take(2).toList(),
  bg: hipGradFor(p.clubId),
);

// "HH:mm" → 분. 새벽(06시 미만)은 +24h 취급 (밤 영업 연속성).
int _toMin(String t) {
  final parts = t.split(':');
  var h = int.parse(parts[0]);
  final m = int.parse(parts[1]);
  if (h < 6) h += 24;
  return h * 60 + m;
}

// 현재 시각 → 분(밤 영업 연속성 동일 규칙).
int _nowMin() {
  final now = DateTime.now();
  var h = now.hour;
  if (h < 6) h += 24;
  return h * 60 + now.minute;
}

enum _Status { past, now, up }

// 시작 후 60분 지나면 past, 시작~60분은 now, 이전은 up.
_Status _statusOf(String t, int nowMin) {
  final m = _toMin(t);
  if (m <= nowMin - 60) return _Status.past;
  if (m <= nowMin) return _Status.now;
  return _Status.up;
}

// 타입(래퍼/DJ) 뱃지 메타.
class _TypeMeta {
  final String label;
  final Color color;
  final Color bg;
  final IconData icon;
  const _TypeMeta(this.label, this.color, this.bg, this.icon);
}

_TypeMeta _metaOf(bool isDj) => isDj
    ? const _TypeMeta('DJ', _djText, Color(0x387731FE), Icons.album_outlined)
    : const _TypeMeta('래퍼', _hip, Color(0x29F5B82E), Icons.mic_none_rounded);

// 클럽 상세 페이지 이동. clubId 없으면 무시.
void _openClub(BuildContext context, String clubId) {
  if (clubId.isEmpty) return;
  Navigator.of(context).push(
    SwipeBackPageRoute(builder: (_) => ClubDetailScreen(clubId: clubId)),
  );
}

class TodayLineupScreen extends ConsumerStatefulWidget {
  const TodayLineupScreen({super.key});

  @override
  ConsumerState<TodayLineupScreen> createState() => _TodayLineupScreenState();
}

class _TodayLineupScreenState extends ConsumerState<TodayLineupScreen> {
  String _type = 'all'; // all | rapper | dj

  @override
  Widget build(BuildContext context) {
    final bottomPad = MediaQuery.of(context).padding.bottom + 90.h;

    final async = ref.watch(hipHopViewModelProvider);
    final data = async.asData?.value;
    final loading = async.isLoading && data == null;

    // 오늘 공연(startAt 오름차순) → 클럽 조인 → 표시 모델.
    final clubById = {
      for (final c in data?.clubs ?? const <ClubModel>[]) c.clubId: c,
    };
    final lineup = [
      for (final p in data?.performances ?? const <PerformanceModel>[])
        _fromPerf(p, clubById[p.clubId]),
    ];

    final nowMin = _nowMin();

    final counts = {
      'all': lineup.length,
      'rapper': lineup.where((l) => !l.isDj).length,
      'dj': lineup.where((l) => l.isDj).length,
    };
    final list = _type == 'all'
        ? lineup
        : lineup.where((l) => (_type == 'dj') == l.isDj).toList();
    _LineupItem? nowItem;
    for (final l in lineup) {
      if (_statusOf(l.time, nowMin) == _Status.now) {
        nowItem = l;
        break;
      }
    }
    _LineupItem? nextUp;
    for (final l in list) {
      if (_statusOf(l.time, nowMin) == _Status.up) {
        nextUp = l;
        break;
      }
    }

    return Scaffold(
      backgroundColor: _bg,
      body: Stack(
        children: [
          // 상단 골드/보라 백드롭 그라데이션
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: 560.h,
            child: const IgnorePointer(child: HipBackdrop()),
          ),
          SafeArea(
        bottom: false,
        child: Column(
        children: [
          Expanded(
            child: ListView(
              padding: EdgeInsets.only(top: 44.h, bottom: bottomPad),
              children: loading
                  // 로딩 중: 전체 레이아웃(인트로·배너·필터·타임라인)을 shimmer로.
                  // 실제 데이터 위젯을 빈 값(0팀·배너없음)으로 렌더하지 않도록 분기.
                  ? const [_LineupSkeleton()]
                  : [
                      _IntroMeta(total: lineup.length),
                      if (nowItem != null) _NowBanner(item: nowItem),
                      SizedBox(height: 12.h),
                      _TypeFilter(
                        active: _type,
                        counts: counts,
                        onChange: (t) => setState(() => _type = t),
                      ),
                      // 타임라인
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16.w),
                        child: Column(
                          children: [
                            for (var i = 0; i < list.length; i++)
                              _TimelineRow(
                                item: list[i],
                                nowMin: nowMin,
                                isFirst: i == 0,
                                isLast: i == list.length - 1,
                                isNext: list[i].id == nextUp?.id,
                              ),
                          ],
                        ),
                      ),
                      if (list.isEmpty)
                        Padding(
                          padding: EdgeInsets.symmetric(
                              vertical: 50.h, horizontal: 24.w),
                          child: Text(
                            lineup.isEmpty
                                ? '오늘 예정된 공연이 없어요'
                                : '해당하는 공연이 없어요',
                            textAlign: TextAlign.center,
                            style: VybeTypography.body4
                                .copyWith(color: VybeColors.gray500),
                          ),
                        ),
                      // footer note
                      Padding(
                        padding: EdgeInsets.fromLTRB(24.w, 10.h, 24.w, 40.h),
                        child: Text(
                          '라인업은 당일 사정에 따라 변경될 수 있어요',
                          textAlign: TextAlign.center,
                          style: VybeTypography.caption.copyWith(
                            fontSize: 11.sp,
                            height: 16 / 11,
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
          // 리퀴드 글래스 뒤로가기 버튼 (오버레이)
          Positioned(
            top: MediaQuery.of(context).padding.top + 4.h,
            left: 8.w,
            child: VybeGlassButton(
              onTap: () => Navigator.of(context).maybePop(),
            ),
          ),
        ],
      ),
    );
  }
}

// ── 인트로 메타 (날짜 · 지역 / N팀) ──
class _IntroMeta extends StatelessWidget {
  final int total;
  const _IntroMeta({required this.total});

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
                  color: _hip,
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
class _NowBanner extends StatelessWidget {
  final _LineupItem item;
  const _NowBanner({required this.item});

  @override
  Widget build(BuildContext context) {
    final meta = _metaOf(item.isDj);
    return GestureDetector(
      onTap: () => _openClub(context, item.clubId),
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
        border: Border.all(color: _hip, width: 1.5),
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
              border: Border.all(color: _hip, width: 2),
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
                    const _RippleDot(size: 7, color: _hip),
                    SizedBox(width: 6.w),
                    Text(
                      '지금 공연 중',
                      style: VybeTypography.caption.copyWith(
                        fontSize: 11.sp,
                        height: 12 / 11,
                        fontWeight: FontWeight.w800,
                        color: _hip,
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
          Icon(Icons.chevron_right_rounded, size: 18.r, color: _hip),
        ],
      ),
      ),
    );
  }
}

// ── 타입 필터 (전체/래퍼/DJ + 시간순) ──
class _TypeFilter extends StatelessWidget {
  final String active;
  final Map<String, int> counts;
  final ValueChanged<String> onChange;
  const _TypeFilter({
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

  Widget _chip(String key, String label) {
    final sel = key == active;
    return GestureDetector(
      onTap: () => onChange(key),
      child: Container(
        height: 34.h,
        padding: EdgeInsets.symmetric(horizontal: 14.w),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: sel ? _hip : VybeColors.gray900,
          borderRadius: BorderRadius.circular(999.r),
          border: sel ? null : Border.all(color: VybeColors.gray800),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: VybeTypography.button2.copyWith(
                fontWeight: sel ? FontWeight.w700 : FontWeight.w500,
                color: sel ? _onHip : VybeColors.gray300,
              ),
            ),
            SizedBox(width: 5.w),
            Text(
              '${counts[key]}',
              style: VybeTypography.caption.copyWith(
                fontSize: 11.sp,
                height: 12 / 11,
                fontWeight: FontWeight.w700,
                color: sel ? _onHip : VybeColors.gray500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── 타임라인 행 ──
class _TimelineRow extends StatelessWidget {
  final _LineupItem item;
  final int nowMin;
  final bool isFirst;
  final bool isLast;
  final bool isNext;
  const _TimelineRow({
    required this.item,
    required this.nowMin,
    required this.isFirst,
    required this.isLast,
    required this.isNext,
  });

  @override
  Widget build(BuildContext context) {
    final st = _statusOf(item.time, nowMin);
    final meta = _metaOf(item.isDj);
    final minsLeft = _toMin(item.time) - nowMin;

    final timeColor = switch (st) {
      _Status.now => _hip,
      _Status.past => VybeColors.gray600,
      _Status.up => VybeColors.gray300,
    };

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 시간
          SizedBox(
            width: 46.w,
            child: Padding(
              padding: EdgeInsets.only(top: 20.h, right: 4.w),
              child: Text(
                item.time,
                textAlign: TextAlign.right,
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
          // 레일 (세로선 + 점)
          SizedBox(
            width: 24.w,
            child: Stack(
              children: [
                if (!isFirst)
                  Positioned(
                    left: 11.w,
                    top: 0,
                    height: 20.h,
                    child: Container(width: 2.w, color: VybeColors.gray800),
                  ),
                if (!isLast)
                  Positioned(
                    left: 11.w,
                    top: 32.h,
                    bottom: 0,
                    child: Container(width: 2.w, color: VybeColors.gray800),
                  ),
                Positioned(
                  left: 6.w,
                  top: 18.h,
                  child: st == _Status.now
                      ? const _RippleDot(size: 12, color: _hip, pulseDot: false)
                      : Container(
                          width: 12.r,
                          height: 12.r,
                          decoration: BoxDecoration(
                            color: st == _Status.past ? VybeColors.gray700 : _bg,
                            shape: BoxShape.circle,
                            border: st == _Status.up
                                ? Border.all(color: VybeColors.gray600, width: 2)
                                : null,
                          ),
                        ),
                ),
              ],
            ),
          ),
          // 카드
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: 14.h),
              child: Opacity(
                opacity: st == _Status.past ? 0.5 : 1,
                child: GestureDetector(
                onTap: () => _openClub(context, item.clubId),
                behavior: HitTestBehavior.opaque,
                child: Container(
                  padding: EdgeInsets.all(12.r),
                  decoration: st == _Status.now
                      ? BoxDecoration(
                          color: const Color(0x14F5B82E),
                          borderRadius: BorderRadius.circular(16.r),
                          border: Border.all(color: _hip, width: 1.5),
                          boxShadow: const [
                            BoxShadow(
                              color: Color(0x21F5B82E),
                              blurRadius: 24,
                              offset: Offset(0, 6),
                            ),
                          ],
                        )
                      : BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.045),
                          borderRadius: BorderRadius.circular(16.r),
                          border: Border.all(color: VybeColors.gray800),
                        ),
                  child: Row(
                    children: [
                      // 아바타
                      Container(
                        width: 46.r,
                        height: 46.r,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: item.bg,
                          ),
                          shape: BoxShape.circle,
                          border: st == _Status.now
                              ? Border.all(color: _hip, width: 2)
                              : Border.all(color: Colors.white.withValues(alpha: 0.14)),
                        ),
                        child: Icon(meta.icon, size: 20.r, color: Colors.white.withValues(alpha: 0.9)),
                      ),
                      SizedBox(width: 12.w),
                      // 정보
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Flexible(
                                  child: Text(
                                    item.dj,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontFamily: 'Pretendard',
                                      fontSize: 17.sp,
                                      height: 19 / 17,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.white,
                                      letterSpacing: 17 * -0.025,
                                    ),
                                  ),
                                ),
                                SizedBox(width: 7.w),
                                // 타입 뱃지
                                Container(
                                  padding: EdgeInsets.symmetric(horizontal: 7.w, vertical: 2.h),
                                  decoration: BoxDecoration(
                                    color: meta.bg,
                                    borderRadius: BorderRadius.circular(6.r),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(meta.icon, size: 10.r, color: meta.color),
                                      SizedBox(width: 3.w),
                                      Text(
                                        meta.label,
                                        style: VybeTypography.caption.copyWith(
                                          fontSize: 10.sp,
                                          height: 11 / 10,
                                          fontWeight: FontWeight.w700,
                                          color: meta.color,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                if (st == _Status.now) ...[
                                  SizedBox(width: 7.w),
                                  Container(
                                    padding: EdgeInsets.symmetric(horizontal: 7.w, vertical: 2.h),
                                    decoration: BoxDecoration(
                                      color: _hip,
                                      borderRadius: BorderRadius.circular(6.r),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const _PulseDot(size: 5, color: _onHip),
                                        SizedBox(width: 4.w),
                                        Text(
                                          'LIVE',
                                          style: VybeTypography.caption.copyWith(
                                            fontSize: 10.sp,
                                            height: 11 / 10,
                                            fontWeight: FontWeight.w800,
                                            color: _onHip,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ],
                            ),
                            SizedBox(height: 6.h),
                            Row(
                              children: [
                                Icon(Icons.place_rounded, size: 11.r, color: VybeColors.gray400),
                                SizedBox(width: 5.w),
                                Flexible(
                                  child: Text(
                                    '${item.club} · ${item.area}',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: VybeTypography.caption.copyWith(
                                      height: 13 / 12,
                                      fontWeight: FontWeight.w600,
                                      color: VybeColors.gray400,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 8.h),
                            Wrap(
                              spacing: 5.w,
                              runSpacing: 5.h,
                              crossAxisAlignment: WrapCrossAlignment.center,
                              children: [
                                for (final g in item.genres)
                                  _tagChip('#$g', VybeColors.gray300,
                                      Colors.white.withValues(alpha: 0.09),
                                      weight: FontWeight.w600),
                                if (isNext)
                                  _tagChip('곧 시작 · $minsLeft분 후', _hip,
                                      const Color(0x24F5B82E),
                                      weight: FontWeight.w700),
                                if (st == _Status.past)
                                  _tagChip('공연 종료', VybeColors.gray500,
                                      Colors.white.withValues(alpha: 0.06),
                                      weight: FontWeight.w700),
                              ],
                            ),
                          ],
                        ),
                      ),
                      Icon(
                        Icons.chevron_right_rounded,
                        size: 16.r,
                        color: st == _Status.now ? _hip : VybeColors.gray600,
                      ),
                    ],
                  ),
                ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _tagChip(String text, Color fg, Color bg, {required FontWeight weight}) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 7.w, vertical: 1.h),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(6.r),
      ),
      child: Text(
        text,
        style: VybeTypography.caption.copyWith(
          fontSize: 10.sp,
          height: 13 / 10,
          fontWeight: weight,
          color: fg,
        ),
      ),
    );
  }
}

// ── 로딩 스켈레톤 (디자인 today_lineup LineupSkeleton 기반) ──
// 인트로 메타 · 지금 공연 배너 · 타입 필터 · 타임라인 5행을 전부 shimmer로.
// 실제 레이아웃과 동일 구조라 로드 완료 시 자리 이동(레이아웃 점프)이 적다.
class _LineupSkeleton extends StatelessWidget {
  const _LineupSkeleton();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 인트로 메타
        Padding(
          padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 12.h),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  VybeSkel(width: 130.w, height: 24.h, radius: 8),
                  SizedBox(height: 8.h),
                  VybeSkel(width: 180.w, height: 13.h),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  VybeSkel(width: 44.w, height: 20.h, radius: 6),
                  SizedBox(height: 8.h),
                  VybeSkel(width: 52.w, height: 12.h),
                ],
              ),
            ],
          ),
        ),
        // 지금 공연 배너
        Container(
          margin: EdgeInsets.fromLTRB(16.w, 4.h, 16.w, 6.h),
          padding: EdgeInsets.all(14.r),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18.r),
            border: Border.all(color: VybeColors.gray800),
          ),
          child: Row(
            children: [
              VybeSkel(width: 54.r, height: 54.r, radius: 99),
              SizedBox(width: 13.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    VybeSkel(width: 90.w, height: 12.h),
                    SizedBox(height: 9.h),
                    VybeSkel(width: 150.w, height: 20.h, radius: 6),
                    SizedBox(height: 9.h),
                    VybeSkel(width: 120.w, height: 12.h),
                  ],
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 12.h),
        // 타입 필터
        Padding(
          padding: EdgeInsets.only(left: 16.w, right: 16.w, bottom: 14.h),
          child: Row(
            children: [
              VybeSkel(width: 60.w, height: 34.h, radius: 999),
              SizedBox(width: 8.w),
              VybeSkel(width: 64.w, height: 34.h, radius: 999),
              SizedBox(width: 8.w),
              VybeSkel(width: 54.w, height: 34.h, radius: 999),
              const Spacer(),
              VybeSkel(width: 56.w, height: 14.h),
            ],
          ),
        ),
        // 타임라인 5행
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          child: Column(
            children: [
              for (var i = 0; i < 5; i++)
                _TimelineRowSkeleton(isFirst: i == 0, isLast: i == 4),
            ],
          ),
        ),
      ],
    );
  }
}

// ── 타임라인 행 스켈레톤 (레일 구조 유지 + 카드 shimmer) ──
class _TimelineRowSkeleton extends StatelessWidget {
  final bool isFirst;
  final bool isLast;
  const _TimelineRowSkeleton({required this.isFirst, required this.isLast});

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 시간
          SizedBox(
            width: 46.w,
            child: Padding(
              padding: EdgeInsets.only(top: 20.h, right: 4.w),
              child: Align(
                alignment: Alignment.centerRight,
                child: VybeSkel(width: 34.w, height: 13.h),
              ),
            ),
          ),
          // 레일 (세로선 + 정적 점)
          SizedBox(
            width: 24.w,
            child: Stack(
              children: [
                if (!isFirst)
                  Positioned(
                    left: 11.w,
                    top: 0,
                    height: 20.h,
                    child: Container(width: 2.w, color: VybeColors.gray800),
                  ),
                if (!isLast)
                  Positioned(
                    left: 11.w,
                    top: 32.h,
                    bottom: 0,
                    child: Container(width: 2.w, color: VybeColors.gray800),
                  ),
                Positioned(
                  left: 6.w,
                  top: 18.h,
                  child: Container(
                    width: 12.r,
                    height: 12.r,
                    decoration: const BoxDecoration(
                      color: VybeColors.gray700,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ],
            ),
          ),
          // 카드
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: 14.h),
              child: Container(
                padding: EdgeInsets.all(12.r),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.03),
                  borderRadius: BorderRadius.circular(16.r),
                  border: Border.all(color: VybeColors.gray800),
                ),
                child: Row(
                  children: [
                    VybeSkel(width: 46.r, height: 46.r, radius: 99),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          FractionallySizedBox(
                            widthFactor: 0.46,
                            child: VybeSkel(height: 16.h),
                          ),
                          SizedBox(height: 8.h),
                          FractionallySizedBox(
                            widthFactor: 0.62,
                            child: VybeSkel(height: 12.h),
                          ),
                          SizedBox(height: 8.h),
                          Row(
                            children: [
                              VybeSkel(width: 44.w, height: 16.h),
                              SizedBox(width: 5.w),
                              VybeSkel(width: 38.w, height: 16.h),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── 펄스 점 (opacity 깜빡임) ──
class _PulseDot extends StatefulWidget {
  final double size;
  final Color color;
  const _PulseDot({required this.size, required this.color});

  @override
  State<_PulseDot> createState() => _PulseDotState();
}

class _PulseDotState extends State<_PulseDot>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1300),
  )..repeat(reverse: true);

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: Tween(begin: 1.0, end: 0.35)
          .animate(CurvedAnimation(parent: _c, curve: Curves.easeInOut)),
      child: Container(
        width: widget.size.r,
        height: widget.size.r,
        decoration: BoxDecoration(color: widget.color, shape: BoxShape.circle),
      ),
    );
  }
}

// ── 파형 점 — 점에서 링이 바깥으로 퍼지며 사라짐 ──
// 디자인 ring keyframes: scale(1)→scale(2.8), opacity 0.75→0.12(70%)→0, 1.6s ease-out 무한.
// pulseDot=true면 중앙 점도 opacity 펄스(배너), false면 고정 점(타임라인).
class _RippleDot extends StatefulWidget {
  final double size;
  final Color color;
  final bool pulseDot;
  const _RippleDot({
    required this.size,
    required this.color,
    this.pulseDot = true,
  });

  @override
  State<_RippleDot> createState() => _RippleDotState();
}

class _RippleDotState extends State<_RippleDot>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1600),
  )..repeat();

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  // 디자인 ring 곡선: 0%→70% 구간 0.75→0.12, 70%→100% 구간 0.12→0.
  double _ringOpacity(double t) => t < 0.7
      ? 0.75 - (0.75 - 0.12) * (t / 0.7)
      : 0.12 * (1 - (t - 0.7) / 0.3);

  @override
  Widget build(BuildContext context) {
    final size = widget.size.r;
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.center,
        children: [
          // 퍼지는 링.
          AnimatedBuilder(
            animation: _c,
            builder: (_, __) {
              final t = Curves.easeOut.transform(_c.value);
              final scale = 1 + t * 1.8; // scale(1) → scale(2.8)
              return Opacity(
                opacity: _ringOpacity(t).clamp(0.0, 1.0),
                child: Container(
                  width: size * scale,
                  height: size * scale,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: widget.color, width: 1.5),
                  ),
                ),
              );
            },
          ),
          // 중앙 점.
          if (widget.pulseDot)
            _PulseDot(size: widget.size, color: widget.color)
          else
            // 링 방출 주기에 맞춰 점이 부풀었다 가라앉는 강조 (scale 1 → 1.25 → 1).
            AnimatedBuilder(
              animation: _c,
              builder: (_, __) => Transform.scale(
                scale: 1 + 0.25 * math.sin(math.pi * _c.value),
                child: Container(
                  width: size,
                  height: size,
                  decoration: BoxDecoration(
                    color: widget.color,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
