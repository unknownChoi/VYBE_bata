import 'package:flutter/material.dart';
import 'package:vybe/core/constants/app_geo.dart';
import 'package:vybe/core/utils/geohash_utils.dart';
import 'package:vybe/data/models/club_model.dart';
import 'package:vybe/data/models/performance_model.dart';
import 'package:vybe/presentation/common/widgets/vybe_club_poster_card.dart';

// EDM 페이지 표시 모델 — Firestore 모델(ClubModel·PerformanceModel)을
// 화면이 쓰기 좋은 형태로 옮긴 어댑터. 로직 없음.
//
// 디자인(edm_renew.jsx)의 셋 카드는 종료 시각·BPM·세부 장르를 그리지만
// performances 스키마엔 그 셋이 없다. **없는 값을 지어내지 않고** 있는 것만 그린다 —
// 종료 시각 대신 시작 시각, BPM(에너지) 대신 진행 상태, 세부 장르는 뺀다.

/// EDM 포인트 색 — 브랜드 퍼플(디자인 ACC).
const Color kEdmAccent = Color(0xFF7731FE);

/// 다크 배경 위 퍼플 텍스트 (디자인 ACC_TXT).
const Color kEdmAccentText = Color(0xFFB694FF);

/// 지금 진행 중 강조 — 브랜드 라임(디자인 HOT).
const Color kEdmHot = Color(0xFFB5FF60);

/// 라임 위에 얹는 어두운 글자색 (디자인 ON_HOT).
const Color kEdmOnHot = Color(0xFF12210A);

/// 타임테이블 한 줄 — 오늘 공연 1건 + 클럽 조인 결과.
class EdmSet {
  final String id;
  final String clubId;
  final String club;
  final String area;

  /// 내 위치 기준 추정 거리(km). 클럽 조인이 안 되면 null — 그 줄은 거리 표기를 뺀다.
  final double? dist;

  final String dj;

  /// 시작 시각 'HH:mm'.
  final String time;

  const EdmSet({
    required this.id,
    required this.clubId,
    required this.club,
    required this.area,
    required this.dist,
    required this.dj,
    required this.time,
  });
}

/// 오늘 공연 + (있으면) 클럽 → 타임테이블 줄.
EdmSet edmSetFrom(
  PerformanceModel p,
  ClubModel? club, {
  ({double lat, double lng})? origin,
}) => EdmSet(
  id: p.performanceId,
  clubId: p.clubId,
  club: p.clubName,
  area: p.clubArea,
  dist: club == null ? null : edmDistanceKm(club.lat, club.lng, origin: origin),
  dj: p.artistName,
  time: p.hhmm,
);

/// ClubModel → 포스터 카드 뷰모델.
///
/// 디자인의 '주변 EDM 클럽 추천' 타일은 LIVE 뱃지를 그리지 않는다 —
/// 바로 위 타임테이블이 오늘 라인업을 이미 말하고 있어서 두 번 말하지 않는다.
VybeClubPoster edmClubFrom(ClubModel c, {({double lat, double lng})? origin}) =>
    VybeClubPoster(
      id: c.clubId,
      name: c.name,
      area: c.area,
      dist: edmDistanceKm(c.lat, c.lng, origin: origin),
      rating: c.rating,
      reviews: c.reviewCount,
      styles: c.tags.isNotEmpty ? c.tags.take(2).toList() : [c.genre],
      lineup: '',
      live: false,
      open: c.operatingHours.today.isCurrentlyOpen,
      thumbnailUrl: c.thumbnailUrl,
      bg: edmGradFor(c.clubId),
      vybe: c.isVybeRecommended,
    );

/// 내 위치 기준 거리(km) — 표시용.
/// [origin]을 안 주면 홍대 좌표 기준(위치를 못 받았을 때의 폴백, AppGeo와 동일).
double edmDistanceKm(
  double lat,
  double lng, {
  ({double lat, double lng})? origin,
}) => GeohashUtils.haversineKm(
  origin?.lat ?? AppGeo.hongdaeLat,
  origin?.lng ?? AppGeo.hongdaeLng,
  lat,
  lng,
);

// ── 포스터 배경 fallback 그라데이션 ──
// 디자인(edm_renew.jsx CLUBS[].bg)의 보라 계열 9종. clubId 해시로 일관 배정 →
// 같은 클럽은 항상 같은 색. 썸네일이 있으면 그 위에 사진이 덮인다.
const edmFallbackGradients = <List<Color>>[
  [Color(0xFF150A2E), Color(0xFF3A1580), Color(0xFF7731FE)],
  [Color(0xFF180D33), Color(0xFF4A1FA8), Color(0xFF9D6BFF)],
  [Color(0xFF120A26), Color(0xFF2F1470), Color(0xFF6B2CE0)],
  [Color(0xFF101019), Color(0xFF2A1B52), Color(0xFFB694FF)],
  [Color(0xFF17102E), Color(0xFF40208C), Color(0xFF8B4DFF)],
  [Color(0xFF1C1230), Color(0xFF55249E), Color(0xFF7731FE)],
  [Color(0xFF0F0D1C), Color(0xFF241452), Color(0xFF6329D6)],
  [Color(0xFF14102B), Color(0xFF35187A), Color(0xFF8A55FF)],
  [Color(0xFF191033), Color(0xFF4B2093), Color(0xFFA179FF)],
];

List<Color> edmGradFor(String clubId) =>
    edmFallbackGradients[clubId.hashCode.abs() % edmFallbackGradients.length];

// ── 표시 문구 ──

const _weekdayKo = ['월', '화', '수', '목', '금', '토', '일'];

/// '8월 28일 (금)' — 타임테이블 섹션 부제.
String edmDateLabel(DateTime d) =>
    '${d.month}월 ${d.day}일 (${_weekdayKo[d.weekday - 1]})';

/// 'HH:mm' — NOW 마커 라벨.
String edmClock(DateTime d) =>
    '${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';
