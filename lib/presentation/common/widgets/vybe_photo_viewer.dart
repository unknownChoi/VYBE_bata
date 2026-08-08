import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vybe/design_system/colors.dart';

/// 사진 라이트박스 (풀스크린 뷰어).
/// 사진탭/리뷰탭에서 사진 클릭 시 호출.
/// - 좌우 스와이프 / 화살표로 이동 (사진 2장 이상)
/// - 핀치 줌
/// - 상단 카운터 + 닫기, 하단 dots
class VybePhotoViewer {
  static Future<void> open(
    BuildContext context, {
    required List<String> imageUrls,
    int initialIndex = 0,
  }) {
    if (imageUrls.isEmpty) return Future.value();
    return Navigator.of(context, rootNavigator: true).push(
      PageRouteBuilder(
        opaque: false,
        barrierColor: Colors.transparent,
        transitionDuration: const Duration(milliseconds: 200),
        reverseTransitionDuration: const Duration(milliseconds: 200),
        pageBuilder: (_, __, ___) => _PhotoViewerScreen(
          imageUrls: imageUrls,
          initialIndex: initialIndex,
        ),
        transitionsBuilder: (_, animation, __, child) =>
            FadeTransition(opacity: animation, child: child),
      ),
    );
  }
}

class _PhotoViewerScreen extends StatefulWidget {
  final List<String> imageUrls;
  final int initialIndex;

  const _PhotoViewerScreen({
    required this.imageUrls,
    required this.initialIndex,
  });

  @override
  State<_PhotoViewerScreen> createState() => _PhotoViewerScreenState();
}

class _PhotoViewerScreenState extends State<_PhotoViewerScreen> {
  late final PageController _pageController;
  late int _index;

  @override
  void initState() {
    super.initState();
    _index = widget.initialIndex;
    _pageController = PageController(initialPage: widget.initialIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _close() => Navigator.of(context).maybePop();

  void _goTo(int i) {
    _pageController.animateToPage(
      i,
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    final total = widget.imageUrls.length;
    final multi = total > 1;
    final topPad = MediaQuery.paddingOf(context).top;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
        child: Container(
          color: Colors.black.withValues(alpha: 0.35),
          child: Column(
            children: [
              // 상단 바: 카운터 + 닫기
              Padding(
                padding: EdgeInsets.fromLTRB(20.w, topPad + 12.h, 20.w, 12.h),
                child: Row(
                  mainAxisAlignment: multi
                      ? MainAxisAlignment.spaceBetween
                      : MainAxisAlignment.end,
                  children: [
                    if (multi)
                      Text.rich(
                        TextSpan(
                          children: [
                            TextSpan(text: '${_index + 1}'),
                            TextSpan(
                              text: ' / $total',
                              style: const TextStyle(
                                color: VybeColors.gray500,
                              ),
                            ),
                          ],
                          style: TextStyle(
                            fontFamily: 'Pretendard',
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    _circleButton(
                      onTap: _close,
                      icon: Icons.close_rounded,
                    ),
                  ],
                ),
              ),

              // 이미지 영역
              Expanded(
                child: Stack(
                  children: [
                    PageView.builder(
                      controller: _pageController,
                      itemCount: total,
                      onPageChanged: (i) => setState(() => _index = i),
                      itemBuilder: (context, i) {
                        return GestureDetector(
                          onTap: _close,
                          child: Padding(
                            padding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 60.h),
                            child: Center(
                              child: GestureDetector(
                                onTap: () {}, // 이미지 탭은 닫기 방지
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(16.r),
                                  child: InteractiveViewer(
                                    minScale: 1,
                                    maxScale: 4,
                                    child: AspectRatio(
                                      aspectRatio: 4 / 5,
                                      child: Container(
                                        color: VybeColors.gray900,
                                        child: Image.network(
                                          widget.imageUrls[i],
                                          fit: BoxFit.cover,
                                          errorBuilder: (_, __, ___) =>
                                              const ColoredBox(
                                                color: VybeColors.gray900,
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
                      },
                    ),

                    // 좌우 화살표 (2장 이상)
                    if (multi && _index > 0)
                      Positioned(
                        left: 16.w,
                        top: 0,
                        bottom: 60.h,
                        child: Center(
                          child: _circleButton(
                            onTap: () => _goTo(_index - 1),
                            icon: Icons.chevron_left_rounded,
                            size: 40,
                          ),
                        ),
                      ),
                    if (multi && _index < total - 1)
                      Positioned(
                        right: 16.w,
                        top: 0,
                        bottom: 60.h,
                        child: Center(
                          child: _circleButton(
                            onTap: () => _goTo(_index + 1),
                            icon: Icons.chevron_right_rounded,
                            size: 40,
                          ),
                        ),
                      ),
                  ],
                ),
              ),

              // 하단 dots (2장 이상)
              if (multi)
                Padding(
                  padding: EdgeInsets.only(bottom: 44.h),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(total, (i) {
                      final active = i == _index;
                      return GestureDetector(
                        onTap: () => _goTo(i),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          margin: EdgeInsets.symmetric(horizontal: 3.w),
                          width: active ? 18.w : 6.w,
                          height: 6.w,
                          decoration: BoxDecoration(
                            color: active
                                ? Colors.white
                                : Colors.white.withValues(alpha: 0.4),
                            borderRadius: BorderRadius.circular(99.r),
                          ),
                        ),
                      );
                    }),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _circleButton({
    required VoidCallback onTap,
    required IconData icon,
    double size = 36,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: size.r,
        height: size.r,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.12),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, size: (size * 0.55).r, color: Colors.white),
      ),
    );
  }
}
