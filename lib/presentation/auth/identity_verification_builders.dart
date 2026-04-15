part of 'identity_verification_screen.dart';

/// UI 빌더 헬퍼 — buildTitle, buildFieldForStep,
/// buildActiveField, buildCompletedField, buildBelowFields
mixin _IdentityVerificationBuildersMixin on State<IdentityVerificationScreen> {
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
  bool get _isMinor;           // LogicMixin 제공
  void _activateStep(_Step s); // HandlerMixin 제공
  void _showCarrierSheet();    // HandlerMixin 제공

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
            caption: _isMinor
                ? '미성년자는 회원가입이 제한됩니다.'
                : '이 서비스는 만 19세 이상만 이용 가능합니다.',
            captionType:
                _isMinor ? VybeStatusType.error : VybeStatusType.warn,
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
            onClear: () => setState(() {}),
          ),
        _Step.birth => BirthInput(
            frontCtrl: _birthFrontCtrl,
            backCtrl: _birthBackCtrl,
            frontFocus: _birthFrontFocus,
            backFocus: _birthBackFocus,
            isError: _isMinor,
          ),
        _Step.phone => VybeTextField(
            hint: '숫자만 입력해주세요.',
            controller: _phoneCtrl,
            focusNode: _phoneFocus,
            keyboardType: TextInputType.phone,
            inputFormatters: [PhoneFormatter()],
            onClear: () => setState(() {}),
          ),
        _Step.carrier => CarrierDropdownField(
            value: _carrier,
            onTap: _showCarrierSheet,
          ),
      };

  /// 탭 시 제자리에서 재활성화되는 read-only 완료 위젯
  Widget _buildCompletedField(_Step step) {
    switch (step) {
      case _Step.name:
        return GestureDetector(
          onTap: () => _activateStep(_Step.name),
          child: CompletedField(label: '이름', value: _nameCtrl.text),
        );
      case _Step.birth:
        return GestureDetector(
          onTap: () => _activateStep(_Step.birth),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '생년월일',
                style: VybeTypography.caption
                    .copyWith(color: VybeColors.gray600),
              ),
              SizedBox(height: 8.h),
              BirthInput(
                frontCtrl: _birthFrontCtrl,
                backCtrl: _birthBackCtrl,
                frontFocus: _birthFrontFocus,
                backFocus: _birthBackFocus,
                readOnly: true,
                // 앞자리 TextField의 탭 이벤트가 GestureDetector로 전달되지 않으므로
                // onTap으로 직접 수신
                onTap: () => _activateStep(_Step.birth),
              ),
            ],
          ),
        );
      case _Step.phone:
        return GestureDetector(
          onTap: () => _activateStep(_Step.phone),
          child: CompletedField(label: '전화번호', value: _phoneCtrl.text),
        );
      case _Step.carrier:
        return GestureDetector(
          onTap: () => _activateStep(_Step.carrier),
          child: CompletedField(label: '통신사', value: _carrier ?? ''),
        );
    }
  }

  /// 맨 위 입력창 아래에 표시되는 완료 필드 목록 (역순)
  List<Widget> _buildBelowFields() {
    final steps = _Step.values
        .where((s) => s.index < _maxStep.index)
        .toList()
        .reversed;
    final widgets = <Widget>[];

    for (final step in steps) {
      if (widgets.isNotEmpty) widgets.add(SizedBox(height: 28.h));
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
