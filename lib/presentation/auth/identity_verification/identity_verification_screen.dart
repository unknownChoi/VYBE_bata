// 본인 인증 화면 진입점 — StatefulWidget 선언 및 State 필드 관리
// - 단계별 입력 (이름 → 생년월일 → 전화번호 → 통신사)
// - 계산 로직은 identity_verification_logic.dart (LogicMixin)
// - 이벤트 핸들러는 identity_verification_handler.dart (HandlerMixin)
// - UI 빌더는 identity_verification_builders.dart (BuildersMixin)
//
// Figma node: (identity verification screen)

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vybe/data/models/terms_agreement.dart';
import 'package:vybe/presentation/auth/certification_number/certification_number_screen.dart';
import 'package:vybe/presentation/auth/signup_flow.dart';
import 'package:vybe/presentation/auth/viewmodels/auth_viewmodel.dart';
import 'package:vybe/presentation/auth/widgets/birth_input.dart';
import 'package:vybe/presentation/auth/widgets/carrier_dropdown_field.dart';
import 'package:vybe/presentation/auth/widgets/carrier_sheet.dart';
import 'package:vybe/presentation/auth/widgets/completed_field.dart';
import 'package:vybe/presentation/auth/widgets/fade_slide_in.dart';
import 'package:vybe/presentation/auth/widgets/phone_formatter.dart';
import 'package:vybe/presentation/auth/widgets/signup_glass.dart';
import 'package:vybe/presentation/auth/widgets/terms_agreement_sheet.dart';
import 'package:vybe/presentation/common/widgets/vybe_aurora.dart';
import 'package:vybe/presentation/common/widgets/vybe_button.dart';
import 'package:vybe/presentation/common/widgets/vybe_loading_overlay.dart';
import 'package:vybe/presentation/common/widgets/vybe_page_title.dart';
import 'package:vybe/presentation/common/widgets/vybe_status_message.dart';
import 'package:vybe/presentation/common/widgets/vybe_text_field.dart';
import 'package:vybe/presentation/common/widgets/vybe_toast.dart';

part 'identity_verification_logic.dart';
part 'identity_verification_handler.dart';
part 'identity_verification_builders.dart';

/// 본인 인증 입력 단계
///
/// 순서대로 진행: 이름 → 생년월일 → 전화번호 → 통신사
enum _Step { name, birth, phone, carrier }

/// 본인 인증 화면 — 개인정보를 단계별로 입력
///
/// Progressive disclosure 패턴:
/// - 새 단계 진행 시 해당 입력창이 맨 위로 올라온다 ([_maxStep] 기준)
/// - [_activeStep]: 현재 편집 중인 단계
///   - [_maxStep]과 동일: 맨 위 입력창이 활성 상태
///   - [_maxStep]보다 낮음: 하단 완료 필드를 탭하여 제자리에서 편집 중
///
/// Figma node: (identity verification screen)
class IdentityVerificationScreen extends ConsumerStatefulWidget {
  /// 이 화면에 오게 된 로그인 방식.
  ///
  /// 소셜 로그인 뒤 프로필을 채우러 온 경우엔 그 소셜 방식이 들어온다.
  /// 전화번호가 이미 쓰이고 있을 때 '같은 방식의 재로그인'인지 가르는 기준이라
  /// 화면이 임의로 추측하지 않고 호출한 쪽이 넘겨준다.
  final SignupMethod method;

  const IdentityVerificationScreen({
    super.key,
    this.method = SignupMethod.identity,
  });

  @override
  ConsumerState<IdentityVerificationScreen> createState() =>
      _IdentityVerificationScreenState();
}

class _IdentityVerificationScreenState
    extends ConsumerState<IdentityVerificationScreen>
    with
        _IdentityVerificationLogicMixin,
        _IdentityVerificationHandlerMixin,
        _IdentityVerificationBuildersMixin {
  // ── 단계 추적 ──
  @override
  _Step _maxStep = _Step.name;
  @override
  _Step _activeStep = _Step.name;

  // ── 각 필드 컨트롤러 ──
  @override
  final _nameCtrl = TextEditingController();
  @override
  final _birthFrontCtrl = TextEditingController(); // YYMMDD (6자리)
  @override
  final _birthBackCtrl = TextEditingController(); // 성별 코드 (1자리)
  @override
  final _phoneCtrl = TextEditingController();
  @override
  String? _carrier;

  // ── 각 필드 포커스 노드 ──
  @override
  final _nameFocus = FocusNode();
  @override
  final _birthFrontFocus = FocusNode();
  @override
  final _birthBackFocus = FocusNode();
  @override
  final _phoneFocus = FocusNode();

  // 앞 6자리 완료 감지를 위한 이전값 추적
  @override
  String _prevBirthFront = '';

  @override
  bool _isLoading = false;

  // ────────────────────────────────────────────
  // Lifecycle
  // ────────────────────────────────────────────

  @override
  void initState() {
    super.initState();
    _nameCtrl.addListener(() => setState(() {}));
    _birthFrontCtrl.addListener(_onBirthFrontChanged);
    _birthBackCtrl.addListener(() => setState(() {}));
    _phoneCtrl.addListener(() => setState(() {}));

    // 화면 진입 시 이름 필드에 자동 포커스
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _nameFocus.requestFocus();
    });
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _birthFrontCtrl.dispose();
    _birthBackCtrl.dispose();
    _phoneCtrl.dispose();
    _nameFocus.dispose();
    _birthFrontFocus.dispose();
    _birthBackFocus.dispose();
    _phoneFocus.dispose();
    super.dispose();
  }

  // ────────────────────────────────────────────
  // Build
  // ────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    // 키보드 표시 여부에 따라 확인 버튼 스타일 전환
    // - 표시 중: withKeyboard (borderRadius 없음, 화면 전체 너비)
    // - 숨김: default (borderRadius 있음, 좌우 패딩 포함)
    final keyboardVisible = MediaQuery.viewInsetsOf(context).bottom > 0;

    return VybeLoadingOverlay(
      isLoading: _isLoading,
      child: Scaffold(
        backgroundColor: kVybeInk,
        body: Stack(
          children: [
            // 리뉴얼 배경 — 글이 주인공인 화면이라 quiet(상단 2겹)
            const Positioned.fill(
              child: IgnorePointer(
                child: VybeAurora(variant: VybeAuroraVariant.quiet),
              ),
            ),
            Column(
              children: [
                // ── 상단 바 + 진행 레일 (총 5단계 = 입력 4 + 인증번호) ──
                SignupHeader(
                  onBack: () => Navigator.pop(context),
                  step: _activeStep.index,
                  total: signupTotalSteps,
                ),
                // ── 입력 영역 (스크롤 가능) ──
                Expanded(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.fromLTRB(24.w, 30.h, 24.w, 24.h),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // 타이틀 전환 애니메이션 (fade + 미세한 위→아래 슬라이드)
                        AnimatedSwitcher(
                          duration: const Duration(milliseconds: 300),
                          switchInCurve: Curves.easeOut,
                          switchOutCurve: Curves.easeIn,
                          transitionBuilder: (child, animation) =>
                              FadeTransition(
                                opacity: animation,
                                child: SlideTransition(
                                  position: Tween<Offset>(
                                    begin: const Offset(0, -0.08),
                                    end: Offset.zero,
                                  ).animate(animation),
                                  child: child,
                                ),
                              ),
                          child: KeyedSubtree(
                            // _activeStep + birth 단계의 에러 여부 모두 key에 반영
                            key: ValueKey(
                              '${_activeStep.name}'
                              '_${_activeStep == _Step.birth ? _isMinor : false}',
                            ),
                            child: Align(
                              alignment: Alignment.centerLeft,
                              child: _buildTitle(),
                            ),
                          ),
                        ),
                        SizedBox(height: 42.h),
                        // 맨 위 입력창: 항상 _maxStep (최신 단계)
                        AnimatedSwitcher(
                          duration: const Duration(milliseconds: 280),
                          switchInCurve: Curves.easeOut,
                          switchOutCurve: Curves.easeIn,
                          transitionBuilder: (child, animation) =>
                              FadeTransition(
                                opacity: animation,
                                child: SlideTransition(
                                  position: Tween<Offset>(
                                    begin: const Offset(0.06, 0),
                                    end: Offset.zero,
                                  ).animate(animation),
                                  child: child,
                                ),
                              ),
                          child: KeyedSubtree(
                            key: ValueKey(_maxStep),
                            child: _buildFieldForStep(_maxStep),
                          ),
                        ),
                        // 하단 완료 필드들: _maxStep 미만을 최신순으로
                        if (_maxStep.index > 0) ...[
                          SizedBox(height: 26.h),
                          ..._buildBelowFields(),
                        ],
                      ],
                    ),
                  ),
                ),

                // ── 확인 버튼 ──
                if (keyboardVisible)
                  VybeButton(
                    label: '확인',
                    onTap: _canProceed ? _onConfirm : null,
                    variant: VybeButtonVariant.withKeyboard,
                  )
                else
                  Padding(
                    padding: EdgeInsets.fromLTRB(24.w, 12.h, 24.w, 40.h),
                    child: VybeButton(
                      label: '확인',
                      glow: true,
                      onTap: _canProceed ? _onConfirm : null,
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
