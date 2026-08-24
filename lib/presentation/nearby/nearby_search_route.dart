import 'package:flutter/material.dart';
import 'package:vybe/presentation/search/search_screen.dart';

/// 주변 탭 → 검색 화면 전환 (페이드 인·아웃).
///
/// 지도 모드로 열기 때문에 검색 제출이 화면 이동이 아니라 [onMapResult] 콜백으로
/// 돌아온다 — 결과를 지도에 핀으로 찍는 건 부른 쪽(`NearbyScreen`)의 몫이다.
Future<void> openNearbySearch(
  BuildContext context, {
  required ValueChanged<String> onMapResult,
}) {
  return Navigator.of(context).push(
    PageRouteBuilder<void>(
      transitionDuration: const Duration(milliseconds: 280),
      reverseTransitionDuration: const Duration(milliseconds: 240),
      pageBuilder: (_, __, ___) =>
          SearchScreen(showBackButton: true, onMapResult: onMapResult),
      transitionsBuilder: (_, anim, __, child) => FadeTransition(
        opacity: CurvedAnimation(
          parent: anim,
          curve: Curves.easeOutCubic,
          reverseCurve: Curves.easeInCubic,
        ),
        child: child,
      ),
    ),
  );
}
