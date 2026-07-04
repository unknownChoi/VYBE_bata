import 'package:flutter/material.dart';

/// 장르/큐레이션 페이지 공용 상단 백드롭.
/// 세로 base 그라데이션(3색) 위에 좌상단·우상단 accent radial 2겹을 얹는다.
/// hip_hop·service_drinks·free_entry가 색/높이만 달리해 재사용.
class VybeGenreBackdrop extends StatelessWidget {
  /// base 세로 그라데이션 색(위→아래, 3색).
  final List<Color> baseColors;

  /// base 그라데이션 중간 stop (기본 0.38).
  final double midStop;

  /// accent radial 높이(px, 디자인 기준값 그대로).
  final double glowHeight;

  /// 좌상단 accent 색.
  final Color accent1;

  /// 우상단 accent 색.
  final Color accent2;

  const VybeGenreBackdrop({
    super.key,
    required this.baseColors,
    required this.accent1,
    required this.accent2,
    this.midStop = 0.38,
    this.glowHeight = 420,
  });

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: baseColors,
          stops: [0.0, midStop, 1.0],
        ),
      ),
      child: Stack(
        children: [
          _glow(const Alignment(-0.85, -1), 1.3, accent1),
          _glow(const Alignment(1, -0.9), 1.2, accent2),
        ],
      ),
    );
  }

  Widget _glow(Alignment center, double radius, Color color) => Positioned(
    top: 0,
    left: 0,
    right: 0,
    height: glowHeight,
    child: DecoratedBox(
      decoration: BoxDecoration(
        gradient: RadialGradient(
          center: center,
          radius: radius,
          colors: [color, const Color(0x00000000)],
          stops: const [0.0, 0.62],
        ),
      ),
    ),
  );
}
