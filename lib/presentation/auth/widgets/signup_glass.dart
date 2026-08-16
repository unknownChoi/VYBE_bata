import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vybe/design_system/colors.dart';
import 'package:vybe/design_system/typography.dart';
import 'package:vybe/presentation/common/renew/renew_glass.dart';
import 'package:vybe/presentation/common/widgets/vybe_glass_button.dart';

/// 회원가입(본인 인증) 리뉴얼 공용 조각.
///
/// 디자인: `signup_verify.jsx` + `signup_verify_parts.jsx`
/// 색·블러 토큰은 다른 리뉴얼 화면과 같은 [RenewGlass]를 그대로 쓴다
/// (디자인의 `SV` 상수가 `RenewGlass`와 동일한 값이다 — 따로 두면 한쪽만 바뀐다).

/// 회원가입 흐름의 전체 단계 수 — 정보 입력 4단계(이름·생년월일·전화번호·통신사)
/// + 인증번호 1단계. 레일이 두 화면에 걸쳐 있어 상수를 한 곳에 둔다.
const int signupTotalSteps = 5;

/// 인증번호 화면의 0-based 단계 번호 (레일의 마지막 칸).
const int signupCodeStep = 4;

// ============================================================================
// 상단 바 + 단계 레일 (SVHeader)
// ============================================================================

/// 글래스 상단 바 + 진행 레일.
///
/// 원본 화면엔 진행 표시가 없어 몇 단계짜리 흐름인지 보이지 않았다.
/// 레일은 **완료 = 보라 / 현재 = 라임**이고, 아직 안 온 칸은 폭 0이라 비어 보인다.
///
/// [step]은 0-based. 표기는 `step + 1 / total`.
class SignupHeader extends StatelessWidget {
  final VoidCallback onBack;
  final String title;
  final int step;
  final int total;

  const SignupHeader({
    super.key,
    required this.onBack,
    required this.step,
    required this.total,
    this.title = '본인 인증',
  });

  @override
  Widget build(BuildContext context) {
    return ClipRect(
      child: BackdropFilter(
        filter: ui.ImageFilter.blur(
          sigmaX: RenewGlass.barBlur,
          sigmaY: RenewGlass.barBlur,
        ),
        child: Container(
          color: RenewGlass.barFill,
          padding: EdgeInsets.only(top: MediaQuery.paddingOf(context).top),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                height: 44.h,
                child: Stack(
                  children: [
                    // 제목은 좌우 버튼과 무관하게 화면 정중앙 (디자인 marginLeft -34)
                    Center(
                      child: Text(
                        title,
                        // 17sp Medium — iOS 표준 네비게이션 바 크기, VybeTypography 미정의
                        style: TextStyle(
                          fontFamily: 'Pretendard',
                          color: const Color(0xFFEBEDF0),
                          fontSize: 17.sp,
                          fontWeight: FontWeight.w500,
                          letterSpacing: 17 * -0.025,
                        ),
                      ),
                    ),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Padding(
                        padding: EdgeInsets.only(left: 17.w),
                        child: VybeGlassButton(
                          onTap: onBack,
                          size: 34,
                          iconSize: 18,
                          hitSize: 40,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(24.w, 6.h, 24.w, 14.h),
                child: Row(
                  children: [
                    Expanded(
                      child: Row(
                        children: List.generate(total, (i) {
                          return Expanded(
                            child: Padding(
                              padding: EdgeInsets.only(right: i == total - 1 ? 0 : 5.w),
                              child: _RailSegment(
                                filled: i <= step,
                                current: i == step,
                              ),
                            ),
                          );
                        }),
                      ),
                    ),
                    SizedBox(width: 8.w),
                    Text.rich(
                      TextSpan(
                        style: VybeTypography.caption.copyWith(
                          height: 1,
                          color: RenewGlass.t4,
                          fontFeatures: const [ui.FontFeature.tabularFigures()],
                        ),
                        children: [
                          TextSpan(
                            text: '${step + 1}',
                            style: const TextStyle(
                              color: VybeColors.mainLime500,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          TextSpan(text: ' / $total'),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RailSegment extends StatelessWidget {
  final bool filled;
  final bool current;

  const _RailSegment({required this.filled, required this.current});

  @override
  Widget build(BuildContext context) {
    final color = current ? VybeColors.mainLime500 : VybeColors.mainPurple500;
    return SizedBox(
      height: 3.h,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: const Color(0x1AFFFFFF),
          borderRadius: BorderRadius.circular(99.r),
        ),
        child: AnimatedFractionallySizedBox(
          duration: const Duration(milliseconds: 420),
          curve: Curves.easeOutCubic,
          alignment: Alignment.centerLeft,
          widthFactor: filled ? 1 : 0,
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(99.r),
              boxShadow: current
                  ? [
                      BoxShadow(
                        color: color.withValues(alpha: 0.40),
                        blurRadius: 10.r,
                      ),
                    ]
                  : null,
            ),
          ),
        ),
      ),
    );
  }
}

// ============================================================================
// 바텀시트 껍데기 (SVSheet)
// ============================================================================

/// 회원가입 흐름 공용 바텀시트 껍데기. 손잡이 + 상단 하이라이트 테두리 + (선택) 블러.
///
/// `showModalBottomSheet(backgroundColor: Colors.transparent,
/// barrierColor: [SignupSheet.barrier])` 와 함께 쓴다 — 배경을 투명으로 두지
/// 않으면 Material 배경이 유리 뒤를 막아 블러가 안 보인다.
///
/// [glass]를 끄면 블러 없는 불투명 서피스가 된다 (디자인 `carrier_sheet.jsx`).
/// 목록만 있는 시트는 유리 뒤가 비쳐 항목 텍스트 대비가 떨어지므로,
/// 손잡이·모서리·여백만 공유하고 표면은 플랫으로 간다.
class SignupSheet extends StatelessWidget {
  final Widget child;

  /// 좌우 여백 (디자인 pad).
  final double padH;

  /// 리퀴드 글래스(블러 + 반투명) 사용 여부.
  final bool glass;

  const SignupSheet({
    super.key,
    required this.child,
    this.padH = 24,
    this.glass = true,
  });

  /// 시트 뒤 스크림 — rgba(14,13,18,0.66)
  static const Color barrier = Color(0xA80E0D12);

  /// 상단 모서리 반경
  static const double _radius = 24;

  /// CSS `blur(28px)` ≈ sigma 14
  static const double _blurSigma = 14;

  /// 유리 표면 — rgba(32,30,40,0.86) + 상단 하이라이트 rgba(255,255,255,0.14)
  static const BoxDecoration _glassSurface = BoxDecoration(
    color: Color(0xDB201E28),
    border: Border(top: BorderSide(color: Color(0x24FFFFFF))),
  );

  /// 플랫 표면 — rgba(28,27,34,0.96) + 상단 헤어라인 rgba(255,255,255,0.10)
  static const BoxDecoration _flatSurface = BoxDecoration(
    color: Color(0xF51C1B22),
    border: Border(top: BorderSide(color: Color(0x1AFFFFFF))),
  );

  @override
  Widget build(BuildContext context) {
    final surface = Container(
      width: double.infinity,
      decoration: glass ? _glassSurface : _flatSurface,
      padding: EdgeInsets.fromLTRB(
        padH.w,
        10.h,
        padH.w,
        34.h + MediaQuery.paddingOf(context).bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 36.w,
              height: 4.h,
              margin: EdgeInsets.only(bottom: 20.h),
              decoration: BoxDecoration(
                color: const Color(0x2EFFFFFF),
                borderRadius: BorderRadius.circular(99.r),
              ),
            ),
          ),
          child,
        ],
      ),
    );

    return ClipRRect(
      borderRadius: BorderRadius.vertical(top: Radius.circular(_radius.r)),
      // 플랫 시트는 뒤가 비치지 않으므로 BackdropFilter(별도 레이어 + 리페인트)를
      // 아예 만들지 않는다.
      child: glass
          ? BackdropFilter(
              filter: ui.ImageFilter.blur(
                sigmaX: _blurSigma,
                sigmaY: _blurSigma,
              ),
              child: surface,
            )
          : surface,
    );
  }
}
