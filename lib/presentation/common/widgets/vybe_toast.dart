import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vybe/design_system/colors.dart';

/// 화면 하단에 떠오르는 pill 형태 토스트.
/// 라임 원형 체크 아이콘 + 메시지. (예: "주소가 복사되었습니다")
class VybeToast {
  static OverlayEntry? _current;

  /// 토스트 표시. 이미 떠 있으면 교체.
  static void show(
    BuildContext context, {
    required String message,
    Duration duration = const Duration(milliseconds: 3000),
  }) {
    final overlay = Overlay.of(context);

    _current?.remove();
    _current = null;

    late final OverlayEntry entry;
    entry = OverlayEntry(
      builder: (_) => _ToastWidget(
        message: message,
        duration: duration,
        onDismissed: () {
          if (_current == entry) _current = null;
          entry.remove();
        },
      ),
    );
    _current = entry;
    overlay.insert(entry);
  }
}

class _ToastWidget extends StatefulWidget {
  final String message;
  final Duration duration;
  final VoidCallback onDismissed;

  const _ToastWidget({
    required this.message,
    required this.duration,
    required this.onDismissed,
  });

  @override
  State<_ToastWidget> createState() => _ToastWidgetState();
}

class _ToastWidgetState extends State<_ToastWidget> {
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
    return Positioned(
      left: 0,
      right: 0,
      bottom: 80.h,
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
                          decoration: const BoxDecoration(
                            color: VybeColors.mainLime500,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.check_rounded,
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
