part of 'identity_verification_screen.dart';

/// 순수 계산 로직 — canProceed, isMinor
///
/// 필드는 직접 소유하지 않고 abstract getter로 선언.
/// 구체 구현은 [_IdentityVerificationScreenState] 필드가 충족한다.
mixin _IdentityVerificationLogicMixin on State<IdentityVerificationScreen> {
  // ── 의존 필드 (abstract) ──
  _Step get _activeStep;
  TextEditingController get _nameCtrl;
  TextEditingController get _birthFrontCtrl;
  TextEditingController get _birthBackCtrl;
  TextEditingController get _phoneCtrl;
  String? get _carrier;

  // ── Computed ──

  /// 현재 활성 단계에서 '확인' 버튼 활성화 여부
  // ignore: unused_element
  bool get _canProceed => switch (_activeStep) {
        _Step.name    => _nameCtrl.text.trim().isNotEmpty,
        _Step.birth   => _birthFrontCtrl.text.length == 6 &&
                         _birthBackCtrl.text.length == 1 &&
                         !_isMinor,
        _Step.phone   => _phoneCtrl.text.replaceAll('-', '').length == 11,
        _Step.carrier => _carrier != null,
      };

  /// 입력한 생년월일이 만 19세 미만인지 여부
  bool get _isMinor {
    final raw = _birthFrontCtrl.text;
    if (raw.length < 6) return false;
    final yy = int.tryParse(raw.substring(0, 2)) ?? 0;
    final mm = int.tryParse(raw.substring(2, 4)) ?? 0;
    final dd = int.tryParse(raw.substring(4, 6)) ?? 0;
    final currentYY = DateTime.now().year % 100;
    final fullYear = yy > currentYY ? 1900 + yy : 2000 + yy;
    try {
      final birthDate = DateTime(fullYear, mm, dd);
      final today = DateTime.now();
      final threshold = DateTime(today.year - 19, today.month, today.day);
      return birthDate.isAfter(threshold);
    } catch (_) {
      return false;
    }
  }
}
