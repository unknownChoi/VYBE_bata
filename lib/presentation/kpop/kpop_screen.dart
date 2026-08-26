import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vybe/presentation/common/widgets/vybe_aurora.dart';
import 'package:vybe/presentation/common/widgets/vybe_glass_header.dart';
import 'package:vybe/presentation/kpop/widgets/kpop_hero.dart';

/// K-POP 장르 페이지.
///
/// 지금은 **헤더(인트로 히어로)만** 있다 — 본문(클럽 목록 등)은 디자인이 나오면
/// 히어로 아래에 붙인다. (EDM 화면과 같은 구조)
class KpopScreen extends StatelessWidget {
  const KpopScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // 플로팅 바텀 nav(MainScaffold) 가림 방지용 하단 여백.
    final bottomPad = MediaQuery.paddingOf(context).bottom + 90.h;

    return Scaffold(
      backgroundColor: kVybeInk,
      // SizedBox.expand로 Stack을 화면 전체로 강제 → 백드롭이 상태바 영역까지 채워진다.
      body: SizedBox.expand(
        child: Stack(
          children: [
            // 배경 — 공용 리뉴얼 오로라 기본색(다른 카테고리 페이지와 동일).
            const Positioned.fill(
              child: IgnorePointer(child: VybeAurora()),
            ),
            Positioned.fill(
              child: ListView(
                // 히어로가 상태바 뒤까지 채우므로 top 패딩을 두지 않는다.
                padding: EdgeInsets.only(bottom: bottomPad),
                // ⚠ 튕김(오버스크롤) 금지 — 히어로가 상태바 뒤까지 올라가 있어서
                // 위로 당기면 이미지 위에 배경이 드러난다.
                physics: const ClampingScrollPhysics(),
                children: const [KpopHero()],
              ),
            ),
            // 상단 투명 헤더 오버레이 (뒤로가기 · 공유).
            const Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: VybeGlassHeader(),
            ),
          ],
        ),
      ),
    );
  }
}
