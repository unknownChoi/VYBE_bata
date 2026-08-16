import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vybe/presentation/common/splash_destination.dart';
import 'package:vybe/presentation/common/splash_gate.dart';
import 'package:vybe/presentation/common/widgets/vybe_splash.dart';

/// 스플래시 게이트 — 최소 노출 시간 + 다음 화면 준비를 **둘 다** 채워야 넘어간다.
///
/// 스플래시엔 무한 반복(조명 스윙) 애니메이션이 있어 [WidgetTester.pumpAndSettle]
/// 은 타임아웃 난다 — 시간을 명시해서 pump 한다.
void main() {
  const minDuration = Duration(milliseconds: 200);

  /// 퇴장(로고 이동)이 완전히 끝나기까지. `_kExitDuration` 보다 넉넉히.
  const afterExit = Duration(milliseconds: 900);

  Future<void> pumpGate(
    WidgetTester tester, {
    SplashDestination destination = SplashDestination.home,
  }) {
    return tester.pumpWidget(
      ProviderScope(
        overrides: [
          splashDestinationProvider.overrideWithValue(destination),
        ],
        child: ScreenUtilInit(
          designSize: const Size(393, 852),
          builder: (context, child) => MaterialApp(home: child),
          child: const SplashGate(
            minDuration: minDuration,
            child: Scaffold(body: Text('앱 본문')),
          ),
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

  testWidgets('최소 노출 시간이 지나면 퇴장하며 child로 넘어간다', (tester) async {
    await pumpGate(tester);

    await tester.pump(minDuration);
    // 퇴장 중 — 로고가 날아갈 자리(상단 바)가 이미 그려져 있어야 하므로 둘 다 트리에 있다.
    await tester.pump(const Duration(milliseconds: 100));
    expect(find.text('앱 본문'), findsOneWidget);
    expect(find.byType(VybeSplash), findsOneWidget);

    // 퇴장이 끝나면 스플래시는 트리에서 빠진다.
    await tester.pump(afterExit);
    expect(find.text('앱 본문'), findsOneWidget);
    expect(find.byType(VybeSplash), findsNothing);
  });

  testWidgets('다음 화면이 아직 안 정해졌으면 최소 시간이 지나도 넘어가지 않는다', (tester) async {
    await pumpGate(tester, destination: SplashDestination.pending);

    await tester.pump(minDuration);
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.byType(VybeSplash), findsOneWidget);
    expect(find.text('앱 본문'), findsNothing);
  });

  testWidgets('홈으로 갈 때만 로고 착지 자리를 넘긴다', (tester) async {
    await pumpGate(tester);
    await tester.pump(minDuration);
    await tester.pump(const Duration(milliseconds: 16));

    final splash = tester.widget<VybeSplash>(find.byType(VybeSplash));
    expect(splash.logoLanding, isNotNull);
    // 좌상단 상단 바 자리 — 화면 중앙이 아니다.
    expect(splash.logoLanding!.left, lessThan(60));

    await tester.pump(afterExit);
  });

  testWidgets('홈이 아니면 로고 착지 자리가 없다', (tester) async {
    await pumpGate(tester, destination: SplashDestination.other);
    await tester.pump(minDuration);
    await tester.pump(const Duration(milliseconds: 16));

    final splash = tester.widget<VybeSplash>(find.byType(VybeSplash));
    expect(splash.logoLanding, isNull);

    await tester.pump(afterExit);
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
