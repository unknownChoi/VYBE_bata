import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vybe/design_system/colors.dart';
import 'package:vybe/design_system/typography.dart';

/// 목록 화면 상단의 가로 스크롤 필터 칩 줄.
///
/// 입장비 무료(지역)·서비스 음료(음료 종류)가 같은 모양을 쓰고 있어 승격했다.
/// 화면마다 다른 건 액센트 색·아이콘·표시 라벨뿐이라 전부 파라미터로 받는다
/// (기본값은 원래 화면 값 유지 — 승격 전후로 그림이 바뀌지 않게).
class VybeChipFilterBar extends StatelessWidget {
  /// 칩으로 그릴 값 목록. 이 값이 그대로 [onChange] 로 올라간다.
  final List<String> options;

  /// 지금 선택된 값.
  final String active;

  final ValueChanged<String> onChange;

  /// 선택된 칩 배경색.
  final Color accent;

  /// 선택된 칩 위에 얹는 글자·아이콘 색 ([accent] 위에서 읽히는 어두운 색).
  final Color accentInk;

  /// 칩에 붙일 아이콘. null을 돌려주면 그 칩만 아이콘 없이 그린다
  /// (예: '전체'는 종류가 아니라 해제라 아이콘을 달지 않는다).
  final IconData? Function(String option)? iconOf;

  /// 표시 라벨 변환. 필터 값은 그대로 두고 글자만 바꿀 때 쓴다
  /// (예: 값 '전체' → 표시 '내 주변'). null이면 값을 그대로 쓴다.
  final String Function(String option)? labelOf;

  /// 칩 좌우 안쪽 여백(dp, `.w` 적용 전).
  final double chipHPadding;

  const VybeChipFilterBar({
    super.key,
    required this.options,
    required this.active,
    required this.onChange,
    required this.accent,
    required this.accentInk,
    this.iconOf,
    this.labelOf,
    this.chipHPadding = 14,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 50.h,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 8.h),
        itemCount: options.length,
        separatorBuilder: (_, __) => SizedBox(width: 8.w),
        itemBuilder: (_, i) {
          final option = options[i];
          return _FilterChip(
            label: labelOf?.call(option) ?? option,
            selected: option == active,
            icon: iconOf?.call(option),
            accent: accent,
            accentInk: accentInk,
            hPadding: chipHPadding,
            onTap: () => onChange(option),
          );
        },
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final IconData? icon;
  final Color accent;
  final Color accentInk;
  final double hPadding;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.selected,
    required this.icon,
    required this.accent,
    required this.accentInk,
    required this.hPadding,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final iconData = icon;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: hPadding.w),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: selected ? accent : VybeColors.gray900,
          borderRadius: BorderRadius.circular(999.r),
          border: selected ? null : Border.all(color: VybeColors.gray800),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (iconData != null) ...[
              Icon(iconData, size: 13.r, color: selected ? accentInk : accent),
              SizedBox(width: 4.w),
            ],
            Text(
              label,
              style: VybeTypography.button2.copyWith(
                fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                color: selected ? accentInk : VybeColors.gray300,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
