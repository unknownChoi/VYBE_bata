import 'package:flutter/material.dart';
import 'package:vybe/core/constants/app_geo.dart';
import 'package:vybe/core/utils/geohash_utils.dart';
import 'package:vybe/data/models/club_model.dart';
import 'package:vybe/data/models/performance_model.dart';
import 'package:vybe/presentation/common/widgets/vybe_club_poster_card.dart';
import 'package:vybe/presentation/hip_hop/hip_hop_gradients.dart';

// 힙합 페이지 표시 모델 — Firestore 모델(ClubModel·PerformanceModel)을
// 화면이 쓰기 좋은 형태로 옮긴 어댑터. 로직 없음.

// ── 더미 모델 ──
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

// 포스터 카드 뷰모델은 공용([VybeClubPoster]) — EDM 페이지가 같은 카드를 쓰면서
// 힙합 전용 클래스에서 승격했다. 힙합 코드가 부르던 이름은 그대로 둔다.
typedef HipHopClub = VybeClubPoster;

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
