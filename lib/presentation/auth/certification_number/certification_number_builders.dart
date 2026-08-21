// 인증번호 화면 UI 빌더 헬퍼
// - 타이틀 (_buildTitle)
// - 상태 서브타이틀 (_buildSubtitle)
// - OTP 6칸 + 숨은 입력 필드 (_buildOtpRow, _buildHiddenField)
// - 남은 시간 · 다시 요청하기 (_buildTimerRow)
// - 만료 복구 카드 (_buildExpiredCard)
// - 하단 확인 버튼 (_buildConfirmBar)
//
// 디자인: signup_code.jsx `CertificationNumber`

part of 'certification_number_screen.dart';

/// UI 빌더 헬퍼 — buildTitle, buildSubtitle, buildOtpRow,
/// buildHiddenField, buildTimerRow, buildExpiredCard, buildConfirmBar
mixin _CertificationNumberBuildersMixin
    on _CertificationNumberLogicMixin, _CertificationNumberHandlerMixin {
  // 필드·computed는 LogicMixin, 이벤트는 HandlerMixin이 제공한다
  // (재선언하면 참조가 이쪽 abstract로 붙어 원본이 미사용으로 잡힌다).

  // ── Build Helpers ──

  /// `인증번호를 입력해주세요` — 앞 단어만 라임
  Widget _buildTitle() => RichText(
    text: TextSpan(
      style: VybeTypography.heading3.copyWith(
        color: Colors.white,
        height: 30 / 24, // 디자인 line-height 30
      ),
      children: const [
        TextSpan(
          text: '인증번호',
          style: TextStyle(color: VybeColors.mainLime500),
        ),
        TextSpan(text: '를 입력해주세요'),
      ],
    ),
  );

  /// 상태별 안내 한 줄. 상태가 바뀔 때마다 위에서 흘러들어온다(디자인 cnFade).
  Widget _buildSubtitle() => AnimatedSwitcher(
    duration: const Duration(milliseconds: 200),
    transitionBuilder: (child, anim) => FadeTransition(
      opacity: anim,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, -0.3),
          end: Offset.zero,
        ).animate(anim),
        child: child,
      ),
    ),
    child: Row(
      key: ValueKey(_status),
      mainAxisSize: MainAxisSize.min,
      children: [
        SvgPicture.asset(_subtitleIconPath, width: 12.r, height: 12.r),
        SizedBox(width: 4.w),
        Flexible(
          child: Text(
            _subtitleText,
            style: VybeTypography.caption.copyWith(
              height: 14 / 12,
              color: _subtitleColor,
            ),
          ),
        ),
      ],
    ),
  );

  /// OTP 6칸. 실제 입력은 [_buildHiddenField]가 받고 여기는 표시 전용이다.
  Widget _buildOtpRow() => GestureDetector(
    onTap: () => _focusNode.requestFocus(),
    behavior: HitTestBehavior.opaque,
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(6, (i) {
        final text = _controller.text;
        return OtpCell(
          digit: i < text.length ? text[i] : '',
          active: _isCellActive(i),
          error: _isErrorStyle,
        );
      }),
    ),
  );

  /// 키보드·입력 이벤트 수신 전용 (화면엔 보이지 않는다)
  Widget _buildHiddenField() => Opacity(
    opacity: 0,
    child: SizedBox(
      height: 1,
      child: TextField(
        controller: _controller,
        focusNode: _focusNode,
        // 만료되면 입력 자체를 막는다 — 지난 코드로 통과되면 안 된다.
        readOnly: _status == _CertStatus.expired,
        keyboardType: TextInputType.number,
        maxLength: 6,
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        decoration: const InputDecoration(counterText: ''),
      ),
    ),
  );

  /// `남은 시간 0:58        다시 요청하기`
  Widget _buildTimerRow() => Row(
    children: [
      Text(
        '남은 시간  ',
        style: VybeTypography.caption.copyWith(
          height: 18 / 12,
          color: VybeColors.gray400,
        ),
      ),
      Text(
        _timerText,
        style: TextStyle(
          fontFamily: 'Pretendard',
          fontWeight: FontWeight.w400,
          fontSize: 16.sp,
          height: 18 / 16,
          letterSpacing: 16 * -0.025,
          color: _timerColor,
          // 숫자가 줄어들 때 폭이 흔들리지 않게 고정폭 숫자
          fontFeatures: const [ui.FontFeature.tabularFigures()],
        ),
      ),
      const Spacer(),
      GestureDetector(
        onTap: _onResendTapped,
        behavior: HitTestBehavior.opaque,
        child: Text(
          '다시 요청하기',
          style: VybeTypography.caption.copyWith(
            height: 18 / 12,
            fontWeight: FontWeight.w500,
            color: VybeColors.gray400,
            decoration: TextDecoration.underline,
            decorationColor: VybeColors.gray400,
          ),
        ),
      ),
    ],
  );

  /// 만료 안내 + 복구 버튼.
  /// 타이머만 0:00으로 두면 무엇을 해야 하는지가 화면에 없다.
  Widget _buildExpiredCard() => Container(
    padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 13.h),
    decoration: BoxDecoration(
      color: const Color(0x12FF5C5F), // rgba(255,92,95,0.07)
      borderRadius: BorderRadius.circular(14.r),
      border: Border.all(color: const Color(0x33FF5C5F)),
    ),
    child: Row(
      children: [
        SvgPicture.asset(
          'assets/icons/auth/error_certification_number.svg.svg',
          width: 14.r,
          height: 14.r,
        ),
        SizedBox(width: 10.w),
        Expanded(
          child: Text(
            '시간이 만료됐어요',
            style: TextStyle(
              fontFamily: 'Pretendard',
              fontSize: 13.sp,
              letterSpacing: 13 * -0.025,
              color: RenewGlass.t2,
            ),
          ),
        ),
        GestureDetector(
          onTap: _onResendTapped,
          behavior: HitTestBehavior.opaque,
          child: Container(
            height: 30.h,
            padding: EdgeInsets.symmetric(horizontal: 13.w),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: const Color(0x17FFFFFF), // rgba(255,255,255,0.09)
              borderRadius: BorderRadius.circular(8.r),
              border: Border.all(color: const Color(0x24FFFFFF)),
            ),
            child: Text(
              '새 번호 받기',
              style: VybeTypography.button2.copyWith(color: Colors.white),
            ),
          ),
        ),
      ],
    ),
  );

  /// 하단 고정 확인 버튼. 6자리를 채우면 자동 확인되지만,
  /// 눌러서 끝내는 동선도 남겨 둔다(자동 확인이 실패한 뒤 재시도 경로).
  Widget _buildConfirmBar() => Padding(
    padding: EdgeInsets.fromLTRB(24.w, 12.h, 24.w, 40.h),
    child: DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: _canConfirm
            ? [
                BoxShadow(
                  color: VybeColors.mainPurple500.withValues(alpha: 0.32),
                  blurRadius: 26.r,
                  offset: Offset(0, 10.h),
                ),
              ]
            : null,
      ),
      child: VybeButton(label: '확인', onTap: _canConfirm ? _onConfirm : null),
    ),
  );
}
