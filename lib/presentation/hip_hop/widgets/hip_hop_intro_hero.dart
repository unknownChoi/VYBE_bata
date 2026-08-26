import 'package:flutter/material.dart';
import 'package:vybe/presentation/common/widgets/vybe_image_hero.dart';

// 힙합 인트로 히어로 — 배지·헤드라인·안내 문구가 이미지에 들어 있다.
// (예전 오늘 공연 히어로 캐러셀 `HipHopHeroCarousel` 자리)

/// 조립·정렬 규칙은 [VybeImageHero] 참고. 여기는 이 화면의 이미지와 치수만 든다.
///
/// ⚠ 이 화면 상단바는 뒤로가기 **한 개(44)** 뿐이라 [VybeImageHero.headerHeight]를
///   52가 아닌 44로 넘긴다 — 그래야 배지가 버튼 아래 20 간격에 놓인다.
class HipHopIntroHero extends StatelessWidget {
  const HipHopIntroHero({super.key});

  @override
  Widget build(BuildContext context) {
    return const VybeImageHero(
      topAsset: 'assets/images/hip_hop/hip_hop_hero_top.jpg',
      heroAsset: 'assets/images/hip_hop/hip_hop_hero.jpg',
      bandAsset: 'assets/images/hip_hop/hip_hop_update_band.png',
      // 원본 786 × 956 을 198px 지점에서 잘라 본체(758).
      // 필러는 그 위 198px + 합성 60px = 258px.
      heroAspect: 786 / 758,
      bandAspect: 786 / 144,
      badgeTopPx: 32,
      headerHeight: 44,
    );
  }
}
