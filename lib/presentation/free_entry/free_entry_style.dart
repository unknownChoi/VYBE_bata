import 'package:flutter/material.dart';
import 'package:vybe/design_system/colors.dart';
import 'package:vybe/presentation/common/club_list_sorting.dart';

/// 입장비 무료 화면 전용 색·상수.

/// 무료입장 액센트 (hot pink).
const Color kEntryAccent = Color(0xFFFF4D8D);

/// pink 위에 얹는 어두운 텍스트/아이콘 색.
const Color kEntryInk = Color(0xFF2A0712);

/// 백드롭 잉크 — 핑크 계열이라 기본 배경보다 살짝 붉게.
const Color kEntryBackdropInk = Color(0xFF0D0A0C);

/// 지역 필터 칩. `clubs.area` 값과 문자열이 같아야 필터가 걸린다.
const List<String> kEntryRegions = [kFilterAll, '홍대', '강남', '이태원', '압구정', '건대'];

/// 이 화면 전용 정렬 옵션 — 기본은 '지금 무료순'.
///
/// 공용 [kClubSorts] 에 넣지 않는 이유: 무료 시간대가 없는 화면(서비스 음료 등)에서는
/// 고를 수 없는 값이 된다.
const String kSortFreeNow = '지금 무료순';
const List<String> kEntrySorts = [kSortFreeNow, ...kClubSorts];

/// 카드 높이 (스켈레톤과 같은 값을 써야 로딩→데이터 전환에 튀지 않는다).
const double kEntryCardHeight = 208;

/// 썸네일이 없을 때 clubId 해시로 고르는 일관 그라데이션.
const List<List<Color>> kEntryFallbackGradients = <List<Color>>[
  [Color(0xFF2B1655), Color(0xFFFF4D8D)],
  [Color(0xFF06FFA5), Color(0xFF3A86FF)],
  [VybeColors.accentBlue500, VybeColors.mainPurple500],
  [Color(0xFF3A0CA3), Color(0xFF4361EE)],
  [Color(0xFFFF006E), Color(0xFF8338EC)],
  [Color(0xFFF72585), Color(0xFFB5179E)],
  [Color(0xFF06FFA5), Color(0xFF1B9AAA)],
  [Color(0xFF6D4C91), Color(0xFF2A2D34)],
];
