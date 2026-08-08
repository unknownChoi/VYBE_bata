// 인증번호 화면 순수 계산 로직 (Computed Properties)
// - 확인 버튼 활성화 여부 (_canConfirm)
// - 서브타이틀 텍스트·색상·아이콘 (_subtitleText, _subtitleColor, _subtitleIconPath)
// - OTP 셀 테두리 색상 (_cellBorderColor)
// - 타이머 표시 텍스트 (_timerText)
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

  /// 6자리 모두 입력됐을 때만 확인 버튼 활성화
  // ignore: unused_element
  bool get _canConfirm => _controller.text.length == 6;

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

  /// 상태와 포커스 여부에 따른 OTP 셀 테두리 색상
  Color get _cellBorderColor {
    if (_isErrorStyle) return VybeColors.accentRed500;
    if ((_status == _CertStatus.focused || _status == _CertStatus.requestSent) &&
        _focusNode.hasFocus) {
      return VybeColors.mainPurple500;
    }
    // 포커스 없거나 initial 상태는 테두리 없음
    return Colors.transparent;
  }

  /// MM:SS 형식의 타이머 표시 문자열
  String get _timerText {
    final m = _remainingSeconds ~/ 60;
    final s = _remainingSeconds % 60;
    return '$m:${s.toString().padLeft(2, '0')}';
  }
}
