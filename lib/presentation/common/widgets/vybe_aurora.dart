import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:vybe/design_system/colors.dart';

/// 오로라 배경의 바닥색(디자인 `VA_LAYERS` 마지막 레이어).
/// [VybeColors.background] 보다 살짝 어두운 잉크 — 글로우가 더 떠 보인다.
const Color kVybeInk = Color(0xFF0E0D12);

/// 오로라 세기. 디자인 `VAurora({ variant })` 와 같은 이름.
enum VybeAuroraVariant {
  /// 좌상단 · 우상단 · 우하단 3겹. 콘텐츠가 있는 일반 화면.
  club,

  /// 상단 2겹만, 알파도 낮음. 글이 주인공인 화면(공지 본문 등).
  quiet,
}

/// 앱 공용 네온 배경 — 디자인 `vybe_bg.jsx` 의 `VAurora` 이식.
///
/// 화면 전체를 채우는 전제(`inset: 0`)이므로 `Positioned.fill` 안에 둔다.
/// 부분 높이로 자르면 우하단 글로우가 화면 중간에 맺히고 아래쪽에 색 경계가 생긴다.
///
/// 색을 넘기면 페이지 아이덴티티 색으로 같은 형태를 재사용할 수 있다
/// (힙합=골드, 서비스음료=시안, 입장비무료=핑크, 핫플레이스=오렌지).
/// 디자인 원본은 보라/라임 고정이지만, 장르 페이지가 쓰던 색을 잃지 않으려고
/// 색만 파라미터로 열었다 — **레이어 배치·알파·페이드는 원본 그대로**.
///
/// 원본의 `grain`(feTurbulence 노이즈)은 이식하지 않았다. Flutter엔 대응하는
/// 필터가 없어 노이즈 이미지를 따로 굽거나 셰이더를 써야 하는데, 기본값이
/// `false`라 실제로 쓰이는 곳이 없다.
class VybeAurora extends StatelessWidget {
  final VybeAuroraVariant variant;

  /// 좌상단 글로우 색(원본: 보라). 알파는 무시하고 레이어 규격 알파를 쓴다.
  final Color accent1;

  /// 우상단 글로우 색(원본: 라임).
  final Color accent2;

  /// 우하단 글로우 색. 비우면 [accent1] — 원본이 좌상단과 같은 보라를 쓴다.
  final Color? accent3;

  /// 바닥 잉크색.
  final Color ink;

  const VybeAurora({
    super.key,
    this.variant = VybeAuroraVariant.club,
    this.accent1 = VybeColors.mainPurple500,
    this.accent2 = VybeColors.mainLime500,
    this.accent3,
    this.ink = kVybeInk,
  });

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: CustomPaint(
        // 배경은 스크롤 내용 뒤에서 그대로 있는다 → 래스터 캐시에 태운다.
        isComplex: true,
        willChange: false,
        size: Size.infinite,
        painter: _AuroraPainter(
          variant: variant,
          accent1: accent1,
          accent2: accent2,
          accent3: accent3 ?? accent1,
          ink: ink,
        ),
      ),
    );
  }
}

/// radial-gradient 한 겹. 반지름은 컨테이너 크기 대비 비율(CSS와 동일 단위).
class _Glow {
  /// CSS `at x% y%` 를 Alignment(-1~1)로 옮긴 중심.
  final Alignment center;

  /// 가로 반지름 / 컨테이너 너비 (CSS `120%` → 1.20).
  final double rx;

  /// 세로 반지름 / 컨테이너 높이 (CSS `80%` → 0.80).
  final double ry;

  /// 중심색(알파 포함).
  final Color color;

  /// `transparent` 도달 지점, 반지름 대비 비율 (CSS `72%` → 0.72).
  final double fadeStop;

  const _Glow(this.center, this.rx, this.ry, this.color, this.fadeStop);
}

class _AuroraPainter extends CustomPainter {
  final VybeAuroraVariant variant;
  final Color accent1;
  final Color accent2;
  final Color accent3;
  final Color ink;

  const _AuroraPainter({
    required this.variant,
    required this.accent1,
    required this.accent2,
    required this.accent3,
    required this.ink,
  });

  /// 디자인 `VA_LAYERS` 를 그대로 옮긴 것 — **CSS 선언 순서(먼저 쓴 것이 위)** 유지.
  List<_Glow> get _layers => switch (variant) {
    // radial(120% 80% at 0% 0%,   rgba(119,49,254,0.50), transparent 72%)
    // radial(110% 80% at 100% 2%, rgba(181,255,96,0.26), transparent 74%)
    // radial(120% 90% at 88% 100%,rgba(119,49,254,0.34), transparent 76%)
    VybeAuroraVariant.club => [
      _Glow(
        Alignment.topLeft,
        1.20,
        0.80,
        accent1.withValues(alpha: 0.50),
        0.72,
      ),
      _Glow(
        const Alignment(1, -0.96),
        1.10,
        0.80,
        accent2.withValues(alpha: 0.26),
        0.74,
      ),
      _Glow(
        const Alignment(0.76, 1),
        1.20,
        0.90,
        accent3.withValues(alpha: 0.34),
        0.76,
      ),
    ],
    // radial(120% 70% at 0% 0%,   rgba(119,49,254,0.34), transparent 70%)
    // radial(100% 70% at 100% 4%, rgba(181,255,96,0.16), transparent 72%)
    VybeAuroraVariant.quiet => [
      _Glow(
        Alignment.topLeft,
        1.20,
        0.70,
        accent1.withValues(alpha: 0.34),
        0.70,
      ),
      _Glow(
        const Alignment(1, -0.92),
        1.00,
        0.70,
        accent2.withValues(alpha: 0.16),
        0.72,
      ),
    ],
  };

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    canvas.drawRect(rect, Paint()..color = ink);
    if (size.isEmpty) return;

    // CSS 배경 레이어는 먼저 선언한 것이 위에 깔린다 → 뒤에서부터 칠한다.
    for (final glow in _layers.reversed) {
      final center = glow.center.withinRect(rect);
      final rx = glow.rx * size.width;
      final ry = glow.ry * size.height;
      if (rx <= 0 || ry <= 0) continue;

      // Skia radial은 정원(正圓)뿐이라 CSS 타원을 그대로 만들 수 없다.
      // 가로 반지름 기준 원을 그린 뒤 중심을 붙박아 둔 채 세로로 ry/rx 배 늘린다.
      //   y' = k·y + cy·(1 - k)   (k = ry / rx)
      // ⚠ Matrix4.translate 대신 setEntry — 세로 확대·이동 두 항만 손대면 되고
      //   vector_math 쪽 translate 시그니처 변화에 안 휘둘린다.
      final k = ry / rx;
      final matrix = Matrix4.identity()
        ..setEntry(1, 1, k)
        ..setEntry(1, 3, center.dy * (1 - k));

      canvas.drawRect(
        rect,
        Paint()
          ..shader = ui.Gradient.radial(
            center,
            rx,
            // 투명 끝색은 같은 색상의 알파 0 — 검정으로 빼면 중간이 탁해진다.
            [glow.color, glow.color.withValues(alpha: 0)],
            [0.0, glow.fadeStop],
            TileMode.clamp,
            matrix.storage,
          ),
      );
    }
  }

  @override
  bool shouldRepaint(_AuroraPainter oldDelegate) =>
      oldDelegate.variant != variant ||
      oldDelegate.accent1 != accent1 ||
      oldDelegate.accent2 != accent2 ||
      oldDelegate.accent3 != accent3 ||
      oldDelegate.ink != ink;
}
