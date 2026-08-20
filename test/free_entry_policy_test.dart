import 'package:flutter_test/flutter_test.dart';
import 'package:vybe/data/models/free_entry_policy.dart';

/// 무료입장 시간대 판정은 Firestore가 못 하는 일(요일 × 시:분 × 자정 넘김)을
/// 앱이 대신하는 자리라, 여기가 틀리면 유료 클럽이 '지금 무료'로 뜬다.
/// 화면 없이 순수 함수만 검증한다.
///
/// 기준 날짜: 2026-08-21은 **금요일**, 22일 토, 20일 목.
void main() {
  FreeEntryPolicy timed(List<FreeEntryWindow> windows) =>
      FreeEntryPolicy(type: FreeEntryType.timed, windows: windows);

  group('type', () {
    test('none은 언제나 무료 아님', () {
      final s = FreeEntryPolicy.none.statusAt(DateTime(2026, 8, 21, 23));
      expect(s.isFreeNow, isFalse);
      expect(s.nextStartsAt, isNull);
    });

    test('always는 창 없이 항상 무료', () {
      const p = FreeEntryPolicy(type: FreeEntryType.always);
      expect(p.statusAt(DateTime(2026, 8, 21, 14)).isFreeNow, isTrue);
      expect(p.statusAt(DateTime(2026, 8, 21, 3)).isFreeNow, isTrue);
    });

    test('timed인데 창이 비면 무료 아님 — always로 새지 않는다', () {
      // '시간대 무료인데 창을 아직 안 넣었다'를 상시 무료로 읽으면
      // 유료 클럽이 24시간 무료로 노출된다.
      expect(timed([]).statusAt(DateTime(2026, 8, 21, 23)).isFreeNow, isFalse);
    });

    test('모르는 type 문자열은 none으로 폴백', () {
      expect(FreeEntryType.parse('weekly'), FreeEntryType.none);
      expect(FreeEntryType.parse(null), FreeEntryType.none);
    });
  });

  group('경계 — start 포함 · end 미포함', () {
    final p = timed([
      const FreeEntryWindow(days: ['fri'], start: '22:00', end: '23:30'),
    ]);

    test('시작 정각은 무료', () {
      expect(p.statusAt(DateTime(2026, 8, 21, 22, 0)).isFreeNow, isTrue);
    });

    test('시작 1분 전은 무료 아님', () {
      expect(p.statusAt(DateTime(2026, 8, 21, 21, 59)).isFreeNow, isFalse);
    });

    test('종료 정각은 무료 아님', () {
      expect(p.statusAt(DateTime(2026, 8, 21, 23, 30)).isFreeNow, isFalse);
    });

    test('종료 1분 전은 무료', () {
      expect(p.statusAt(DateTime(2026, 8, 21, 23, 29)).isFreeNow, isTrue);
    });
  });

  group('자정 넘김', () {
    test("end='00:00'은 그날 24:00까지로 평가된다", () {
      final p = timed([
        const FreeEntryWindow(days: ['fri'], start: '22:00', end: '00:00'),
      ]);
      expect(p.statusAt(DateTime(2026, 8, 21, 23, 59)).isFreeNow, isTrue);
      // 토요일 00:00은 금요일 창의 끝 — 포함되지 않는다.
      expect(p.statusAt(DateTime(2026, 8, 22, 0, 0)).isFreeNow, isFalse);
    });

    test('금 23:00~02:00은 토요일 01:00에도 무료 (어제 창을 본다)', () {
      final p = timed([
        const FreeEntryWindow(days: ['fri'], start: '23:00', end: '02:00'),
      ]);
      // 창은 '시작 요일'에 속한다 — 토요일 창이 따로 있는 게 아니다.
      expect(p.statusAt(DateTime(2026, 8, 22, 1, 0)).isFreeNow, isTrue);
      expect(p.statusAt(DateTime(2026, 8, 22, 2, 0)).isFreeNow, isFalse);
    });

    test('토요일 자체 창은 금요일 새벽에 걸리지 않는다', () {
      final p = timed([
        const FreeEntryWindow(days: ['sat'], start: '01:00', end: '05:00'),
      ]);
      expect(p.statusAt(DateTime(2026, 8, 22, 3)).isFreeNow, isTrue);
      expect(p.statusAt(DateTime(2026, 8, 21, 3)).isFreeNow, isFalse);
    });

    test('창 길이 계산 — 자정을 넘으면 다음 날 몫까지', () {
      const w = FreeEntryWindow(start: '22:00', end: '06:00');
      expect(w.crossesMidnight, isTrue);
      expect(w.durationMinutes, 8 * 60);
      const w2 = FreeEntryWindow(start: '22:00', end: '23:30');
      expect(w2.crossesMidnight, isFalse);
      expect(w2.durationMinutes, 90);
    });
  });

  group('요일', () {
    test('days가 비면 매일', () {
      final p = timed([const FreeEntryWindow(start: '22:00', end: '23:00')]);
      for (final day in [20, 21, 22, 23]) {
        expect(
          p.statusAt(DateTime(2026, 8, day, 22, 30)).isFreeNow,
          isTrue,
          reason: '8/$day',
        );
      }
    });

    test('지정 요일이 아니면 무료 아님', () {
      final p = timed([
        const FreeEntryWindow(days: ['thu'], start: '22:00', end: '23:00'),
      ]);
      expect(p.statusAt(DateTime(2026, 8, 20, 22, 30)).isFreeNow, isTrue); // 목
      expect(p.statusAt(DateTime(2026, 8, 21, 22, 30)).isFreeNow, isFalse); // 금
    });

    test('weekday → 요일 키', () {
      expect(dayKeyOf(DateTime.monday), 'mon');
      expect(dayKeyOf(DateTime.sunday), 'sun');
      expect(dayKeyOf(DateTime.friday), 'fri');
    });
  });

  group('다음 무료 창', () {
    test('오늘 아직 안 온 창을 집는다', () {
      final p = timed([
        const FreeEntryWindow(days: ['fri'], start: '22:00', end: '23:30'),
      ]);
      final s = p.statusAt(DateTime(2026, 8, 21, 20));
      expect(s.isFreeNow, isFalse);
      expect(s.nextStartsAt, DateTime(2026, 8, 21, 22));
      expect(s.untilNextFrom(DateTime(2026, 8, 21, 20)), const Duration(hours: 2));
    });

    test('오늘 창이 끝났으면 다음 주 같은 요일', () {
      final p = timed([
        const FreeEntryWindow(days: ['fri'], start: '22:00', end: '23:30'),
      ]);
      final s = p.statusAt(DateTime(2026, 8, 21, 23, 40));
      expect(s.nextStartsAt, DateTime(2026, 8, 28, 22));
    });

    test('창이 여러 개면 가장 이른 것', () {
      final p = timed([
        const FreeEntryWindow(days: ['fri'], start: '03:00', end: '05:00'),
        const FreeEntryWindow(days: ['fri'], start: '22:00', end: '23:00'),
      ]);
      // 정의 순서가 아니라 시각으로 고른다.
      final s = p.statusAt(DateTime(2026, 8, 21, 1));
      expect(s.nextStartsAt, DateTime(2026, 8, 21, 3));
      expect(s.next?.end, '05:00');
    });

    test('진행 중이면 next 대신 active를 준다', () {
      final p = timed([
        const FreeEntryWindow(days: ['fri'], start: '22:00', end: '23:30'),
        const FreeEntryWindow(days: ['sat'], start: '22:00', end: '23:30'),
      ]);
      final now = DateTime(2026, 8, 21, 22, 52);
      final s = p.statusAt(now);
      expect(s.isFreeNow, isTrue);
      expect(s.active?.start, '22:00');
      expect(s.activeEndsAt, DateTime(2026, 8, 21, 23, 30));
      expect(s.remainingFrom(now), const Duration(minutes: 38));
      expect(s.next, isNull);
    });
  });

  group('잘못된 데이터', () {
    test('시각 형식이 깨진 창은 무시된다', () {
      final p = timed([
        const FreeEntryWindow(days: ['fri'], start: '이십이시', end: '23:30'),
      ]);
      final s = p.statusAt(DateTime(2026, 8, 21, 23));
      expect(s.isFreeNow, isFalse);
      expect(s.nextStartsAt, isNull);
    });

    test('start == end 인 창은 길이 0이라 무시된다', () {
      final p = timed([
        const FreeEntryWindow(days: ['fri'], start: '22:00', end: '22:00'),
      ]);
      expect(p.statusAt(DateTime(2026, 8, 21, 22)).isFreeNow, isFalse);
    });
  });

  group('fromMap', () {
    test('Firestore 맵 파싱', () {
      final p = FreeEntryPolicy.fromMap({
        'type': 'timed',
        'condition': '자정 이전 입장 무료',
        'windows': [
          {
            'days': ['thu', 'fri', 'sat'],
            'start': '22:00',
            'end': '00:00',
            'label': '자정 전',
          },
        ],
      });
      expect(p.type, FreeEntryType.timed);
      expect(p.condition, '자정 이전 입장 무료');
      expect(p.windows.single.days, ['thu', 'fri', 'sat']);
      expect(p.windows.single.rangeLabel, '22:00 – 00:00');
    });

    test('필드 없는 문서(백필 전)는 none', () {
      expect(FreeEntryPolicy.fromMap(null), FreeEntryPolicy.none);
      expect(FreeEntryPolicy.fromMap(null).hasFreeEntry, isFalse);
    });

    test('알 수 없는 요일 키는 버린다', () {
      final p = FreeEntryPolicy.fromMap({
        'type': 'timed',
        'windows': [
          {
            'days': ['fri', 'holiday'],
            'start': '22:00',
            'end': '23:00',
          },
        ],
      });
      expect(p.windows.single.days, ['fri']);
    });

    test('toMap → fromMap 왕복', () {
      final p = timed([
        const FreeEntryWindow(
          days: ['sat'],
          start: '01:00',
          end: '05:00',
          label: '토요일 심야',
        ),
      ]);
      expect(FreeEntryPolicy.fromMap(p.toMap()), p);
    });
  });
}
