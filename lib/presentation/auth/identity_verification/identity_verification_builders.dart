// 본인 인증 화면 UI 빌더 헬퍼
// - 단계별 페이지 타이틀 (_buildTitle)
// - 활성/완료 필드 전환 빌더 (_buildFieldForStep)
// - 편집 가능한 활성 입력 위젯 (_buildActiveField)
// - 탭 가능한 read-only 완료 위젯 (_buildCompletedField)
// - 맨 위 입력창 아래 완료 필드 목록 (_buildBelowFields)

part of 'identity_verification_screen.dart';

/// UI 빌더 헬퍼 — buildTitle, buildFieldForStep,
/// buildActiveField, buildCompletedField, buildBelowFields
mixin _IdentityVerificationBuildersMixin
    on ConsumerState<IdentityVerificationScreen> {
  // ── 의존 필드 (abstract) ──
  _Step get _activeStep;
  _Step get _maxStep;
  String? get _carrier;
  TextEditingController get _nameCtrl;
  TextEditingController get _birthFrontCtrl;
  TextEditingController get _birthBackCtrl;
  TextEditingController get _phoneCtrl;
  FocusNode get _nameFocus;
  FocusNode get _birthFrontFocus;
  FocusNode get _birthBackFocus;
  FocusNode get _phoneFocus;

  // ── 의존 computed/method (abstract) ──
  bool get _isMinor; // LogicMixin 제공
  bool get _isForeigner; // LogicMixin 제공
  bool get _isInvalidBirth; // LogicMixin 제공
  void _activateStep(_Step s); // HandlerMixin 제공
  void _showCarrierSheet(); // HandlerMixin 제공

  // ── Build Helpers ──

  /// 현재 활성 단계에 맞는 페이지 타이틀 반환
  Widget _buildTitle() => switch (_activeStep) {
    _Step.name => const VybePageTitle(
      highlightText: '이름',
      regularText: '을 입력해주세요.',
    ),
    _Step.birth => VybePageTitle(
      highlightText: '생년월일',
      regularText: '을 입력해주세요.',
      caption: _isForeigner
          ? '외국인은 회원가입이 불가 합니다.'
          : _isInvalidBirth
          ? '올바른 생년월일을 입력해주세요.'
          : _isMinor
          ? '미성년자는 회원가입이 제한됩니다.'
          : '이 서비스는 만 19세 이상만 이용 가능합니다.',
      captionType: (_isForeigner || _isInvalidBirth || _isMinor)
          ? VybeStatusType.error
          : VybeStatusType.warn,
    ),
    _Step.phone => const VybePageTitle(
      highlightText: '전화번호',
      regularText: '를 입력해주세요.',
    ),
    _Step.carrier => const VybePageTitle(
      highlightText: '통신사',
      regularText: '를 선택해주세요.',
    ),
  };

  /// [step]이 현재 편집 중이면 활성 입력 위젯, 아니면 탭 가능한 완료 위젯 반환
  Widget _buildFieldForStep(_Step step) {
    final isActive = step == _activeStep;
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 220),
      switchInCurve: Curves.easeOut,
      switchOutCurve: Curves.easeIn,
      transitionBuilder: (child, animation) =>
          FadeTransition(opacity: animation, child: child),
      child: KeyedSubtree(
        key: ValueKey('${step.name}_$isActive'),
        child: isActive ? _buildActiveField(step) : _buildCompletedField(step),
      ),
    );
  }

  /// 편집 가능한 활성 입력 위젯
  Widget _buildActiveField(_Step step) => switch (step) {
    _Step.name => VybeTextField(
      hint: '이름을 입력해주세요.',
      controller: _nameCtrl,
      focusNode: _nameFocus,
      glowUnderline: true,
      onClear: () => setState(() {}),
    ),
    _Step.birth => BirthInput(
      frontCtrl: _birthFrontCtrl,
      backCtrl: _birthBackCtrl,
      frontFocus: _birthFrontFocus,
      backFocus: _birthBackFocus,
      isError: _isForeigner || _isInvalidBirth || _isMinor,
    ),
    _Step.phone => VybeTextField(
      hint: '숫자만 입력해주세요.',
      controller: _phoneCtrl,
      focusNode: _phoneFocus,
      keyboardType: TextInputType.phone,
      inputFormatters: [PhoneFormatter()],
      glowUnderline: true,
      onClear: () => setState(() {}),
    ),
    _Step.carrier => CarrierDropdownField(
      value: _carrier,
      onTap: _showCarrierSheet,
      isActive: true, // _buildActiveField에서만 호출 → 항상 보라색 border
    ),
  };

  /// 탭 시 제자리에서 재활성화되는 완료 위젯 — 전부 접힌 글래스 행 한 줄.
  ///
  /// 생년월일도 read-only 입력 필드가 아니라 같은 행으로 접는다(디자인 `SVDone`).
  /// 24sp 필드를 그대로 쌓으면 단계가 늘수록 지금 입력할 칸이 화면 밖으로 밀린다.
  Widget _buildCompletedField(_Step step) => switch (step) {
    _Step.name => CompletedField(
      label: '이름',
      value: _nameCtrl.text,
      onTap: () => _activateStep(_Step.name),
    ),
    _Step.birth => CompletedField(
      label: '생년월일',
      value: _birthSummary,
      onTap: () => _activateStep(_Step.birth),
    ),
    _Step.phone => CompletedField(
      label: '전화번호',
      value: _phoneCtrl.text,
      onTap: () => _activateStep(_Step.phone),
    ),
    _Step.carrier => CompletedField(
      label: '통신사',
      value: _carrier ?? '',
      onTap: () => _activateStep(_Step.carrier),
    ),
  };

  /// 완료 행에 쓰는 생년월일 요약 — `YYMMDD — 1●●●●●●`.
  /// 뒷자리는 성별 코드 1자리만 실제 값이고 나머지는 원본 화면과 같이 점으로 가린다.
  String get _birthSummary =>
      '${_birthFrontCtrl.text} — ${_birthBackCtrl.text}●●●●●●';

  /// 맨 위 입력창 아래에 표시되는 완료 필드 목록 (역순)
  List<Widget> _buildBelowFields() {
    final steps = _Step.values
        .where((s) => s.index < _maxStep.index)
        .toList()
        .reversed;
    final widgets = <Widget>[];

    for (final step in steps) {
      // 접힌 행끼리는 10 — 24sp 입력 필드였을 때의 28이 남아 있으면 카드 사이가 뜬다.
      if (widgets.isNotEmpty) widgets.add(SizedBox(height: 10.h));
      widgets.add(
        FadeSlideIn(
          key: ValueKey('below_${step.name}'),
          child: _buildFieldForStep(step),
        ),
      );
    }

    return widgets;
  }
}
