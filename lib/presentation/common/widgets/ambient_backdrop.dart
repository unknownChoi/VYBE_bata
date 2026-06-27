import 'package:flutter/material.dart';

/// 앰비언트 클럽 조명 백드롭 — 보라/라임 글로우 그라데이션 배경.
/// 홈·찜 등 메인 탭 화면 공통 배경.
class AmbientBackdrop extends StatelessWidget {
  const AmbientBackdrop({super.key});

  @override
  Widget build(BuildContext context) {
    return const DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF120F1A), Color(0xFF101013), Color(0xFF0E0D12)],
          stops: [0.0, 0.34, 1.0],
        ),
      ),
      child: Stack(
        children: [
          // 좌상단 보라 글로우
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: 420,
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment(-0.9, -1),
                  radius: 1.4,
                  colors: [Color(0x8A7731FE), Color(0x00000000)],
                  stops: [0.0, 0.78],
                ),
              ),
            ),
          ),
          // 우상단 라임 글로우
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: 420,
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment(1, -0.9),
                  radius: 1.4,
                  colors: [Color(0x4DB5FF60), Color(0x00000000)],
                  stops: [0.0, 0.8],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
