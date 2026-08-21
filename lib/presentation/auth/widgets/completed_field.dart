import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vybe/design_system/colors.dart';
import 'package:vybe/design_system/typography.dart';
import 'package:vybe/presentation/common/renew/renew_glass.dart';

/// 입력이 끝난 항목을 접어 두는 리퀴드 글래스 행 (디자인 `SVDone`).
///
/// 리뉴얼 전에는 24sp 입력 필드가 그대로 아래에 쌓여 화면을 채웠다 —
/// 단계가 늘수록 정작 지금 입력할 칸이 밀려 내려간다. 값이 확정된 항목은
/// 한 줄 카드로 접고, 탭하면 [onTap]으로 제자리 편집에 돌아간다.
class CompletedField extends StatefulWidget {
  /// 필드 레이블 (예: '이름', '생년월일', '전화번호', '통신사')
  final String label;

  /// 표시할 값 (포맷 적용 후 문자열)
  final String value;

  /// 행 탭 — 해당 단계 재활성화
  final VoidCallback? onTap;

  const CompletedField({
    super.key,
    required this.label,
    required this.value,
    this.onTap,
  });

  @override
  State<CompletedField> createState() => _CompletedFieldState();
}

class _CompletedFieldState extends State<CompletedField> {
  bool _pressed = false;

  void _setPressed(bool v) {
    if (v != _pressed) setState(() => _pressed = v);
  }

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(16.r);

    return GestureDetector(
      onTap: widget.onTap,
      onTapDown: (_) => _setPressed(true),
      onTapUp: (_) => _setPressed(false),
      onTapCancel: () => _setPressed(false),
      behavior: HitTestBehavior.opaque,
      child: AnimatedScale(
        scale: _pressed ? 0.985 : 1,
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOutCubic,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          decoration: BoxDecoration(
            borderRadius: radius,
            boxShadow: [
              BoxShadow(
                color: const Color(0x57000000), // rgba(0,0,0,0.34)
                blurRadius: (_pressed ? 10 : 22).r,
                offset: Offset(0, (_pressed ? 2 : 8).h),
              ),
            ],
          ),
          foregroundDecoration: BoxDecoration(
            borderRadius: radius,
            border: Border.all(color: RenewGlass.cardBorder),
          ),
          child: ClipRRect(
            borderRadius: radius,
            child: BackdropFilter(
              filter: ui.ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: DecoratedBox(
                // 158deg 유리면 — 좌상단이 밝고 우하단으로 옅어진다
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment(-0.7, -1),
                    end: Alignment(0.7, 1),
                    colors: [
                      Color(0x21FFFFFF),
                      Color(0x0DFFFFFF),
                      Color(0x05FFFFFF),
                    ],
                    stops: [0.0, 0.42, 1.0],
                  ),
                ),
                child: Stack(
                  children: [
                    // 굴절광 — 좌상단 흰 스펙큘러 / 우하단 보라 반사
                    const Positioned(
                      left: -30,
                      top: -46,
                      child: _Specular(
                        width: 190,
                        height: 96,
                        color: Color(0x33FFFFFF),
                        blur: 5,
                      ),
                    ),
                    const Positioned(
                      right: -40,
                      bottom: -52,
                      child: _Specular(
                        width: 150,
                        height: 90,
                        color: Color(0x427731FE),
                        blur: 6,
                      ),
                    ),
                    // 상단 1px 하이라이트
                    const Positioned(
                      top: 0,
                      left: 0,
                      right: 0,
                      height: 1,
                      child: ColoredBox(color: Color(0x38FFFFFF)),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: 16.w,
                        vertical: 14.h,
                      ),
                      child: Row(
                        children: [
                          const _DoneTick(),
                          SizedBox(width: 12.w),
                          Text(
                            widget.label,
                            style: VybeTypography.caption.copyWith(
                              height: 1,
                              color: RenewGlass.t4,
                            ),
                          ),
                          SizedBox(width: 12.w),
                          Expanded(
                            child: Text(
                              widget.value,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              textAlign: TextAlign.right,
                              style: TextStyle(
                                fontFamily: 'Pretendard',
                                fontWeight: FontWeight.w500,
                                fontSize: 15.sp,
                                letterSpacing: 15 * -0.025,
                                color: RenewGlass.t2,
                              ),
                            ),
                          ),
                          SizedBox(width: 12.w),
                          Icon(
                            Icons.edit_outlined,
                            size: 15.r,
                            color: VybeColors.gray600,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// 완료 표시 — 라임 링 안의 체크.
class _DoneTick extends StatelessWidget {
  const _DoneTick();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 16.r,
      height: 16.r,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: VybeColors.mainLime500.withValues(alpha: 0.16),
        border: Border.all(
          color: VybeColors.mainLime500.withValues(alpha: 0.34),
        ),
      ),
      child: Icon(
        Icons.check_rounded,
        size: 10.r,
        color: VybeColors.mainLime500,
      ),
    );
  }
}

/// 유리면에 번지는 빛 얼룩. 카드 밖으로 걸쳐야 자연스러워 [Positioned] 음수와 함께 쓴다.
class _Specular extends StatelessWidget {
  final double width;
  final double height;
  final Color color;
  final double blur;

  const _Specular({
    required this.width,
    required this.height,
    required this.color,
    required this.blur,
  });

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: ImageFiltered(
        imageFilter: ui.ImageFilter.blur(sigmaX: blur, sigmaY: blur),
        child: Container(
          width: width.w,
          height: height.h,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: RadialGradient(
              colors: [color, color.withValues(alpha: 0)],
              stops: const [0.0, 0.7],
            ),
          ),
        ),
      ),
    );
  }
}
