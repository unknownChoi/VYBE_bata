import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vybe/design_system/colors.dart';
import 'package:vybe/presentation/common/widgets/vybe_map_pin.dart';

/// VYBE 추천 클럽 지도 핀 — 왕관을 얹은 핑크→퍼플 그라데이션 핀.
///
/// 디자인 `nearby_glass_shell.jsx` `NGRecPin`.
/// 몸통 경로는 일반 핀([VybeMapPinPainter])과 같고 채움·글로우·왕관만 다르다.
///
/// **라임은 '선택된 핀' 전용 색이라 평상시엔 쓰지 않는다** — 추천 핀까지
/// 라임으로 칠하면 지도에서 지금 고른 핀이 어느 것인지 구분이 사라진다.
/// 그래서 평상시는 핑크→퍼플, 선택되면 다른 핀과 똑같이 라임으로 바뀐다.
class NearbyRecPin extends StatelessWidget {
  final bool selected;

  const NearbyRecPin({super.key, required this.selected});

  /// 핀 몸통 (일반 핀과 동일 — viewBox 24 x 27).
  static const double pinWidth = 24;
  static const double pinHeight = 27;

  /// 왕관 한 변. 디자인은 핀 폭의 0.54배.
  static const double crownSize = 13;

  /// 왕관이 핀 위로 삐져나온 높이. 디자인은 왕관의 0.62배 —
  /// 나머지 0.38배는 핀 머리에 얹혀 겹친다(붙어 있어야 '씌운' 것으로 읽힌다).
  static const double crownOverhang = crownSize * 0.62;

  /// 마커 캔버스 크기. 삐져나온 왕관까지 담아야 잘리지 않는다.
  static const double canvasWidth = pinWidth;
  static const double canvasHeight = pinHeight + crownOverhang;

  /// 추천 그라데이션 양 끝 — 핀·이름 태그가 같은 색을 써야 한 쌍으로 읽힌다.
  static const Color pink = Color(0xFFFF9EDB);
  static const Color violet = Color(0xFFBB67ED);

  /// linear-gradient(135deg, #FF9EDB, #BB67ED 55%, #7731FE)
  static const LinearGradient gradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [pink, violet, VybeColors.mainPurple500],
    stops: [0, 0.55, 1],
  );

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: canvasWidth.r,
      height: canvasHeight.r,
      child: CustomPaint(painter: NearbyRecPinPainter(selected: selected)),
    );
  }
}

/// [NearbyRecPin]의 실제 드로잉.
///
/// 위젯을 쌓지 않고 한 페인터에서 다 그리는 이유 — 마커는
/// `NOverlayImage.fromWidget`으로 한 번에 이미지화되므로 그림자·겹침을
/// 위젯 트리로 흉내 내면(Stack + BoxShadow) 캔버스 밖으로 새어 잘린다.
class NearbyRecPinPainter extends CustomPainter {
  final bool selected;

  const NearbyRecPinPainter({required this.selected});

  /// 왕관 테두리 — 핀 머리와 왕관이 같은 색일 때 서로 먹지 않게 어둡게 두른다.
  static const Color _crownStroke = Color(0xD90E0D12);

  @override
  void paint(Canvas canvas, Size size) {
    final s = size.width / NearbyRecPin.canvasWidth;
    final pinSize = Size(
      NearbyRecPin.pinWidth * s,
      NearbyRecPin.pinHeight * s,
    );

    // ---- 핀 몸통 (왕관 높이만큼 내려서 그린다) ----
    canvas.save();
    canvas.translate(0, NearbyRecPin.crownOverhang * s);
    final body = VybeMapPinPainter.buildPath(pinSize);

    // drop-shadow(0 4px 11px 컬러) + drop-shadow(0 5px 10px 검정)
    _shadow(
      canvas,
      body,
      color: selected
          ? VybeColors.mainLime500.withValues(alpha: 0.5)
          : NearbyRecPin.violet.withValues(alpha: 0.55),
      dy: 4 * s,
      blur: 11 * s,
    );
    _shadow(canvas, body, color: const Color(0x80000000), dy: 5 * s, blur: 10 * s);

    final fill = Paint()..style = PaintingStyle.fill;
    if (selected) {
      fill.color = VybeColors.mainLime500;
    } else {
      fill.shader = NearbyRecPin.gradient.createShader(Offset.zero & pinSize);
    }
    canvas.drawPath(body, fill);
    VybeMapPinPainter.paintHole(canvas, pinSize);
    canvas.restore();

    // ---- 왕관 ----
    final crown = NearbyRecPin.crownSize * s;
    canvas.save();
    canvas.translate((size.width - crown) / 2, 0);
    final path = buildCrownPath(crown);
    _shadow(canvas, path, color: const Color(0xB3000000), dy: 1 * s, blur: 2 * s);
    // paint-order: stroke — 테두리를 먼저 깔고 채움을 덮어야 선이 안쪽을 안 먹는다.
    canvas.drawPath(
      path,
      Paint()
        ..color = _crownStroke
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.9 * crown / 12
        ..strokeJoin = StrokeJoin.round,
    );
    canvas.drawPath(
      path,
      Paint()
        ..color = selected ? VybeColors.mainLime500 : NearbyRecPin.pink
        ..style = PaintingStyle.fill,
    );
    canvas.restore();
  }

  /// CSS `drop-shadow(0 {dy}px {blur}px c)` 흉내 — blur radius의 절반이 시그마.
  void _shadow(
    Canvas canvas,
    Path path, {
    required Color color,
    required double dy,
    required double blur,
  }) {
    canvas.drawPath(
      path.shift(Offset(0, dy)),
      Paint()
        ..color = color
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, blur / 2),
    );
  }

  /// 왕관 경로. `assets/icons/common/club_card/vybe_recommend.svg`(viewBox 12)와
  /// 같은 도형을 코드로 옮긴 것.
  ///
  /// ⚠ SVG를 그대로 안 쓰는 이유 — [SvgPicture]는 비동기로 로드돼
  /// `NOverlayImage.fromWidget`이 캡처하는 첫 프레임에 아직 비어 있다
  /// (= 왕관 없는 핀이 이미지로 굳는다). 도형을 바꾸려면 두 곳을 같이 고칠 것.
  static Path buildCrownPath(double side) {
    final s = side / 12;
    return Path()
      ..moveTo(2.5 * s, 10 * s)
      ..lineTo(2.5 * s, 9 * s)
      ..lineTo(9.5 * s, 9 * s)
      ..lineTo(9.5 * s, 10 * s)
      ..lineTo(2.5 * s, 10 * s)
      ..close()
      ..moveTo(2.5 * s, 8.25 * s)
      ..lineTo(1.8625 * s, 4.2375 * s)
      ..cubicTo(1.84583 * s, 4.2375 * s, 1.827 * s, 4.23967 * s, 1.806 * s, 4.244 * s)
      ..cubicTo(1.785 * s, 4.24833 * s, 1.76633 * s, 4.25033 * s, 1.75 * s, 4.25 * s)
      ..cubicTo(1.54167 * s, 4.25 * s, 1.36467 * s, 4.177 * s, 1.219 * s, 4.031 * s)
      ..cubicTo(1.07333 * s, 3.885 * s, 1.00033 * s, 3.708 * s, 1 * s, 3.5 * s)
      ..cubicTo(0.99967 * s, 3.292 * s, 1.07267 * s, 3.115 * s, 1.219 * s, 2.969 * s)
      ..cubicTo(1.36533 * s, 2.823 * s, 1.54233 * s, 2.75 * s, 1.75 * s, 2.75 * s)
      ..cubicTo(1.95767 * s, 2.75 * s, 2.13483 * s, 2.823 * s, 2.2815 * s, 2.969 * s)
      ..cubicTo(2.42817 * s, 3.115 * s, 2.501 * s, 3.292 * s, 2.5 * s, 3.5 * s)
      ..cubicTo(2.5 * s, 3.55833 * s, 2.49367 * s, 3.6125 * s, 2.481 * s, 3.6625 * s)
      ..cubicTo(2.46833 * s, 3.7125 * s, 2.45383 * s, 3.75833 * s, 2.4375 * s, 3.8 * s)
      ..lineTo(4 * s, 4.5 * s)
      ..lineTo(5.5625 * s, 2.3625 * s)
      ..cubicTo(5.47083 * s, 2.29583 * s, 5.39583 * s, 2.20833 * s, 5.3375 * s, 2.1 * s)
      ..cubicTo(5.27917 * s, 1.99167 * s, 5.25 * s, 1.875 * s, 5.25 * s, 1.75 * s)
      ..cubicTo(5.25 * s, 1.54167 * s, 5.323 * s, 1.3645 * s, 5.469 * s, 1.2185 * s)
      ..cubicTo(5.615 * s, 1.0725 * s, 5.792 * s, 0.99967 * s, 6 * s, 1 * s)
      ..cubicTo(6.208 * s, 1.00033 * s, 6.38517 * s, 1.07333 * s, 6.5315 * s, 1.219 * s)
      ..cubicTo(6.67783 * s, 1.36467 * s, 6.75067 * s, 1.54167 * s, 6.75 * s, 1.75 * s)
      ..cubicTo(6.75 * s, 1.875 * s, 6.72083 * s, 1.99167 * s, 6.6625 * s, 2.1 * s)
      ..cubicTo(6.60417 * s, 2.20833 * s, 6.52917 * s, 2.29583 * s, 6.4375 * s, 2.3625 * s)
      ..lineTo(8 * s, 4.5 * s)
      ..lineTo(9.5625 * s, 3.8 * s)
      ..cubicTo(9.54583 * s, 3.75833 * s, 9.53117 * s, 3.7125 * s, 9.5185 * s, 3.6625 * s)
      ..cubicTo(9.50583 * s, 3.6125 * s, 9.49967 * s, 3.55833 * s, 9.5 * s, 3.5 * s)
      ..cubicTo(9.5 * s, 3.29167 * s, 9.573 * s, 3.1145 * s, 9.719 * s, 2.9685 * s)
      ..cubicTo(9.865 * s, 2.8225 * s, 10.042 * s, 2.74967 * s, 10.25 * s, 2.75 * s)
      ..cubicTo(10.458 * s, 2.75033 * s, 10.6352 * s, 2.82333 * s, 10.7815 * s, 2.969 * s)
      ..cubicTo(10.9278 * s, 3.11467 * s, 11.0007 * s, 3.29167 * s, 11 * s, 3.5 * s)
      ..cubicTo(10.9993 * s, 3.70833 * s, 10.9265 * s, 3.8855 * s, 10.7815 * s, 4.0315 * s)
      ..cubicTo(10.6365 * s, 4.1775 * s, 10.4593 * s, 4.25033 * s, 10.25 * s, 4.25 * s)
      ..cubicTo(10.2333 * s, 4.25 * s, 10.2147 * s, 4.248 * s, 10.194 * s, 4.244 * s)
      ..cubicTo(10.1733 * s, 4.24 * s, 10.1545 * s, 4.23783 * s, 10.1375 * s, 4.2375 * s)
      ..lineTo(9.5 * s, 8.25 * s)
      ..lineTo(2.5 * s, 8.25 * s)
      ..close();
  }

  @override
  bool shouldRepaint(NearbyRecPinPainter oldDelegate) =>
      oldDelegate.selected != selected;
}
