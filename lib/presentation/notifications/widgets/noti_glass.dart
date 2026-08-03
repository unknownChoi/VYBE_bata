/// 알림 카드 치수 (디자인 notifications_glass.jsx `NGRow` → NGCard pad/radius).
///
/// 유리 껍데기 자체는 공지 목록과 공유하므로
/// `common/widgets/vybe_glass_surface.dart`의 [VybeGlassSurface]를 쓴다.
class NotiGlass {
  NotiGlass._();

  /// 카드 라운드 · 내부 여백 (CSS px, `.r` 적용).
  static const double cardRadius = 19;
  static const double cardPad = 13;
}
