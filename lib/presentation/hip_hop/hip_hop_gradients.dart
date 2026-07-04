import 'package:flutter/material.dart';
import 'package:vybe/presentation/common/widgets/vybe_genre_backdrop.dart';

// 힙합 페이지 공용 — 썸네일/포스터/아바타 배경 fallback 그라데이션.
// clubId 해시로 일관 배정 → 같은 클럽은 항상 같은 색.
const hipFallbackGradients = <List<Color>>[
  [Color(0xFF2B1655), Color(0xFF7731FE), Color(0xFFF5B82E)],
  [Color(0xFFFB5607), Color(0xFFFFBE0B)],
  [Color(0xFF2A1A3E), Color(0xFF7731FE)],
  [Color(0xFF4A1E1E), Color(0xFFF72585)],
  [Color(0xFF3A0CA3), Color(0xFF4361EE)],
  [Color(0xFF3A2F0A), Color(0xFFF5B82E), Color(0xFFFB8500)],
  [Color(0xFF5A3A1A), Color(0xFFF5B82E)],
  [Color(0xFF1B3A3A), Color(0xFF2A9D8F)],
  [Color(0xFFFFBE0B), Color(0xFFFB5607)],
  [Color(0xFF2A2410), Color(0xFFB5860B)],
];

// clubId 해시 기반 일관 그라데이션.
List<Color> hipGradFor(String clubId) =>
    hipFallbackGradients[clubId.hashCode.abs() % hipFallbackGradients.length];

// 상단 골드/보라 백드롭 — 힙합 페이지 공용 배경 그라데이션.
// Stack 최하단 Positioned(height 560 등)에 IgnorePointer로 배치.
class HipBackdrop extends StatelessWidget {
  const HipBackdrop({super.key});
  @override
  Widget build(BuildContext context) {
    return const VybeGenreBackdrop(
      baseColors: [Color(0xFF1A130A), Color(0xFF0F0B0C), Color(0xFF0D0A0C)],
      midStop: 0.4,
      glowHeight: 440,
      accent1: Color(0x66F5B82E),
      accent2: Color(0x407731FE),
    );
  }
}
