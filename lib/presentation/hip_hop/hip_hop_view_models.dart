import 'package:flutter/material.dart';
import 'package:vybe/core/constants/app_geo.dart';
import 'package:vybe/core/utils/geohash_utils.dart';
import 'package:vybe/data/models/club_model.dart';
import 'package:vybe/data/models/performance_model.dart';
import 'package:vybe/presentation/hip_hop/hip_hop_gradients.dart';

// 힙합 페이지 표시 모델 — Firestore 모델(ClubModel·PerformanceModel)을
// 화면이 쓰기 좋은 형태로 옮긴 어댑터. 로직 없음.

// ── 더미 모델 ──
class HipHopHero {
  final String name;
  final String area;
  final double dist;
  final double rating;
  final String lineup;
  final String genre;
  final String time;
  final String tag;
  final List<Color> bg;
  const HipHopHero({
    required this.name,
    required this.area,
    required this.dist,
    required this.rating,
    required this.lineup,
    required this.genre,
    required this.time,
    required this.tag,
    required this.bg,
  });
}

class HipHopDj {
  final int id;
  final String clubId; // 탭 → 클럽 상세 이동용
  final String dj;
  final String club;
  final String time;
  final bool isDj; // true=DJ(disc), false=rapper(mic)
  final List<Color> bg;
  const HipHopDj({
    required this.id,
    required this.clubId,
    required this.dj,
    required this.club,
    required this.time,
    required this.isDj,
    required this.bg,
  });
}

class HipHopClub {
  final String id;
  final String name;
  final String area;
  final double dist;
  final double rating;
  final int reviews;
  final List<String> styles;
  final String lineup;
  final bool live;
  final bool open;
  final String thumbnailUrl;
  final List<Color> bg;
  final bool vybe; // isVybeRecommended — VYBE 추천 뱃지 노출
  const HipHopClub({
    required this.id,
    required this.name,
    required this.area,
    required this.dist,
    required this.rating,
    required this.reviews,
    required this.styles,
    required this.lineup,
    required this.live,
    required this.open,
    required this.thumbnailUrl,
    required this.bg,
    required this.vybe,
  });
}

// 내 위치 기준 거리(km) — 표시용.
// [origin]을 안 주면 홍대 좌표 기준 (위치를 못 받았을 때의 폴백, AppGeo와 동일).
double hipHopDistanceKm(
  double lat,
  double lng, {
  ({double lat, double lng})? origin,
}) =>
    GeohashUtils.haversineKm(
      origin?.lat ?? AppGeo.hongdaeLat,
      origin?.lng ?? AppGeo.hongdaeLng,
      lat,
      lng,
    );

// ClubModel(+오늘 헤드라이너 공연) → 포스터 카드 뷰모델.
HipHopClub hipHopClubFrom(
  ClubModel c,
  PerformanceModel? headliner, {
  ({double lat, double lng})? origin,
}) {
  return HipHopClub(
    id: c.clubId,
    name: c.name,
    area: c.area,
    dist: hipHopDistanceKm(c.lat, c.lng, origin: origin),
    rating: c.rating,
    reviews: c.reviewCount,
    // 세부 장르 스타일 칩(genreStyles), 없으면 태그/장르 fallback.
    styles: c.genreStyles.isNotEmpty
        ? c.genreStyles.take(2).toList()
        : (c.tags.isNotEmpty ? c.tags.take(2).toList() : [c.genre]),
    lineup: headliner?.artistName ?? '',
    live: headliner != null,
    open: c.operatingHours.today.isCurrentlyOpen,
    thumbnailUrl: c.thumbnailUrl,
    bg: hipGradFor(c.clubId),
    vybe: c.isVybeRecommended,
  );
}

// 오늘 공연(performance) + 클럽 → hero(배너) 슬라이드 뷰모델. (텍스트=실데이터, 배경=그라데이션)
HipHopHero hipHopHeroFrom(
  PerformanceModel p,
  ClubModel? club, {
  ({double lat, double lng})? origin,
}) {
  return HipHopHero(
    name: p.clubName,
    area: p.clubArea,
    dist: club != null
        ? hipHopDistanceKm(club.lat, club.lng, origin: origin)
        : 0,
    rating: club?.rating ?? 0,
    lineup: p.artistName,
    genre: club?.genre ?? p.genre,
    time: '오늘 ${p.hhmm} 공연',
    tag: '오늘밤 주목할 공연',
    bg: hipGradFor(p.clubId),
  );
}

// 오늘 공연 → DJ rail(아티스트) 뷰모델.
HipHopDj hipHopDjFrom(PerformanceModel p, int idx) => HipHopDj(
  id: idx,
  clubId: p.clubId,
  dj: p.artistName,
  club: p.clubName,
  time: p.hhmm,
  isDj: p.isDj,
  bg: hipGradFor(p.clubId),
);
