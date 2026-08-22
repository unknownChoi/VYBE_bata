import 'package:vybe/core/utils/number_format.dart';

// 테이블 금액 표기. 배치도 도형·상세 카드·홈 요약이 **같은 문구**를 쓰도록 한 곳에 둔다.
//
// Firestore 에는 원 단위 정수만 저장한다(`price: 1000000`). 업주가 '100만원'·'100만'·
// '1000000' 을 제각각 입력하는 문자열이면 정렬·비교가 불가능해진다.

/// 배치도 도형 안에 들어가는 짧은 표기 — `1000000 → '100만'`.
///
/// 도형이 좁아 글자 수가 곧 가독성이라 만 단위로 줄인다.
/// 만 단위로 안 떨어지면 소수 한 자리(`1250000 → '125만'`, `1234000 → '123.4만'`).
String formatTablePriceShort(int won) {
  if (won <= 0) return '문의';
  if (won < 10000) return formatThousands(won);

  final man = won / 10000;
  if (won % 10000 == 0) return '${man.toInt()}만';
  return '${man.toStringAsFixed(1)}만';
}

/// 상세 카드용 정식 표기 — `1000000 → '1,000,000원'`.
String formatWon(int won) {
  if (won <= 0) return '문의';
  return '${formatThousands(won)}원';
}
