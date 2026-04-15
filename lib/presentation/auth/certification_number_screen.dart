import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:vybe/design_system/colors.dart';
import 'package:vybe/design_system/typography.dart';
import 'package:vybe/presentation/auth/signup_success_screen.dart';

enum _CertStatus { initial, focused, requestSent, error, expired }

/// 인증번호 입력 화면
///
/// [phoneNumber]: 이전 화면에서 입력한 전화번호 (subtitle에 표시)
///
/// Figma node: 2146-6652
class CertificationNumberScreen extends StatefulWidget {
  final String phoneNumber;

  const CertificationNumberScreen({super.key, required this.phoneNumber});

  @override
  State<CertificationNumberScreen> createState() =>
      _CertificationNumberScreenState();
}

class _CertificationNumberScreenState extends State<CertificationNumberScreen> {
  static const _correctCode = '123456';
  static const _totalSeconds = 10; // 5:00

  final _controller = TextEditingController();
  final _focusNode = FocusNode();

  _CertStatus _status = _CertStatus.initial;
  int _remainingSeconds = _totalSeconds;
  Timer? _timer;
  bool _isResending = false;

  // ────────────────────────────────────────────
  // Computed
  // ────────────────────────────────────────────

  bool get _canConfirm => _controller.text.length == 6;

  bool get _isErrorStyle =>
      _status == _CertStatus.error || _status == _CertStatus.expired;

  String get _subtitleText {
    if (_status == _CertStatus.error) return '인증번호가 일치하지 않습니다.';
    if (_status == _CertStatus.expired) return '인증번호 입력 시간이 만료 되었습니다.';
    if (_status == _CertStatus.requestSent) return '새로운 인증번호가 요청되었습니다.';
    return '${widget.phoneNumber}로 인증번호를 전송했습니다.';
  }

  Color get _subtitleColor =>
      _isErrorStyle ? VybeColors.accentRed500 : VybeColors.gray500;

  String get _subtitleIconPath => _isErrorStyle
      ? 'assets/icons/auth/error_certification_number.svg.svg'
      : 'assets/icons/auth/check_certification_number.svg';

  Color get _cellBorderColor {
    if (_isErrorStyle) return VybeColors.accentRed500;
    if ((_status == _CertStatus.focused ||
            _status == _CertStatus.requestSent) &&
        _focusNode.hasFocus) {
      return VybeColors.mainPurple500;
    }
    return Colors.transparent;
  }

  String get _timerText {
    final m = _remainingSeconds ~/ 60;
    final s = _remainingSeconds % 60;
    return '$m:${s.toString().padLeft(2, '0')}';
  }

  // ────────────────────────────────────────────
  // Lifecycle
  // ────────────────────────────────────────────

  @override
  void initState() {
    super.initState();
    _controller.addListener(_onCodeChanged);
    _focusNode.addListener(_onFocusChanged);
    _startTimer();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  // ────────────────────────────────────────────
  // Handlers
  // ────────────────────────────────────────────

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

  void _onFocusChanged() {
    if (_focusNode.hasFocus && _status == _CertStatus.initial) {
      setState(() => _status = _CertStatus.focused);
    } else {
      setState(() {});
    }
  }

  void _onCodeChanged() {
    if (_isResending) return;
    // 오류/만료 상태에서 다시 입력하면 focused로 전환
    if (_status == _CertStatus.error || _status == _CertStatus.expired) {
      setState(() => _status = _CertStatus.focused);
    } else {
      setState(() {});
    }
    // 6자리 입력 완료 시 자동 확인
    if (_controller.text.length == 6) _onConfirm();
  }

  void _onResendTapped() {
    _isResending = true;
    _controller.clear();
    _isResending = false;
    _startTimer();
    setState(() => _status = _CertStatus.requestSent);
    _focusNode.requestFocus();
  }

  void _onConfirm() {
    if (!_canConfirm) return;
    if (_controller.text == _correctCode) {
      // 인증 성공 — 이전 스택 전체 제거 후 완료 화면으로 이동
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const SignupSuccessScreen()),
        (route) => false,
      );
    } else {
      setState(() => _status = _CertStatus.error);
    }
  }

  // ────────────────────────────────────────────
  // Build
  // ────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: VybeColors.background,
      appBar: AppBar(
        backgroundColor: VybeColors.background,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: SvgPicture.asset(
            'assets/icons/common/arrow_back.svg',
            width: 24.r,
            height: 24.r,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          '본인 인증',
          style: TextStyle(
            color: const Color(0xFFEBEDF0),
            fontSize: 17.sp,
            fontWeight: FontWeight.w500,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(24.w, 38.h, 24.w, 40.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 타이틀
            RichText(
              text: TextSpan(
                style: VybeTypography.heading3.copyWith(color: Colors.white),
                children: [
                  TextSpan(
                    text: '인증번호',
                    style: TextStyle(color: VybeColors.mainLime500),
                  ),
                  const TextSpan(text: '를 입력해주세요'),
                ],
              ),
            ),
            SizedBox(height: 8.h),
            // 서브타이틀
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              child: KeyedSubtree(
                key: ValueKey(_status),
                child: Row(
                  children: [
                    SvgPicture.asset(
                      _subtitleIconPath,
                      width: 12.r,
                      height: 12.r,
                    ),
                    SizedBox(width: 4.w),
                    Text(
                      _subtitleText,
                      style: VybeTypography.caption.copyWith(
                        color: _subtitleColor,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 42.h),
            // OTP 셀
            GestureDetector(
              onTap: () => _focusNode.requestFocus(),
              child: SizedBox(
                height: 46.h,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: List.generate(6, (i) {
                    final digit = i < _controller.text.length
                        ? _controller.text[i]
                        : '';
                    return _OtpCell(
                      digit: digit,
                      borderColor: _cellBorderColor,
                    );
                  }),
                ),
              ),
            ),
            SizedBox(height: 20.h),
            // 타이머 + 다시 요청하기
            Row(
              children: [
                Text(
                  '남은 시간  ',
                  style: VybeTypography.caption.copyWith(
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
                    color: VybeColors.mainPurple500,
                  ),
                ),
                const Spacer(),
                GestureDetector(
                  onTap: _onResendTapped,
                  child: Text(
                    '다시 요청하기',
                    style: VybeTypography.caption.copyWith(
                      fontWeight: FontWeight.w500,
                      color: VybeColors.gray400,
                      decoration: TextDecoration.underline,
                      decorationColor: VybeColors.gray400,
                    ),
                  ),
                ),
              ],
            ),
            // 숨겨진 입력 필드 (키보드 연결용)
            Opacity(
              opacity: 0,
              child: SizedBox(
                height: 1,
                child: TextField(
                  controller: _controller,
                  focusNode: _focusNode,
                  keyboardType: TextInputType.number,
                  maxLength: 6,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  decoration: const InputDecoration(counterText: ''),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// OTP 입력 셀 하나
class _OtpCell extends StatelessWidget {
  final String digit;
  final Color borderColor;

  const _OtpCell({required this.digit, required this.borderColor});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 43.w,
      height: 46.h,
      decoration: BoxDecoration(
        color: VybeColors.gray800,
        borderRadius: BorderRadius.circular(6.r),
        border: borderColor != Colors.transparent
            ? Border.all(color: borderColor, width: 1)
            : null,
      ),
      alignment: Alignment.center,
      child: Text(
        digit,
        style: TextStyle(
          fontFamily: 'Pretendard',
          fontWeight: FontWeight.w500,
          fontSize: 24.sp,
          height: 1,
          letterSpacing: 24 * -0.025,
          color: VybeColors.gray200,
        ),
      ),
    );
  }
}
