import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vybe/design_system/colors.dart';
import 'package:vybe/presentation/clubs/widgets/club_glass.dart';
import 'package:vybe/presentation/nearby/widgets/nearby_glass.dart';
import 'package:vybe/presentation/search/viewmodels/club_filter_viewmodel.dart';

/// 주변 리스트 시트의 정렬 + 필터 칩 줄.
///
/// 디자인 nearby_glass.jsx `NGListSheet`의 칩 줄. 상태는 검색·찜과 공유하는
/// [clubFilterViewModelProvider] · [clubSortViewModelProvider]를 그대로 쓴다.
///
/// 디자인 칩 목록(영업중·입장료 무료·서비스 음료·핫플레이스·찜한 클럽) 대신
/// 앱에 이미 있는 필터 세트를 쓴다 — '핫플레이스'는 Firestore 기준이 없고,
/// 장르·금연 필터는 검색 화면과 동작을 맞춰야 하기 때문.
class NearbyFilterChipBar extends ConsumerStatefulWidget {
  const NearbyFilterChipBar({super.key});

  @override
  ConsumerState<NearbyFilterChipBar> createState() =>
      _NearbyFilterChipBarState();
}

class _NearbyFilterChipBarState extends ConsumerState<NearbyFilterChipBar> {
  final LayerLink _sortLink = LayerLink();
  OverlayEntry? _sortOverlay;
  bool _sortOpen = false;

  // 디자인 NG_FILTERS 순서를 따르되 앱 필터로 매핑.
  static const List<(ClubFilter, String)> _filters = [
    (ClubFilter.vybeRecommended, 'VYBE 추천'),
    (ClubFilter.open, '영업중'),
    (ClubFilter.freeEntry, '입장료 무료'),
    (ClubFilter.serviceDrink, '서비스 음료'),
    (ClubFilter.favorite, '찜한 클럽'),
    (ClubFilter.hiphop, '힙합'),
    (ClubFilter.edm, 'EDM'),
    (ClubFilter.hybrid, '하이브리드'),
    (ClubFilter.noSmoking, '금연'),
  ];

  @override
  void dispose() {
    _removeOverlay();
    super.dispose();
  }

  void _removeOverlay() {
    _sortOverlay?.remove();
    _sortOverlay = null;
  }

  void _toggleSort() => _sortOverlay != null ? _closeSort() : _openSort();

  void _openSort() {
    _sortOverlay = OverlayEntry(
      builder: (_) => Stack(
        children: [
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
            offset: Offset(0, 6.h),
            child: _SortMenu(
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
    _removeOverlay();
    if (mounted) setState(() => _sortOpen = false);
  }

  void _selectSort(ClubSort opt) {
    _removeOverlay();
    if (!mounted) return;
    ref.read(clubSortViewModelProvider.notifier).select(opt);
    setState(() => _sortOpen = false);
  }

  @override
  Widget build(BuildContext context) {
    final active = ref.watch(clubFilterViewModelProvider);
    final notifier = ref.read(clubFilterViewModelProvider.notifier);

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Row(
        children: [
          _buildSortChip(),
          for (final (filter, label) in _filters) ...[
            SizedBox(width: 7.w),
            _Chip(
              label: label,
              selected: active.contains(filter),
              onTap: () => notifier.toggle(filter),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSortChip() {
    final sort = ref.watch(clubSortViewModelProvider);
    final child = Padding(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            kClubSortLabels[sort]!,
            style: NearbyGlass.chipText(selected: true),
          ),
          SizedBox(width: 4.w),
          AnimatedRotation(
            turns: _sortOpen ? 0.5 : 0,
            duration: const Duration(milliseconds: 200),
            child: Icon(
              Icons.keyboard_arrow_down_rounded,
              size: 13.r,
              color: const Color(0xCCFFFFFF),
            ),
          ),
        ],
      ),
    );

    return CompositedTransformTarget(
      link: _sortLink,
      child: GestureDetector(
        onTap: _toggleSort,
        behavior: HitTestBehavior.opaque,
        child: Container(
          decoration: BoxDecoration(
            color: const Color(0x1AFFFFFF),
            borderRadius: BorderRadius.circular(999.r),
            border: Border.all(color: NearbyGlass.floatBorder),
          ),
          child: child,
        ),
      ),
    );
  }
}

/// 필터 칩 1개. 선택 시 보라 그라데이션 + 라임 테두리.
class _Chip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _Chip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final child = Padding(
      padding: EdgeInsets.symmetric(horizontal: 13.w, vertical: 8.h),
      child: Text(label, style: NearbyGlass.chipText(selected: selected)),
    );

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        decoration: BoxDecoration(
          color: selected ? null : NearbyGlass.chipFill,
          gradient: selected ? NearbyGlass.activeChip : null,
          borderRadius: BorderRadius.circular(999.r),
          border: Border.all(
            color: selected ? NearbyGlass.activeBorder : ClubGlass.tileBorder,
          ),
        ),
        child: child,
      ),
    );
  }
}

/// 정렬 드롭다운 — 선택 항목은 보라 배경 + 라임 체크 (찜 탭 _SortMenu와 동일 톤).
class _SortMenu extends StatelessWidget {
  final ClubSort current;
  final ValueChanged<ClubSort> onSelect;

  const _SortMenu({required this.current, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Container(
        width: 168.w,
        padding: EdgeInsets.all(5.r),
        decoration: BoxDecoration(
          color: const Color(0xF01A181F),
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(color: ClubGlass.cardBorder),
          boxShadow: [
            BoxShadow(
              color: const Color(0x5C000000),
              blurRadius: 30.r,
              offset: Offset(0, 10.h),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (final o in ClubSort.values)
              GestureDetector(
                onTap: () => onSelect(o),
                behavior: HitTestBehavior.opaque,
                child: Container(
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(
                    horizontal: 12.w,
                    vertical: 11.h,
                  ),
                  decoration: BoxDecoration(
                    color: o == current
                        ? VybeColors.mainPurple500.withValues(alpha: 0.22)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(11.r),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        kClubSortLabels[o]!,
                        style: TextStyle(
                          fontFamily: 'Pretendard',
                          fontSize: 14.sp,
                          height: 16 / 14,
                          letterSpacing: 14 * -0.025,
                          fontWeight: o == current
                              ? FontWeight.w700
                              : FontWeight.w500,
                          color: o == current ? Colors.white : ClubGlass.t3,
                        ),
                      ),
                      if (o == current)
                        Icon(
                          Icons.check_rounded,
                          size: 14.r,
                          color: VybeColors.mainLime500,
                        ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
