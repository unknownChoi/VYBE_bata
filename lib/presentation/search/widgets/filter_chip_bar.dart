import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:vybe/design_system/colors.dart';
import 'package:vybe/design_system/typography.dart';
import 'package:vybe/presentation/search/viewmodels/club_filter_viewmodel.dart';

class FilterChipBar extends ConsumerStatefulWidget {
  final bool hasBackground;

  const FilterChipBar({super.key, this.hasBackground = false});

  @override
  ConsumerState<FilterChipBar> createState() => _FilterChipBarState();
}

class _FilterChipBarState extends ConsumerState<FilterChipBar> {
  bool _sortOpen = false;

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
              current: ref.read(clubSortViewModelProvider),
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

  void _selectSort(ClubSort opt) {
    _removeSortOverlay();
    if (!mounted) return;
    ref.read(clubSortViewModelProvider.notifier).select(opt);
    setState(() => _sortOpen = false);
  }

  @override
  Widget build(BuildContext context) {
    final active = ref.watch(clubFilterViewModelProvider);
    final notifier = ref.read(clubFilterViewModelProvider.notifier);

    Widget toggle({
      required String label,
      required IconData icon,
      required ClubFilter filter,
    }) {
      return _buildToggleChip(
        label: label,
        icon: icon,
        isActive: active.contains(filter),
        onTap: () => notifier.toggle(filter),
      );
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: EdgeInsets.fromLTRB(24.w, 12.h, 24.w, 4.h),
      child: Row(
        children: [
          _buildSortChip(),
          SizedBox(width: 8.w),
          toggle(
            label: '영업중',
            icon: Icons.access_time_rounded,
            filter: ClubFilter.open,
          ),
          SizedBox(width: 8.w),
          toggle(
            label: '서비스 음료',
            icon: Icons.local_bar_rounded,
            filter: ClubFilter.serviceDrink,
          ),
          SizedBox(width: 8.w),
          toggle(
            label: '입장료 무료',
            icon: Icons.money_off_rounded,
            filter: ClubFilter.freeEntry,
          ),
          SizedBox(width: 8.w),
          toggle(
            label: '힙합',
            icon: Icons.headphones_rounded,
            filter: ClubFilter.hiphop,
          ),
          SizedBox(width: 8.w),
          toggle(
            label: 'EDM',
            icon: Icons.graphic_eq_rounded,
            filter: ClubFilter.edm,
          ),
          SizedBox(width: 8.w),
          toggle(
            label: '하이브리드',
            icon: Icons.shuffle_rounded,
            filter: ClubFilter.hybrid,
          ),
          SizedBox(width: 8.w),
          toggle(
            label: '금연',
            icon: Icons.smoke_free_rounded,
            filter: ClubFilter.noSmoking,
          ),
        ],
      ),
    );
  }

  Widget _buildSortChip() {
    final sort = ref.watch(clubSortViewModelProvider);
    // 기본값(추천순)이 아니거나 열린 상태면 보라로 강조.
    final isActive = _sortOpen || sort != ClubSort.recommended;
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
                kClubSortLabels[sort]!,
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

  Widget _buildToggleChip({
    required String label,
    required bool isActive,
    required VoidCallback onTap,
    required IconData icon,
  }) {
    final color = isActive ? Colors.white : VybeColors.gray200;
    return GestureDetector(
      onTap: onTap,
      child: _chipContainer(
        isActive: isActive,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14.r, color: color),
            SizedBox(width: 4.w),
            Text(
              label,
              style: VybeTypography.caption.copyWith(color: color, height: 14 / 12),
            ),
          ],
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
  final ClubSort current;
  final ValueChanged<ClubSort> onSelect;

  const _SortDropdown({
    required this.current,
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
          children: ClubSort.values.map((opt) {
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
                        kClubSortLabels[opt]!,
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
