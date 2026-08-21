// 본인 인증 화면 이벤트 핸들러
// - 생년월일 앞 6자리 자동 포커스 이동 (_onBirthFrontChanged)
// - 확인 버튼 처리 — 단계 전진 또는 번호 주인 확인 (_onConfirm, _submitIdentity)
// - 완료 필드 탭 시 해당 단계 재활성화 (_activateStep)
// - 포커스 이동 (_requestFocus)
// - 약관 동의 바텀시트 표시 (_showTermsSheet)
// - 인증번호 화면으로 이동 (_goToCertification)
// - 통신사 선택 바텀시트 표시 (_showCarrierSheet)

part of 'identity_verification_screen.dart';

/// 이벤트 핸들러 — onConfirm, submitIdentity, activateStep, requestFocus,
/// onBirthFrontChanged, showTermsSheet, showCarrierSheet
mixin _IdentityVerificationHandlerMixin
    on ConsumerState<IdentityVerificationScreen> {
  // ── 의존 필드 (abstract) ──
  _Step get _activeStep;
  set _activeStep(_Step value);
  _Step get _maxStep;
  set _maxStep(_Step value);
  String? get _carrier;
  set _carrier(String? value);
  String get _prevBirthFront;
  set _prevBirthFront(String value);
  set _isLoading(bool value);

  TextEditingController get _nameCtrl;
  TextEditingController get _birthFrontCtrl;
  TextEditingController get _birthBackCtrl;
  TextEditingController get _phoneCtrl;
  FocusNode get _nameFocus;
  FocusNode get _birthFrontFocus;
  FocusNode get _birthBackFocus;
  FocusNode get _phoneFocus;

  // ── 의존 computed (abstract — LogicMixin이 구현 제공) ──
  bool get _canProceed;

  // ── Handlers ──

  /// 생년월일 앞 6자리 완료 시 뒷 자리로 자동 포커스 이동
  void _onBirthFrontChanged() {
    final text = _birthFrontCtrl.text;
    if (text.length == 6 && _prevBirthFront.length < 6) {
      _birthBackFocus.requestFocus();
    }
    _prevBirthFront = text;
    setState(() {});
  }

  /// '확인' 버튼 탭 처리
  void _onConfirm() {
    if (!_canProceed) return;

    if (_activeStep == _Step.carrier) {
      _submitIdentity();
      return;
    }

    if (_activeStep == _maxStep) {
      final nextStep = _Step.values[_maxStep.index + 1];
      setState(() {
        _maxStep = nextStep;
        _activeStep = nextStep;
      });
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _requestFocus(_activeStep);
      });
    } else {
      setState(() => _activeStep = _maxStep);
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _requestFocus(_activeStep);
      });
    }
  }

  /// 완료된 필드를 탭했을 때 해당 단계를 제자리에서 활성화
  // BuildersMixin이 abstract 선언을 통해 호출한다 — 호출부가 그 선언에 묶여
  // 분석기는 이 구현을 미사용으로 본다 (지우지 말 것).
  // ignore: unused_element
  void _activateStep(_Step step) {
    if (_activeStep == step) return;
    FocusManager.instance.primaryFocus?.unfocus();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      setState(() => _activeStep = step);
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _requestFocus(step);
      });
    });
  }

  /// 단계에 해당하는 필드에 포커스 요청
  void _requestFocus(_Step step) {
    switch (step) {
      case _Step.name:
        _nameFocus.requestFocus();
      case _Step.birth:
        _birthFrontFocus.requestFocus();
      case _Step.phone:
        _phoneFocus.requestFocus();
      case _Step.carrier:
        FocusManager.instance.primaryFocus?.unfocus();
    }
  }

  /// 마지막 단계 '확인' — 인증번호 화면으로 넘기기 전에 번호 주인을 먼저 본다.
  ///
  /// - 처음 보는 번호        → 약관 동의 → 인증번호(가입)
  /// - 같은 방식의 내 계정    → 약관 생략 → 인증번호(**로그인**)
  ///     이미 동의한 사람에게 약관을 다시 받지 않는다. 문자 인증은 그대로 거친다.
  ///     탈퇴 대기 중이어도 파기 전이면 여기로 온다 — 로그인이 곧 복구다.
  /// - 다른 방식으로 가입된 번호 → 막는다. 계정도 만들지 않는다.
  Future<void> _submitIdentity() async {
    final phone = _phoneCtrl.text;
    final vm = ref.read(authViewModelProvider.notifier);

    setState(() => _isLoading = true);
    try {
      final check = await vm.checkPhoneAccount(phone, widget.method);
      if (!mounted) return;

      switch (check.status) {
        case PhoneAccountStatus.takenByOther:
        case PhoneAccountStatus.pendingDeletion:
          // 만들다 만 세션(소셜 로그인은 여기 오기 전에 붙는다)을 먼저 정리한다.
          await vm.abortSignup();
          if (!mounted) return;
          VybeToast.show(
            context,
            message: phoneBlockedMessage(check),
            isError: true,
          );
        case PhoneAccountStatus.ownAccount:
          // 탈퇴 대기 중이던 내 계정이면 인증을 마치는 순간 되살아난다.
          // 아무 말 없이 복구하면 사용자가 탈퇴가 취소된 걸 모른다.
          if (check.restorable) {
            VybeToast.show(context, message: kAccountRestoreNotice);
          }
          _goToCertification(phone, isLogin: true);
        case PhoneAccountStatus.available:
          _showTermsSheet(phone);
      }
    } catch (e) {
      if (!mounted) return;
      VybeToast.show(context, message: '오류가 발생했습니다: $e', isError: true);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  /// 약관 동의 바텀시트 표시 — 신규 가입일 때만 거친다.
  void _showTermsSheet(String phone) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      barrierColor: SignupSheet.barrier,
      isScrollControlled: true,
      builder: (_) => TermsAgreementSheet(
        onConfirmed: () async {
          if (!mounted) return;
          _goToCertification(phone, isLogin: false);
        },
      ),
    );
  }

  /// 인증번호 화면으로 이동. [isLogin] 이면 프로필이 이미 있는 계정의 재로그인.
  void _goToCertification(String phone, {required bool isLogin}) {
    final birthFront = _birthFrontCtrl.text; // YYMMDD
    final genderCode = _birthBackCtrl.text; // 1~4
    final century = (genderCode == '1' || genderCode == '2') ? '19' : '20';

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CertificationNumberScreen(
          phoneNumber: phone,
          name: _nameCtrl.text,
          birthDate: '$century$birthFront', // YYYYMMDD
          // 뒷자리 성별코드는 생년 세기 판정에만 쓰고 버리고 있었다 —
          // users.gender 로도 남긴다.
          gender: genderFromCode(genderCode),
          method: widget.method,
          isLogin: isLogin,
        ),
      ),
    );
  }

  /// 통신사 선택 바텀시트 표시
  // _activateStep과 같은 이유 — BuildersMixin의 abstract 선언을 통해 호출된다.
  // ignore: unused_element
  void _showCarrierSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      barrierColor: SignupSheet.barrier,
      builder: (_) => CarrierSheet(
        selected: _carrier,
        onSelected: (value) {
          setState(() => _carrier = value);
          Navigator.pop(context);
        },
      ),
    );
  }
}
