import 'package:flutter/material.dart';
import 'package:vybe/design_system/colors.dart';

// 테이블 등급·배치 데이터. Firestore 스키마가 없어 화면 상수로 둔다.

// ── 티어 메타 ──
class TableTier {
  final String name; // 상세 배지 라벨
  final String short; // 플로어맵 표시 라벨
  final Color color; // 텍스트 accent
  final Color dot; // 범례 dot / 선택 border
  final Color selBg; // 선택 배경
  final Color soft; // 미선택 배경
  final Color ring; // 미선택 border
  const TableTier({
    required this.name,
    required this.short,
    required this.color,
    required this.dot,
    required this.selBg,
    required this.soft,
    required this.ring,
  });
}

const kTableTiers = <String, TableTier>{
  'VVIP': TableTier(
    name: 'VVIP',
    short: 'VVIP',
    color: Color(0xFFC8A8FF),
    dot: VybeColors.mainPurple500,
    selBg: VybeColors.mainPurple500,
    soft: Color(0x297731FE), // rgba(119,49,254,0.16)
    ring: Color(0x807731FE), // rgba(119,49,254,0.5)
  ),
  'VIP': TableTier(
    name: 'VIP',
    short: 'VIP',
    color: Color(0xFF8FB5FF),
    dot: VybeColors.accentBlue500,
    selBg: VybeColors.accentBlue500,
    soft: Color(0x242B6BFF), // rgba(43,107,255,0.14)
    ring: Color(0x802B6BFF), // rgba(43,107,255,0.5)
  ),
  'STD': TableTier(
    name: 'STANDARD',
    short: 'STD',
    color: VybeColors.gray300,
    dot: VybeColors.gray500,
    selBg: VybeColors.gray700,
    soft: Color(0x0DFFFFFF), // rgba(255,255,255,0.05)
    ring: Color(0x33FFFFFF), // rgba(255,255,255,0.2)
  ),
};

// ── 자리 데이터 ──
class ClubTable {
  final String id;
  final String tierKey;
  final String name;
  final String desc;
  final String price; // 플로어맵 표시 (예 '100만')
  final int minPeople;
  final int minBottles;
  final String minSpend; // 상세 (예 '1,000,000원')
  // 위치: left/right 는 컨테이너 너비 대비 비율, top 은 px(393 기준).
  final double? left;
  final double? right;
  final double top;
  const ClubTable({
    required this.id,
    required this.tierKey,
    required this.name,
    required this.desc,
    required this.price,
    required this.minPeople,
    required this.minBottles,
    required this.minSpend,
    this.left,
    this.right,
    required this.top,
  });
}

const kClubFloorTables = <ClubTable>[
  ClubTable(
    id: 'S1',
    tierKey: 'VVIP',
    name: '스테이지 프론트 A',
    desc: '무대 바로 앞 · 최고의 시야',
    price: '100만',
    minPeople: 8,
    minBottles: 3,
    minSpend: '1,000,000원',
    left: 0.05,
    top: 62,
  ),
  ClubTable(
    id: 'S2',
    tierKey: 'VVIP',
    name: '스테이지 프론트 B',
    desc: '무대 바로 앞 · 최고의 시야',
    price: '100만',
    minPeople: 8,
    minBottles: 3,
    minSpend: '1,000,000원',
    right: 0.05,
    top: 62,
  ),
  ClubTable(
    id: 'V1',
    tierKey: 'VIP',
    name: '센터 사이드 1',
    desc: '플로어 옆 · 활기찬 자리',
    price: '50만',
    minPeople: 6,
    minBottles: 2,
    minSpend: '500,000원',
    left: 0.03,
    top: 126,
  ),
  ClubTable(
    id: 'V2',
    tierKey: 'VIP',
    name: '센터 사이드 2',
    desc: '플로어 옆 · 활기찬 자리',
    price: '50만',
    minPeople: 6,
    minBottles: 2,
    minSpend: '500,000원',
    right: 0.03,
    top: 126,
  ),
  ClubTable(
    id: 'V3',
    tierKey: 'VIP',
    name: '센터 사이드 3',
    desc: '플로어 옆 · 활기찬 자리',
    price: '50만',
    minPeople: 6,
    minBottles: 2,
    minSpend: '500,000원',
    left: 0.03,
    top: 188,
  ),
  ClubTable(
    id: 'V4',
    tierKey: 'VIP',
    name: '센터 사이드 4',
    desc: '플로어 옆 · 활기찬 자리',
    price: '50만',
    minPeople: 6,
    minBottles: 2,
    minSpend: '500,000원',
    right: 0.03,
    top: 188,
  ),
  ClubTable(
    id: 'T1',
    tierKey: 'STD',
    name: '바 라운지 1',
    desc: '바 근처 · 편안한 자리',
    price: '20만',
    minPeople: 4,
    minBottles: 1,
    minSpend: '200,000원',
    left: 0.04,
    top: 288,
  ),
  ClubTable(
    id: 'T2',
    tierKey: 'STD',
    name: '바 라운지 2',
    desc: '바 근처 · 편안한 자리',
    price: '20만',
    minPeople: 4,
    minBottles: 1,
    minSpend: '200,000원',
    left: 0.37,
    top: 288,
  ),
  ClubTable(
    id: 'T3',
    tierKey: 'STD',
    name: '바 라운지 3',
    desc: '바 근처 · 편안한 자리',
    price: '20만',
    minPeople: 4,
    minBottles: 1,
    minSpend: '200,000원',
    right: 0.04,
    top: 288,
  ),
];
