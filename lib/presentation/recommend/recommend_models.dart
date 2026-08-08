import 'package:flutter/material.dart';
import 'package:vybe/design_system/colors.dart';
import 'package:vybe/domain/repositories/vybe_recommendation_repository.dart';

// VYBE 추천 표시 모델 — 큐레이션 문서 + 클럽 조인 결과 어댑터.

// ── 추천 기준 칩 ──
class RecommendCriterion {
  final String label;
  final IconData icon;
  final Color color;
  const RecommendCriterion(this.label, this.icon, this.color);
}

const kRecommendCriteria = [
  RecommendCriterion('플로어 분위기', Icons.auto_awesome, VybeColors.mainPurple500),
  RecommendCriterion('사운드 퀄리티', Icons.graphic_eq, VybeColors.accentBlue500),
  RecommendCriterion('최근 리뷰', Icons.star_rounded, VybeColors.mainLime500),
  RecommendCriterion('혼잡도', Icons.groups_rounded, Color(0xFFFF8A3D)),
  RecommendCriterion('재방문율', Icons.repeat_rounded, Color(0xFFFF4D8D)),
];

// 이미지 없을 때 쓰는 그라데이션 폴백 팔레트 (rank 순으로 배정).
const kRecommendBgPalette = <List<Color>>[
  [Color(0xFF2B1655), VybeColors.mainPurple500, Color(0xFFFF4D8D)],
  [Color(0xFF06FFA5), Color(0xFF3A86FF)],
  [VybeColors.accentBlue500, VybeColors.mainPurple500],
  [Color(0xFFFB5607), Color(0xFFFFBE0B)],
  [Color(0xFF2A2D34), Color(0xFF6C757D)],
];

// 썸네일 URL 있으면 이미지, 없거나 로드 실패면 그라데이션 폴백.
Widget recommendImageOrGradient(String url, List<Color> bg) {
  final fallback = DecoratedBox(
    decoration: BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: bg,
      ),
    ),
  );
  if (url.isEmpty) return fallback;
  return Image.network(
    url,
    fit: BoxFit.cover,
    errorBuilder: (_, __, ___) => fallback,
  );
}

// ── 추천 클럽 프레젠테이션 어댑터 ──
// VybeRecommendedClub(도메인) → 위젯이 쓰는 평면 모델로 변환.
class RecommendClub {
  final String id; // = clubId
  final int? rank; // null = featured(1위)
  final String name;
  final String area;
  final String genre;
  final double rating;
  final int reviews;
  final int match;
  final bool open;
  final String imageUrl; // 비면 bg 그라데이션 폴백
  final List<Color> bg;
  final List<String> tags;
  final String reason;
  final bool vybeRecommended; // club.isVybeRecommended — VYBE 추천 뱃지 노출

  const RecommendClub({
    required this.id,
    this.rank,
    required this.name,
    required this.area,
    required this.genre,
    required this.rating,
    this.reviews = 0,
    required this.match,
    required this.open,
    required this.imageUrl,
    required this.bg,
    required this.tags,
    required this.reason,
    required this.vybeRecommended,
  });

  factory RecommendClub.from(VybeRecommendedClub r, {required bool featured}) {
    final club = r.club;
    return RecommendClub(
      id: club.clubId,
      rank: featured ? null : r.rank,
      name: club.name,
      area: club.area,
      genre: club.genre,
      rating: club.rating,
      reviews: club.reviewCount,
      match: r.match,
      open: r.isOpen,
      imageUrl: club.thumbnailUrl,
      bg: kRecommendBgPalette[(r.rank - 1).clamp(0, kRecommendBgPalette.length - 1)],
      tags: r.tags,
      reason: r.reason,
      vybeRecommended: club.isVybeRecommended,
    );
  }
}
