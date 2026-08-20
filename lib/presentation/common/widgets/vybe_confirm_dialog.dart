import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vybe/design_system/colors.dart';
import 'package:vybe/design_system/typography.dart';
import 'package:vybe/presentation/common/widgets/vybe_liquid_press.dart';

// ============================================================
// 되돌릴 수 없는 동작을 한 번 더 묻는 리퀴드 글래스 다이얼로그.
//
// 디자인: my.jsx `ConfirmSheet` + `VybeDialogButton` (이름은 Sheet지만
// 실제 구현은 화면 정중앙 다이얼로그다 — 바텀시트가 아니다).
//
// 「제목 → 설명 → [취소][확인]」 고정 구조. 스크림을 탭하면 취소로 닫힌다.
// 앱 전역에서 재사용하는 공용 위젯 — 삭제·로그아웃 등 확인이 필요한 모든 곳.
// ============================================================

/// 카드 최대 폭. 좌우 24 여백과 함께 393 기준에서 디자인 폭이 나온다.
const double _kMaxWidth = 301;

/// CSS `blur(Npx)` ↔ Flutter `sigma N/2` (프로젝트 글래스 공통 환산).
const double _kScrimSigma = 3; // 디자인 blur(6px)
const double _kCardSigma = 9; // 디자인 blur(18px)

/// 확인 버튼 톤.
///
/// - [danger]: 레드 — 되돌릴 수 없는 동작(삭제·로그아웃). 기본값.
/// - [neutral]: 취소와 같은 글래스 톤 — 강조할 필요 없는 확인.
/// - [primary]: 퍼플 — 권유하는 동작(업데이트 등). 취소보다 눈에 띄어야 할 때.
enum VybeConfirmTone { danger, neutral, primary }

class VybeConfirmDialog extends StatelessWidget {
  final String title;
  final String message;

  /// 확인 버튼 문구. 예: '삭제', '로그아웃'.
  final String confirmLabel;

  /// 취소 버튼 문구.
  final String cancelLabel;

  /// 확인 버튼 톤. 기본은 위험(레드) — 이 다이얼로그의 원래 용도.
  final VybeConfirmTone tone;

  const VybeConfirmDialog({
    super.key,
    required this.title,
    required this.message,
    required this.confirmLabel,
    this.cancelLabel = '취소',
    this.tone = VybeConfirmTone.danger,
  });

  /// 다이얼로그를 띄우고 결과를 돌려준다 — 확인이면 true, 취소·바깥 탭·뒤로가기면 false.
  ///
  /// 확인 후 처리는 **호출측이** 반환값을 받아서 한다(위젯이 콜백을 들고 있지 않음).
  /// 비동기 작업 중 다이얼로그가 떠 있을 이유가 없고, `context.mounted` 판정도
  /// 호출측 화면 기준이라야 맞다.
  ///
  /// [useRootNavigator]는 기본 true — MainScaffold의 floating 바텀 nav는 탭
  /// Navigator 위(Stack)에 떠 있어서, 탭 Navigator에 띄우면 스크림이 nav를 못 덮고
  /// 그 아래로 깔린다. 루트에 띄우면 nav까지 덮이므로 nav를 따로 숨길 필요가 없다.
  static Future<bool> show(
    BuildContext context, {
    required String title,
    required String message,
    required String confirmLabel,
    String cancelLabel = '취소',
    VybeConfirmTone tone = VybeConfirmTone.danger,
    bool useRootNavigator = true,
  }) async {
    final result = await showGeneralDialog<bool>(
      context: context,
      useRootNavigator: useRootNavigator,
      barrierDismissible: true,
      barrierLabel: cancelLabel,
      // 스크림은 카드와 함께 페이드돼야 해서 barrierColor는 투명으로 두고
      // 배리어를 다이얼로그 안에서 직접 그린다(디자인의 blur 6 스크림).
      barrierColor: Colors.transparent,
      transitionDuration: const Duration(milliseconds: 220),
      pageBuilder: (_, __, ___) => VybeConfirmDialog(
        title: title,
        message: message,
        confirmLabel: confirmLabel,
        cancelLabel: cancelLabel,
        tone: tone,
      ),
      transitionBuilder: (context, animation, _, child) {
        // 디자인 dialogIn: opacity 0→1 + scale .92→1, cubic-bezier(.2,.9,.3,1).
        final curved = CurvedAnimation(
          parent: animation,
          curve: const Cubic(0.2, 0.9, 0.3, 1),
        );
        return FadeTransition(
          opacity: curved,
          child: ScaleTransition(
            scale: Tween<double>(begin: 0.92, end: 1).animate(curved),
            child: child,
          ),
        );
      },
    );
    return result ?? false;
  }

  @override
  Widget build(BuildContext context) {
    // showGeneralDialog는 showDialog와 달리 Material을 씌워 주지 않는다.
    // Material 조상이 없으면 Text가 전부 노란 이중 밑줄로 그려지므로
    // 배경을 안 칠하는 transparency 타입으로 감싼다.
    return Material(
      type: MaterialType.transparency,
      child: Stack(
        children: [
          // 스크림 — 탭하면 취소.
          Positioned.fill(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => Navigator.of(context).pop(false),
              child: BackdropFilter(
                filter: ui.ImageFilter.blur(
                  sigmaX: _kScrimSigma,
                  sigmaY: _kScrimSigma,
                ),
                child: const ColoredBox(color: Color(0xA80E0D12)),
              ),
            ),
          ),
          Center(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 24.w),
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: _kMaxWidth.w),
                child: _card(context),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _card(BuildContext context) {
    final radius = BorderRadius.circular(19.r);

    // 그림자는 ClipRRect 바깥에 둔다 — 안에 두면 클립에 잘려 아예 안 보인다.
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: radius,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.36),
            blurRadius: 30.r,
            offset: Offset(0, 10.h),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: radius,
        child: BackdropFilter(
          filter: ui.ImageFilter.blur(sigmaX: _kCardSigma, sigmaY: _kCardSigma),
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: const Color(0x29787880),
              borderRadius: radius,
              border: Border.all(color: Colors.white.withValues(alpha: 0.10)),
            ),
            child: Stack(
              children: [
                // 카드 상단 1px 하이라이트 — 유리 모서리에 빛이 걸린 느낌.
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    height: 1,
                    color: Colors.white.withValues(alpha: 0.18),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(24.r),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        title,
                        textAlign: TextAlign.center,
                        style: VybeTypography.heading4.copyWith(
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(height: 12.h),
                      Text(
                        message,
                        textAlign: TextAlign.center,
                        style: VybeTypography.body4.copyWith(
                          height: 20 / 14,
                          color: Colors.white.withValues(alpha: 0.68),
                        ),
                      ),
                      SizedBox(height: 24.h),
                      Row(
                        children: [
                          Expanded(
                            child: _DialogButton(
                              label: cancelLabel,
                              onTap: () => Navigator.of(context).pop(false),
                            ),
                          ),
                          SizedBox(width: 12.w),
                          Expanded(
                            child: _DialogButton(
                              label: confirmLabel,
                              tone: tone,
                              onTap: () => Navigator.of(context).pop(true),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// 다이얼로그 하단 버튼 — 누르는 동안 배경만 밝아진다(디자인 transition .1s linear).
///
/// VybeButton 규격을 다이얼로그 크기로 줄인 값: height 48 · radius 12 ·
/// 라벨 Medium 500 / 18sp / lh 1 / ls -2.5%.
class _DialogButton extends StatefulWidget {
  final String label;
  final VoidCallback onTap;

  /// 취소 버튼은 항상 글래스([VybeConfirmTone.neutral]).
  final VybeConfirmTone tone;

  const _DialogButton({
    required this.label,
    required this.onTap,
    this.tone = VybeConfirmTone.neutral,
  });

  @override
  State<_DialogButton> createState() => _DialogButtonState();
}

class _DialogButtonState extends State<_DialogButton> {
  bool _pressed = false;

  void _setPressed(bool v) {
    if (v != _pressed) setState(() => _pressed = v);
  }

  @override
  Widget build(BuildContext context) {
    final fill = switch (widget.tone) {
      VybeConfirmTone.danger =>
        _pressed ? VybeColors.accentRed700 : VybeColors.accentRed500,
      VybeConfirmTone.primary =>
        _pressed ? VybeColors.mainPurple700 : VybeColors.mainPurple500,
      VybeConfirmTone.neutral =>
        Colors.white.withValues(alpha: _pressed ? 0.12 : 0.07),
    };

    return VybeLiquidPress(
      onTap: widget.onTap,
      borderRadius: BorderRadius.circular(12.r),
      onPressChanged: _setPressed,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 340),
        curve: Curves.ease,
        height: 48.h,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: fill,
          borderRadius: BorderRadius.circular(12.r),
          // 채운 버튼(레드·퍼플)엔 테두리를 두지 않는다 — 글래스 톤만 경계가 필요.
          border: widget.tone == VybeConfirmTone.neutral
              ? Border.all(color: Colors.white.withValues(alpha: 0.12))
              : null,
        ),
        child: Text(
          widget.label,
          style: TextStyle(
            fontFamily: 'Pretendard',
            fontWeight: FontWeight.w500,
            fontSize: 18.sp,
            height: 1,
            letterSpacing: 18 * -0.025,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
