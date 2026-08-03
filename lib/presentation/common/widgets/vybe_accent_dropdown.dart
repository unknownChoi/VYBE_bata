import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vybe/design_system/colors.dart';
import 'package:vybe/design_system/typography.dart';

/// 정렬·필터용 팝업 드롭다운. 선택된 항목은 [accent] 색 + 체크 표시.
///
/// [child] 가 트리거(버튼 UI)이고, 항목 목록은 `toString()` 으로 그린다.
class VybeAccentDropdown<T> extends StatelessWidget {
  final T value;
  final List<T> items;
  final ValueChanged<T> onSelected;

  /// 선택된 항목 강조 색 (화면별 액센트).
  final Color accent;

  /// 드롭다운을 여는 트리거 위젯.
  final Widget child;

  const VybeAccentDropdown({
    super.key,
    required this.value,
    required this.items,
    required this.onSelected,
    required this.accent,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<T>(
      onSelected: onSelected,
      color: VybeColors.gray800,
      elevation: 12,
      position: PopupMenuPosition.under,
      offset: Offset(0, 6.h),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.r),
        side: const BorderSide(color: VybeColors.gray700),
      ),
      itemBuilder: (_) => items.map((it) {
        final on = it == value;
        return PopupMenuItem<T>(
          value: it,
          height: 40.h,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '$it',
                style: VybeTypography.caption.copyWith(
                  fontWeight: on ? FontWeight.w700 : FontWeight.w500,
                  color: on ? accent : Colors.white,
                ),
              ),
              if (on) ...[
                SizedBox(width: 12.w),
                Icon(Icons.check_rounded, size: 14.r, color: accent),
              ],
            ],
          ),
        );
      }).toList(),
      child: child,
    );
  }
}
