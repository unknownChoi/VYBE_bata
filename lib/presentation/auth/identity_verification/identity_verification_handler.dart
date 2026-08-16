// 본인 인증 화면 이벤트 핸들러
// - 생년월일 앞 6자리 자동 포커스 이동 (_onBirthFrontChanged)
// - 확인 버튼 처리 — 단계 전진 또는 약관 시트 표시 (_onConfirm)
// - 완료 필드 탭 시 해당 단계 재활성화 (_activateStep)
// - 포커스 이동 (_requestFocus)
// - 약관 동의 바텀시트 표시 (_showTermsSheet)
// - 통신사 선택 바텀시트 표시 (_showCarrierSheet)

part of 'identity_verification_screen.dart';

/// 이벤트 핸들러 — onConfirm, activateStep, requestFocus,
/// onBirthFrontChanged, showTermsSheet, showCarrierSheet
mixin _IdentityVerificationHandlerMixin on ConsumerState<IdentityVerificationScreen> {
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
      _showTermsSheet();
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

  /// 약관 동의 바텀시트 표시
  void _showTermsSheet() {
    final phone = _phoneCtrl.text;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      barrierColor: SignupSheet.barrier,
      isScrollControlled: true,
      builder: (_) => TermsAgreementSheet(
        onConfirmed: () async {
          setState(() => _isLoading = true);
          try {
            final isDuplicate = await ref
                .read(authViewModelProvider.notifier)
                .checkPhoneDuplicate(phone);
            if (!mounted) return;

            if (isDuplicate) {
              VybeToast.show(
                context,
                message: '이미 존재하는 계정입니다.',
                isError: true,
              );
              return;
            }

            final birthFront = _birthFrontCtrl.text; // YYMMDD
            final genderCode = _birthBackCtrl.text;  // 1~4
            final century = (genderCode == '1' || genderCode == '2') ? '19' : '20';
            final birthDate = '$century$birthFront'; // YYYYMMDD
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => CertificationNumberScreen(
                  phoneNumber: phone,
                  name: _nameCtrl.text,
                  birthDate: birthDate,
                ),
              ),
            );
          } finally {
            if (mounted) setState(() => _isLoading = false);
          }
        },
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
