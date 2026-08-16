import 'package:flutter/widgets.dart';

/// 스플래시 로고가 착지할 자리를 알려 주는 키.
///
/// 스플래시가 빠질 때 로고는 가운데에서 **다음 화면의 로고 자리**로 날아간 뒤
/// 사라진다([VybeSplash.logoLanding]). 홈 상단 바는 위치가 상수라 계산으로
/// 구하지만([kHomeGnbHPadding] 등), 로그인 화면 로고는 `Spacer` 비율에 걸려
/// 있어 계산이 안 된다 — 그래서 화면이 이 키를 로고에 달고, [SplashGate] 가
/// 퇴장 첫 프레임에 실제 좌표를 재 간다.
///
/// ⚠ 같은 GlobalKey 를 단 위젯이 트리에 둘 있으면 프레임워크가 죽는다.
/// **앱 루트로 그려지는 화면 하나만** 이 키를 달 것 (로그인 화면은 마이페이지
/// 에서 push 로도 열리므로 그쪽은 달지 않는다).
final GlobalKey splashLogoLandingKey = GlobalKey(
  debugLabel: 'splashLogoLanding',
);
