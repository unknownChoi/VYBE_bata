import 'package:flutter/material.dart';
import 'package:vybe/presentation/common/widgets/vybe_image_hero.dart';

// 입장비 무료 인트로 히어로 — 배지·헤드라인·안내 문구가 이미지에 들어 있다.
// (예전 FreeEntryIntro 위젯 자리. 문구를 바꾸려면 이미지를 갈아 끼운다)

/// 조립·정렬 규칙은 [VybeImageHero] 참고. 여기는 이 화면의 이미지와 치수만 든다.
///
/// ⚠ 예전 `FreeEntryIntro`가 보여 주던 **'지금 무료 n곳' · '{지역} 근처 n곳'**
///   숫자는 사라졌다 — 이미지라 실데이터를 못 싣는다. 숫자가 다시 필요하면
///   히어로 아래에 별도 행으로 붙일 것.
class FreeEntryHero extends StatelessWidget {
  const FreeEntryHero({super.key});

  @override
  Widget build(BuildContext context) {
    return const VybeImageHero(
      topAsset: 'assets/images/free_entry/free_entry_hero_top.jpg',
      heroAsset: 'assets/images/free_entry/free_entry_hero.jpg',
      bandAsset: 'assets/images/free_entry/free_entry_update_band.png',
      // 원본 786 × 956 을 196px 지점에서 잘라 본체(760).
      // 필러는 그 위 196px + 합성 60px = 256px.
      heroAspect: 786 / 760,
      bandAspect: 786 / 144,
      badgeTopPx: 32,
    );
  }
}
