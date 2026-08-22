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

/// 무대·DJ 부스는 클럽의 기준점이라 보라로 강조하고, 나머지는 무채색으로 둔다 —
/// 배치도에서 눈에 띄어야 하는 건 테이블이지 구조물이 아니다.
const FixtureStyle _accentFixture = FixtureStyle(
  fill: Color(0x267731FE),
  border: Color(0x807731FE),
  text: Color(0xFFC8A8FF),
  icon: Icons.album_outlined,
);

const FixtureStyle _outlineFixture = FixtureStyle(
  fill: Color(0x04FFFFFF),
  border: VybeColors.gray700,
  text: VybeColors.gray500,
);

const FixtureStyle _quietFixture = FixtureStyle(
  fill: Color(0x0AFFFFFF),
  border: VybeColors.gray800,
  text: VybeColors.gray400,
);

const FixtureStyle _wallFixture = FixtureStyle(
  fill: Color(0x1AFFFFFF),
  border: Color(0x1AFFFFFF),
  text: Colors.transparent,
);

FixtureStyle fixtureStyleOf(String typeKey) => switch (typeKey) {
  'stage' || 'dj' => _accentFixture,
  'dancefloor' => _outlineFixture,
  'wall' => _wallFixture,
  _ => _quietFixture,
};
