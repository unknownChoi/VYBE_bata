import 'package:flutter/widgets.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Vybe 디자인 시스템 타이포그래피
///
/// Pretendard 폰트 기반, Figma Typo 섹션 기준
/// - fontSize: .sp 단위 (flutter_screenutil)
/// - height: lineHeight / fontSize
/// - letterSpacing: Figma spacing (-2.5%) → fontSize × -0.025
class VybeTypography {
  VybeTypography._();

  // ---------------------------------------------------------------------------
  // Heading
  // ---------------------------------------------------------------------------

  /// Heading 1 — Bold / 32sp / lh 34 / ls -2.5%
  static TextStyle get heading1 => TextStyle(
        fontFamily: 'Pretendard',
        fontWeight: FontWeight.w700,
        fontSize: 32.sp,
        height: 34 / 32,
        letterSpacing: 32 * -0.025,
      );

  /// Heading 2 — Bold / 28sp / lh 30 / ls -2.5%
  static TextStyle get heading2 => TextStyle(
        fontFamily: 'Pretendard',
        fontWeight: FontWeight.w700,
        fontSize: 28.sp,
        height: 30 / 28,
        letterSpacing: 28 * -0.025,
      );

  /// Heading 3 — SemiBold / 24sp / lh 26 / ls -2.5%
  static TextStyle get heading3 => TextStyle(
        fontFamily: 'Pretendard',
        fontWeight: FontWeight.w600,
        fontSize: 24.sp,
        height: 26 / 24,
        letterSpacing: 24 * -0.025,
      );

  /// Heading 4 — SemiBold / 20sp / lh 22 / ls -2.5%
  static TextStyle get heading4 => TextStyle(
        fontFamily: 'Pretendard',
        fontWeight: FontWeight.w600,
        fontSize: 20.sp,
        height: 22 / 20,
        letterSpacing: 20 * -0.025,
      );

  // ---------------------------------------------------------------------------
  // Body
  // ---------------------------------------------------------------------------

  /// Body 1 — Regular / 20sp / lh 22 / ls -2.5%
  static TextStyle get body1 => TextStyle(
        fontFamily: 'Pretendard',
        fontWeight: FontWeight.w400,
        fontSize: 20.sp,
        height: 22 / 20,
        letterSpacing: 20 * -0.025,
      );

  /// Body 2 — Regular / 18sp / lh 20 / ls -2.5%
  static TextStyle get body2 => TextStyle(
        fontFamily: 'Pretendard',
        fontWeight: FontWeight.w400,
        fontSize: 18.sp,
        height: 20 / 18,
        letterSpacing: 18 * -0.025,
      );

  /// Body 3 — Regular / 16sp / lh 18 / ls -2.5%
  static TextStyle get body3 => TextStyle(
        fontFamily: 'Pretendard',
        fontWeight: FontWeight.w400,
        fontSize: 16.sp,
        height: 18 / 16,
        letterSpacing: 16 * -0.025,
      );

  /// Body 4 — Regular / 14sp / lh 16 / ls -2.5%
  static TextStyle get body4 => TextStyle(
        fontFamily: 'Pretendard',
        fontWeight: FontWeight.w400,
        fontSize: 14.sp,
        height: 16 / 14,
        letterSpacing: 14 * -0.025,
      );

  // ---------------------------------------------------------------------------
  // Etc
  // ---------------------------------------------------------------------------

  /// Tagline — Bold / 14sp / lh 24 / ls -2.5%
  static TextStyle get tagline => TextStyle(
        fontFamily: 'Pretendard',
        fontWeight: FontWeight.w700,
        fontSize: 14.sp,
        height: 24 / 14,
        letterSpacing: 14 * -0.025,
      );

  /// Caption — Regular / 12sp / lh 24 / ls -2.5%
  static TextStyle get caption => TextStyle(
        fontFamily: 'Pretendard',
        fontWeight: FontWeight.w400,
        fontSize: 12.sp,
        height: 24 / 12,
        letterSpacing: 12 * -0.025,
      );

  // ---------------------------------------------------------------------------
  // Button
  // ---------------------------------------------------------------------------

  /// Button 1 — SemiBold / 16sp / lh 18 / ls -2.5%
  static TextStyle get button1 => TextStyle(
        fontFamily: 'Pretendard',
        fontWeight: FontWeight.w600,
        fontSize: 16.sp,
        height: 18 / 16,
        letterSpacing: 16 * -0.025,
      );

  /// Button 2 — SemiBold / 14sp / lh 16 / ls -2.5%
  static TextStyle get button2 => TextStyle(
        fontFamily: 'Pretendard',
        fontWeight: FontWeight.w600,
        fontSize: 14.sp,
        height: 16 / 14,
        letterSpacing: 14 * -0.025,
      );
}
