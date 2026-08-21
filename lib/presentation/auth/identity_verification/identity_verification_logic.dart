// 본인 인증 화면 순수 계산 로직 (Computed Properties)
// - 확인 버튼 활성화 여부 (_canProceed)
// - 만 19세 미만 여부 (_isMinor)

part of 'identity_verification_screen.dart';

/// 순수 계산 로직 — canProceed, isMinor
///
/// 필드는 직접 소유하지 않고 abstract getter로 선언.
/// 구체 구현은 [_IdentityVerificationScreenState] 필드가 충족한다.
mixin _IdentityVerificationLogicMixin
    on ConsumerState<IdentityVerificationScreen> {
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
    _Step.name => _nameCtrl.text.trim().isNotEmpty,
    _Step.birth =>
      _birthFrontCtrl.text.length == 6 &&
          _birthBackCtrl.text.length == 1 &&
          !_isMinor &&
          !_isForeigner &&
          !_isInvalidBirth,
    _Step.phone => _phoneCtrl.text.replaceAll('-', '').length == 11,
    _Step.carrier => _carrier != null,
  };

  /// 뒷자리 성별코드 (1~8)
  String get _genderCode => _birthBackCtrl.text;

  /// 외국인 여부 (성별코드 5~8)
  bool get _isForeigner {
    if (_genderCode.isEmpty) return false;
    final code = int.tryParse(_genderCode);
    return code != null && code >= 5 && code <= 8;
  }

  /// 올바르지 않은 생년월일 여부
  /// - 성별코드가 1~4 범위 밖 (단, 외국인 5~8은 별도 처리)
  /// - 앞자리와 뒷자리 성별코드의 세기가 불일치 (예: 990520-3)
  /// - 존재하지 않는 날짜 (예: 990230)
  bool get _isInvalidBirth {
    final raw = _birthFrontCtrl.text;
    if (raw.length < 6 || _genderCode.isEmpty) return false;

    final code = int.tryParse(_genderCode);
    if (code == null || code < 1 || code > 8) return true;
    if (_isForeigner) return false; // 외국인은 별도 처리

    final yy = int.tryParse(raw.substring(0, 2)) ?? -1;
    final mm = int.tryParse(raw.substring(2, 4)) ?? -1;
    final dd = int.tryParse(raw.substring(4, 6)) ?? -1;
    if (yy < 0 || mm < 0 || dd < 0) return true;

    // 성별코드로 세기 결정
    final century = (code == 1 || code == 2) ? 1900 : 2000;
    final fullYear = century + yy;

    // 날짜 유효성 + 미래 날짜 여부
    try {
      final date = DateTime(fullYear, mm, dd);
      if (date.isAfter(DateTime.now())) return true;
      // 세기 불일치: 예) YY=99이고 코드=3(2000년대) → 2099년 → 미래
      return false;
    } catch (_) {
      return true; // 존재하지 않는 날짜
    }
  }

  /// 입력한 생년월일이 만 19세 미만인지 여부
  bool get _isMinor {
    final raw = _birthFrontCtrl.text;
    if (raw.length < 6 || _genderCode.isEmpty) return false;
    if (_isForeigner || _isInvalidBirth) return false;

    final code = int.tryParse(_genderCode) ?? 0;
    final century = (code == 1 || code == 2) ? 1900 : 2000;
    final yy = int.tryParse(raw.substring(0, 2)) ?? 0;
    final mm = int.tryParse(raw.substring(2, 4)) ?? 0;
    final dd = int.tryParse(raw.substring(4, 6)) ?? 0;

    try {
      final birthDate = DateTime(century + yy, mm, dd);
      final threshold = DateTime(
        DateTime.now().year - 19,
        DateTime.now().month,
        DateTime.now().day,
      );
      return birthDate.isAfter(threshold);
    } catch (_) {
      return false;
    }
  }
}
