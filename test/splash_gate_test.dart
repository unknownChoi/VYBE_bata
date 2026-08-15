import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vybe/presentation/common/splash_gate.dart';
import 'package:vybe/presentation/common/widgets/vybe_splash.dart';

/// 스플래시 게이트 — 인트로가 끝나기 전엔 아래 게이트(child)를 만들지 않는다.
///
/// 스플래시엔 무한 반복(글로우 호흡) 애니메이션이 있어 [WidgetTester.pumpAndSettle]
/// 은 타임아웃 난다 — 시간을 명시해서 pump 한다.
void main() {
  const minDuration = Duration(milliseconds: 200);

  Future<void> pumpGate(WidgetTester tester) {
    return tester.pumpWidget(
      ScreenUtilInit(
        designSize: const Size(393, 852),
        builder: (context, child) => MaterialApp(home: child),
        child: const SplashGate(
          minDuration: minDuration,
          child: Scaffold(body: Text('앱 본문')),
        ),
      ),
    );
  }

  testWidgets('최소 노출 시간 전에는 스플래시만 보이고 child는 만들어지지 않는다', (tester) async {
    await pumpGate(tester);

    expect(find.byType(VybeSplash), findsOneWidget);
    expect(find.text('앱 본문'), findsNothing);

    // 아직 최소 시간 이내.
    await tester.pump(const Duration(milliseconds: 150));
    expect(find.text('앱 본문'), findsNothing);
  });

  testWidgets('최소 노출 시간이 지나면 child로 교차 페이드된다', (tester) async {
    await pumpGate(tester);

    await tester.pump(minDuration);
    // 교차 페이드 중 — 둘 다 트리에 있다.
    await tester.pump(const Duration(milliseconds: 100));
    expect(find.text('앱 본문'), findsOneWidget);
    expect(find.byType(VybeSplash), findsOneWidget);

    // 전환이 끝나면 스플래시는 사라진다.
    await tester.pump(const Duration(milliseconds: 500));
    expect(find.text('앱 본문'), findsOneWidget);
    expect(find.byType(VybeSplash), findsNothing);
  });

  testWidgets('playIntro:false 스플래시는 완성 프레임에서 시작한다', (tester) async {
    await tester.pumpWidget(
      ScreenUtilInit(
        designSize: const Size(393, 852),
        builder: (context, child) => MaterialApp(home: child),
        child: const VybeSplash(playIntro: false),
      ),
    );
    await tester.pump();

    // 게이트 전환 직후에도 로고가 투명(0)에서 다시 등장하지 않아야 한다.
    final fade = tester.widget<FadeTransition>(
      find.descendant(
        of: find.byType(VybeSplash),
        matching: find.byType(FadeTransition),
      ),
    );
    expect(fade.opacity.value, 1.0);
  });
}
