import 'package:flutter/material.dart';
import 'package:vybe/design_system/colors.dart';
import 'package:vybe/presentation/common/widgets/vybe_aurora.dart';

// 힙합 페이지 공용 — 썸네일/포스터/아바타 배경 fallback 그라데이션.
// clubId 해시로 일관 배정 → 같은 클럽은 항상 같은 색.
const hipFallbackGradients = <List<Color>>[
  [Color(0xFF2B1655), VybeColors.mainPurple500, Color(0xFFF5B82E)],
  [Color(0xFFFB5607), Color(0xFFFFBE0B)],
  [Color(0xFF2A1A3E), VybeColors.mainPurple500],
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

// 150deg 그라데이션 근사 (디자인 색/순서 유지, 각도만 근사).
LinearGradient hipHopSlideGradient(List<Color> colors) => LinearGradient(
  begin: const Alignment(-0.5, -0.87),
  end: const Alignment(0.5, 0.87),
  colors: colors,
);

// 힙합 페이지 배경 — 공용 [VybeAurora]에 골드/보라만 얹은 것.
// Stack 최하단 Positioned.fill에 IgnorePointer로 배치.
class HipBackdrop extends StatelessWidget {
  const HipBackdrop({super.key});
  @override
  Widget build(BuildContext context) {
    return const VybeAurora(
      accent1: Color(0xFFF5B82E), // 좌상단 골드
      accent2: VybeColors.mainPurple500, // 우상단 보라
      ink: Color(0xFF0F0B0C), // 기존 세로 그라데이션 중간색을 단색 잉크로
    );
  }
}
