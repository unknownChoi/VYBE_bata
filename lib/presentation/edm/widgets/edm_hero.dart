import 'package:flutter/material.dart';
import 'package:vybe/presentation/common/widgets/vybe_image_hero.dart';

// EDM 인트로 히어로 — 배지·헤드라인·안내 문구가 이미지에 들어 있다.

/// 조립·정렬 규칙은 [VybeImageHero] 참고. 여기는 이 화면의 이미지와 치수만 든다.
class EdmHero extends StatelessWidget {
  const EdmHero({super.key});

  @override
  Widget build(BuildContext context) {
    return const VybeImageHero(
      topAsset: 'assets/images/edm/edm_hero_top.jpg',
      heroAsset: 'assets/images/edm/edm_hero.jpg',
      bandAsset: 'assets/images/edm/edm_update_band.png',
      // 원본 786 × 956 을 197px 지점에서 잘라 본체(759).
      // 필러는 그 위 197px + 합성 60px = 257px.
      heroAspect: 786 / 759,
      bandAspect: 786 / 144,
      badgeTopPx: 32,
    );
  }
}
