import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vybe/data/models/performance_model.dart';
import 'package:vybe/design_system/colors.dart';
import 'package:vybe/presentation/edm/edm_models.dart';
import 'package:vybe/presentation/edm/edm_schedule_screen.dart';
import 'package:vybe/presentation/edm/viewmodels/edm_viewmodel.dart';
import 'package:vybe/presentation/edm/widgets/edm_timetable.dart';

/// EDM 'DJ 공연 일정' — 진행 상태 표기 · 앞 3줄만 노출 · 전체보기.
///
/// 판정 시각을 주입할 수 있게 만들어 뒀으므로(now) 실행 시각과 무관하게 같은 결과가 나온다.

// 23:30 기준 — 22:00은 종료(시작 후 60분 초과), 23:00은 진행 중, 01:00은 90분 뒤.
final _now = DateTime(2026, 8, 28, 23, 30);

EdmSet _set({required String id, required String club, required String time}) =>
    EdmSet(
      id: id,
      clubId: 'club_$id',
      club: club,
      area: '홍대',
      dist: 1.2,
      dj: 'DJ$id',
      time: time,
    );

// 종료 1 + 진행 중 1 + 예정 1 — 접힌 게 있지만 흐린 미리보기를 만들 만큼은 아니다.
final _sets = [
  _set(id: 'a', club: '알파', time: '22:00'),
  _set(id: 'b', club: '베타', time: '23:00'),
  _set(id: 'c', club: '감마', time: '01:00'),
];

// 종료 1 + 진행 중 1 + 예정 5 — 또렷 3줄 · 흐린 2줄 · 나머지는 전체보기 뒤로.
final _manySets = [
  _set(id: 'a', club: '알파', time: '22:00'),
  _set(id: 'b', club: '베타', time: '23:00'),
  _set(id: 'c', club: '감마', time: '00:00'),
  _set(id: 'd', club: '델타', time: '00:30'),
  _set(id: 'e', club: '엡실론', time: '01:00'),
  _set(id: 'f', club: '제타', time: '01:30'),
  _set(id: 'g', club: '에타', time: '02:00'),
];

Widget _host(List<EdmSet> sets, {VoidCallback? onSeeAll}) => ScreenUtilInit(
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
          onSeeAll: onSeeAll ?? () {},
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

// ── 전체 일정 페이지용 ──

PerformanceModel _perf({
  required String id,
  required String club,
  required DateTime startAt,
}) => PerformanceModel(
  performanceId: id,
  clubId: 'club_$id',
  clubName: club,
  clubArea: '홍대',
  genre: kEdmGenre,
  artistName: 'DJ$id',
  artistType: 'dj',
  startAt: startAt,
  date: '20260828',
  createdAt: DateTime(2026),
);

final _perfs = [
  _perf(id: 'a', club: '알파', startAt: DateTime(2026, 8, 28, 22)),
  _perf(id: 'b', club: '베타', startAt: DateTime(2026, 8, 28, 23)),
  _perf(id: 'c', club: '감마', startAt: DateTime(2026, 8, 29, 1)),
];

class _FakeEdmViewModel extends EdmViewModel {
  _FakeEdmViewModel(this._perfs);
  final List<PerformanceModel> _perfs;

  @override
  Future<EdmData> build() async =>
      EdmData(clubs: const [], performances: _perfs);
}

Widget _scheduleApp(List<PerformanceModel> perfs) => ProviderScope(
  overrides: [
    edmViewModelProvider.overrideWith(() => _FakeEdmViewModel(perfs)),
  ],
  child: ScreenUtilInit(
    designSize: const Size(393, 852),
    builder: (_, __) => MaterialApp(
      home: EdmScheduleScreen(saved: const {}, onSave: (_) {}),
    ),
  ),
);

void main() {
  testWidgets('종료된 공연은 섹션에서 빠지고 전체보기가 전부를 센다', (tester) async {
    _wideScreen(tester);

    await tester.pumpWidget(_host(_sets));
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text('DJ 공연 일정'), findsOneWidget);
    expect(find.text('베타'), findsOneWidget);
    expect(find.text('진행 중'), findsOneWidget);
    expect(find.text('감마'), findsOneWidget);
    expect(find.text('90분 후 시작'), findsOneWidget);

    // 종료(22:00)는 섹션에서 빠진다 — 전체 일정 페이지가 보여준다.
    expect(find.text('알파'), findsNothing);

    // 전체보기가 세는 건 남은 공연이 아니라 **오늘 전체**.
    expect(find.text('전체보기'), findsOneWidget);
    expect(find.text('3'), findsOneWidget);

    // 진행 중인 '곳' 수 — 같은 클럽 두 셋을 두 곳으로 세지 않는다.
    expect(find.text('1곳 플레이 중'), findsOneWidget);

    // 지금이 어디인지 알리는 NOW 마커.
    expect(find.text('NOW 23:30'), findsOneWidget);
  });

  testWidgets('남은 공연이 많으면 앞 3줄만 또렷하고 2줄만 흐리게 비친다', (tester) async {
    _wideScreen(tester);

    await tester.pumpWidget(_host(_manySets));
    await tester.pump(const Duration(milliseconds: 100));

    // 또렷한 3줄.
    expect(find.text('베타'), findsOneWidget);
    expect(find.text('감마'), findsOneWidget);
    expect(find.text('델타'), findsOneWidget);
    // 흐린 미리보기 2줄 — 그려지긴 한다.
    expect(find.text('엡실론'), findsOneWidget);
    expect(find.text('제타'), findsOneWidget);
    // 그 뒤와 종료된 공연은 전체보기 뒤로.
    expect(find.text('에타'), findsNothing);
    expect(find.text('알파'), findsNothing);

    expect(find.text('전체보기'), findsOneWidget);
    expect(find.text('7'), findsOneWidget);
  });

  testWidgets('남은 공연이 없어도 전체보기로 종료된 공연에 갈 수 있다', (tester) async {
    _wideScreen(tester);

    await tester.pumpWidget(_host([_set(id: 'a', club: '알파', time: '22:00')]));
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text('오늘 남은 EDM 공연이 없어요'), findsOneWidget);
    expect(find.text('전체보기'), findsOneWidget);
    expect(find.text('1'), findsOneWidget);
  });

  testWidgets('전체보기를 누르면 콜백이 온다', (tester) async {
    _wideScreen(tester);

    var tapped = 0;
    await tester.pumpWidget(_host(_manySets, onSeeAll: () => tapped++));
    await tester.pump(const Duration(milliseconds: 100));

    await tester.tap(find.text('전체보기'));
    await tester.pump(const Duration(milliseconds: 100));

    expect(tapped, 1);
  });

  testWidgets('오늘 공연이 없으면 빈 안내를 보여준다', (tester) async {
    _wideScreen(tester);

    await tester.pumpWidget(_host(const []));
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text('오늘 예정된 EDM 공연이 없어요'), findsOneWidget);
    expect(find.text('8월 28일 (금) · 공연 0개'), findsOneWidget);
    // 갈 곳이 없으면 전체보기도 안 띄운다.
    expect(find.text('전체보기'), findsNothing);
  });

  testWidgets('전체 일정 페이지는 종료된 공연까지 전부 그린다', (tester) async {
    _wideScreen(tester);

    await tester.pumpWidget(_scheduleApp(_perfs));
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text('DJ 공연 일정'), findsOneWidget);
    expect(find.text('오늘 밤 공연 3개'), findsOneWidget);
    // 섹션이 접었던 것까지 여기선 전부 나온다.
    expect(find.text('알파'), findsOneWidget);
    expect(find.text('베타'), findsOneWidget);
    expect(find.text('감마'), findsOneWidget);
    expect(find.text('공연 정보는 클럽 사정에 따라 변경될 수 있어요'), findsOneWidget);
  });
}
