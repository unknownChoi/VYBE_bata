import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vybe/data/models/club_model.dart';
import 'package:vybe/data/models/free_entry_policy.dart';
import 'package:vybe/data/models/operating_hours.dart';
import 'package:vybe/presentation/clubs/renew/widgets/renew_free_entry.dart';
import 'package:vybe/presentation/common/renew/renew_glass.dart';

/// 클럽 상세 '시간대별 무료입장' 섹션 위젯.
///
/// 이 화면은 **현재 시각**으로 스스로 판정하므로(카운트다운·마커) 테스트가
/// 시:분에 매이지 않게 매일 여는 클럽 + 매일 도는 무료 창을 쓰고,
/// 시각에 따라 달라지지 않는 것만 검증한다 —
/// 섹션이 뜨는지 / 도형 칸이 요금과 함께 그려지는지 / 요일 표가 펼쳐지는지.
/// 구간 계산 자체는 `free_entry_timeline_test.dart` 가 시각을 주입해 본다.
const _hours = OperatingHours(
  mon: DayHours(isOpen: true, open: '22:00', close: '06:00'),
  tue: DayHours(isOpen: true, open: '22:00', close: '06:00'),
  wed: DayHours(isOpen: true, open: '22:00', close: '06:00'),
  thu: DayHours(isOpen: true, open: '22:00', close: '06:00'),
  fri: DayHours(isOpen: true, open: '22:00', close: '06:00'),
  sat: DayHours(isOpen: true, open: '22:00', close: '06:00'),
  sun: DayHours(isOpen: true, open: '22:00', close: '06:00'),
);

ClubModel _club({
  required FreeEntryPolicy freeEntry,
  int entryFeeMin = 20000,
  int entryFeeMax = 20000,
}) => ClubModel(
  clubId: 'c1',
  name: '어썸 레드',
  description: '',
  address: '서울 마포구 잔다리로 12',
  area: '홍대',
  phone: '02-333-1094',
  instagramUrl: '',
  lat: 37.55,
  lng: 126.92,
  geohash: 'wydm',
  genre: '힙합',
  rating: 4.7,
  reviewCount: 13,
  operatingHours: _hours,
  entryFeeMin: entryFeeMin,
  entryFeeMax: entryFeeMax,
  imageUrls: const [],
  thumbnailUrl: '',
  tags: const ['힙합'],
  favoriteCount: 3,
  isActive: true,
  isVybeRecommended: false,
  freeEntry: freeEntry,
  isFreeEntry: freeEntry.hasFreeEntry,
  createdAt: DateTime(2026),
  updatedAt: DateTime(2026),
);

// 금요일 22:00~23:30 만 무료 — 표시 게이트(시작 1시간 전)를 시각별로 보기 위한 것.
const _fridayTimed = FreeEntryPolicy(
  type: FreeEntryType.timed,
  condition: '자정 이전 입장 무료',
  windows: [
    FreeEntryWindow(days: ['fri'], start: '22:00', end: '23:30'),
  ],
);

// 매일 22:00~23:30 무료 — 요일에 상관없이 늘 "다음 창"이 존재한다.
const _dailyTimed = FreeEntryPolicy(
  type: FreeEntryType.timed,
  condition: '자정 이전 입장 무료',
  windows: [FreeEntryWindow(start: '22:00', end: '23:30')],
);

Widget _host(Widget child) => ScreenUtilInit(
  designSize: const Size(393, 852),
  builder: (_, __) => MaterialApp(
    home: Scaffold(
      backgroundColor: RenewGlass.ink,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: child,
        ),
      ),
    ),
  ),
);

void main() {
  // 2026-08-21 은 금요일. 무료 창은 22:00~23:30.
  group('섹션 노출', () {
    Widget? build(ClubModel club, DateTime now) =>
        RenewFreeEntrySection.maybeBuild(club, now: now);

    final friday = _club(freeEntry: _fridayTimed);

    test('무료 정책이 없으면 섹션을 만들지 않는다', () {
      expect(
        build(
          _club(freeEntry: FreeEntryPolicy.none),
          DateTime(2026, 8, 21, 21, 30),
        ),
        isNull,
      );
    });

    test('시간대 무료인데 쓸 수 있는 창이 없으면 만들지 않는다', () {
      // 제목만 뜨고 알맹이가 비는 섹션은 없느니만 못하다.
      final broken = _club(
        freeEntry: const FreeEntryPolicy(
          type: FreeEntryType.timed,
          windows: [FreeEntryWindow(start: '99:99', end: '오후')],
        ),
      );
      expect(build(broken, DateTime(2026, 8, 21, 21, 30)), isNull);
    });

    test('상시 무료는 만들지 않는다 — 나눌 시간대가 없다', () {
      // 영업시간 전체가 한 칸이라 도형도 카운트다운도 보여 줄 게 없다.
      // '무료'라는 사실은 입장료 행이 이미 알린다.
      expect(
        build(
          _club(
            freeEntry: const FreeEntryPolicy(type: FreeEntryType.always),
            entryFeeMin: 0,
            entryFeeMax: 0,
          ),
          DateTime(2026, 8, 21, 21, 30),
        ),
        isNull,
      );
    });

    group('무료 시작 1시간 전부터', () {
      test('한 시간보다 멀면 안 만든다', () {
        // 22:00 시작 — 20:59 는 1시간 1분 전.
        expect(build(friday, DateTime(2026, 8, 21, 20, 59)), isNull);
        expect(build(friday, DateTime(2026, 8, 21, 15)), isNull);
      });

      test('정확히 한 시간 전이면 만든다 — 경계 포함', () {
        expect(build(friday, DateTime(2026, 8, 21, 21)), isNotNull);
      });

      test('한 시간 안쪽이면 만든다', () {
        expect(build(friday, DateTime(2026, 8, 21, 21, 30)), isNotNull);
        expect(build(friday, DateTime(2026, 8, 21, 21, 59, 59)), isNotNull);
      });

      test('무료가 진행 중이면 남은 시간이 알맹이라 만든다', () {
        expect(build(friday, DateTime(2026, 8, 21, 22, 45)), isNotNull);
      });

      test('무료가 끝나면 다시 안 만든다 — 다음 창은 일주일 뒤', () {
        expect(build(friday, DateTime(2026, 8, 21, 23, 31)), isNull);
      });

      test('다른 요일엔 창이 멀어 안 만든다', () {
        // 목요일 21:30 — 창은 금요일이라 24시간 뒤다.
        expect(build(friday, DateTime(2026, 8, 20, 21, 30)), isNull);
      });

      test('자정을 넘긴 창도 시작 한 시간 전부터', () {
        final lateNight = _club(
          freeEntry: const FreeEntryPolicy(
            type: FreeEntryType.timed,
            windows: [
              FreeEntryWindow(days: ['fri'], start: '01:00', end: '02:00'),
            ],
          ),
        );
        // 창은 **시작 요일**에 속한다 — 금 01:00 은 목요일 밤 회차의 새벽.
        expect(build(lateNight, DateTime(2026, 8, 20, 23, 59)), isNull);
        expect(build(lateNight, DateTime(2026, 8, 21, 0, 15)), isNotNull);
        expect(build(lateNight, DateTime(2026, 8, 21, 1, 30)), isNotNull);
      });
    });
  });

  group('위젯', () {
    testWidgets('도형이 무료 칸과 평상시 요금 칸을 함께 그린다', (tester) async {
      tester.view.physicalSize = const Size(393, 852);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(
        _host(RenewFreeEntrySection(club: _club(freeEntry: _dailyTimed))),
      );
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('시간대별 무료입장'), findsOneWidget);
      // 무료 칸 + 눈금(22:00 시작·23:30 경계)
      expect(find.text('무료'), findsWidgets);
      expect(find.text('20,000원'), findsWidgets);
      expect(find.text('22:00'), findsWidgets);
      expect(find.text('23:30'), findsWidgets);
      // 등록된 조건 문구를 그대로 쓴다
      expect(find.text('자정 이전 입장 무료'), findsOneWidget);

      expect(tester.takeException(), isNull);
    });

    testWidgets('상한이 다르면 요금 칸에 ~ 를 붙인다', (tester) async {
      tester.view.physicalSize = const Size(393, 852);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(
        _host(
          RenewFreeEntrySection(
            club: _club(
              freeEntry: _dailyTimed,
              entryFeeMin: 20000,
              entryFeeMax: 30000,
            ),
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('20,000원~'), findsWidgets);
    });

    testWidgets('창이 여러 개여도 도형이 393 폭 안에서 넘치지 않는다', (tester) async {
      tester.view.physicalSize = const Size(393, 852);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);

      // 6칸(무료 3 · 유료 3) + 10분짜리 짧은 창 — 최소 폭 재분배가 도는 조건.
      await tester.pumpWidget(
        _host(
          RenewFreeEntrySection(
            club: _club(
              freeEntry: const FreeEntryPolicy(
                type: FreeEntryType.timed,
                windows: [
                  FreeEntryWindow(start: '22:10', end: '22:20'),
                  FreeEntryWindow(start: '23:00', end: '23:30'),
                  FreeEntryWindow(start: '01:00', end: '02:00'),
                ],
              ),
            ),
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('무료'), findsNWidgets(3));
      expect(tester.takeException(), isNull);
    });

    testWidgets('요일별 무료입장 시간을 펼치면 7일 표가 나온다', (tester) async {
      tester.view.physicalSize = const Size(393, 852);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(
        _host(RenewFreeEntrySection(club: _club(freeEntry: _dailyTimed))),
      );
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('월'), findsNothing);

      await tester.tap(find.text('요일별 무료입장 시간'));
      await tester.pump(const Duration(milliseconds: 400));

      for (final day in ['월', '화', '수', '목', '금', '토', '일']) {
        expect(find.text(day), findsOneWidget);
      }
      expect(find.text('22:00 – 23:30'), findsNWidgets(7));
      expect(find.text('오늘'), findsOneWidget);
    });

    testWidgets('조건이 비면 동작 설명으로 대신한다 — 클럽 조건을 지어내지 않는다', (tester) async {
      tester.view.physicalSize = const Size(393, 852);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(
        _host(
          RenewFreeEntrySection(
            club: _club(
              freeEntry: const FreeEntryPolicy(
                type: FreeEntryType.timed,
                windows: [FreeEntryWindow(start: '22:00', end: '23:30')],
              ),
            ),
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('무료 시간 안에 입장한 경우에만 적용돼요'), findsOneWidget);
    });

    testWidgets('상시 무료는 입장료 행에서만 알린다', (tester) async {
      tester.view.physicalSize = const Size(393, 852);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(
        _host(
          RenewFeeRow(
            club: _club(
              freeEntry: const FreeEntryPolicy(type: FreeEntryType.always),
              entryFeeMin: 0,
              entryFeeMax: 0,
            ),
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('영업 시간 내내 무료입장'), findsOneWidget);
      expect(find.text('시간대별 무료입장'), findsNothing);
      expect(tester.takeException(), isNull);
    });

    testWidgets('매장 정보 입장료 행에 무료 pill 과 시간대가 붙는다', (tester) async {
      tester.view.physicalSize = const Size(393, 852);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(
        _host(RenewFeeRow(club: _club(freeEntry: _dailyTimed))),
      );
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('입장료 '), findsOneWidget);
      expect(find.text('20,000원'), findsOneWidget);
      expect(find.text('22:00 – 23:30 무료 · 이후 20,000원부터'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('무료 정책이 없으면 입장료 행은 한 줄 그대로', (tester) async {
      tester.view.physicalSize = const Size(393, 852);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(
        _host(RenewFeeRow(club: _club(freeEntry: FreeEntryPolicy.none))),
      );
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('20,000원'), findsOneWidget);
      expect(find.textContaining('무료'), findsNothing);
    });
  });

  group('남은 시간 표기', () {
    test('한 시간 안쪽은 분:초', () {
      expect(
        formatFreeCountdown(const Duration(minutes: 7, seconds: 42)),
        '07:42',
      );
      expect(formatFreeCountdown(Duration.zero), '00:00');
    });

    test('한 시간 넘으면 시간 · 분', () {
      expect(
        formatFreeCountdown(const Duration(hours: 1, minutes: 5)),
        '1시간 05분',
      );
    });

    test('하루 넘으면 일 · 시간', () {
      expect(
        formatFreeCountdown(const Duration(days: 2, hours: 3, minutes: 40)),
        '2일 3시간',
      );
    });
  });
}
