import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:vybe/core/utils/firebase_guard.dart';

/// 중복 요청 합류([FirebaseGuard.dedupe]) 단위 테스트.
///
/// Firebase 의존이 없어 위젯 트리 없이 검증한다.
void main() {
  group('FirebaseGuard.dedupe', () {
    setUp(FirebaseGuard.reset);
    tearDown(FirebaseGuard.reset);

    test('같은 키가 떠 있으면 run을 다시 실행하지 않고 합류한다', () async {
      var calls = 0;
      final completer = Completer<int>();

      Future<int> run() {
        calls++;
        return completer.future;
      }

      final first = FirebaseGuard.dedupe('k', run);
      final second = FirebaseGuard.dedupe('k', run);

      expect(calls, 1);
      expect(identical(first, second), isTrue);

      completer.complete(7);
      expect(await first, 7);
      expect(await second, 7);
    });

    test('키가 다르면 각각 실행된다', () async {
      var calls = 0;
      Future<int> run() async {
        calls++;
        return 1;
      }

      await Future.wait([
        FirebaseGuard.dedupe('a', run),
        FirebaseGuard.dedupe('b', run),
      ]);
      expect(calls, 2);
    });

    test('완료 뒤에는 키가 풀려 다시 실행된다', () async {
      var calls = 0;
      Future<int> run() async {
        calls++;
        return 1;
      }

      await FirebaseGuard.dedupe('k', run);
      expect(FirebaseGuard.inFlightCount, 0);

      await FirebaseGuard.dedupe('k', run);
      expect(calls, 2);
    });

    test('실패해도 예외는 그대로 전파되고 키는 정리된다', () async {
      var secondRun = false;
      final completer = Completer<void>();

      final first = FirebaseGuard.dedupe<void>('k', () => completer.future);
      final joined = FirebaseGuard.dedupe<void>('k', () async {
        secondRun = true;
      });

      expect(secondRun, isFalse);
      expect(identical(first, joined), isTrue);

      completer.completeError(StateError('boom'));
      await expectLater(first, throwsStateError);
      await expectLater(joined, throwsStateError);

      // 파생 Future 정리가 마이크로태스크로 돌아간 뒤 확인.
      await Future<void>.delayed(Duration.zero);
      expect(FirebaseGuard.inFlightCount, 0);
    });

    test('찜 연타 시나리오 — 추가가 떠 있으면 해제 요청이 나가지 않는다', () async {
      final calls = <String>[];
      final addDone = Completer<void>();

      Future<void> toggle({required bool isFav}) {
        return FirebaseGuard.dedupe<void>('favorite:u1:c1', () {
          calls.add(isFav ? 'remove' : 'add');
          return addDone.future;
        });
      }

      final tap1 = toggle(isFav: false); // 찜 추가 시작
      final tap2 = toggle(isFav: true); // 서버 ack 전 해제 연타

      expect(calls, ['add']);

      addDone.complete();
      await Future.wait([tap1, tap2]);
      expect(FirebaseGuard.inFlightCount, 0);
    });
  });
}
