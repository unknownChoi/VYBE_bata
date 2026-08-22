import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vybe/presentation/nearby/widgets/nearby_map_markers.dart';
import 'package:vybe/presentation/nearby/widgets/nearby_rec_pin.dart';

/// 지도 마커는 `NOverlayImage.fromWidget`이 **고정 크기 캔버스**로 이미지화한다.
/// 캔버스보다 커지면 그냥 잘린 PNG가 지도에 박히고 화면엔 아무 경고도 안 뜬다
/// (오버플로 줄무늬는 마커에서 안 보인다) — 그래서 여기서 크기를 지킨다.
void main() {
  Future<void> pumpPin(
    WidgetTester tester, {
    required bool selected,
    required bool isRecommended,
  }) async {
    // 기준 기기(iPhone 15)로 맞춘다 — 기본 테스트 화면(800x600)은 가로가 넓고
    // 세로가 짧아 .sp(가로 비)만 커지고 .h(세로 비)는 줄어 실제와 다르게 넘친다.
    tester.view.physicalSize = const Size(393, 852);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      ScreenUtilInit(
        designSize: const Size(393, 852),
        builder: (_, _) => Directionality(
          textDirection: TextDirection.ltr,
          child: Center(
            child: NearbyPin(
              label: '어썸레드',
              selected: selected,
              rating: 4.76,
              reviewCount: 13,
              isOpen: true,
              isRecommended: isRecommended,
            ),
          ),
        ),
      ),
    );
  }

  for (final selected in [false, true]) {
    for (final rec in [false, true]) {
      testWidgets(
        '마커가 캔버스 안에 들어간다 (selected=$selected, rec=$rec)',
        (tester) async {
          await pumpPin(tester, selected: selected, isRecommended: rec);
          expect(tester.takeException(), isNull);

          // 내용은 캔버스 아래쪽에 붙고 남는 공간은 위로 생긴다. 넘치면
          // 예외 없이 조용히 위가 잘리므로(Transform.scale 안이라 경고도 없다)
          // 이름표 윗변이 캔버스 안에 있는지를 실측한다.
          final canvasTop = tester.getTopLeft(find.byType(NearbyPin)).dy;
          final labelTop = tester
              .getTopLeft(
                find
                    .descendant(
                      of: find.byType(NearbyPin),
                      matching: find.byType(Container),
                    )
                    .first,
              )
              .dy;
          expect(
            labelTop,
            greaterThanOrEqualTo(canvasTop),
            reason: '이름표+핀 높이가 NearbyPin.canvasHeight를 넘어 위가 잘린다',
          );
        },
      );
    }
  }

  testWidgets('VYBE 추천 클럽만 왕관 핀을 쓴다', (tester) async {
    await pumpPin(tester, selected: false, isRecommended: true);
    expect(find.byType(NearbyRecPin), findsOneWidget);

    await pumpPin(tester, selected: false, isRecommended: false);
    expect(find.byType(NearbyRecPin), findsNothing);
  });

  testWidgets('추천 핀은 선택돼도 왕관을 유지한다', (tester) async {
    await pumpPin(tester, selected: true, isRecommended: true);
    final pin = tester.widget<NearbyRecPin>(find.byType(NearbyRecPin));
    expect(pin.selected, isTrue);
  });
}
