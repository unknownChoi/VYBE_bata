import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vybe/design_system/colors.dart';
import 'package:vybe/design_system/typography.dart';
import 'package:vybe/presentation/common/renew/renew_glass.dart';
import 'package:vybe/presentation/common/renew/renew_icons.dart';
import 'package:vybe/presentation/common/version_gate/viewmodels/version_check_viewmodel.dart';
import 'package:vybe/presentation/common/widgets/vybe_glass_button.dart';

// ============================================================
// 마이페이지 **리뉴얼** 공통 위젯 (my_renew.html 디자인 기반)
//
// 토큰·글래스 카드·섹션 헤더는 공용 [RenewGlass]를 그대로 쓰고,
// 여기엔 마이 화면 계열에서만 쓰는 조각(푸시 헤더·메뉴 행·토글·입력)을 둔다.
// ============================================================

/// 위험(로그아웃·삭제) 강조 색 — 디자인 RED[500].
const Color kMyDanger = VybeColors.accentRed500;

/// 화면 좌우 여백 (디자인 PAGE_H).
const double kMyPagePad = RenewGlass.pagePad;

/// 섹션 사이 간격 (디자인 SP.xxl).
const double kMySectionGap = 24;

/// 유리 인풋 배경 (디자인 MRField) — 카드보다 옅은 채움.
BoxDecoration myInputDecoration({double radius = 12}) => BoxDecoration(
  color: const Color(0x0FFFFFFF), // rgba(255,255,255,0.06)
  borderRadius: BorderRadius.circular(radius.r),
  border: Border.all(color: RenewGlass.tileBorder),
);

// ============================================================
// 푸시 화면 헤더 (MRPushHead)
// ============================================================

/// 하위 화면 공통 상단 바 — 뒤로가기 + 가운데 제목 + (선택) 우측 슬롯.
///
/// 제목이 정확히 가운데 오도록 좌·우 슬롯 폭을 [_slot]으로 같게 맞춘다.
class MyPushHeader extends StatelessWidget {
  final String title;

  /// 우측 38 슬롯에 넣을 위젯. 없으면 빈 자리로 남겨 제목 중앙을 지킨다.
  final Widget? trailing;

  const MyPushHeader({super.key, required this.title, this.trailing});

  static const double _slot = 38;

  @override
  Widget build(BuildContext context) {
    return RenewBar(
      padding: EdgeInsets.only(top: MediaQuery.paddingOf(context).top),
      child: SizedBox(
        height: 46.h,
        child: Row(
          children: [
            SizedBox(width: (kMyPagePad - 8).w),
            VybeGlassButton(
              onTap: () => Navigator.of(context).maybePop(),
              size: _slot,
              iconSize: 17,
              hitSize: _slot,
            ),
            Expanded(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 8.w),
                child: Text(
                  title,
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: VybeTypography.button1.copyWith(color: RenewGlass.t1),
                ),
              ),
            ),
            SizedBox(
              width: _slot.w,
              child: Align(
                alignment: Alignment.centerRight,
                child: trailing ?? const SizedBox.shrink(),
              ),
            ),
            SizedBox(width: (kMyPagePad - 8).w),
          ],
        ),
      ),
    );
  }
}

// ============================================================
// 메뉴 행 (MRRow)
// ============================================================

/// `[아이콘] 라벨 ... 값 >` 한 줄. 카드로 감싸지 않고 헤어라인으로만 나눈다.
///
/// [danger]는 로그아웃처럼 되돌리기 어려운 항목 — 붉은 톤에 꺾쇠를 빼서
/// '이동'이 아니라 '실행'임을 드러낸다.
class MyMenuRow extends StatelessWidget {
  /// [RenewIcons] 패스.
  final String icon;
  final String label;

  /// 우측 보조 값 (예: 리뷰 개수). null이면 표시 안 함.
  final String? value;

  final VoidCallback onTap;
  final bool danger;

  /// 섹션 마지막 행 — 아래 구분선을 지운다.
  final bool last;

  const MyMenuRow({
    super.key,
    required this.icon,
    required this.label,
    required this.onTap,
    this.value,
    this.danger = false,
    this.last = false,
  });

  @override
  Widget build(BuildContext context) {
    final tint = danger ? kMyDanger : null;

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 12.h),
        decoration: BoxDecoration(
          border: last
              ? null
              : const Border(bottom: BorderSide(color: RenewGlass.hair)),
        ),
        child: Row(
          children: [
            Container(
              width: 34.r,
              height: 34.r,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: tint?.withValues(alpha: 0.12) ?? RenewGlass.tileFill,
                border: Border.all(
                  color: tint?.withValues(alpha: 0.26) ?? RenewGlass.tileBorder,
                ),
              ),
              child: RenewIcon(
                path: icon,
                size: 17,
                color: tint ?? RenewGlass.t2,
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: VybeTypography.body3.copyWith(
                  fontWeight: FontWeight.w500,
                  color: tint ?? RenewGlass.t1,
                ),
              ),
            ),
            if (value != null) ...[
              SizedBox(width: 12.w),
              Text(value!, style: RenewGlass.body(color: RenewGlass.t4)),
            ],
            if (!danger) ...[
              SizedBox(width: 12.w),
              const RenewChevron(
                dir: RenewChevronDir.right,
                size: 16,
                color: Color(0x52FFFFFF), // rgba(255,255,255,0.32)
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// ============================================================
// 등장 애니메이션 (VFadeUp)
// ============================================================

/// 위로 6px 떠오르며 나타난다. [index]마다 45ms씩 밀어 순서대로 들어온다.
class MyFadeUp extends StatefulWidget {
  final int index;
  final Widget child;

  const MyFadeUp({super.key, this.index = 0, required this.child});

  @override
  State<MyFadeUp> createState() => _MyFadeUpState();
}

class _MyFadeUpState extends State<MyFadeUp> {
  bool _on = false;

  @override
  void initState() {
    super.initState();
    // 첫 프레임 전에 true가 되면 애니메이션 없이 그려져 계단 효과가 사라진다.
    Future.delayed(Duration(milliseconds: 40 + widget.index * 45), () {
      if (mounted) setState(() => _on = true);
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedSlide(
      offset: _on ? Offset.zero : const Offset(0, 0.06),
      duration: const Duration(milliseconds: 280),
      curve: Curves.easeOut,
      child: AnimatedOpacity(
        opacity: _on ? 1 : 0,
        duration: const Duration(milliseconds: 280),
        curve: Curves.easeOut,
        child: widget.child,
      ),
    );
  }
}

// ============================================================
// 토글 (MRToggle)
// ============================================================

/// 46×28 스위치. 켜짐 보라 · 꺼짐 흰 16%.
class MyToggle extends StatelessWidget {
  final bool on;
  final VoidCallback onTap;

  const MyToggle({super.key, required this.on, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        width: 46.w,
        height: 28.h,
        padding: EdgeInsets.all(3.r),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(99.r),
          color: on
              ? VybeColors.mainPurple500
              : Colors.white.withValues(alpha: 0.16),
        ),
        child: AnimatedAlign(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOut,
          alignment: on ? Alignment.centerRight : Alignment.centerLeft,
          child: Container(
            width: 22.r,
            height: 22.r,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.35),
                  blurRadius: 5.r,
                  offset: Offset(0, 2.h),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ============================================================
// 입력 필드 (MRField)
// ============================================================

/// 라벨 + 유리 상자 한 칸. 상자 안 내용([child])은 화면이 정한다
/// (편집 가능한 `TextField` / 읽기 전용 `Text`).
class MyField extends StatelessWidget {
  final String label;
  final Widget child;

  const MyField({super.key, required this.label, required this.child});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: EdgeInsets.only(bottom: 8.h),
          child: Text(
            label,
            style: RenewGlass.caption(
              lineHeight: 14,
              weight: FontWeight.w700,
            ),
          ),
        ),
        Container(
          height: 50.h,
          padding: EdgeInsets.symmetric(horizontal: 14.w),
          alignment: Alignment.centerLeft,
          decoration: myInputDecoration(),
          child: child,
        ),
      ],
    );
  }
}

// ============================================================
// 작은 조각
// ============================================================

/// 아이콘 하나만 든 원형 유리 타일 (빈 상태 일러스트용).
class MyGlassTile extends StatelessWidget {
  final String icon;
  final double size;
  final double radius;

  const MyGlassTile({
    super.key,
    required this.icon,
    this.size = 60,
    this.radius = 18,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size.r,
      height: size.r,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: RenewGlass.tileFill,
        borderRadius: BorderRadius.circular(radius.r),
        border: Border.all(color: RenewGlass.tileBorder),
      ),
      child: RenewIcon(path: icon, size: size * 0.42, color: RenewGlass.t4),
    );
  }
}

/// 하단 앱 버전 표기. 값은 앱 실행 시 버전 게이트가 이미 읽어둔 것을
/// 그대로 쓴다 — 화면마다 다시 조회하지 않는다.
/// (하드코딩하면 릴리스마다 잊고 안 고쳐서 실제 버전과 어긋난다)
class AppVersionLabel extends ConsumerWidget {
  const AppVersionLabel({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 버전 문자열만 구독 — 복귀 재검사로 정책이 바뀌어도 버전이 그대로면
    // 이 라벨은 리빌드되지 않는다.
    final label = ref.watch(
      versionCheckProvider.select((s) => s.value?.versionLabel ?? ''),
    );
    return Text(
      label.isEmpty ? 'vybe' : 'vybe · 버전 $label',
      textAlign: TextAlign.center,
      style: RenewGlass.caption(),
    );
  }
}

// ============================================================
// 아바타 (MRAvatar)
// ============================================================

/// 프로필 아바타 — 이미지가 있으면 네트워크 이미지, 없으면 이니셜 + 퍼플 그라데이션.
class MyAvatar extends StatelessWidget {
  final String name;
  final String imageUrl;
  final double size;

  /// 라임 링 + 퍼플 글로우. 편집 화면처럼 강조가 필요 없으면 false.
  final bool ring;

  const MyAvatar({
    super.key,
    required this.name,
    required this.imageUrl,
    this.size = 76,
    this.ring = true,
  });

  @override
  Widget build(BuildContext context) {
    final child = imageUrl.isNotEmpty
        ? ClipOval(
            child: Image.network(
              imageUrl,
              width: size.r,
              height: size.r,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => _initial(),
            ),
          )
        : _initial();

    return Container(
      width: size.r,
      height: size.r,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: ring
            ? [
                // 0 0 0 2px rgba(181,255,96,0.5)
                BoxShadow(
                  color: VybeColors.mainLime500.withValues(alpha: 0.5),
                  spreadRadius: 2.r,
                ),
                // 0 10px 26px rgba(119,49,254,0.38)
                BoxShadow(
                  color: VybeColors.mainPurple500.withValues(alpha: 0.38),
                  blurRadius: 26.r,
                  offset: Offset(0, 10.h),
                ),
              ]
            : null,
      ),
      child: child,
    );
  }

  Widget _initial() {
    return Container(
      width: size.r,
      height: size.r,
      alignment: Alignment.center,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF8B52FF),
            VybeColors.mainPurple500,
            VybeColors.mainPurple900,
          ],
          stops: [0, 0.45, 1],
        ),
      ),
      child: Text(
        name.isNotEmpty ? name.characters.first : '?',
        style: TextStyle(
          fontFamily: 'Pretendard',
          fontWeight: FontWeight.w800,
          fontSize: (size * 0.4).sp,
          color: Colors.white,
          letterSpacing: size * 0.4 * -0.02,
        ),
      ),
    );
  }
}

// ============================================================
// 하단 고정 액션 바
// ============================================================

/// 저장 버튼처럼 화면 맨 아래 붙는 유리 바 (디자인 MREditScreen 하단).
class MyBottomBar extends StatelessWidget {
  final Widget child;

  const MyBottomBar({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final safe = MediaQuery.paddingOf(context).bottom;
    return ClipRect(
      child: BackdropFilter(
        filter: ui.ImageFilter.blur(
          sigmaX: RenewGlass.barBlur,
          sigmaY: RenewGlass.barBlur,
        ),
        child: Container(
          padding: EdgeInsets.fromLTRB(
            kMyPagePad.w,
            12.h,
            kMyPagePad.w,
            // 홈 인디케이터가 있으면 그만큼, 없으면 디자인 값 30.
            safe > 30.h ? safe : 30.h,
          ),
          decoration: const BoxDecoration(
            color: RenewGlass.barFill,
            border: Border(top: BorderSide(color: RenewGlass.hair)),
          ),
          child: child,
        ),
      ),
    );
  }
}
