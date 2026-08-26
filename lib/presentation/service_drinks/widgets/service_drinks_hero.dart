import 'package:flutter/material.dart';
import 'package:vybe/presentation/common/widgets/vybe_image_hero.dart';

// 서비스 음료 인트로 히어로 — 배지·헤드라인·안내 문구가 이미지에 들어 있다.
// (예전 ServiceDrinksIntro 위젯 자리. 문구를 바꾸려면 이미지를 갈아 끼운다)

/// 조립·정렬 규칙은 [VybeImageHero] 참고. 여기는 이 화면의 이미지와 치수만 든다.
///
/// ⚠ 이미지 오른쪽 아래 **'제공 클럽 14곳'은 그림에 박힌 숫자**다 — 실데이터가
///   아니라서 클럽이 늘거나 필터를 걸어도 안 바뀐다. 실제 개수를 보여 주려면
///   이미지에서 빼고 히어로 아래에 텍스트 행으로 붙여야 한다.
class ServiceDrinksHero extends StatelessWidget {
  const ServiceDrinksHero({super.key});

  @override
  Widget build(BuildContext context) {
    return const VybeImageHero(
      topAsset: 'assets/images/service_drinks/service_drinks_hero_top.jpg',
      heroAsset: 'assets/images/service_drinks/service_drinks_hero.jpg',
      bandAsset: 'assets/images/service_drinks/service_drinks_update_band.png',
      // 원본 786 × 956 을 196px 지점에서 잘라 본체(760).
      // 필러는 그 위 196px + 합성 60px = 256px.
      heroAspect: 786 / 760,
      bandAspect: 786 / 144,
      badgeTopPx: 32,
    );
  }
}
