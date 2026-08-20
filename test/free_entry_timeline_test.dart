import 'package:flutter_test/flutter_test.dart';
import 'package:vybe/data/models/free_entry_policy.dart';
import 'package:vybe/data/models/free_entry_timeline.dart';
import 'package:vybe/data/models/operating_hours.dart';

/// 클럽 상세 '시간대별 입장비' 도형이 그리는 구간표 검증.
///
/// Firestore 에 시간대별 요금표는 없다 — 도형은 영업시간 · 무료 창 · 평상시
/// 요금 셋을 겹쳐서 만든다. 여기가 틀리면 화면이 **없는 요금 구간**을 그린다.
///
/// 기준 날짜: 2026-08-20 목 · 21 금 · 22 토 · 23 일.
void main() {
  // DB 의 클럽들과 같은 패턴 — 목·금 22:00~06:00, 토 22:00~05:00, 나머지 휴무.
  const hours = OperatingHours(
    thu: DayHours(isOpen: true, open: '22:00', close: '06:00'),
    fri: DayHours(isOpen: true, open: '22:00', close: '06:00'),
    sat: DayHours(isOpen: true, open: '22:00', close: '05:00'),
  );

  FreeEntryPolicy timed(List<FreeEntryWindow> windows) =>
      FreeEntryPolicy(type: FreeEntryType.timed, windows: windows);

  FreeEntryTimeline? build(
    FreeEntryPolicy policy,
    DateTime at, {
    OperatingHours operating = hours,
    int normalFee = 20000,
  }) => buildFreeEntryTimeline(
    hours: operating,
    policy: policy,
    normalFee: normalFee,
    at: at,
  );

  group('만들지 않는 경우', () {
    test('무료 정책이 없으면 null', () {
      expect(build(FreeEntryPolicy.none, DateTime(2026, 8, 21, 23)), isNull);
    });

    test('영업일이 하나도 없으면 null', () {
      final t = build(
        timed(const [
          FreeEntryWindow(days: ['fri'], start: '22:00', end: '23:30'),
        ]),
        DateTime(2026, 8, 21, 23),
        operating: const OperatingHours(),
      );
      expect(t, isNull);
    });

    test('무료 창이 영업시간과 안 겹치면 null — 없는 구간을 그리지 않는다', () {
      // 금 18:00~20:00 은 오픈(22:00) 전이다.
      final t = build(
        timed(const [
          FreeEntryWindow(days: ['fri'], start: '18:00', end: '20:00'),
        ]),
        DateTime(2026, 8, 21, 23),
      );
      expect(t, isNull);
    });
  });

  group('구간 쪼개기', () {
    test('무료 창 하나 → 무료 칸 + 이후 유료 칸', () {
      final t = build(
        timed(const [
          FreeEntryWindow(days: ['fri'], start: '22:00', end: '23:30'),
        ]),
        DateTime(2026, 8, 21, 23),
      )!;

      expect(t.start, DateTime(2026, 8, 21, 22));
      expect(t.end, DateTime(2026, 8, 22, 6));
      expect(t.slots.length, 2);
      expect(t.slots[0].isFree, isTrue);
      expect(t.slots[0].end, DateTime(2026, 8, 21, 23, 30));
      expect(t.slots[1].fee, 20000);
      expect(t.slots[1].end, DateTime(2026, 8, 22, 6));
    });

    test('창이 오픈보다 늦게 시작하면 앞에 유료 칸이 생긴다', () {
      final t = build(
        timed(const [
          FreeEntryWindow(days: ['fri'], start: '23:00', end: '02:00'),
        ]),
        DateTime(2026, 8, 21, 23, 30),
      )!;

      expect(t.slots.length, 3);
      expect(t.slots[0].fee, 20000);
      expect(t.slots[0].start, DateTime(2026, 8, 21, 22));
      expect(t.slots[1].isFree, isTrue);
      // 자정을 넘긴 창은 다음 날 02:00 에 끝난다.
      expect(t.slots[1].end, DateTime(2026, 8, 22, 2));
      expect(t.slots[2].fee, 20000);
    });

    test('창이 오픈 전부터면 오픈 시각으로 잘린다', () {
      final t = build(
        timed(const [
          FreeEntryWindow(days: ['fri'], start: '20:00', end: '23:00'),
        ]),
        DateTime(2026, 8, 21, 22, 30),
      )!;

      expect(t.slots.first.isFree, isTrue);
      expect(t.slots.first.start, DateTime(2026, 8, 21, 22)); // 20:00 아님
    });

    test('마감 뒤까지 이어지는 창은 마감 시각으로 잘린다', () {
      final t = build(
        timed(const [
          FreeEntryWindow(days: ['sat'], start: '23:00', end: '08:00'),
        ]),
        DateTime(2026, 8, 22, 23, 30),
      )!;

      expect(t.end, DateTime(2026, 8, 23, 5)); // 토요일 마감 05:00
      expect(t.slots.last.isFree, isTrue);
      expect(t.slots.last.end, DateTime(2026, 8, 23, 5));
    });

    test('겹치는 창 둘은 한 칸으로 합쳐진다', () {
      final t = build(
        timed(const [
          FreeEntryWindow(days: ['fri'], start: '22:00', end: '23:30'),
          FreeEntryWindow(days: ['fri'], start: '23:00', end: '01:00'),
        ]),
        DateTime(2026, 8, 21, 23),
      )!;

      expect(t.slots.length, 2);
      expect(t.slots[0].isFree, isTrue);
      expect(t.slots[0].end, DateTime(2026, 8, 22, 1));
    });

    test('떨어진 창 둘은 사이에 유료 칸을 둔다', () {
      // 창은 **시작 요일**에 속한다 — 금요일 회차의 새벽 01:00 창은 sat 로 적는다.
      final t = build(
        timed(const [
          FreeEntryWindow(days: ['fri'], start: '22:00', end: '23:00'),
          FreeEntryWindow(days: ['sat'], start: '01:00', end: '02:00'),
        ]),
        DateTime(2026, 8, 21, 23),
      )!;

      expect(t.slots.map((s) => s.isFree).toList(), [true, false, true, false]);
      expect(t.slots[2].start, DateTime(2026, 8, 22, 1));
    });

    test('구간은 빈틈 없이 회차 전체를 덮는다', () {
      final t = build(
        timed(const [
          FreeEntryWindow(days: ['fri'], start: '23:00', end: '01:00'),
        ]),
        DateTime(2026, 8, 21, 23, 30),
      )!;

      var cursor = t.start;
      for (final s in t.slots) {
        expect(s.start, cursor);
        cursor = s.end;
      }
      expect(cursor, t.end);
    });
  });

  group('회차 고르기', () {
    test('자정을 넘긴 시각은 어제 시작한 회차에 붙는다', () {
      final t = build(
        timed(const [
          FreeEntryWindow(days: ['fri'], start: '23:00', end: '02:00'),
        ]),
        DateTime(2026, 8, 22, 1), // 토 01:00 = 금요일 회차 진행 중
      )!;

      expect(t.start, DateTime(2026, 8, 21, 22));
      expect(t.contains(DateTime(2026, 8, 22, 1)), isTrue);
    });

    test('영업 중이 아니면 [at] 이후 첫 회차를 고른다', () {
      final t = build(
        timed(const [
          FreeEntryWindow(days: ['thu'], start: '23:00', end: '01:00'),
        ]),
        DateTime(2026, 8, 19, 15), // 수요일 낮 — 휴무
      )!;

      expect(t.start, DateTime(2026, 8, 20, 22)); // 목요일 회차
    });

    test('고른 회차에 무료 창이 없으면 다른 날로 건너뛰지 않고 null', () {
      // 건너뛰면 도형이 헤드('오늘 22:00 시작')와 다른 날을 그리게 된다.
      // 다른 날 회차를 보여 주려면 호출부가 그 창의 시작 시각을 앵커로 준다.
      final t = build(
        timed(const [
          FreeEntryWindow(days: ['fri'], start: '22:00', end: '23:30'),
        ]),
        DateTime(2026, 8, 20, 23), // 목요일 회차 한가운데
      );
      expect(t, isNull);

      expect(
        build(
          timed(const [
            FreeEntryWindow(days: ['fri'], start: '22:00', end: '23:30'),
          ]),
          DateTime(2026, 8, 21, 22), // 창 시작 시각을 앵커로
        )!.start,
        DateTime(2026, 8, 21, 22),
      );
    });
  });

  group('상시 무료', () {
    test('회차 전체가 무료 한 칸', () {
      final t = build(
        const FreeEntryPolicy(type: FreeEntryType.always),
        DateTime(2026, 8, 21, 23),
        normalFee: 0,
      )!;

      expect(t.slots.length, 1);
      expect(t.slots.single.isFree, isTrue);
      expect(t.slots.single.start, t.start);
      expect(t.slots.single.end, t.end);
    });
  });

  group('진행도 · 현재 칸', () {
    test('회차 밖이면 진행도 null', () {
      final t = build(
        timed(const [
          FreeEntryWindow(days: ['fri'], start: '22:00', end: '23:30'),
        ]),
        DateTime(2026, 8, 21, 23),
      )!;

      expect(t.progressAt(DateTime(2026, 8, 21, 20)), isNull);
      expect(t.progressAt(DateTime(2026, 8, 22, 7)), isNull);
    });

    test('회차 한가운데는 0.5', () {
      final t = build(
        timed(const [
          FreeEntryWindow(days: ['fri'], start: '22:00', end: '23:30'),
        ]),
        DateTime(2026, 8, 21, 23),
      )!;

      // 22:00 ~ 06:00 = 8시간 → 한가운데는 02:00
      expect(t.progressAt(DateTime(2026, 8, 22, 2)), closeTo(0.5, 0.001));
    });

    test('slotAt 은 그 시각의 요금 칸을 준다', () {
      final t = build(
        timed(const [
          FreeEntryWindow(days: ['fri'], start: '22:00', end: '23:30'),
        ]),
        DateTime(2026, 8, 21, 23),
      )!;

      expect(t.slotAt(DateTime(2026, 8, 21, 22, 30))!.isFree, isTrue);
      expect(t.slotAt(DateTime(2026, 8, 21, 23, 30))!.fee, 20000); // end 미포함
      expect(t.slotAt(DateTime(2026, 8, 22, 8)), isNull);
    });
  });
}
