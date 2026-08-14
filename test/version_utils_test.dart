import 'package:flutter_test/flutter_test.dart';
import 'package:vybe/core/utils/version_utils.dart';

/// 버전 게이트 판정은 잘못되면 앱 전체가 잠기는 로직이라
/// Firestore 없이 순수 함수 단위로 검증한다.
void main() {
  group('compareVersion', () {
    test('숫자 비교 — 자릿수 단위가 아니라 파트 단위', () {
      // "1.10.0" > "1.9.0" — 문자열 비교로는 반대가 나온다.
      expect(compareVersion('1.10.0', '1.9.0'), greaterThan(0));
      expect(compareVersion('1.9.0', '1.10.0'), lessThan(0));
      expect(compareVersion('2.0.0', '1.99.99'), greaterThan(0));
    });

    test('같은 버전은 0', () {
      expect(compareVersion('1.2.3', '1.2.3'), 0);
    });

    test('자릿수가 달라도 빠진 자리는 0으로 채움', () {
      expect(compareVersion('1.2', '1.2.0'), 0);
      expect(compareVersion('1.2', '1.2.1'), lessThan(0));
      expect(compareVersion('1.2.0.1', '1.2'), greaterThan(0));
    });

    test('빌드번호·프리릴리스 꼬리는 무시', () {
      expect(compareVersion('1.2.0+7', '1.2.0+1'), 0);
      expect(compareVersion('1.2.0-beta1', '1.2.0'), 0);
      expect(compareVersion('1.2.0+7', '1.3.0'), lessThan(0));
    });

    test('망가진 값도 예외 없이 0 취급', () {
      expect(compareVersion('', '0.0.0'), 0);
      expect(compareVersion('v1.2.0', '1.2.0'), 0); // 접두 v 허용
      expect(compareVersion('abc', '0.0.1'), lessThan(0));
    });
  });

  group('decideVersionAction', () {
    VersionAction decide(
      String current, {
      String min = '',
      String latest = '',
      bool maintenance = false,
    }) =>
        decideVersionAction(
          currentVersion: current,
          minVersion: min,
          latestVersion: latest,
          isMaintenance: maintenance,
        );

    test('점검은 버전보다 우선', () {
      expect(
        decide('9.9.9', min: '1.0.0', latest: '1.0.0', maintenance: true),
        VersionAction.maintenance,
      );
    });

    test('minVersion 미만이면 강제', () {
      expect(decide('1.0.0', min: '1.2.0', latest: '1.3.0'),
          VersionAction.force);
    });

    test('minVersion 이상 latestVersion 미만이면 선택', () {
      expect(decide('1.2.0', min: '1.2.0', latest: '1.3.0'),
          VersionAction.optional);
    });

    test('최신이면 통과', () {
      expect(decide('1.3.0', min: '1.2.0', latest: '1.3.0'), VersionAction.ok);
      expect(decide('2.0.0', min: '1.2.0', latest: '1.3.0'), VersionAction.ok);
    });

    test('fail-open — 현재 버전 못 읽으면 막지 않음', () {
      expect(decide('', min: '9.9.9', latest: '9.9.9'), VersionAction.ok);
    });

    test('fail-open — 정책 값이 비면 그 단계는 건너뜀', () {
      // minVersion만 비어 있으면 강제는 없고 선택만 판단.
      expect(decide('1.0.0', latest: '1.3.0'), VersionAction.optional);
      // 둘 다 비면 통과.
      expect(decide('1.0.0'), VersionAction.ok);
    });
  });
}
