// 인증번호 입력 화면에서 사용하는 단일 OTP 셀 위젯
// - 6개의 셀이 Row로 나열되어 6자리 인증번호를 시각적으로 표현
// - 리퀴드 글래스 표면 + 상태별 언더라인(입력됨=라임 / 활성=보라 / 오류=레드)
//
// 디자인: signup_code.jsx `CNCell`

import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vybe/design_system/colors.dart';

/// 인증번호 입력 셀 하나 (리뉴얼)
///
/// [digit]: 표시할 숫자 문자 (비어있으면 빈 칸)
/// [active]: 지금 입력받을 자리 — 보라 테두리 + 캐럿 점멸
/// [error]: 불일치·만료 — 레드 테두리와 레드 숫자
class OtpCell extends StatefulWidget {
  final String digit;
  final bool active;
  final bool error;

  const OtpCell({
    super.key,
    required this.digit,
    this.active = false,
    this.error = false,
  });

  @override
  State<OtpCell> createState() => _OtpCellState();
}

class _OtpCellState extends State<OtpCell> with SingleTickerProviderStateMixin {
  // 캐럿 점멸 (디자인 cnCaret 1.05s)
  late final AnimationController _caret = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 525),
  );

  /// 캐럿은 '활성 + 아직 안 채워진 칸'에서만 뛴다 — 6칸이 전부 애니메이션을
  /// 돌면 입력 중 매 프레임 6개 셀이 리페인트된다.
  bool get _showCaret => widget.active && widget.digit.isEmpty;

  @override
  void initState() {
    super.initState();
    if (_showCaret) _caret.repeat(reverse: true);
  }

  @override
  void didUpdateWidget(OtpCell oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_showCaret && !_caret.isAnimating) {
      _caret.repeat(reverse: true);
    } else if (!_showCaret && _caret.isAnimating) {
      _caret.stop();
    }
  }

  @override
  void dispose() {
    _caret.dispose();
    super.dispose();
  }

  /// 테두리 — 오류 > 활성 > 기본
  Color get _border => widget.error
      ? const Color(0x73FF5C5F) // rgba(255,92,95,0.45)
      : widget.active
      ? const Color(0x807731FE) // rgba(119,49,254,0.50)
      : const Color(0x1AFFFFFF);

  /// 언더라인 — 오류 > 활성 > 입력됨(라임) > 빈 칸
  Color get _underline => widget.error
      ? VybeColors.accentRed500
      : widget.active
      ? VybeColors.mainPurple500
      : widget.digit.isNotEmpty
      ? const Color(0x8CB5FF60) // rgba(181,255,96,0.55)
      : const Color(0x1AFFFFFF);

  @override
  Widget build(BuildContext context) {
    final filled = widget.digit.isNotEmpty;
    final radius = BorderRadius.circular(13.r);

    return AnimatedSlide(
      // 채워진 칸만 1px 떠오른다 (디자인 transform: translateY(-1))
      offset: filled ? const Offset(0, -1 / 56) : Offset.zero,
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOutCubic,
      child: Container(
        width: 46.w,
        height: 56.h,
        decoration: BoxDecoration(
          borderRadius: radius,
          boxShadow: [
            BoxShadow(
              color: const Color(0x57000000), // 0 8px 22px rgba(0,0,0,0.34)
              blurRadius: 22.r,
              offset: Offset(0, 8.h),
            ),
            // 활성 칸을 감싸는 보라 링 (디자인 0 0 0 3px rgba(119,49,254,0.16))
            if (widget.active)
              const BoxShadow(
                color: Color(0x297731FE),
                spreadRadius: 3,
              ),
          ],
        ),
        // 테두리는 하이라이트 위에 그린다 — 아래 두면 선이 하이라이트에 먹힌다.
        foregroundDecoration: BoxDecoration(
          borderRadius: radius,
          border: Border.all(color: _border),
        ),
        child: ClipRRect(
          borderRadius: radius,
          child: BackdropFilter(
            // CSS blur(20px) ≈ sigma 10
            filter: ui.ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: DecoratedBox(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0x21FFFFFF), // 0.13
                    Color(0x0DFFFFFF), // 0.05
                    Color(0x05FFFFFF), // 0.02
                  ],
                  stops: [0.0, 0.42, 1.0],
                ),
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // 좌상단에서 흘러드는 굴절광
                  const Positioned.fill(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: RadialGradient(
                          center: Alignment(-0.85, -1),
                          radius: 1.1,
                          colors: [Color(0x33FFFFFF), Color(0x00FFFFFF)],
                          stops: [0.0, 0.7],
                        ),
                      ),
                    ),
                  ),
                  // 위·아래 1px 하이라이트 (CSS inset shadow 대체)
                  const Positioned(
                    top: 0,
                    left: 0,
                    right: 0,
                    height: 1,
                    child: ColoredBox(color: Color(0x38FFFFFF)),
                  ),
                  const Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    height: 1,
                    child: ColoredBox(color: Color(0x0DFFFFFF)),
                  ),

                  // 숫자 — 입력될 때 살짝 튀어오른다 (디자인 cnPop)
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 220),
                    transitionBuilder: (child, anim) => ScaleTransition(
                      scale: Tween<double>(begin: 0.7, end: 1).animate(
                        CurvedAnimation(parent: anim, curve: Curves.easeOutBack),
                      ),
                      child: FadeTransition(opacity: anim, child: child),
                    ),
                    child: Text(
                      widget.digit,
                      key: ValueKey(widget.digit),
                      style: TextStyle(
                        fontFamily: 'Pretendard',
                        fontWeight: FontWeight.w500,
                        fontSize: 24.sp,
                        height: 1,
                        letterSpacing: 24 * -0.025,
                        color: widget.error
                            ? VybeColors.accentRed500
                            : VybeColors.gray200,
                      ),
                    ),
                  ),

                  // 캐럿 (빈 활성 칸)
                  if (_showCaret)
                    FadeTransition(
                      opacity: _caret,
                      child: Container(
                        width: 2.w,
                        height: 24.h,
                        decoration: BoxDecoration(
                          color: VybeColors.mainPurple500,
                          borderRadius: BorderRadius.circular(2.r),
                        ),
                      ),
                    ),

                  // 하단 언더라인
                  Positioned(
                    left: 12.w,
                    right: 12.w,
                    bottom: 8.h,
                    height: 2.h,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      decoration: BoxDecoration(
                        color: _underline,
                        borderRadius: BorderRadius.circular(99.r),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
