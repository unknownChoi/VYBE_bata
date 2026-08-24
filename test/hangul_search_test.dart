import 'package:flutter_test/flutter_test.dart';
import 'package:vybe/core/utils/hangul_search.dart';

/// 한글 IME 조합 중 자모 처리.
///
/// 검색엔진(Algolia)은 단독 자모('ㅇ')를 인덱싱하지 않아, 그대로 던지면 AND 매칭이
/// 결과를 통째로 0건으로 만든다(실측: '홍대' 57건 → '홍대 ㅇ' 0건).
/// 자모는 엔진에 안 보내고 결과 초성으로 거른다 — 그 규칙을 고정한다.
void main() {
  group('parse — 엔진에 던질 부분과 자모 분리', () {
    test('조합 중 자모는 엔진 쿼리에서 빠진다', () {
      final q = HangulQuery.parse('홍대 ㅇ');
      expect(q.engineQuery, '홍대');
      expect(q.hasJamo, isTrue);
    });

    test('완성형만 있으면 자모 필터 자체가 없다', () {
      final q = HangulQuery.parse('홍대 어');
      expect(q.engineQuery, '홍대 어');
      expect(q.hasJamo, isFalse);
    });

    test('한 토큰 안에 완성형 + 자모가 섞여도 앞부분은 엔진으로 간다', () {
      final q = HangulQuery.parse('어ㅆ');
      expect(q.engineQuery, '어');
      expect(q.hasJamo, isTrue);
    });

    test('자모만 입력하면 엔진 쿼리는 비고 초성으로만 거른다', () {
      final q = HangulQuery.parse('ㅇㅆ');
      expect(q.engineQuery, isEmpty);
      expect(q.hasJamo, isTrue);
    });

    test('초성이 될 수 없는 모음 자모는 버린다 (엉뚱한 매칭 방지)', () {
      final q = HangulQuery.parse('홍대 ㅏ');
      expect(q.engineQuery, '홍대');
      expect(q.hasJamo, isFalse);
    });
  });

  group('matches — 결과를 초성으로 거른다', () {
    test("'홍대 ㅇ' 는 초성에 ㅇ이 있는 이름만 통과", () {
      final q = HangulQuery.parse('홍대 ㅇ');
      expect(q.matches('어썸레드'), isTrue);
      expect(q.matches('홍대 클럽 도어'), isTrue); // '어'의 초성
      expect(q.matches('클럽 프리즘'), isFalse);
    });

    test('앞 글자가 이어져야 한다 — 어ㅆ 는 어 뒤가 ㅅ/ㅆ 인 이름만', () {
      final q = HangulQuery.parse('어ㅆ');
      expect(q.matches('어썸레드'), isTrue);
      expect(q.matches('어반나이트'), isFalse);
    });

    test('쌍자음은 홑자음으로 눕혀 매칭한다 (ㅅ 로도 썸이 걸린다)', () {
      expect(HangulQuery.parse('어ㅅ').matches('어썸레드'), isTrue);
    });

    test('자모 여러 개는 연속 초성으로 본다', () {
      final q = HangulQuery.parse('ㅇㅆㄹ');
      expect(q.matches('어썸레드'), isTrue);
      expect(q.matches('어반라운지'), isFalse);
    });

    test('영문 이름은 자모와 섞이지 않는다', () {
      expect(HangulQuery.parse('ㅋ').matches('OCTAGON'), isFalse);
    });
  });

  group('highlightIn — 강조 구간', () {
    test('자모가 걸린 글자까지 강조한다', () {
      final m = HangulQuery.parse('홍대 ㅇ').highlightIn('어썸레드')!;
      expect('어썸레드'.substring(m.start, m.end), '어');
    });

    test('완성형 + 자모는 이어진 구간을 통째로 강조한다', () {
      final m = HangulQuery.parse('어ㅆ').highlightIn('어썸레드')!;
      expect('어썸레드'.substring(m.start, m.end), '어썸');
    });

    test('자모가 없으면 검색어가 나온 구간을 강조한다 (앞부분이 아니어도)', () {
      final m = HangulQuery.parse('테이션').highlightIn('클럽 스테이션')!;
      expect('클럽 스테이션'.substring(m.start, m.end), '테이션');
    });

    test('친 글자가 떨어져 있으면 구간도 나뉜다', () {
      final r = HangulQuery.parse('홍대 ㅋ').highlightRangesIn('홍대 클럽 프리즘');
      expect(
        r.map((m) => '홍대 클럽 프리즘'.substring(m.start, m.end)),
        ['홍대', '클'],
      );
    });

    test('겹치는 구간은 하나로 합친다', () {
      final r = HangulQuery.parse('어ㅆ').highlightRangesIn('어썸레드');
      expect(r.map((m) => '어썸레드'.substring(m.start, m.end)), ['어썸']);
    });

    test('자모가 없어도 토큰마다 따로 강조한다', () {
      final r = HangulQuery.parse('홍대 어').highlightRangesIn('홍대 클럽 도어');
      expect(
        r.map((m) => '홍대 클럽 도어'.substring(m.start, m.end)),
        ['홍대', '어'],
      );
    });

    test('매칭이 없으면 null', () {
      expect(HangulQuery.parse('강남').highlightIn('어썸레드'), isNull);
    });
  });

  test('chosungOf — 공백은 빼고 초성만', () {
    expect(chosungOf('홍대 클럽 도어'), 'ㅎㄷㅋㄹㄷㅇ');
    expect(chosungOf('어썸레드'), 'ㅇㅅㄹㄷ'); // ㅆ → ㅅ 정규화
  });
}
