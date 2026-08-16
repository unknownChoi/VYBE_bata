// 인증번호 입력 화면 진입점
// - StatefulWidget 선언 및 State 필드 관리
// - 계산 로직은 certification_number_logic.dart (LogicMixin)
// - 이벤트 핸들러는 certification_number_handler.dart (HandlerMixin)
// - UI 빌더는 certification_number_builders.dart (BuildersMixin)
// - OTP 셀 위젯은 widgets/otp_cell.dart (OtpCell)
//
// 디자인: signup_code.jsx (리뉴얼 — 오로라 배경 + 글래스 OTP 셀 + 단계 레일)
// Figma node: 2146-6652

import 'dart:async';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:vybe/design_system/colors.dart';
import 'package:vybe/design_system/typography.dart';
import 'package:vybe/presentation/auth/signup_success/signup_success_screen.dart';
import 'package:vybe/presentation/auth/viewmodels/auth_viewmodel.dart';
import 'package:vybe/presentation/auth/widgets/otp_cell.dart';
import 'package:vybe/presentation/auth/widgets/signup_glass.dart';
import 'package:vybe/presentation/common/renew/renew_glass.dart';
import 'package:vybe/presentation/common/widgets/vybe_aurora.dart';
import 'package:vybe/presentation/common/widgets/vybe_button.dart';
import 'package:vybe/presentation/common/widgets/vybe_loading_overlay.dart';
import 'package:vybe/presentation/common/widgets/vybe_toast.dart';

part 'certification_number_logic.dart';
part 'certification_number_handler.dart';
part 'certification_number_builders.dart';

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
class CertificationNumberScreen extends ConsumerStatefulWidget {
  final String phoneNumber;
  final String name;
  final String birthDate; // YYYYMMDD 형식

  const CertificationNumberScreen({
    super.key,
    required this.phoneNumber,
    required this.name,
    required this.birthDate,
  });

  @override
  ConsumerState<CertificationNumberScreen> createState() =>
      _CertificationNumberScreenState();
}

class _CertificationNumberScreenState extends ConsumerState<CertificationNumberScreen>
    with
        _CertificationNumberLogicMixin,
        _CertificationNumberHandlerMixin,
        _CertificationNumberBuildersMixin {

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
  @override
  bool _isLoading = false;

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
    return VybeLoadingOverlay(
      isLoading: _isLoading,
      child: Scaffold(
        backgroundColor: kVybeInk,
        // ⚠ fit: expand 필수 — Stack은 Positioned가 아닌 자식에게 loose 제약을
        // 준다. 그러면 Column이 내용 폭만큼 줄고 오로라까지 같이 줄어 화면
        // 왼쪽 일부만 칠해진다.
        body: Stack(
          fit: StackFit.expand,
          children: [
            const Positioned.fill(
              // 글이 주인공인 화면이라 상단 2겹만 (디자인 variant="quiet")
              child: VybeAurora(variant: VybeAuroraVariant.quiet),
            ),
            Column(
              children: [
                // 본인 인증 4단계(이름·생년월일·전화번호·통신사) 다음 = 마지막 칸
                SignupHeader(
                  onBack: () => Navigator.pop(context),
                  step: signupCodeStep,
                  total: signupTotalSteps,
                ),
                Expanded(
                  child: GestureDetector(
                    // 빈 곳을 눌러도 키보드가 다시 올라온다
                    onTap: () => _focusNode.requestFocus(),
                    behavior: HitTestBehavior.opaque,
                    child: SingleChildScrollView(
                      padding: EdgeInsets.fromLTRB(24.w, 30.h, 24.w, 24.h),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildTitle(),
                          SizedBox(height: 8.h),
                          _buildSubtitle(),
                          SizedBox(height: 42.h),
                          _buildOtpRow(),
                          SizedBox(height: 20.h),
                          _buildTimerRow(),
                          if (_status == _CertStatus.expired) ...[
                            SizedBox(height: 22.h),
                            _buildExpiredCard(),
                          ],
                          _buildHiddenField(),
                        ],
                      ),
                    ),
                  ),
                ),
                _buildConfirmBar(),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
