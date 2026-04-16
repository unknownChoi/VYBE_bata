// TODO: certification_number_screen.dart
// 인증번호 입력 화면 진입점
// - StatefulWidget 선언 및 State 필드 관리
// - 계산 로직은 certification_number_logic.dart (LogicMixin)
// - 이벤트 핸들러는 certification_number_handler.dart (HandlerMixin)
// - OTP 셀 위젯은 widgets/otp_cell.dart (OtpCell)
//
// Figma node: 2146-6652

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:vybe/design_system/colors.dart';
import 'package:vybe/design_system/typography.dart';
import 'package:vybe/presentation/auth/signup_success/signup_success_screen.dart';
import 'package:vybe/presentation/auth/widgets/otp_cell.dart';

part 'certification_number_logic.dart';
part 'certification_number_handler.dart';

/// 인증 진행 상태
enum _CertStatus {
  initial,      // 최초 진입 (포커스 전)
  focused,      // 입력 필드 포커스 중
  requestSent,  // 인증번호 재전송 완료
  error,        // 인증번호 불일치
  expired,      // 제한 시간 만료
}

/// 인증번호 입력 화면
///
/// [phoneNumber]: 이전 화면(본인 인증)에서 입력한 전화번호 — 서브타이틀에 표시
class CertificationNumberScreen extends StatefulWidget {
  final String phoneNumber;

  const CertificationNumberScreen({
    super.key,
    required this.phoneNumber,
  });

  @override
  State<CertificationNumberScreen> createState() =>
      _CertificationNumberScreenState();
}

class _CertificationNumberScreenState extends State<CertificationNumberScreen>
    with _CertificationNumberLogicMixin, _CertificationNumberHandlerMixin {

  // ── 입력 컨트롤러 / 포커스 ──
  @override
  final _controller = TextEditingController();
  @override
  final _focusNode = FocusNode();

  // ── 화면 상태 ──
  @override
  _CertStatus _status = _CertStatus.initial;
  @override
  int _remainingSeconds = _CertificationNumberHandlerMixin._totalSeconds;
  @override
  Timer? _timer;
  @override
  bool _isResending = false;

  // ────────────────────────────────────────────
  // Lifecycle
  // ────────────────────────────────────────────

  @override
  void initState() {
    super.initState();
    _controller.addListener(_onCodeChanged);
    _focusNode.addListener(_onFocusChanged);
    // 화면 진입 즉시 타이머 시작
    _startTimer();
    // 첫 프레임 이후 키보드 자동 표시
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
          // 17sp Medium — VybeTypography 미정의 (iOS 표준 네비게이션 바 크기) → 하드코딩
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
            // ── 타이틀 ──
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

            // ── 서브타이틀 (상태별 메시지 + 아이콘, 전환 애니메이션) ──
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

            // ── OTP 셀 6개 (GestureDetector로 탭 시 키보드 재표시) ──
            GestureDetector(
              onTap: () => _focusNode.requestFocus(),
              child: SizedBox(
                height: 46.h,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: List.generate(6, (i) {
                    // 입력된 인덱스까지만 숫자 표시, 나머지는 빈 문자열
                    final digit = i < _controller.text.length
                        ? _controller.text[i]
                        : '';
                    return OtpCell(
                      digit: digit,
                      borderColor: _cellBorderColor,
                    );
                  }),
                ),
              ),
            ),
            SizedBox(height: 20.h),

            // ── 타이머 + 다시 요청하기 ──
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

            // ── 숨겨진 TextField (키보드 및 입력 이벤트 수신 전용) ──
            // OTP 셀은 단순 표시용이며, 실제 입력은 이 위젯이 처리함
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
