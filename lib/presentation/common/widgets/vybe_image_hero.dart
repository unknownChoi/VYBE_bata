import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// 상태바 뒤까지 올라가는 전체폭 인트로 이미지 + 바로 아래 안내 띠.
///
/// 전용 페이지(VYBE 추천 · 핫플레이스)의 인트로가 문구까지 그려진 이미지 한 장이라
/// 위젯으로 조립하지 않고 통째로 깐다. 조각은 위에서부터 셋 —
/// ① [topAsset]  : 사진 바로 위 천장. **위쪽을 잘라 쓴다**(높이 가변)
/// ② [heroAsset] : 배지·헤드라인이 들어 있는 본체
/// ③ [bandAsset] : 하단 안내 띠
///
/// ⚠ **필러(①)가 있는 이유** — 사진 하나만 깔면 배지 위치가 화면 폭에만 비례해서,
///   상태바가 얕은 기기(SE, safe-area 20)에선 배지가 헤더 버튼에서 60pt 넘게
///   떨어지고 깊은 기기(17 Pro, 62)에선 붙어 버린다. 필러 높이로 그 차이를
///   흡수해 **어느 기기에서나 버튼 아래 [gapBelowHeader]** 로 고정한다.
/// ⚠ 필러는 `cover` + 아래 정렬이라 **넘치는 위쪽을 잘라낸다**. `fill`로 늘리면
///   천장이 눌려 아래 사진과 이어지지 않는다. 그래서 필러 원본은 어느 기기에서든
///   모자라지 않을 만큼 넉넉해야 한다(모자라면 확대되며 좌우가 잘린다).
/// ⚠ 좌우 패딩 0 · `BoxFit.fitWidth` — `cover`를 쓰면 이미지 안의 카피가 잘린다.
/// ⚠ 본체 높이는 `AspectRatio`로 **미리 확정**한다. 디코드 뒤에 높이가 정해지면
///   목록이 한 번 튀면서 스크롤 위치가 흔들린다.
/// ⚠ 세 장 사이에 간격을 두지 않는다(디자인상 붙어 있는 한 덩어리).
class VybeImageHero extends StatelessWidget {
  /// 사진 위를 채우는 조각. 원본 세로가 길수록 안전하다(위에서 잘라 쓰므로).
  final String topAsset;

  /// 배지·헤드라인이 든 본체.
  final String heroAsset;

  /// 본체 바로 아래 붙는 안내 띠.
  final String bandAsset;

  /// 본체·띠의 원본 가로/세로 비. 이미지를 교체하면 같이 고칠 것.
  final double heroAspect;
  final double bandAspect;

  /// 본체 안에서 배지가 시작하는 y (원본 px). 이 값 기준으로 필러 높이를 잰다.
  final double badgeTopPx;

  /// 원본 이미지 가로 픽셀 — px ↔ 논리 px 환산 기준.
  final double sourceWidthPx;

  /// 글래스 헤더(뒤로가기·공유) 높이 — `VybeGlassHeader`와 같은 값이어야 한다.
  final double headerHeight;

  /// 헤더 버튼 아래부터 배지까지 띄울 간격.
  final double gapBelowHeader;

  const VybeImageHero({
    super.key,
    required this.topAsset,
    required this.heroAsset,
    required this.bandAsset,
    required this.heroAspect,
    required this.bandAspect,
    required this.badgeTopPx,
    this.sourceWidthPx = 786,
    this.headerHeight = 52,
    this.gapBelowHeader = 20,
  });

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final scale = width / sourceWidthPx; // 원본 px → 논리 px
    final fillerHeight = MediaQuery.paddingOf(context).top +
        headerHeight.h +
        gapBelowHeader.h -
        badgeTopPx * scale;

    return Column(
      children: [
        if (fillerHeight > 0)
          SizedBox(
            width: double.infinity,
            height: fillerHeight,
            child: Image.asset(
              topAsset,
              fit: BoxFit.cover,
              alignment: Alignment.bottomCenter,
            ),
          ),
        AspectRatio(
          aspectRatio: heroAspect,
          child: Image.asset(heroAsset, fit: BoxFit.fitWidth),
        ),
        AspectRatio(
          aspectRatio: bandAspect,
          child: Image.asset(bandAsset, fit: BoxFit.fitWidth),
        ),
      ],
    );
  }
}
