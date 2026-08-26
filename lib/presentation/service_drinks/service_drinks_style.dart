import 'package:flutter/material.dart';
import 'package:vybe/design_system/colors.dart';
import 'package:vybe/presentation/common/club_list_sorting.dart';

/// 서비스 음료 화면 전용 색·상수.

/// 서비스음료 포인트 색 — 브랜드 라임.
/// (예전엔 화면 전용 시안. 카테고리 페이지마다 포인트가 달라 브랜드로 통일)
const Color kDrinkAccent = VybeColors.mainLime500;

/// 라임 위에 얹는 어두운 텍스트/아이콘 색 (배경 잉크와 같은 톤).
const Color kDrinkInk = Color(0xFF0E0D12);

/// 종류 필터 칩. `clubs.serviceDrink.drinks` 값과 문자열이 같아야 필터가 걸린다.
const List<String> kDrinkTypes = [
  kFilterAll,
  '양주',
  '샴페인',
  '칵테일',
  '맥주',
  '와인',
];

/// 카드 높이 (스켈레톤과 같은 값을 써야 로딩→데이터 전환에 튀지 않는다).
const double kDrinkCardHeight = 208;

/// 썸네일이 없을 때 clubId 해시로 고르는 일관 그라데이션.
const List<List<Color>> kDrinkFallbackGradients = <List<Color>>[
  [VybeColors.accentBlue500, VybeColors.mainPurple500],
  [Color(0xFFFF006E), Color(0xFF8338EC)],
  [Color(0xFFF72585), Color(0xFFB5179E)],
  [Color(0xFF3A0CA3), Color(0xFF4361EE)],
  [Color(0xFF2B1655), Color(0xFFFF4D8D)],
  [Color(0xFF06FFA5), Color(0xFF3A86FF)],
  [Color(0xFF06FFA5), Color(0xFF1B9AAA)],
  [Color(0xFF6D4C91), Color(0xFF2A2D34)],
];
