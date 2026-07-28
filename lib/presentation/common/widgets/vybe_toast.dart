import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vybe/design_system/colors.dart';
import 'package:vybe/presentation/main_scaffold/main_scaffold.dart';
import 'package:vybe/presentation/main_scaffold/nav_bar_visibility_provider.dart';

/// 화면 하단에 떠오르는 pill 형태 토스트.
/// 라임 원형 체크 아이콘 + 메시지. (예: "주소가 복사되었습니다")
///
/// 앱의 하단 알림은 전부 이 토스트로 통일한다 (SnackBar 사용 금지).
/// SnackBar는 화면 맨 아래에 붙어 floating nav 바에 가린다.
class VybeToast {
  static OverlayEntry? _current;

  /// 토스트 표시. 이미 떠 있으면 교체.
  /// [isError] true면 라임 체크 대신 빨강 경고 아이콘.
  static void show(
    BuildContext context, {
    required String message,
    bool isError = false,
    Duration duration = const Duration(milliseconds: 3000),
  }) {
    // 루트 오버레이에 넣어야 MainScaffold의 floating nav 바(탭 콘텐츠 위 레이어)나
    // 탭별 중첩 Navigator·바텀시트보다 항상 위에 그려진다.
    final overlay = Overlay.of(context, rootOverlay: true);

    // nav 바 존재 여부는 '호출한 화면'의 context로 판단한다.
    // 루트 오버레이 안에서는 MainScaffold가 조상이 아니라 항상 null이 되고,
    // 루트 Navigator로 push된 전체화면(사진 뷰어 등)은 바 자체가 안 보이므로
    // 호출부 기준 판정이 곧 '지금 바에 가릴 수 있는가'와 같다.
    final hasNavBar =
        context.findAncestorWidgetOfExactType<MainScaffold>() != null;

    // 이미 제거된 엔트리를 또 remove하면 assert가 나므로 mounted 확인.
    if (_current?.mounted ?? false) _current!.remove();
    _current = null;

    late final OverlayEntry entry;
    entry = OverlayEntry(
      builder: (_) => _ToastWidget(
        message: message,
        isError: isError,
        hasNavBar: hasNavBar,
        duration: duration,
        onDismissed: () {
          if (_current == entry) _current = null;
          if (entry.mounted) entry.remove();
        },
      ),
    );
    _current = entry;
    overlay.insert(entry);
  }
}

class _ToastWidget extends ConsumerStatefulWidget {
  final String message;
  final bool isError;
  final bool hasNavBar;
  final Duration duration;
  final VoidCallback onDismissed;

  const _ToastWidget({
    required this.message,
    required this.isError,
    required this.hasNavBar,
    required this.duration,
    required this.onDismissed,
  });

  @override
  ConsumerState<_ToastWidget> createState() => _ToastWidgetState();
}

class _ToastWidgetState extends ConsumerState<_ToastWidget> {
  bool _visible = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      setState(() => _visible = true);
    });
    Future.delayed(widget.duration, () {
      if (!mounted) return;
      setState(() => _visible = false);
      // 사라지는 애니메이션(250ms) 종료 후 제거
      Future.delayed(const Duration(milliseconds: 260), widget.onDismissed);
    });
  }

  @override
  Widget build(BuildContext context) {
    // 하단 floating nav 바가 떠 있으면 바 바로 위(12 간격)에 붙인다.
    // (MainScaffold 밖 화면 — 인증 플로우 등 — 은 바가 없으므로 기본 위치)
    final navBarShown = widget.hasNavBar && !ref.watch(navBarHiddenProvider);
    // 키보드가 올라와 있으면 바는 키보드 뒤에 가려지므로 키보드 위로만 띄운다.
    final keyboard = MediaQuery.of(context).viewInsets.bottom;
    final bottomOffset = keyboard > 0
        ? keyboard + 12.h
        : navBarShown
        ? navBarTotalHeight(context) + 12.h
        : 80.h;

    return AnimatedPositioned(
      // nav 바가 숨거나 키보드가 오르내릴 때 토스트도 따라 움직인다.
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOutCubic,
      left: 0,
      right: 0,
      bottom: bottomOffset,
      child: IgnorePointer(
        child: Center(
          child: AnimatedSlide(
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeOut,
            offset: Offset(0, _visible ? 0 : 0.4),
            child: AnimatedOpacity(
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeOut,
              opacity: _visible ? 1 : 0,
              child: Material(
                type: MaterialType.transparency,
                child: ClipRRect(
                borderRadius: BorderRadius.circular(999.r),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 18.w,
                      vertical: 12.h,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xF51C1C20),
                      borderRadius: BorderRadius.circular(999.r),
                      border: Border.all(color: VybeColors.gray700),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.5),
                          blurRadius: 28.r,
                          offset: Offset(0, 8.h),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 18.r,
                          height: 18.r,
                          decoration: BoxDecoration(
                            color: widget.isError
                                ? VybeColors.accentRed500
                                : VybeColors.mainLime500,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            widget.isError
                                ? Icons.priority_high_rounded
                                : Icons.check_rounded,
                            size: 11.r,
                            color: const Color(0xFF101013),
                          ),
                        ),
                        SizedBox(width: 8.w),
                        Text(
                          widget.message,
                          style: TextStyle(
                            fontFamily: 'Pretendard',
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
