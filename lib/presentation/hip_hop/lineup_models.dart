import 'package:flutter/material.dart';
import 'package:vybe/data/models/performance_model.dart';
import 'package:vybe/presentation/clubs/club_detail_route.dart';
import 'package:vybe/presentation/common/night_clock.dart';
import 'package:vybe/presentation/hip_hop/hip_hop_gradients.dart';
import 'package:vybe/presentation/hip_hop/hip_hop_style.dart';

// 오늘의 라인업 표시 모델 · 시각 계산 · 상태 판정.
// 화면(위젯)과 분리해 순수 계산만 둔다.

// DJ 타입 텍스트 (다크 위 가독 보라)
const Color kLineupDjText = Color(0xFFB79CFF);

// 라인업 표시 모델.
class LineupItem {
  final String id;
  final String clubId; // 상세 페이지 이동용
  final String dj;
  final String club;
  final String area;
  final String time; // "HH:mm"
  final bool isDj; // true=DJ(disc), false=래퍼(mic)
  final List<Color> bg;
  const LineupItem({
    required this.id,
    required this.clubId,
    required this.dj,
    required this.club,
    required this.area,
    required this.time,
    required this.isDj,
    required this.bg,
  });
}

// 오늘 공연(performance) → 라인업 표시 모델. bg = clubId 해시 그라데이션.
LineupItem lineupItemFrom(PerformanceModel p) => LineupItem(
  id: p.performanceId,
  clubId: p.clubId,
  dj: p.artistName,
  club: p.clubName,
  area: p.clubArea,
  time: p.hhmm,
  isDj: p.isDj,
  bg: hipGradFor(p.clubId),
);

// 시각 계산은 공용 [night_clock] 단일 소스에 위임한다 — 힙합/EDM 타임라인이
// 같은 공연을 다른 상태로 말하지 않게.
int lineupToMinutes(String t) => nightMinutes(t);

int lineupNowMinutes() => nightNowMinutes();

enum LineupStatus { past, now, up }

// 시작 후 60분 지나면 past, 시작~60분은 now, 이전은 up.
LineupStatus lineupStatusOf(String t, int nowMin) =>
    switch (nightSlotStatus(t, nowMin)) {
      NightSlotStatus.past => LineupStatus.past,
      NightSlotStatus.live => LineupStatus.now,
      NightSlotStatus.upcoming => LineupStatus.up,
    };

// 타입(래퍼/DJ) 뱃지 메타.
class LineupTypeMeta {
  final String label;
  final Color color;
  final Color bg;
  final IconData icon;
  const LineupTypeMeta(this.label, this.color, this.bg, this.icon);
}

LineupTypeMeta lineupTypeMetaOf(bool isDj) => isDj
    ? const LineupTypeMeta('DJ', kLineupDjText, Color(0x387731FE), Icons.album_outlined)
    : const LineupTypeMeta('래퍼', kHipAccent, Color(0x29F5B82E), Icons.mic_none_rounded);

// 클럽 상세 페이지 이동. clubId 없으면 무시.
void openLineupClub(BuildContext context, String clubId) {
  if (clubId.isEmpty) return;
  openClubDetail(context, clubId);
}
