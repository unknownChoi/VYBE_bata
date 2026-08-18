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
mixin _CertificationNumberHandlerMixin on _CertificationNumberLogicMixin {
  // ── 의존 필드 (abstract) ──
  // 읽기 전용 getter(_controller · _focusNode · _status · _remainingSeconds)와
  // computed(_canConfirm)는 LogicMixin이 이미 선언했다 — 여기선 쓰기만 추가한다.
  set _status(_CertStatus value);
  set _remainingSeconds(int value);
  Timer? get _timer;
  set _timer(Timer? value);
  bool get _isResending;
  set _isResending(bool value);
  set _isLoading(bool value);

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
  /// - 만료 상태에서는 입력을 받지 않는다 (재요청이 유일한 복구 동선)
  /// - 오류 상태에서 재입력 시 focused 상태로 복구
  /// - 6자리 완성 시 자동 확인 처리
  void _onCodeChanged() {
    if (_isResending) return;
    if (_status == _CertStatus.expired) return;
    if (_status == _CertStatus.error) {
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
    // 서브타이틀 문구만으로는 눌린 걸 놓치기 쉬워 토스트로 한 번 더 알린다.
    VybeToast.show(context, message: '인증번호를 다시 보냈어요');
  }

  /// 인증번호 확인
  /// - 일치하면 번호 주인을 한 번 더 확인한 뒤 로그인/가입을 마무리한다
  /// - 불일치하면 error 상태로 전환
  Future<void> _onConfirm() async {
    if (!_canConfirm) return;
    if (_controller.text != _correctCode) {
      setState(() => _status = _CertStatus.error);
      return;
    }

    setState(() => _isLoading = true);
    final vm = ref.read(authViewModelProvider.notifier);
    // 실패 시 어느 단계에서 터졌는지 로그로 남긴다 — 토스트 문구만으로는
    // Functions 호출인지 Firestore 쓰기인지 구분이 안 된다.
    var step = 'checkPhoneAccount';

    try {
      // 앞 화면에서 이미 봤지만 다시 본다 — 그 사이 다른 기기·다른 방식으로
      // 같은 번호가 가입됐을 수 있고, 계정을 만드는 건 여기부터다.
      final check = await vm.checkPhoneAccount(widget.phoneNumber, widget.method);
      if (!mounted) return;
      if (check.status == PhoneAccountStatus.takenByOther ||
          check.status == PhoneAccountStatus.pendingDeletion) {
        await vm.abortSignup();
        if (!mounted) return;
        VybeToast.show(
          context,
          message: phoneBlockedMessage(check),
          isError: true,
        );
        return;
      }

      // 본인인증 직접 경로: pending token 없음 → phone 기반 Custom Token 발급
      // 소셜 로그인 경로: pending token 이미 있으므로 스킵
      // 가입 이어하기(소셜 로그인은 끝났지만 프로필이 비어 다시 들어온 경우):
      //   이미 세션이 있으므로 phoneLogin을 하면 안 된다 — `phone:{phone}`
      //   uid가 새로 생겨 원래 소셜 계정이 프로필 없이 버려진다.
      if (!vm.hasPendingToken && !vm.isSignedIn) {
        step = 'phoneLogin';
        await vm.phoneLogin(widget.phoneNumber);
        if (!mounted) return;
      }

      step = 'finalizeLogin';
      await vm.finalizeLogin();
      if (!mounted) return;

      if (widget.isLogin) {
        // 로그인은 프로필을 건드리지 않는다 — 쓸 게 없다.
        // isLogin은 '이 번호의 주인이 나'일 때만 켜지고, users에 phone을 쓰는
        // 경로가 곧 프로필 완성 경로라(setUserProfile · verifyIdentity 둘 다
        // isVerified=true를 같이 쓴다) 이 시점엔 이미 다 채워져 있다.
        // 그대로 saveUserProfile을 부르면 값은 그대로인데 updatedAt만 갱신돼
        // '수정된 적 없는 계정'이 로그인할 때마다 수정된 것으로 남는다.
        // 이름·생년월일 변경은 마이페이지 '내 정보 수정'의 몫.
        //
        // '가입 완료' 축하 화면도 건너뛰고 홈으로.
        await enterHomeAfterAuth(context, ref);
        return;
      }

      step = 'saveUserProfile';
      await vm.saveUserProfile(
        name: widget.name,
        phone: widget.phoneNumber,
        birthDate: widget.birthDate,
        gender: widget.gender,
      );
      if (!mounted) return;

      // 루트(AuthGate) 라우트는 남겨둔다 — 제거하면 로그인 상태 감시가 끊긴다.
      Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => const SignupSuccessScreen()),
      );
    } catch (e, st) {
      debugPrint('[CertificationNumber] 로그인/가입 실패 — step: $step');
      debugPrint('[CertificationNumber] error(${e.runtimeType}): $e');
      debugPrintStack(stackTrace: st, label: '[CertificationNumber]');
      if (!mounted) return;
      VybeToast.show(context, message: '오류가 발생했습니다: $e', isError: true);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }
}
