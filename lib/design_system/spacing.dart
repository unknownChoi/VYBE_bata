import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Vybe 디자인 시스템 간격 상수
///
/// 4px 그리드 기반
class VybeSpacing {
  VybeSpacing._();

  static double get xs => 4.h;
  static double get sm => 8.h;
  static double get md => 12.h;
  static double get lg => 16.h;
  static double get xl => 20.h;
  static double get xxl => 24.h;
  static double get xxxl => 32.h;
  static double get xxxxl => 40.h;
  static double get xxxxxl => 48.h;

  /// 수평 기본 페이지 패딩
  static double get pagePaddingH => 24.w;

  /// 수직 기본 페이지 패딩
  static double get pagePaddingV => 20.h;
}
