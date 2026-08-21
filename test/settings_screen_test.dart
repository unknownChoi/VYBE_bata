import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vybe/core/storage/local_prefs.dart';
import 'package:vybe/presentation/common/version_gate/viewmodels/version_check_viewmodel.dart';
import 'package:vybe/presentation/my_page/settings_screen.dart';
import 'package:vybe/presentation/my_page/viewmodels/settings_viewmodel.dart';
import 'package:vybe/presentation/my_page/widgets/my_page_common.dart';

/// 설정 화면 스모크 — 디자인 my_renew.html `MRSettingsScreen` 이식 확인.
///
/// 기기·서버를 타는 provider(캐시 용량·버전 조회)는 값을 고정해 화면만 본다.

class _FakeCache extends CacheManager {
  @override
  Future<int> build() async => 50528000; // 48.2MB
}

class _FakeVersion extends VersionCheck {
  @override
  Future<VersionCheckResult> build() async =>
      const VersionCheckResult.pass(currentVersion: '1.0.0');
}

Future<void> pumpSettings(WidgetTester tester) async {
  SharedPreferences.setMockInitialValues({});
  final prefs = await SharedPreferences.getInstance();

  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        localPrefsProvider.overrideWith((ref) async => LocalPrefs(prefs)),
        cacheManagerProvider.overrideWith(_FakeCache.new),
        versionCheckProvider.overrideWith(_FakeVersion.new),
      ],
      child: ScreenUtilInit(
        designSize: const Size(393, 852),
        builder: (context, child) => MaterialApp(home: child),
        child: const SettingsScreen(),
      ),
    ),
  );
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 100));
}

void main() {
  testWidgets('4개 그룹과 각 행이 오버플로 없이 그려진다', (tester) async {
    tester.view.physicalSize = const Size(393 * 3, 852 * 3);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);

    await pumpSettings(tester);

    for (final title in ['알림', '일반', '데이터', '계정']) {
      expect(find.text(title), findsOneWidget, reason: '$title 그룹 헤더');
    }
    expect(find.text('푸시 알림'), findsOneWidget);
    expect(find.text('자동 로그인 유지'), findsOneWidget);
    expect(find.text('테마'), findsOneWidget);
    expect(find.text('다크'), findsOneWidget);
    expect(find.text('한국어'), findsOneWidget);
    expect(find.text('48.2MB 사용 중'), findsOneWidget);
    expect(find.text('삭제'), findsOneWidget);
    // 법적 고지는 문서마다 별개 행이다 (어느 문서에 동의했는지 확인 가능해야 함).
    expect(find.text('서비스 이용약관'), findsOneWidget);
    expect(find.text('개인정보처리방침'), findsOneWidget);
    expect(find.text('위치기반서비스 이용약관'), findsOneWidget);
    expect(find.text('로그아웃'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('푸시 알림을 끄면 헤더에 전체 꺼짐이 뜨고 하위 알림이 잠긴다', (tester) async {
    tester.view.physicalSize = const Size(393 * 3, 852 * 3);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);

    await pumpSettings(tester);

    // 켜져 있는 동안은 잠금 표시가 없다.
    expect(find.text('전체 꺼짐'), findsNothing);
    expect(
      tester.widget<IgnorePointer>(find.byType(IgnorePointer).last).ignoring,
      isFalse,
    );

    // 첫 토글 = 푸시 알림(마스터).
    await tester.tap(find.byType(MyToggle).first);
    await tester.pump(const Duration(milliseconds: 250));

    expect(find.text('전체 꺼짐'), findsOneWidget);
    expect(
      tester.widget<IgnorePointer>(find.byType(IgnorePointer).last).ignoring,
      isTrue,
    );
    expect(
      tester
          .widget<AnimatedOpacity>(
            find.ancestor(
              of: find.byType(IgnorePointer).last,
              matching: find.byType(AnimatedOpacity),
            ),
          )
          .opacity,
      0.4,
    );
  });

  testWidgets('하단에 탈퇴하기 링크와 버전 표기가 있다', (tester) async {
    tester.view.physicalSize = const Size(393 * 3, 852 * 3);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);

    await pumpSettings(tester);
    await tester.dragUntilVisible(
      find.text('탈퇴하기'),
      find.byType(SingleChildScrollView),
      const Offset(0, -200),
    );

    expect(find.text('탈퇴하기'), findsOneWidget);
    expect(find.text('vybe · 버전 1.0.0'), findsOneWidget);
  });
}
