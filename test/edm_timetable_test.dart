import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vybe/design_system/colors.dart';
import 'package:vybe/presentation/edm/edm_models.dart';
import 'package:vybe/presentation/edm/widgets/edm_timetable.dart';

/// EDM 'DJ 타임테이블' — 진행 상태 표기 · 종료 공연 접기.
///
/// 판정 시각을 주입할 수 있게 만들어 뒀으므로(now) 실행 시각과 무관하게 같은 결과가 나온다.

// 23:30 기준 — 22:00은 종료(시작 후 60분 초과), 23:00은 진행 중, 01:00은 90분 뒤.
final _now = DateTime(2026, 8, 28, 23, 30);

EdmSet _set({
  required String id,
  required String club,
  required String time,
}) => EdmSet(
  id: id,
  clubId: 'club_$id',
  club: club,
  area: '홍대',
  dist: 1.2,
  dj: 'DJ$id',
  time: time,
);

final _sets = [
  _set(id: 'a', club: '알파', time: '22:00'),
  _set(id: 'b', club: '베타', time: '23:00'),
  _set(id: 'c', club: '감마', time: '01:00'),
];

Widget _host(List<EdmSet> sets) => ScreenUtilInit(
  designSize: const Size(393, 852),
  builder: (_, __) => MaterialApp(
    home: Scaffold(
      backgroundColor: VybeColors.background,
      body: SingleChildScrollView(
        child: EdmTimetable(
          sets: sets,
          loading: false,
          now: _now,
          saved: const {},
          onSave: (_) {},
        ),
      ),
    ),
  ),
);

// 실기기 폭 그대로 두면 테스트 폰트(Ahem)가 넓어 오버플로가 잡힌다.
// 검증 대상은 폭이 아니라 표기·필터 동작이라 넉넉한 화면을 준다.
void _wideScreen(WidgetTester tester) {
  tester.view.physicalSize = const Size(700, 1400);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
}

void main() {
  testWidgets('진행 중·예정은 보이고 종료된 공연은 기본으로 접힌다', (tester) async {
    _wideScreen(tester);

    await tester.pumpWidget(_host(_sets));
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text('베타'), findsOneWidget);
    expect(find.text('진행 중'), findsOneWidget);
    expect(find.text('감마'), findsOneWidget);
    expect(find.text('90분 후 시작'), findsOneWidget);

    // 종료(22:00)는 접혀 있고, 대신 펼치기 버튼이 개수를 말한다.
    expect(find.text('알파'), findsNothing);
    expect(find.text('종료된 공연 1개 보기'), findsOneWidget);

    // 지금이 어디인지 알리는 NOW 마커.
    expect(find.text('NOW 23:30'), findsOneWidget);
  });

  testWidgets('종료된 공연을 펼치면 목록에 들어온다', (tester) async {
    _wideScreen(tester);

    await tester.pumpWidget(_host(_sets));
    await tester.pump(const Duration(milliseconds: 100));

    await tester.tap(find.text('종료된 공연 1개 보기'));
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text('알파'), findsOneWidget);
    expect(find.text('공연 종료'), findsOneWidget);
    expect(find.text('종료된 공연 접기'), findsOneWidget);
  });

  testWidgets('오늘 공연이 없으면 빈 안내를 보여준다', (tester) async {
    _wideScreen(tester);

    await tester.pumpWidget(_host(const []));
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text('오늘 예정된 EDM 공연이 없어요'), findsOneWidget);
    expect(find.text('8월 28일 (금) · 공연 0개'), findsOneWidget);
  });
}
