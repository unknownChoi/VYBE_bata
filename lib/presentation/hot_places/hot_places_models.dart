import 'package:flutter/material.dart';
import 'package:vybe/design_system/colors.dart';

// 핫플레이스 표시 모델 · 더미 데이터.
// TODO: 추후 Firebase 실연동 (현재는 더미 데이터).

// hot-place accent (flame orange)
const Color kHotAccent = Color(0xFFFF6A2B);

// ── 혼잡도 ──
enum HotCrowd { packed, busy, lively }

class HotCrowdInfo {
  final String label;
  final Color color;
  final double pct;
  const HotCrowdInfo(this.label, this.color, this.pct);
}

const Map<HotCrowd, HotCrowdInfo> kHotCrowdMap = {
  HotCrowd.packed: HotCrowdInfo('매우 붐빔', Color(0xFFFF3B30), 95),
  HotCrowd.busy: HotCrowdInfo('붐빔', kHotAccent, 78),
  HotCrowd.lively: HotCrowdInfo('활기참', VybeColors.mainLime500, 55),
};

// ── 클럽 더미 모델 ──
class HotClub {
  final int id;
  final int rank;
  final String name;
  final String area;
  final String genre;
  final double dist; // km
  final String visitors;
  final double rating;
  final HotCrowd crowd;
  final bool up;
  final List<Color> bg;
  const HotClub({
    required this.id,
    required this.rank,
    required this.name,
    required this.area,
    required this.genre,
    required this.dist,
    required this.visitors,
    required this.rating,
    required this.crowd,
    this.up = false,
    required this.bg,
  });

  HotClub copyRank(int r) => HotClub(
        id: id,
        rank: r,
        name: name,
        area: area,
        genre: genre,
        dist: dist,
        visitors: visitors,
        rating: rating,
        crowd: crowd,
        up: up,
        bg: bg,
      );
}

const List<String> kHotAreas = ['전체', '내 주변', '홍대', '강남', '이태원', '압구정', '건대'];

const List<HotClub> kHotTopClubs = [
  HotClub(id: 1, rank: 1, name: '어썸레드', area: '홍대', genre: '힙합', dist: 0.4, visitors: '2.4천', rating: 4.76, crowd: HotCrowd.packed, bg: [Color(0xFF2B1655), VybeColors.mainPurple500, Color(0xFFFF4D8D)]),
  HotClub(id: 2, rank: 2, name: 'OCTAGON', area: '강남', genre: 'EDM', dist: 5.2, visitors: '2.1천', rating: 4.80, crowd: HotCrowd.packed, bg: [VybeColors.accentBlue500, VybeColors.mainPurple500]),
  HotClub(id: 3, rank: 3, name: '버뮤다', area: '홍대', genre: '힙합', dist: 0.7, visitors: '1.8천', rating: 4.62, crowd: HotCrowd.busy, bg: [Color(0xFF06FFA5), Color(0xFF3A86FF)]),
];

const List<HotClub> kHotListClubs = [
  HotClub(id: 4, rank: 4, name: '인클', area: '홍대', genre: '힙합', dist: 0.5, visitors: '1.6천', rating: 4.70, crowd: HotCrowd.busy, up: true, bg: [Color(0xFFFB5607), Color(0xFFFFBE0B)]),
  HotClub(id: 5, rank: 5, name: '메이드', area: '이태원', genre: 'EDM', dist: 6.1, visitors: '1.5천', rating: 4.58, crowd: HotCrowd.busy, up: true, bg: [Color(0xFFFF006E), Color(0xFF8338EC)]),
  HotClub(id: 6, rank: 6, name: '소다', area: '강남', genre: '하우스', dist: 5.4, visitors: '1.3천', rating: 4.49, crowd: HotCrowd.lively, bg: [Color(0xFF3A0CA3), Color(0xFF4361EE)]),
  HotClub(id: 7, rank: 7, name: '케이크샵', area: '이태원', genre: '테크노', dist: 6.3, visitors: '1.2천', rating: 4.66, crowd: HotCrowd.lively, up: true, bg: [Color(0xFF06FFA5), Color(0xFF1B9AAA)]),
  HotClub(id: 8, rank: 8, name: '글로우', area: '압구정', genre: 'EDM', dist: 4.2, visitors: '1.1천', rating: 4.41, crowd: HotCrowd.lively, bg: [Color(0xFFF72585), Color(0xFFB5179E)]),
  HotClub(id: 9, rank: 9, name: '하이브', area: '건대', genre: '힙합', dist: 3.1, visitors: '980', rating: 4.38, crowd: HotCrowd.lively, up: true, bg: [Color(0xFFFFBE0B), Color(0xFFFB5607)]),
  HotClub(id: 10, rank: 10, name: '벨로주', area: '홍대', genre: '재즈', dist: 0.9, visitors: '870', rating: 4.51, crowd: HotCrowd.lively, bg: [Color(0xFF2A2D34), Color(0xFF6C757D)]),
];

const double kHotNearRadiusKm = 2; // km
