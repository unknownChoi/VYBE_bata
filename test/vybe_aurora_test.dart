import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vybe/design_system/colors.dart';
import 'package:vybe/presentation/common/widgets/vybe_aurora.dart';

/// 공용 오로라 배경(디자인 `vybe_bg.jsx` 의 `VAurora`) 실제 픽셀 검증.
///
/// 핵심은 **타원**이다 — CSS `radial-gradient(120% 80% at 0% 0%, …)` 는
/// 가로 1.2W · 세로 0.8H 짜리 타원인데, Flutter/Skia radial은 정원뿐이라
/// 행렬로 세로를 늘려 만든다. 그 행렬이 틀어지면 글로우가 정원으로 쪼그라들어
/// 화면 중간에서 배경이 끊긴다 — 눈으로는 놓치기 쉬워 픽셀로 잡는다.
void main() {
  const w = 393.0;
  const h = 852.0;

  /// [VybeAurora] 를 w×h로 그려 픽셀 버퍼로 돌려준다.
  Future<_Pixels> renderAurora(WidgetTester tester, Widget aurora) async {
    final key = GlobalKey();
    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: Center(
          child: RepaintBoundary(
            key: key,
            child: SizedBox(width: w, height: h, child: aurora),
          ),
        ),
      ),
    );
    await tester.pump();

    late _Pixels pixels;
    await tester.runAsync(() async {
      final boundary =
          key.currentContext!.findRenderObject()! as RenderRepaintBoundary;
      final image = await boundary.toImage();
      final data = await image.toByteData(format: ui.ImageByteFormat.rawRgba);
      pixels = _Pixels(data!.buffer.asUint8List(), image.width, image.height);
      image.dispose();
    });
    return pixels;
  }

  testWidgets('좌상단은 보라, 우상단은 라임으로 물든다', (tester) async {
    final px = await renderAurora(tester, const VybeAurora());

    final topLeft = px.at(6, 6);
    final topRight = px.at(px.width - 6, 6);

    // 좌상단 = 보라(파랑 우세), 우상단 = 라임(초록 우세).
    expect(topLeft.b, greaterThan(topLeft.g), reason: '좌상단이 보라가 아님: $topLeft');
    expect(
      topRight.g,
      greaterThan(topRight.b),
      reason: '우상단이 라임이 아님: $topRight',
    );
  });

  testWidgets('좌상단 글로우가 화면 세로 절반까지 닿는다 (정원이면 실패)', (tester) async {
    final px = await renderAurora(tester, const VybeAurora());

    // 왼쪽 변만 본다 — 이 x에서는 좌상단 글로우 말고는 닿는 레이어가 없다.
    //   타원(세로 반지름 0.8H=682px): y=0.5H 는 페이드 0.72 안쪽 → 보라가 남는다.
    //   정원(반지름 1.2W=472px)     : 같은 점이 0.90 지점 → 완전히 투명, 잉크만.
    final halfway = px.at(6, (px.height * 0.5).round());
    // 세 글로우 모두 페이드가 끝난 지점 — 사실상 잉크색.
    final ink = px.at(6, (px.height * 0.82).round());

    expect(
      halfway.b,
      greaterThan(ink.b + 8),
      reason: '세로로 늘어나지 않았다(정원으로 그려짐): 절반높이 $halfway / 잉크 $ink',
    );
  });

  testWidgets('우하단에도 보라 글로우가 있다 (club 3겹)', (tester) async {
    final px = await renderAurora(tester, const VybeAurora());

    final bottomRight = px.at(px.width - 6, px.height - 6);
    final bottomLeft = px.at(6, px.height - 6);

    expect(
      bottomRight.b,
      greaterThan(bottomLeft.b),
      reason: '우하단 글로우 없음: 우하단 $bottomRight / 좌하단 $bottomLeft',
    );
  });

  testWidgets('quiet 변형은 상단 2겹뿐 — 우하단이 잉크로 남는다', (tester) async {
    final px = await renderAurora(
      tester,
      const VybeAurora(variant: VybeAuroraVariant.quiet),
    );

    final bottomRight = px.at(px.width - 6, px.height - 6);
    expect(bottomRight.r, lessThan(30), reason: '우하단이 잉크가 아님: $bottomRight');
  });

  testWidgets('accent 색을 넘기면 그 색으로 물든다 (장르 페이지용)', (tester) async {
    final px = await renderAurora(
      tester,
      const VybeAurora(
        accent1: Color(0xFFF5B82E), // 골드
        accent2: VybeColors.mainPurple500,
      ),
    );

    final topLeft = px.at(6, 6);
    // 골드 = 빨강 > 파랑.
    expect(topLeft.r, greaterThan(topLeft.b), reason: '좌상단이 골드가 아님: $topLeft');
  });
}

/// 렌더 결과 픽셀 버퍼(rawRgba).
class _Pixels {
  final Uint8List bytes;
  final int width;
  final int height;

  const _Pixels(this.bytes, this.width, this.height);

  _Rgb at(int x, int y) {
    final i = (y * width + x) * 4;
    return _Rgb(bytes[i], bytes[i + 1], bytes[i + 2]);
  }
}

class _Rgb {
  final int r;
  final int g;
  final int b;

  const _Rgb(this.r, this.g, this.b);

  @override
  String toString() => 'rgb($r, $g, $b)';
}
