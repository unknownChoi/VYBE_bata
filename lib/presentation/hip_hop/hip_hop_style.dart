/// 힙합 페이지 공용 색. 힙합 메인·오늘의 라인업이 같은 값을 쓴다.
///
/// 그라데이션·백드롭은 `hip_hop_gradients.dart`.
library;

import 'dart:ui' show Color;

import 'package:vybe/design_system/colors.dart';
import 'package:vybe/presentation/common/widgets/vybe_aurora.dart';

/// 힙합 포인트 색 — 브랜드 라임.
/// (예전엔 화면 전용 골드. 카테고리 페이지마다 포인트가 달라 브랜드로 통일)
const Color kHipAccent = VybeColors.mainLime500;

/// 라임 위에 얹는 어두운 텍스트/아이콘 색 (배경 잉크와 같은 톤).
const Color kHipOnAccent = Color(0xFF0E0D12);

/// 화면 배경 — 오로라 기본 잉크와 같은 값(다른 카테고리 페이지와 동일).
const Color kHipBg = kVybeInk;
