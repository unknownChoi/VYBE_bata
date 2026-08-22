import 'package:flutter/material.dart';
import 'package:vybe/design_system/colors.dart';

/// 지도 마커 핀 페인터.
/// 내 주변 지도탭과 클럽 상세 위치 지도에서 공통 사용.
class VybeMapPinPainter extends CustomPainter {
  final Color color;
  const VybeMapPinPainter({this.color = VybeColors.mainPurple700});

  /// 핀 몸통 경로 (viewBox 24 x 27을 [size]에 맞춰 늘린 것).
  ///
  /// VYBE 추천 핀은 같은 몸통에 그라데이션·글로우·왕관만 얹으므로
  /// 경로를 복사하지 않고 여기서 가져다 쓴다.
  static Path buildPath(Size size) {
    final sx = size.width / 24;
    final sy = size.height / 27;
    return Path()
      ..moveTo(12 * sx, 0)
      ..cubicTo(16.4183 * sx, 0, 20 * sx, 3.58172 * sy, 20 * sx, 8 * sy)
      ..cubicTo(19.9999 * sx, 10.5544 * sy, 18.8005 * sx, 12.8264 * sy,
          16.9365 * sx, 14.291 * sy)
      ..lineTo(13.3867 * sx, 17.7031 * sy)
      ..cubicTo(12.6127 * sx, 18.4469 * sy, 11.3894 * sx, 18.4468 * sy,
          10.6152 * sx, 17.7031 * sy)
      ..lineTo(7.06738 * sx, 14.2959 * sy)
      ..cubicTo(5.20068 * sx, 12.8314 * sy, 4.00008 * sx, 10.5566 * sy,
          4 * sx, 8 * sy)
      ..cubicTo(4 * sx, 3.58172 * sy, 7.58172 * sx, 0, 12 * sx, 0)
      ..close();
  }

  /// 핀 머리 가운데 흰 점. 몸통과 함께 그려야 핀으로 읽힌다.
  static void paintHole(Canvas canvas, Size size) {
    canvas.drawCircle(
      Offset(size.width / 2, 8 * size.height / 27),
      3 * size.width / 24,
      Paint()
        ..color = const Color(0xFFFFFFFF)
        ..style = PaintingStyle.fill,
    );
  }

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawPath(
      buildPath(size),
      Paint()
        ..color = color
        ..style = PaintingStyle.fill,
    );
    paintHole(canvas, size);
  }

  @override
  bool shouldRepaint(VybeMapPinPainter oldDelegate) =>
      oldDelegate.color != color;
}
