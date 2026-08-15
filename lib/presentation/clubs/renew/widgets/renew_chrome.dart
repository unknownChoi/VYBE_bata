import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vybe/design_system/colors.dart';
import 'package:vybe/design_system/typography.dart';
import 'package:vybe/presentation/clubs/renew/widgets/renew_button.dart';
import 'package:vybe/presentation/clubs/renew/widgets/renew_glass.dart';
import 'package:vybe/presentation/common/widgets/vybe_glass_button.dart';
import 'package:vybe/presentation/common/widgets/vybe_liquid_press.dart';

/// 상단바 안쪽 행 높이 (디자인 VR_CHROME_H = 상태바 54 + 행 46).
const double kRenewChromeRow = 46;

/// 상단바가 불투명해지는 스크롤 지점.
const double _solidAt = 210;

/// 상단바에 클럽 이름이 나타나는 스크롤 지점.
const double _titleAt = 250;

// ============================================================================
// 상단바 (VRChrome)
// ============================================================================

/// 스크롤 위에 떠 있는 상단바. 처음엔 투명하고 히어로를 지나면 유리로 바뀐다.
///
/// 뒤로가기 · 공유는 앱 공통 리퀴드 글래스 버튼([VybeGlassButton])을 쓴다.
///
/// 찜은 여기 두지 않는다 — 하단 액션 바([RenewBottomBar])에 같은 버튼이 있어
/// 한 화면에 찜 버튼이 둘이면 어느 쪽이 눌린 상태인지 헷갈린다.
class RenewChrome extends StatelessWidget {
  final double scrollY;
  final String clubName;
  final VoidCallback onBack;
  final VoidCallback onShare;

  const RenewChrome({
    super.key,
    required this.scrollY,
    required this.clubName,
    required this.onBack,
    required this.onShare,
  });

  /// 원 지름 = 탭 영역. 디자인 VGlassRound 38px 간격을 그대로 살리려고
  /// 히트 영역을 원 크기에 맞춘다.
  static const double _button = 38;

  @override
  Widget build(BuildContext context) {
    final solid = scrollY > _solidAt.h;
    final topInset = MediaQuery.paddingOf(context).top;

    // 색·블러를 한 진행값(t)으로 같이 굴린다 — 조건부로 BackdropFilter를
    // 끼웠다 뺐다 하면 위젯 트리가 바뀌어 색 전환이 뚝 끊긴다.
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0, end: solid ? 1 : 0),
      duration: const Duration(milliseconds: 240),
      curve: Curves.easeOut,
      builder: (context, t, child) {
        final bar = Container(
          padding: EdgeInsets.only(top: topInset),
          decoration: BoxDecoration(
            color: Color.lerp(Colors.transparent, RenewGlass.barFill, t),
            border: Border(
              bottom: BorderSide(
                color: Color.lerp(Colors.transparent, RenewGlass.hair, t)!,
              ),
            ),
          ),
          child: child,
        );
        // 투명할 땐 블러도 걸지 않는다 — 히어로가 그대로 보여야 하고,
        // 뒤 배경을 매 프레임 다시 뜨는 비용도 아낀다.
        if (t < 0.02) return bar;
        return ClipRect(
          child: BackdropFilter(
            filter: ui.ImageFilter.blur(
              sigmaX: RenewGlass.barBlur * t,
              sigmaY: RenewGlass.barBlur * t,
            ),
            child: bar,
          ),
        );
      },
      child: SizedBox(
        height: kRenewChromeRow.h,
        child: Row(
          children: [
            SizedBox(width: (RenewGlass.pagePad - 8).w),
            VybeGlassButton(
              onTap: onBack,
              icon: Icons.arrow_back_ios_new_rounded,
              size: _button,
              iconSize: 17,
              hitSize: _button,
            ),
            Expanded(
              child: AnimatedOpacity(
                opacity: scrollY > _titleAt.h ? 1 : 0,
                duration: const Duration(milliseconds: 200),
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8.w),
                  child: Text(
                    clubName,
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: VybeTypography.button1.copyWith(
                      color: RenewGlass.t1,
                    ),
                  ),
                ),
              ),
            ),
            VybeGlassButton(
              onTap: onShare,
              icon: Icons.ios_share_rounded,
              size: _button,
              iconSize: 16,
              hitSize: _button,
            ),
            SizedBox(width: (RenewGlass.pagePad - 8).w),
          ],
        ),
      ),
    );
  }
}

// ============================================================================
// 탭 바 (VRTabs)
// ============================================================================

/// 5개 세그먼트 탭. 선택된 칸만 흰 pill.
class RenewTabBar extends StatelessWidget {
  final List<String> tabs;
  final int activeIndex;
  final ValueChanged<int> onSelect;

  const RenewTabBar({
    super.key,
    required this.tabs,
    required this.activeIndex,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return RenewBar(
      topBorder: true,
      padding: EdgeInsets.symmetric(
        horizontal: RenewGlass.pagePad.w,
        vertical: 9.h,
      ),
      child: Row(
        children: List.generate(tabs.length, (i) {
          final selected = i == activeIndex;
          return Expanded(
            child: Padding(
              padding: EdgeInsets.only(right: i == tabs.length - 1 ? 0 : 2.w),
              child: GestureDetector(
                onTap: () => onSelect(i),
                behavior: HitTestBehavior.opaque,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  padding: EdgeInsets.symmetric(vertical: 9.h),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: selected ? Colors.white : Colors.transparent,
                    borderRadius: BorderRadius.circular(999.r),
                  ),
                  child: Text(
                    tabs[i],
                    maxLines: 1,
                    style: TextStyle(
                      fontFamily: 'Pretendard',
                      fontSize: 12.5.sp,
                      height: 16 / 12.5,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 12.5 * -0.025,
                      color: selected ? RenewGlass.ink : RenewGlass.t3,
                    ),
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}

// ============================================================================
// 하단 액션 바 (VRBottomBar)
// ============================================================================

/// 찜(정사각) + 길찾기 + 전화 문의. 화면 맨 아래 고정.
class RenewBottomBar extends StatelessWidget {
  final bool saved;
  final VoidCallback onSave;
  final VoidCallback onDirections;
  final VoidCallback onCall;

  const RenewBottomBar({
    super.key,
    required this.saved,
    required this.onSave,
    required this.onDirections,
    required this.onCall,
  });

  /// 홈 인디케이터가 있으면 그만큼, 없으면 디자인 값 30.
  static double bottomInset(BuildContext context) {
    final safe = MediaQuery.paddingOf(context).bottom;
    return safe > 30.h ? safe : 30.h;
  }

  /// 콘텐츠가 바에 가리지 않도록 확보해야 할 높이.
  static double height(BuildContext context) =>
      12.h + 56.h + bottomInset(context);

  @override
  Widget build(BuildContext context) {
    return ClipRect(
      child: BackdropFilter(
        filter: ui.ImageFilter.blur(
          sigmaX: RenewGlass.barBlur,
          sigmaY: RenewGlass.barBlur,
        ),
        child: Container(
          padding: EdgeInsets.fromLTRB(
            RenewGlass.pagePad.w,
            12.h,
            RenewGlass.pagePad.w,
            bottomInset(context),
          ),
          decoration: const BoxDecoration(
            color: RenewGlass.barFill,
            border: Border(top: BorderSide(color: RenewGlass.hair)),
          ),
          child: Row(
            children: [
              VybeLiquidPress(
                onTap: onSave,
                borderRadius: BorderRadius.circular(12.r),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 340),
                  width: 56.r,
                  height: 56.h,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: saved
                        ? VybeColors.mainPurple500.withValues(alpha: 0.20)
                        : RenewGlass.tileFill,
                    borderRadius: BorderRadius.circular(12.r),
                    border: Border.all(
                      color: saved
                          ? VybeColors.mainPurple500.withValues(alpha: 0.45)
                          : RenewGlass.tileBorder,
                    ),
                  ),
                  child: Icon(
                    saved ? Icons.favorite_rounded : Icons.favorite_border,
                    size: 21.r,
                    color: saved ? VybeColors.mainPurple500 : RenewGlass.t2,
                  ),
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: RenewButton(
                  label: '길찾기',
                  onTap: onDirections,
                  variant: RenewButtonVariant.quiet,
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: RenewButton(label: '전화 문의', onTap: onCall),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
