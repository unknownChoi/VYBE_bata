import 'package:flutter/widgets.dart';

/// Vybe 디자인 시스템 색상
///
/// Figma 'Color' 섹션 기준
class VybeColors {
  VybeColors._();

  // ---------------------------------------------------------------------------
  // Main Purple
  // ---------------------------------------------------------------------------

  static const Color mainPurple500 = Color(0xFF7731FE);
  static const Color mainPurple700 = Color(0xFF622ACF);
  static const Color mainPurple900 = Color(0xFF4E24A0);

  /// disabled 상태에서 사용
  static const Color mainPurpleDisabled = Color(0xFF2F1A5A);

  // ---------------------------------------------------------------------------
  // Main Lime
  // ---------------------------------------------------------------------------

  static const Color mainLime500 = Color(0xFFB5FF60);
  static const Color mainLime700 = Color(0xFF94CF51);
  static const Color mainLime900 = Color(0xFF739F41);

  /// disabled 상태에서 사용
  static const Color mainLimeDisabled = Color(0xFF42582A);

  // ---------------------------------------------------------------------------
  // Gray Scale
  // ---------------------------------------------------------------------------

  static const Color gray100 = Color(0xFFF8F8F8);
  static const Color gray200 = Color(0xFFECECEC);
  static const Color gray300 = Color(0xFFDBDBDC);
  static const Color gray400 = Color(0xFFCACACA);
  static const Color gray500 = Color(0xFF9F9FA1);
  static const Color gray600 = Color(0xFF707071);
  static const Color gray700 = Color(0xFF535355);
  static const Color gray800 = Color(0xFF404042);
  static const Color gray900 = Color(0xFF2F2F33);

  // ---------------------------------------------------------------------------
  // Accent — Red
  // ---------------------------------------------------------------------------

  static const Color accentRed500 = Color(0xFFFF5C5F);
  static const Color accentRed700 = Color(0xFFCF4D50);
  static const Color accentRed900 = Color(0xFF9F3E40);

  // ---------------------------------------------------------------------------
  // Accent — Blue
  // ---------------------------------------------------------------------------

  static const Color accentBlue500 = Color(0xFF2B6BFF);
  static const Color accentBlue700 = Color(0xFF2659D0);
  static const Color accentBlue900 = Color(0xFF2047A1);

  // ---------------------------------------------------------------------------
  // Semantic — Background / Surface
  // ---------------------------------------------------------------------------

  /// 앱 기본 배경색
  static const Color background = Color(0xFF101013);

  /// 카드, 바텀시트 등 컨텐츠 레이어 배경
  static const Color surface = Color(0xFF1A1A1E);
}
