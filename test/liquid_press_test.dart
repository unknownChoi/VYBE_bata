import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vybe/presentation/common/widgets/vybe_liquid_press.dart';

/// 리퀴드 버튼 누름 반응 (디자인 kakao_liquid_press.html).
void main() {
  Future<void> pumpButton(
    WidgetTester tester, {
    required VoidCallback? onTap,
    ValueChanged<bool>? onPressChanged,
  }) {
    return tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: VybeLiquidPress(
              onTap: onTap,
              borderRadius: BorderRadius.circular(12),
              onPressChanged: onPressChanged,
              child: const SizedBox(width: 200, height: 56),
            ),
          ),
        ),
      ),
    );
  }

  /// 바깥(버튼 전체) 확대 — 렌즈 쪽 AnimatedScale보다 트리에서 앞선다.
  double outerScale(WidgetTester tester) =>
      tester.widgetList<AnimatedScale>(find.byType(AnimatedScale)).first.scale;

  testWidgets('톡 눌러도 눌린 모습이 최소 160ms 유지된다', (tester) async {
    var taps = 0;
    await pumpButton(tester, onTap: () => taps++);

    expect(outerScale(tester), 1.0);

    // 손가락이 닿았다 바로 떨어지는 짧은 탭.
    await tester.tap(find.byType(VybeLiquidPress));
    await tester.pump();
    expect(outerScale(tester), 1.045, reason: '뗐어도 아직 눌린 상태여야 한다');
    expect(taps, 0, reason: '동작은 눌린 모습을 다 보여준 뒤에 실행된다');

    await tester.pump(const Duration(milliseconds: 200));
    expect(outerScale(tester), 1.0);
    expect(taps, 1);

    // 렌즈가 퍼지며 사라지는 300ms 뒤 정리까지 흘려보낸다.
    await tester.pumpAndSettle();
  });

  testWidgets('길게 눌렀다 떼면 곧바로 되돌아온다', (tester) async {
    var taps = 0;
    await pumpButton(tester, onTap: () => taps++);

    final gesture = await tester.startGesture(
      tester.getCenter(find.byType(VybeLiquidPress)),
    );
    await tester.pump(const Duration(milliseconds: 500));
    expect(outerScale(tester), 1.045);

    await gesture.up();
    await tester.pump();
    expect(outerScale(tester), 1.0, reason: '이미 최소 시간을 넘겼으니 기다리지 않는다');
    expect(taps, 1);

    await tester.pumpAndSettle();
  });

  testWidgets('누름 상태를 호출측에 알려준다', (tester) async {
    final log = <bool>[];
    await pumpButton(tester, onTap: () {}, onPressChanged: log.add);

    await tester.tap(find.byType(VybeLiquidPress));
    await tester.pump();
    expect(log, [true]);

    await tester.pump(const Duration(milliseconds: 200));
    expect(log, [true, false]);
    await tester.pumpAndSettle();
  });

  testWidgets('onTap이 null이면 눌러도 반응하지 않는다', (tester) async {
    final log = <bool>[];
    await pumpButton(tester, onTap: null, onPressChanged: log.add);

    final gesture = await tester.startGesture(
      tester.getCenter(find.byType(VybeLiquidPress)),
    );
    await tester.pump();

    expect(outerScale(tester), 1.0);
    expect(log, isEmpty);

    await gesture.up();
    await tester.pumpAndSettle();
  });
}
