import 'package:flutter/material.dart';
import 'package:vybe/design_system/colors.dart';

// 테이블 배치도 색·아이콘 대응표.
//
// Firestore 에는 `colorKey`(purple·blue·gray…) 만 저장하고 실제 색값은 앱이 갖는다.
// 업주가 hex 를 자유 입력하게 두면 다크 배경에 안 보이는 색(#111 위 #222)이 나오고,
// 앱 테마를 바꿀 때 전 클럽 문서를 손봐야 한다. `ClubFacility` 와 같은 규칙.

/// 등급 하나에 쓰이는 색 묶음.
class TableTierStyle {
  /// 텍스트·아이콘 accent (밝은 쪽).
  final Color text;

  /// 범례 dot · 선택 테두리 (진한 쪽).
  final Color dot;

  /// 선택된 도형 배경.
  final Color selectedFill;

  /// 미선택 도형 배경 (반투명).
  final Color fill;

  /// 미선택 도형 테두리 (반투명).
  final Color border;

  const TableTierStyle({
    required this.text,
    required this.dot,
    required this.selectedFill,
    required this.fill,
    required this.border,
  });
}

/// `colorKey` → 색 묶음. 모르는 키는 [kGrayTierStyle].
const Map<String, TableTierStyle> kTableTierStyles = {
  'purple': TableTierStyle(
    text: Color(0xFFC8A8FF),
    dot: VybeColors.mainPurple500,
    selectedFill: VybeColors.mainPurple500,
    fill: Color(0x297731FE),
    border: Color(0x807731FE),
  ),
  'blue': TableTierStyle(
    text: Color(0xFF8FB5FF),
    dot: VybeColors.accentBlue500,
    selectedFill: VybeColors.accentBlue500,
    fill: Color(0x242B6BFF),
    border: Color(0x802B6BFF),
  ),
  'lime': TableTierStyle(
    text: Color(0xFFD3FFA0),
    dot: VybeColors.mainLime500,
    selectedFill: VybeColors.mainLime700,
    fill: Color(0x24B5FF60),
    border: Color(0x80B5FF60),
  ),
  'pink': TableTierStyle(
    text: Color(0xFFFFA8C8),
    dot: Color(0xFFFF4D8D),
    selectedFill: Color(0xFFCF3E71),
    fill: Color(0x24FF4D8D),
    border: Color(0x80FF4D8D),
  ),
  'amber': TableTierStyle(
    text: Color(0xFFFFD79A),
    dot: Color(0xFFFFA726),
    selectedFill: Color(0xFFCF861F),
    fill: Color(0x24FFA726),
    border: Color(0x80FFA726),
  ),
  'gray': kGrayTierStyle,
};

/// 모르는 `colorKey` 폴백. 색을 지어내지 않고 무채색으로 떨어뜨린다.
const TableTierStyle kGrayTierStyle = TableTierStyle(
  text: VybeColors.gray300,
  dot: VybeColors.gray500,
  selectedFill: VybeColors.gray700,
  fill: Color(0x0DFFFFFF),
  border: Color(0x33FFFFFF),
);

TableTierStyle tierStyleOf(String colorKey) =>
    kTableTierStyles[colorKey] ?? kGrayTierStyle;

/// 편집기에서 고를 수 있는 색 키 목록 (문서·seed 와 공유).
const List<String> kTableTierColorKeys = [
  'purple',
  'blue',
  'lime',
  'pink',
  'amber',
  'gray',
];

// ── 구조물 ──

/// 구조물 도형의 색·아이콘.
class FixtureStyle {
  final Color fill;
  final Color border;
  final Color text;
  final IconData? icon;

  const FixtureStyle({
    required this.fill,
    required this.border,
    required this.text,
    this.icon,
  });
}

/// `fixture.type` → 색·아이콘. **타입마다 고정**이고 업주가 못 바꾼다.
///
/// 색을 업주 손에 맡기면 클럽마다 무대가 다른 색이 되어, 사용자가 배치도를 볼 때
/// 색으로 무엇인지 알아보는 학습이 통째로 무너진다. 등급(tier)만 클럽별로 다르고
/// 구조물은 앱이 정한 색을 쓴다.
///
/// ⚠ `partner/editor.js` 의 `FX_STYLE` 과 **같은 값이어야 한다** —
///   어긋나면 업주가 편집기에서 보는 색과 앱이 보여주는 색이 달라진다.
const Map<String, FixtureStyle> kFixtureStyles = {
  // 무대 — 클럽의 기준점. 가장 강한 보라.
  'stage': FixtureStyle(
    fill: Color(0x337731FE),
    border: Color(0x8C7731FE),
    text: Color(0xFFC8A8FF),
    icon: Icons.music_note_rounded,
  ),
  // DJ 부스 — 무대 옆에 붙는 경우가 많아 무대와 구분되는 핑크.
  'dj': FixtureStyle(
    fill: Color(0x29FF4D8D),
    border: Color(0x80FF4D8D),
    text: Color(0xFFFFA8C8),
    icon: Icons.album_outlined,
  ),
  // 댄스플로어 — 면적이 가장 넓어 옅게. 진하면 테이블을 덮어 보인다.
  'dancefloor': FixtureStyle(
    fill: Color(0x1A2DD4D0),
    border: Color(0x6B2DD4D0),
    text: Color(0xFF7FE3E0),
    icon: Icons.blur_on_rounded,
  ),
  'bar': FixtureStyle(
    fill: Color(0x29FFA726),
    border: Color(0x80FFA726),
    text: Color(0xFFFFD79A),
    icon: Icons.local_bar_outlined,
  ),
  // 입구 — 안내 표지 관례대로 초록 계열.
  'entrance': FixtureStyle(
    fill: Color(0x24B5FF60),
    border: Color(0x80B5FF60),
    text: Color(0xFFD3FFA0),
    icon: Icons.meeting_room_outlined,
  ),
  'restroom': FixtureStyle(
    fill: Color(0x242B6BFF),
    border: Color(0x802B6BFF),
    text: Color(0xFF8FB5FF),
    icon: Icons.wc_rounded,
  ),
  'stairs': FixtureStyle(
    fill: Color(0x14FFFFFF),
    border: Color(0x47FFFFFF),
    text: Color(0xFFB9B9C6),
    icon: Icons.stairs_outlined,
  ),
  // 벽 — 글자 없이 덩어리로만 보인다.
  'wall': FixtureStyle(
    fill: Color(0x24FFFFFF),
    border: Color(0x24FFFFFF),
    text: Colors.transparent,
  ),
  'etc': FixtureStyle(
    fill: Color(0x0AFFFFFF),
    border: VybeColors.gray800,
    text: VybeColors.gray400,
  ),
};

/// 모르는 타입 폴백 — 파서가 이미 모르는 키를 버리므로 실제로는 안 쓰인다.
const FixtureStyle kUnknownFixtureStyle = FixtureStyle(
  fill: Color(0x0AFFFFFF),
  border: VybeColors.gray800,
  text: VybeColors.gray400,
);

FixtureStyle fixtureStyleOf(String typeKey) =>
    kFixtureStyles[typeKey] ?? kUnknownFixtureStyle;
