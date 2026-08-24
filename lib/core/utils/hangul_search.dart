/// 한글 IME 조합 중 자모까지 감안한 검색어 처리 (순수 함수 — Firebase 의존 없음).
///
/// 검색엔진(Algolia)은 **완성형 음절 토큰만** 인덱싱한다. 한글을 치는 중에는
/// 마지막 글자가 단독 자모('ㅇ' U+3147)로 남는데, 이 문자는 인덱스 어디에도 없다.
/// 그대로 던지면 엔진의 AND 매칭이 결과를 통째로 0건으로 만든다
/// (실측: `홍대` 57건 · `홍대 어` 4건 → **`홍대 ㅇ` 0건**).
///
/// 그래서 자모는 **엔진에 보내지 않고**([engineQuery]), 받아온 결과의 **초성**으로
/// 클라에서 거른다([matches]). '홍대 ㅇ' → 엔진에 '홍대' → 결과 중 초성에 ㅇ이
/// 있는 곳(어썸레드 …)만 남는다.
library;

/// 유니코드 완성형 한글 음절 구간.
const int _syllableBase = 0xAC00;
const int _syllableLast = 0xD7A3;
const int _syllableChosungStride = 588; // 초성 1칸 = 중성21 × 종성28

/// 초성 19자 (완성형 음절의 초성 인덱스 순서 그대로).
const String _chosungTable = 'ㄱㄲㄴㄷㄸㄹㅁㅂㅃㅅㅆㅇㅈㅉㅊㅋㅌㅍㅎ';

/// 호환 자모(단독 자모) 구간 — 조합 중인 글자가 여기에 들어온다.
const int _compatJamoFirst = 0x3131; // ㄱ
const int _compatJamoLast = 0x318E;

/// 쌍자음은 홑자음으로 눕힌다 — 'ㅅ'을 쳐도 '썸'이 걸리게.
/// 입력이 관대한 쪽이 검색에 맞다(사용자는 자기가 쌍자음을 쳤는지 신경 안 쓴다).
const Map<String, String> _doubleToSingle = {
  'ㄲ': 'ㄱ',
  'ㄸ': 'ㄷ',
  'ㅃ': 'ㅂ',
  'ㅆ': 'ㅅ',
  'ㅉ': 'ㅈ',
};

bool _isCompatJamo(int rune) =>
    rune >= _compatJamoFirst && rune <= _compatJamoLast;

/// 초성으로 쓸 수 있는 자음인지. 모음(ㅏ~ㅣ)과 겹받침(ㄳ·ㄺ…)은 초성이 못 되므로
/// 매칭에 쓰지 않고 버린다 — 억지로 맞추면 엉뚱한 결과가 섞인다.
bool _isChosungJamo(String ch) =>
    _chosungTable.contains(_doubleToSingle[ch] ?? ch);

String _normalize(String ch) => _doubleToSingle[ch] ?? ch;

/// [text]의 초성열 + 각 초성이 [text]의 몇 번째 글자에서 왔는지.
/// 공백은 건너뛴다 — '홍대 클럽'의 초성열은 'ㅎㄷㅋㄹ'.
class _Chosung {
  final String value;
  final List<int> sourceIndex;

  const _Chosung(this.value, this.sourceIndex);
}

_Chosung _chosungOf(String text) {
  final buffer = StringBuffer();
  final indexes = <int>[];
  final units = text.runes.toList();
  for (var i = 0; i < units.length; i++) {
    final rune = units[i];
    final ch = String.fromCharCode(rune);
    if (ch.trim().isEmpty) continue; // 공백류
    if (rune >= _syllableBase && rune <= _syllableLast) {
      final index = (rune - _syllableBase) ~/ _syllableChosungStride;
      buffer.write(_normalize(_chosungTable[index]));
    } else {
      // 한글이 아니면 그 문자를 그대로 — 영문·숫자 이름이 자모와 섞이지 않게.
      buffer.write(_normalize(ch));
    }
    indexes.add(i);
  }
  return _Chosung(buffer.toString(), indexes);
}

/// [text]의 초성열 (디버깅·테스트용).
String chosungOf(String text) => _chosungOf(text).value;

/// 강조할 구간 (끝 인덱스는 미포함).
class HangulMatch {
  final int start;
  final int end;

  /// 걸린 자리가 **단어 첫 글자**인지 (앞이 문자열 처음이거나 공백).
  ///
  /// 정렬용 — '홍대 ㅋ'을 치면 사람은 '홍대 <b>클</b>럽 …'처럼 **다음 단어**를
  /// 시작하는 중이다. 단어 중간에 걸린 이름('나<b>인</b>')보다 위에 와야 한다.
  final bool wordStart;

  const HangulMatch(this.start, this.end, {this.wordStart = false});
}

/// [text]의 [index] 글자가 단어 첫 글자인지.
bool _isWordStart(String text, int index) =>
    index <= 0 || text[index - 1].trim().isEmpty;

/// 검색어 토큰 하나 — 완성된 앞부분([head])과 조합 중인 자모 꼬리([jamo]).
///
/// '어ㅆ'을 치는 중이면 head='어', jamo='ㅅ'(쌍자음은 눕힌 값).
class HangulTerm {
  final String head;
  final String jamo;

  const HangulTerm({required this.head, required this.jamo});

  /// [text]가 이 토큰과 맞는지 — head 바로 뒤 글자들의 초성이 jamo와 이어지는지.
  bool matches(String text) => _match(text) != null;

  /// 맞으면 강조 구간, 아니면 null.
  HangulMatch? _match(String text) {
    final lower = text.toLowerCase();
    final chosung = _chosungOf(lower);
    final h = head.toLowerCase();

    if (h.isEmpty) return _chosungMatch(lower, chosung, jamo);

    var from = 0;
    while (from <= lower.length - h.length) {
      final i = lower.indexOf(h, from);
      if (i < 0) break;
      final tail = _chosungOf(lower.substring(i + h.length));
      if (tail.value.startsWith(jamo)) {
        // head + 자모가 가리키는 글자까지 강조 (자모 n개 = 뒤 n글자).
        final lastJamoIndex = tail.sourceIndex[jamo.length - 1];
        return HangulMatch(
          i,
          i + h.length + lastJamoIndex + 1,
          wordStart: _isWordStart(lower, i),
        );
      }
      from = i + 1;
    }

    // 이름에 head가 아예 없는 결과(태그·장르로 걸린 것)는 초성만으로 판단한다 —
    // 엔진이 이미 head로 좁혀 준 결과라 여기서 더 막을 이유가 없다.
    if (!lower.contains(h)) return _chosungMatch(lower, chosung, jamo);
    return null;
  }

  static HangulMatch? _chosungMatch(
    String text,
    _Chosung chosung,
    String jamo,
  ) {
    // 단어 첫 글자에서 걸린 자리를 먼저 찾는다 — '홍대 ㅋ'이 '홍대 클럽 …'의
    // '클'을 가리키게. 없으면 예전처럼 아무 자리나(단어 중간) 허용한다.
    var at = -1;
    for (var i = chosung.value.indexOf(jamo); i >= 0;
        i = chosung.value.indexOf(jamo, i + 1)) {
      if (at < 0) at = i;
      if (_isWordStart(text, chosung.sourceIndex[i])) {
        at = i;
        break;
      }
    }
    if (at < 0) return null;
    return HangulMatch(
      chosung.sourceIndex[at],
      chosung.sourceIndex[at + jamo.length - 1] + 1,
      wordStart: _isWordStart(text, chosung.sourceIndex[at]),
    );
  }
}

/// 검색어를 '엔진에 던질 부분'과 '클라에서 초성으로 거를 부분'으로 나눈 결과.
class HangulQuery {
  /// 조합 중 자모를 뺀, 검색엔진에 그대로 던질 검색어.
  final String engineQuery;

  /// 완성된 토큰들 ('홍대 ㅋ' → ['홍대']). 강조 구간을 토큰마다 따로 잡는 데 쓴다.
  final List<String> heads;

  /// 자모 꼬리가 붙은 토큰들. 비어 있으면 평소처럼 엔진 결과를 그대로 쓴다.
  final List<HangulTerm> jamoTerms;

  const HangulQuery({
    required this.engineQuery,
    required this.heads,
    required this.jamoTerms,
  });

  bool get hasJamo => jamoTerms.isNotEmpty;

  static HangulQuery parse(String query) {
    final heads = <String>[];
    final terms = <HangulTerm>[];

    for (final token in query.trim().split(RegExp(r'\s+'))) {
      if (token.isEmpty) continue;
      final head = StringBuffer();
      final jamo = StringBuffer();
      for (final rune in token.runes) {
        final ch = String.fromCharCode(rune);
        if (_isCompatJamo(rune)) {
          // 초성이 될 수 없는 자모(모음·겹받침)는 매칭에 못 쓰므로 버린다.
          if (_isChosungJamo(ch)) jamo.write(_normalize(ch));
        } else {
          head.write(ch);
        }
      }
      if (head.isNotEmpty) heads.add(head.toString());
      if (jamo.isNotEmpty) {
        terms.add(HangulTerm(head: head.toString(), jamo: jamo.toString()));
      }
    }

    return HangulQuery(
      engineQuery: heads.join(' '),
      heads: heads,
      jamoTerms: terms,
    );
  }

  /// 엔진 결과 [text]가 조합 중 자모까지 만족하는지.
  bool matches(String text) => jamoTerms.every((t) => t.matches(text));

  /// [text]에서 강조할 구간 **전부** — 완성된 토큰 자리 + 조합 중 자모 자리.
  ///
  /// 구간이 하나가 아닌 이유 — '홍대 ㅋ'이면 '<b>홍대</b> <b>클</b>럽 프리즘'처럼
  /// 친 글자가 전부 물들어야 한다. 자모 구간만 칠하면 '홍대'가 왜 걸렸는지 안 보이고,
  /// 반대로 처음~자모까지 통으로 칠하면 안 친 글자('럽 …')까지 칠해진다.
  List<HangulMatch> highlightRangesIn(String text) {
    final lower = text.toLowerCase();
    final ranges = <HangulMatch>[];

    // 토큰은 친 순서대로 앞에서부터 찾는다. 그 뒤에 없으면(순서가 다른 이름)
    // 처음부터 다시 찾는다 — 엔진이 걸어 준 결과라 어디서든 칠할 값은 있다.
    var from = 0;
    for (final head in heads) {
      final h = head.toLowerCase();
      if (h.isEmpty) continue;
      var at = lower.indexOf(h, from);
      if (at < 0) at = lower.indexOf(h);
      if (at < 0) continue;
      ranges.add(HangulMatch(at, at + h.length));
      from = at + h.length;
    }
    for (final term in jamoTerms) {
      final match = term._match(text);
      if (match != null) ranges.add(match);
    }
    if (ranges.isEmpty) return const [];

    // 겹치거나 맞닿은 구간은 합친다 ('어ㅆ'은 head '어'와 매치 '어썸'이 겹친다).
    ranges.sort((a, b) => a.start - b.start);
    final merged = <HangulMatch>[ranges.first];
    for (final r in ranges.skip(1)) {
      final last = merged.last;
      if (r.start <= last.end) {
        merged[merged.length - 1] = HangulMatch(
          last.start,
          r.end > last.end ? r.end : last.end,
        );
      } else {
        merged.add(r);
      }
    }
    return merged;
  }

  /// [text]에서 강조할 구간. 자모가 없으면 검색어 앞부분 일치로 폴백한다.
  HangulMatch? highlightIn(String text) {
    for (final term in jamoTerms) {
      final match = term._match(text);
      if (match != null) return match;
    }
    if (engineQuery.isEmpty) return null;
    final lower = text.toLowerCase();
    final at = lower.indexOf(engineQuery.toLowerCase());
    if (at < 0) return null;
    return HangulMatch(
      at,
      at + engineQuery.length,
      wordStart: _isWordStart(lower, at),
    );
  }
}
