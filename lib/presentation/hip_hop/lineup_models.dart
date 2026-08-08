import 'package:flutter/material.dart';
import 'package:vybe/core/navigation/swipe_back_page_route.dart';
import 'package:vybe/data/models/club_model.dart';
import 'package:vybe/data/models/performance_model.dart';
import 'package:vybe/presentation/clubs/club_detail_screen.dart';
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
  final List<String> genres;
  final List<Color> bg;
  const LineupItem({
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
LineupItem lineupItemFrom(PerformanceModel p, ClubModel? club) => LineupItem(
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
int lineupToMinutes(String t) {
  final parts = t.split(':');
  var h = int.parse(parts[0]);
  final m = int.parse(parts[1]);
  if (h < 6) h += 24;
  return h * 60 + m;
}

// 현재 시각 → 분(밤 영업 연속성 동일 규칙).
int lineupNowMinutes() {
  final now = DateTime.now();
  var h = now.hour;
  if (h < 6) h += 24;
  return h * 60 + now.minute;
}

enum LineupStatus { past, now, up }

// 시작 후 60분 지나면 past, 시작~60분은 now, 이전은 up.
LineupStatus lineupStatusOf(String t, int nowMin) {
  final m = lineupToMinutes(t);
  if (m <= nowMin - 60) return LineupStatus.past;
  if (m <= nowMin) return LineupStatus.now;
  return LineupStatus.up;
}

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
  Navigator.of(context).push(
    SwipeBackPageRoute(builder: (_) => ClubDetailScreen(clubId: clubId)),
  );
}
