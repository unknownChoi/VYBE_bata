import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vybe/presentation/common/network_gate/network_gate.dart';
import 'package:vybe/presentation/common/network_gate/viewmodels/network_status_viewmodel.dart';
import 'package:vybe/presentation/common/network_gate/widgets/network_error_screen.dart';
import 'package:vybe/presentation/common/widgets/vybe_aurora.dart';
import 'package:vybe/presentation/common/widgets/vybe_splash.dart';

/// 기기 조회 없이 상태만 고정하는 대역. [NetworkStatus.build] 를 통째로 덮어
/// connectivity 플러그인을 타지 않는다.
class _FakeNetworkStatus extends NetworkStatus {
  _FakeNetworkStatus(this.result);

  /// null이면 확인 중(끝나지 않는 Future).
  final bool? result;

  @override
  Future<bool> build() =>
      result == null ? Completer<bool>().future : Future.value(result!);
}

void main() {
  Future<void> pumpGate(WidgetTester tester, {bool? connected}) {
    return tester.pumpWidget(
      ProviderScope(
        overrides: [
          networkStatusProvider.overrideWith(() => _FakeNetworkStatus(connected)),
        ],
        child: ScreenUtilInit(
          designSize: const Size(393, 852),
          builder: (context, child) => MaterialApp(home: child),
          child: const NetworkGate(child: Scaffold(body: Text('앱 본문'))),
        ),
      ),
    );
  }

  testWidgets('연결이 없으면 네트워크 안내 화면을 그리고 앱 본문은 만들지 않는다', (tester) async {
    await pumpGate(tester, connected: false);
    await tester.pump();

    expect(find.byType(NetworkErrorScreen), findsOneWidget);
    expect(find.text('다시 시도'), findsOneWidget);
    expect(find.text('네트워크 설정 열기'), findsOneWidget);
    expect(find.text('앱 본문'), findsNothing);
  });

  testWidgets('안내 화면과 오로라 배경이 화면 폭을 가득 채운다', (tester) async {
    tester.view.physicalSize = const Size(393 * 3, 852 * 3);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);

    await pumpGate(tester, connected: false);
    await tester.pump();

    // Stack이 non-positioned 자식에게 loose 제약을 주는 탓에 예전엔 본문이
    // 글자 폭(≈272)까지 줄고 배경도 같이 줄어 화면 일부만 그려졌다.
    expect(tester.getSize(find.byType(VybeAurora).first).width, 393);
    expect(tester.getSize(find.byType(SafeArea).first).width, 393);
  });

  testWidgets('연결돼 있으면 그대로 앱 본문으로 넘긴다', (tester) async {
    await pumpGate(tester, connected: true);
    await tester.pump();

    expect(find.text('앱 본문'), findsOneWidget);
    expect(find.byType(NetworkErrorScreen), findsNothing);
  });

  testWidgets('확인 중에는 스플래시를 이어 그린다(인트로 재생 없이)', (tester) async {
    await pumpGate(tester);
    await tester.pump();

    final splash = tester.widget<VybeSplash>(find.byType(VybeSplash));
    expect(splash.playIntro, isFalse);
    expect(find.text('앱 본문'), findsNothing);
  });
}
