import 'package:flutter/material.dart';
import 'package:vybe/presentation/common/widgets/vybe_image_hero.dart';

// VYBE 추천 인트로 히어로 — 배지·헤드라인·안내 문구가 이미지에 들어 있다.
// (예전 RecommendIntro 위젯 자리. 문구를 바꾸려면 이미지를 갈아 끼운다)

/// 조립·정렬 규칙은 [VybeImageHero] 참고. 여기는 이 화면의 이미지와 치수만 든다.
class RecommendHero extends StatelessWidget {
  const RecommendHero({super.key});

  @override
  Widget build(BuildContext context) {
    return const VybeImageHero(
      topAsset: 'assets/images/recommend/recommend_hero_top.jpg',
      heroAsset: 'assets/images/recommend/recommend_hero.jpg',
      bandAsset: 'assets/images/recommend/recommend_update_band.png',
      // 원본 786 × 1132 을 230px 지점에서 잘라 필러(230) + 본체(902).
      heroAspect: 786 / 902,
      bandAspect: 786 / 144,
      badgeTopPx: 32,
    );
  }
}
