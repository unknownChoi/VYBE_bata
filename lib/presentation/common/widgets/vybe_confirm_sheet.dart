import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vybe/design_system/colors.dart';
import 'package:vybe/design_system/typography.dart';

/// 되돌릴 수 없는 동작을 한 번 더 묻는 바텀시트 (로그아웃 · 리뷰 삭제 등).
///
/// 「핸들 → 제목 → 설명 → [취소][확인]」 고정 구조.
/// 확인 버튼은 위험 동작이라 항상 레드([VybeColors.accentRed500]).
/// 취소는 시트를 pop 하고, 확인은 [onConfirm]만 호출한다(닫기는 호출부 책임 —
/// 비동기 처리 후 닫는 화면이 있어서).
class VybeConfirmSheet extends StatelessWidget {
  final String title;
  final String message;

  /// 확인(레드) 버튼 문구. 예: '로그아웃', '삭제'.
  final String confirmLabel;
  final VoidCallback onConfirm;

  /// 설명 문단 줄 간격. 두 줄 이상이면 지정한다.
  final double? messageHeight;

  /// 상단 핸들 색. 기본값은 시트 배경과 대비되는 흰색 30%.
  final Color? handleColor;

  /// 취소 버튼 배경. 기본값은 시트 위에서도 보이도록 흰색 14% + 테두리 24%.
  final BoxDecoration? cancelDecoration;

  const VybeConfirmSheet({
    super.key,
    required this.title,
    required this.message,
    required this.confirmLabel,
    required this.onConfirm,
    this.messageHeight,
    this.handleColor,
    this.cancelDecoration,
  });

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.paddingOf(context).bottom;
    return Container(
      padding: EdgeInsets.fromLTRB(20.w, 24.h, 20.w, 28.h + bottomInset),
      decoration: BoxDecoration(
        color: const Color(0xF01C1C20),
        borderRadius: BorderRadius.vertical(top: Radius.circular(22.r)),
        border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 38.w,
            height: 4.h,
            decoration: BoxDecoration(
              // gray700(#535355)은 시트 배경과 명도차가 작아 핸들이 안 보인다.
              color: handleColor ?? Colors.white.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(99.r),
            ),
          ),
          SizedBox(height: 18.h),
          Text(
            title,
            style: VybeTypography.heading4.copyWith(
              fontSize: 19.sp,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            message,
            textAlign: TextAlign.center,
            style: VybeTypography.body4.copyWith(
              height: messageHeight,
              color: VybeColors.gray400,
            ),
          ),
          SizedBox(height: 22.h),
          Row(
            children: [
              Expanded(
                child: _SheetButton(
                  label: '취소',
                  onTap: () => Navigator.of(context).pop(),
                  // glassTile(alpha 0.08)은 시트 위에서 버튼 경계가 거의 안 보여
                  // 대비를 올린다.
                  decoration: cancelDecoration ??
                      BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.14),
                        borderRadius: BorderRadius.circular(14.r),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.24),
                        ),
                      ),
                ),
              ),
              SizedBox(width: 10.w),
              Expanded(
                child: _SheetButton(
                  label: confirmLabel,
                  onTap: onConfirm,
                  decoration: BoxDecoration(
                    color: VybeColors.accentRed500,
                    borderRadius: BorderRadius.circular(14.r),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SheetButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  final BoxDecoration decoration;

  const _SheetButton({
    required this.label,
    required this.onTap,
    required this.decoration,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 50.h,
        alignment: Alignment.center,
        decoration: decoration,
        child: Text(
          label,
          style: VybeTypography.button1.copyWith(
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
