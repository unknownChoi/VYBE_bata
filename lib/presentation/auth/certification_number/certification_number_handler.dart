// 인증번호 화면 이벤트 핸들러
// - 타이머 시작/정지 (_startTimer)
// - 포커스 변경 감지 (_onFocusChanged)
// - 코드 입력 변경 감지 및 자동 확인 (_onCodeChanged)
// - 재전송 요청 (_onResendTapped)
// - 인증번호 확인 및 화면 전환 (_onConfirm)

part of 'certification_number_screen.dart';

/// 인증번호 화면 — 이벤트 핸들러
///
/// 필드를 직접 소유하지 않고 abstract getter/setter 로 선언.
/// 구체 구현은 [_CertificationNumberScreenState] 필드가 충족한다.
mixin _CertificationNumberHandlerMixin on ConsumerState<CertificationNumberScreen> {
  // ── 의존 필드 (abstract) ──
  TextEditingController get _controller;
  FocusNode get _focusNode;
  _CertStatus get _status;
  set _status(_CertStatus value);
  int get _remainingSeconds;
  set _remainingSeconds(int value);
  Timer? get _timer;
  set _timer(Timer? value);
  bool get _isResending;
  set _isResending(bool value);
  set _isLoading(bool value);

  // ── 의존 computed (LogicMixin 제공) ──
  bool get _canConfirm;

  // ── 인증 로직 상수 ──
  // TODO: 실제 서비스 연동 시 Firebase SMS 인증으로 교체 필요
  static const _correctCode = '123456';
  static const _totalSeconds = 10; // 실제 서비스: 300 (5분)

  // ── Handlers ──

  /// 타이머를 초기화하고 1초 간격으로 카운트다운 시작
  /// 만료 시 상태를 [_CertStatus.expired]로 변경하고 타이머 정지
  void _startTimer() {
    _timer?.cancel();
    _remainingSeconds = _totalSeconds;
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      setState(() {
        if (_remainingSeconds > 0) {
          _remainingSeconds--;
        }
        if (_remainingSeconds == 0) {
          timer.cancel();
          _status = _CertStatus.expired;
        }
      });
    });
  }

  /// 포커스 획득 시 initial → focused 상태로 전환
  void _onFocusChanged() {
    if (_focusNode.hasFocus && _status == _CertStatus.initial) {
      setState(() => _status = _CertStatus.focused);
    } else {
      setState(() {});
    }
  }

  /// 코드 입력값 변경 감지
  /// - 재전송 중이면 무시 (controller.clear 시 리스너 중복 방지)
  /// - 오류/만료 상태에서 재입력 시 focused 상태로 복구
  /// - 6자리 완성 시 자동 확인 처리
  void _onCodeChanged() {
    if (_isResending) return;
    if (_status == _CertStatus.error || _status == _CertStatus.expired) {
      setState(() => _status = _CertStatus.focused);
    } else {
      setState(() {});
    }
    // 6자리 입력 완료 시 자동으로 확인 시도
    if (_controller.text.length == 6) _onConfirm();
  }

  /// 인증번호 재전송 요청
  /// 입력값을 초기화하고 타이머를 재시작하며 requestSent 상태로 전환
  void _onResendTapped() {
    // _isResending 플래그로 clear 중 _onCodeChanged 리스너 억제
    _isResending = true;
    _controller.clear();
    _isResending = false;
    _startTimer();
    setState(() => _status = _CertStatus.requestSent);
    _focusNode.requestFocus();
  }

  /// 인증번호 확인
  /// - 일치하면 finalizeLogin 후 SignupSuccessScreen으로 이동
  /// - 불일치하면 error 상태로 전환
  Future<void> _onConfirm() async {
    if (!_canConfirm) return;
    if (_controller.text == _correctCode) {
      setState(() => _isLoading = true);
      final vm = ref.read(authViewModelProvider.notifier);

      try {
        final isDuplicate = await vm.checkPhoneDuplicate(widget.phoneNumber);
        if (!mounted) return;
        if (isDuplicate) {
          VybeToast.show(context, message: '이미 존재하는 계정입니다.', isError: true);
          return;
        }

        // 본인인증 직접 경로: pending token 없음 → phone 기반 Custom Token 발급
        // 소셜 로그인 경로: pending token 이미 있으므로 스킵
        if (!vm.hasPendingToken) {
          await vm.phoneLogin(widget.phoneNumber);
          if (!mounted) return;
        }

        await vm.finalizeLogin();
        if (!mounted) return;

        await vm.saveUserProfile(
          name: widget.name,
          phone: widget.phoneNumber,
          birthDate: widget.birthDate,
        );
        if (!mounted) return;
        // 루트(AuthGate) 라우트는 남겨둔다 — 제거하면 로그인 상태 감시가 끊긴다.
        Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const SignupSuccessScreen()),
        );
      } catch (e) {
        if (!mounted) return;
        VybeToast.show(context, message: '오류가 발생했습니다: $e', isError: true);
      } finally {
        if (mounted) setState(() => _isLoading = false);
      }
    } else {
      setState(() => _status = _CertStatus.error);
    }
  }
}
