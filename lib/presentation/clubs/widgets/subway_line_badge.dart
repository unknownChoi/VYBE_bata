import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vybe/design_system/colors.dart';

/// 한국 수도권 전철 노선별 공식 상징색.
/// key 는 정규화된 노선명("2호선", "경의중앙선" 등).
const Map<String, Color> _kSubwayLineColors = {
  '1호선': Color(0xFF0052A4),
  '2호선': Color(0xFF00A84D),
  '3호선': Color(0xFFEF7C1C),
  '4호선': Color(0xFF00A5DE),
  '5호선': Color(0xFF996CAC),
  '6호선': Color(0xFFCD7C2F),
  '7호선': Color(0xFF747F00),
  '8호선': Color(0xFFE6186C),
  '9호선': Color(0xFFBB8336),
  '경의중앙선': Color(0xFF77C4A3),
  '공항철도': Color(0xFF0090D2),
  '신분당선': Color(0xFFD31145),
  '수인분당선': Color(0xFFFABE00),
  '분당선': Color(0xFFFABE00),
  '경춘선': Color(0xFF0C8E72),
  '경강선': Color(0xFF003DA5),
  '서해선': Color(0xFF8FC31F),
  '우이신설선': Color(0xFFB7C452),
  '김포골드라인': Color(0xFFAD8605),
  '신림선': Color(0xFF6789CA),
  '인천1호선': Color(0xFF7CA8D5),
  '인천2호선': Color(0xFFED8B00),
  '의정부경전철': Color(0xFFFDA600),
  '용인에버라인': Color(0xFF509F46),
  'GTX-A': Color(0xFF99509E),
};

/// 원형 뱃지 안에 보여줄 한 글자 라벨(명칭 노선용).
const Map<String, String> _kSubwayLineLabels = {
  '경의중앙선': '경',
  '공항철도': '공',
  '신분당선': '신',
  '수인분당선': '수',
  '분당선': '분',
  '경춘선': '춘',
  '경강선': '강',
  '서해선': '서',
  '우이신설선': '우',
  '김포골드라인': '김',
  '신림선': '림',
  '인천1호선': '인',
  '인천2호선': '인',
  '의정부경전철': '의',
  '용인에버라인': '에',
};

/// 입력 노선명을 map key 형태로 정규화. (앞뒤 공백 제거)
String _normalizeLine(String line) => line.trim();

/// "2호선" → 2 처럼 숫자 노선이면 숫자 반환, 아니면 null.
int? _numericLine(String line) {
  final m = RegExp(r'^(\d+)호선$').firstMatch(line);
  if (m != null) return int.parse(m.group(1)!);
  if (RegExp(r'^\d+$').hasMatch(line)) return int.parse(line);
  return null;
}

/// 한국 지하철 노선명 → 상징색 반환. 미등록 노선은 회색.
Color subwayLineColor(String line) =>
    _kSubwayLineColors[_normalizeLine(line)] ?? VybeColors.gray700;

/// 배경색 위에서 가독성 좋은 글자색(밝으면 검정, 어두우면 흰색).
Color _onColor(Color bg) =>
    bg.computeLuminance() > 0.6 ? Colors.black : Colors.white;

/// 지하철 노선 뱃지.
/// 숫자 노선(1~9호선)은 원형 + 숫자, 명칭 노선은 알약형 + 짧은 라벨.
///
/// ```dart
/// SubwayLineBadge(line: '2호선')
/// SubwayLineBadge(line: '경의중앙선')
/// ```
class SubwayLineBadge extends StatelessWidget {
  final String line;
  const SubwayLineBadge({super.key, required this.line});

  @override
  Widget build(BuildContext context) {
    final normalized = _normalizeLine(line);
    final bg = subwayLineColor(normalized);
    final fg = _onColor(bg);
    final numeric = _numericLine(normalized);
    // 숫자 노선은 숫자, 명칭 노선은 한 글자 라벨.
    final label = numeric != null
        ? '$numeric'
        : (_kSubwayLineLabels[normalized] ?? normalized.characters.first);

    return Container(
      width: 18.r,
      height: 18.r,
      decoration: BoxDecoration(color: bg, shape: BoxShape.circle),
      alignment: Alignment.center,
      child: Text(
        label,
        style: TextStyle(
          fontFamily: 'Pretendard',
          fontWeight: FontWeight.w600,
          fontSize: 11.sp,
          color: fg,
          letterSpacing: -0.5,
          height: 1,
        ),
      ),
    );
  }
}
