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
  static const List<String> _sortOptions = [
    '추천순',
    '거리순',
    '평점순',
    '리뷰 많은순',
  ];

  String _sortOrder = '추천순';
  bool _sortOpen = false;
  bool _filterOpen = false;
  bool _onlyOpen = false;
  bool _serviceDrink = false;
  bool _freeEntry = false;

  // 정렬 칩 아래에 붙는 드롭다운 오버레이.
  final LayerLink _sortLink = LayerLink();
  OverlayEntry? _sortOverlay;

  @override
  void dispose() {
    _removeSortOverlay();
    super.dispose();
  }

  void _toggleSort() {
    if (_sortOverlay != null) {
      _closeSort();
    } else {
      _openSort();
    }
  }

  void _openSort() {
    _sortOverlay = OverlayEntry(
      builder: (_) => Stack(
        children: [
          // 바깥 탭 → 닫기.
          Positioned.fill(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: _closeSort,
            ),
          ),
          CompositedTransformFollower(
            link: _sortLink,
            showWhenUnlinked: false,
            targetAnchor: Alignment.bottomLeft,
            followerAnchor: Alignment.topLeft,
            offset: Offset(0, 8.h),
            child: _SortDropdown(
              current: _sortOrder,
              options: _sortOptions,
              onSelect: _selectSort,
            ),
          ),
        ],
      ),
    );
    Overlay.of(context).insert(_sortOverlay!);
    setState(() => _sortOpen = true);
  }

  void _closeSort() {
    _removeSortOverlay();
    if (mounted) setState(() => _sortOpen = false);
  }

  void _removeSortOverlay() {
    _sortOverlay?.remove();
    _sortOverlay = null;
  }

  void _selectSort(String opt) {
    _removeSortOverlay();
    if (!mounted) return;
    setState(() {
      _sortOpen = false;
      _sortOrder = opt;
    });
    // TODO: 선택된 정렬값으로 목록 재정렬 (viewmodel 연동)
  }

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
    // 기본값(추천순)이 아니거나 열린 상태면 보라로 강조.
    final isActive = _sortOpen || _sortOrder != _sortOptions.first;
    return CompositedTransformTarget(
      link: _sortLink,
      child: GestureDetector(
        onTap: _toggleSort,
        child: _chipContainer(
          isActive: isActive,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                _sortOrder,
                style: VybeTypography.caption.copyWith(
                  color: isActive ? Colors.white : VybeColors.gray200,
                  height: 14 / 12,
                ),
              ),
              SizedBox(width: 4.w),
              AnimatedRotation(
                turns: _sortOpen ? 0.5 : 0,
                duration: const Duration(milliseconds: 200),
                child: SvgPicture.asset(
                  'assets/icons/common/add_content_arrow_down.svg',
                  width: 12.r,
                  height: 12.r,
                ),
              ),
            ],
          ),
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
                  VybeTypography.caption.copyWith(color: VybeColors.gray200, height: 14 / 12),
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
          style: VybeTypography.caption.copyWith(color: VybeColors.gray200, height: 14 / 12),
        ),
      ),
    );
  }

  Widget _chipContainer({required bool isActive, required Widget child}) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 7.h),
      decoration: BoxDecoration(
        color: isActive
            ? VybeColors.mainPurple700
            : widget.hasBackground
                ? VybeColors.gray900
                : Colors.transparent,
        border: Border.all(
            color: isActive ? VybeColors.mainPurple700 : VybeColors.gray700,
            width: 1,
          ),
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: child,
    );
  }
}

// 정렬 칩 아래 드롭다운. 선택 항목 = 라임 배경 pill + 라임 텍스트 + 체크.
class _SortDropdown extends StatelessWidget {
  final String current;
  final List<String> options;
  final ValueChanged<String> onSelect;

  const _SortDropdown({
    required this.current,
    required this.options,
    required this.onSelect,
  });

  static const _lime = Color(0xFFB5FF60);

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Container(
        width: 180.w,
        padding: EdgeInsets.all(8.r),
        decoration: BoxDecoration(
          color: const Color(0xFF1C1C20),
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: VybeColors.gray800, width: 1),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.4),
              blurRadius: 24.r,
              offset: Offset(0, 8.h),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: options.map((opt) {
            final selected = opt == current;
            return InkWell(
              borderRadius: BorderRadius.circular(8.r),
              onTap: () => onSelect(opt),
              child: Container(
                padding:
                    EdgeInsets.symmetric(horizontal: 12.w, vertical: 11.h),
                decoration: BoxDecoration(
                  color: selected
                      ? _lime.withValues(alpha: 0.14)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        opt,
                        style: VybeTypography.body4.copyWith(
                          color: selected ? _lime : VybeColors.gray200,
                          fontWeight:
                              selected ? FontWeight.w600 : FontWeight.w400,
                        ),
                      ),
                    ),
                    if (selected)
                      Icon(Icons.check_rounded, size: 16.r, color: _lime),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}
