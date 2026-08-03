import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// 리스트 카드용 유리 표면 — 라운드 클립 + 블러 + 채움/테두리(+그림자).
///
/// 디자인 notifications_glass_shell.jsx의 `NGCard`(glass / glassQuiet) 대응.
/// 알림·공지처럼 "강조 카드(색 링 + 그림자) vs 뒤로 물러난 카드(옅은 유리)"가
/// 섞인 목록이 이 껍데기를 공유한다.
///
/// 내부 여백은 호출측에서 준다 — 강조 카드의 틴트 오버레이가 여백 바깥
/// (카드 전체)까지 깔려야 하기 때문.
class VybeGlassSurface extends StatelessWidget {
  /// 물러난 카드 채움 (NG.glassQuiet) — rgba(120,120,128,0.08)
  static const Color quietFill = Color(0x14787880);

  /// 물러난 카드 테두리 — rgba(255,255,255,0.06)
  static const Color quietBorder = Color(0x0FFFFFFF);

  /// 물러난 카드 블러 — CSS blur(14px) ≈ sigma 7
  static const double quietBlur = 7;

  final Widget child;
  final Color fill;
  final Color border;
  final double blurSigma;

  /// 라운드 (CSS px, `.r` 적용).
  final double radius;

  /// 카드를 띄우는 검정 그림자 (강조 카드만).
  final bool elevated;

  const VybeGlassSurface({
    super.key,
    required this.child,
    required this.fill,
    required this.border,
    required this.blurSigma,
    this.radius = 19,
    this.elevated = false,
  });

  /// 물러난 카드(읽은 알림 · 일반 공지 · 스켈레톤) 프리셋.
  const VybeGlassSurface.quiet({
    super.key,
    required this.child,
    this.radius = 19,
  })  : fill = quietFill,
        border = quietBorder,
        blurSigma = quietBlur,
        elevated = false;

  @override
  Widget build(BuildContext context) {
    final r = BorderRadius.circular(radius.r);

    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: r,
        boxShadow: elevated
            ? [
                BoxShadow(
                  color: const Color(0x5C000000),
                  blurRadius: 30.r,
                  offset: Offset(0, 10.h),
                ),
              ]
            : null,
      ),
      child: ClipRRect(
        borderRadius: r,
        child: BackdropFilter(
          filter: ui.ImageFilter.blur(sigmaX: blurSigma, sigmaY: blurSigma),
          child: Container(
            decoration: BoxDecoration(
              color: fill,
              borderRadius: r,
              border: Border.all(color: border),
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}

/// 강조 카드 위에 깔리는 종류 색 틴트 (CSS `linear-gradient(115deg, tint, transparent 58%)`).
class GlassTintOverlay extends StatelessWidget {
  final Color tint;

  const GlassTintOverlay({super.key, required this.tint});

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: DecoratedBox(
        decoration: BoxDecoration(
          // 115deg — 좌상단에서 우하단으로 옅게 흐른다.
          gradient: LinearGradient(
            begin: const Alignment(-0.9, -0.6),
            end: const Alignment(0.6, 0.5),
            colors: [tint, tint.withValues(alpha: 0)],
            stops: const [0.0, 0.58],
          ),
        ),
      ),
    );
  }
}

/// 카드 상단 1px 하이라이트 (`inset 0 1px 0 rgba(255,255,255,.18/.08)`).
class GlassTopHighlight extends StatelessWidget {
  /// 강조 카드면 밝게, 물러난 카드면 옅게.
  final bool strong;

  const GlassTopHighlight({super.key, required this.strong});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      height: 1,
      child: ColoredBox(
        color: strong ? const Color(0x2EFFFFFF) : const Color(0x14FFFFFF),
      ),
    );
  }
}
