// 인증번호 화면 순수 계산 로직 (Computed Properties)
// - 확인 버튼 활성화 여부 (_canConfirm)
// - 서브타이틀 텍스트·색상·아이콘 (_subtitleText, _subtitleColor, _subtitleIconPath)
// - OTP 셀 활성 여부 (_isCellActive)
// - 타이머 표시 텍스트·색상 (_timerText, _timerColor)
// - 오류·만료 스타일 여부 (_isErrorStyle)

part of 'certification_number_screen.dart';

/// 인증번호 화면 — 순수 계산 로직
///
/// 필드를 직접 소유하지 않고 abstract getter 로 선언.
/// 구체 구현은 [_CertificationNumberScreenState] 필드가 충족한다.
mixin _CertificationNumberLogicMixin on ConsumerState<CertificationNumberScreen> {
  // ── 의존 필드 (abstract) ──
  TextEditingController get _controller;
  FocusNode get _focusNode;
  _CertStatus get _status;
  int get _remainingSeconds;

  // ── Computed ──

  /// 6자리를 다 채웠고 아직 만료되지 않았을 때만 확인 버튼 활성화.
  /// 만료를 빼면 시간이 지난 코드로도 통과된다.
  bool get _canConfirm =>
      _controller.text.length == 6 && _status != _CertStatus.expired;

  /// 오류 또는 만료 상태이면 에러 스타일 적용
  bool get _isErrorStyle =>
      _status == _CertStatus.error || _status == _CertStatus.expired;

  /// 현재 상태에 따른 서브타이틀 메시지
  String get _subtitleText {
    if (_status == _CertStatus.error) return '인증번호가 일치하지 않습니다.';
    if (_status == _CertStatus.expired) return '인증번호 입력 시간이 만료 되었습니다.';
    if (_status == _CertStatus.requestSent) return '새로운 인증번호가 요청되었습니다.';
    return '${widget.phoneNumber}로 인증번호를 전송했습니다.';
  }

  /// 에러 상태면 빨간색, 정상 상태면 회색
  Color get _subtitleColor =>
      _isErrorStyle ? VybeColors.accentRed500 : VybeColors.gray500;

  /// 에러 상태면 에러 아이콘, 정상 상태면 체크 아이콘
  String get _subtitleIconPath => _isErrorStyle
      ? 'assets/icons/auth/error_certification_number.svg.svg'
      : 'assets/icons/auth/check_certification_number.svg';

  /// [index] 칸이 '지금 입력받는 자리'인지 — 보라 테두리 + 캐럿 대상.
  /// 오류·만료 상태에서는 활성 칸을 두지 않는다(레드 표시가 우선).
  bool _isCellActive(int index) {
    if (_isErrorStyle || !_focusNode.hasFocus) return false;
    if (_status != _CertStatus.focused && _status != _CertStatus.requestSent) {
      return false;
    }
    return index == _controller.text.length;
  }

  /// MM:SS 형식의 타이머 표시 문자열
  String get _timerText {
    final m = _remainingSeconds ~/ 60;
    final s = _remainingSeconds % 60;
    return '$m:${s.toString().padLeft(2, '0')}';
  }

  /// 0초가 되면 레드 — 숫자만 보고도 만료를 알 수 있게
  Color get _timerColor => _remainingSeconds == 0
      ? VybeColors.accentRed500
      : VybeColors.mainPurple500;
}
