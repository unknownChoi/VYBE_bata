import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:vybe/design_system/colors.dart';
import 'package:vybe/design_system/typography.dart';

class FilterChipBar extends StatefulWidget {
  final bool hasBackground;

  const FilterChipBar({super.key, this.hasBackground = false});

  @override
  State<FilterChipBar> createState() => _FilterChipBarState();
}

class _FilterChipBarState extends State<FilterChipBar> {
  final String _sortOrder = '추천순';
  bool _filterOpen = false;
  bool _onlyOpen = false;
  bool _serviceDrink = false;
  bool _freeEntry = false;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: EdgeInsets.fromLTRB(24.w, 12.h, 24.w, 4.h),
      child: Row(
        children: [
          _buildSortChip(),
          SizedBox(width: 8.w),
          _buildFilterChip(),
          SizedBox(width: 8.w),
          _buildToggleChip(
            label: '영업중',
            isActive: _onlyOpen,
            onTap: () => setState(() => _onlyOpen = !_onlyOpen),
          ),
          SizedBox(width: 8.w),
          _buildToggleChip(
            label: '서비스 음료',
            isActive: _serviceDrink,
            onTap: () => setState(() => _serviceDrink = !_serviceDrink),
          ),
          SizedBox(width: 8.w),
          _buildToggleChip(
            label: '입장료 무료',
            isActive: _freeEntry,
            onTap: () => setState(() => _freeEntry = !_freeEntry),
          ),
        ],
      ),
    );
  }

  Widget _buildSortChip() {
    return GestureDetector(
      onTap: () {
        // TODO: 정렬 옵션 바텀시트
      },
      child: _chipContainer(
        isActive: false,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              _sortOrder,
              style:
                  VybeTypography.caption.copyWith(color: VybeColors.gray200),
            ),
            SizedBox(width: 4.w),
            SvgPicture.asset(
              'assets/icons/common/add_content_arrow_down.svg',
              width: 12.r,
              height: 12.r,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip() {
    return GestureDetector(
      onTap: () => setState(() => _filterOpen = !_filterOpen),
      child: _chipContainer(
        isActive: _filterOpen,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '필터',
              style:
                  VybeTypography.caption.copyWith(color: VybeColors.gray200),
            ),
            SizedBox(width: 4.w),
            SvgPicture.asset(
              'assets/icons/common/filter.svg',
              width: 12.r,
              height: 12.r,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildToggleChip({
    required String label,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: _chipContainer(
        isActive: isActive,
        child: Text(
          label,
          style: VybeTypography.caption.copyWith(color: VybeColors.gray200),
        ),
      ),
    );
  }

  Widget _chipContainer({required bool isActive, required Widget child}) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: isActive
            ? VybeColors.mainPurple700
            : widget.hasBackground
                ? VybeColors.gray900
                : Colors.transparent,
        border:
            isActive ? null : Border.all(color: VybeColors.gray700, width: 1),
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: child,
    );
  }
}
