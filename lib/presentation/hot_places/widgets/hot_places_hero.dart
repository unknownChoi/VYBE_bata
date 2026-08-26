import 'package:flutter/material.dart';
import 'package:vybe/presentation/common/widgets/vybe_image_hero.dart';

// 핫플레이스 인트로 히어로 — 배지·헤드라인·안내 문구가 이미지에 들어 있다.
// (예전 HotPlacesIntro 위젯 자리. 문구를 바꾸려면 이미지를 갈아 끼운다)

/// 조립·정렬 규칙은 [VybeImageHero] 참고. 여기는 이 화면의 이미지와 치수만 든다.
///
/// ⚠ 지역 칩을 바꿔도 헤드라인은 안 바뀐다 — 예전 `HotPlacesIntro`는
///   '지금 강남에서 가장 뜨거운…'처럼 지역명을 넣었는데 이미지라 고정 문구다.
class HotPlacesHero extends StatelessWidget {
  const HotPlacesHero({super.key});

  @override
  Widget build(BuildContext context) {
    return const VybeImageHero(
      topAsset: 'assets/images/hot_places/hot_places_hero_top.jpg',
      heroAsset: 'assets/images/hot_places/hot_places_hero.jpg',
      bandAsset: 'assets/images/hot_places/hot_places_update_band.png',
      // 원본 786 × 956 을 196px 지점에서 잘라 본체(760).
      // 필러는 그 위 196px + 합성 60px = 256px (아래 ⚠ 참고).
      heroAspect: 786 / 760,
      bandAspect: 786 / 144,
      badgeTopPx: 32,
    );
  }
}
