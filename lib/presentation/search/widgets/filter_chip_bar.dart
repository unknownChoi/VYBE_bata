import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:vybe/design_system/colors.dart';
import 'package:vybe/design_system/typography.dart';
import 'package:vybe/presentation/clubs/widgets/club_glass.dart';
import 'package:vybe/presentation/nearby/widgets/nearby_glass.dart';
import 'package:vybe/presentation/search/viewmodels/club_filter_viewmodel.dart';

/// 클럽 필터/정렬 칩 줄. 검색 결과 화면과 주변 페이지 바텀시트가 공유한다.
///
/// 칩 외형은 주변 리퀴드 글래스 토큰([NearbyGlass]) 기준 —
/// 테두리 없음, 비활성은 흰색 6% 채움, 활성은 보라 그라데이션.
class FilterChipBar extends ConsumerStatefulWidget {
  final bool hasBackground;
  // 찜 필터 칩 노출 여부 (주변 페이지 전용 — 로그인 사용자 찜 목록 의존).
  final bool showFavorite;

  /// 칩 줄 바깥 여백. 화면마다 좌우 거터가 달라 주입받는다.
  final EdgeInsetsGeometry? padding;

  const FilterChipBar({
    super.key,
    this.hasBackground = false,
    this.showFavorite = false,
    this.padding,
  });

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
      required ClubFilter filter,
      IconData? icon,
      String? svgAsset,
    }) {
      return _buildToggleChip(
        label: label,
        icon: icon,
        svgAsset: svgAsset,
        isActive: active.contains(filter),
        onTap: () => notifier.toggle(filter),
      );
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: widget.padding ?? EdgeInsets.fromLTRB(24.w, 12.h, 24.w, 4.h),
      child: Row(
        children: [
          _buildSortChip(),
          // 정렬 칩과 필터 칩 구분선 (칩에 테두리가 없어 이 선이 둘을 가른다).
          Container(
            width: 1,
            height: 18.h,
            margin: EdgeInsets.symmetric(horizontal: 9.w),
            color: const Color(0x1FFFFFFF),
          ),
          // 필터 칩 맨 앞 — 클럽 카드 리본과 같은 VYBE 추천 아이콘.
          toggle(
            label: 'VYBE 추천',
            svgAsset: 'assets/icons/common/club_card/vybe_recommend.svg',
            filter: ClubFilter.vybeRecommended,
          ),
          SizedBox(width: 8.w),
          if (widget.showFavorite) ...[
            toggle(
              label: '찜',
              icon: Icons.favorite_rounded,
              filter: ClubFilter.favorite,
            ),
            SizedBox(width: 8.w),
          ],
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
                style: NearbyGlass.chipText(selected: true),
              ),
              SizedBox(width: 5.w),
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

  // 글래스 pill + 아이콘.
  // [svgAsset]을 주면 Material 아이콘 대신 SVG를 쓴다 (VYBE 추천 등 전용 아이콘).
  Widget _buildToggleChip({
    required String label,
    required bool isActive,
    required VoidCallback onTap,
    IconData? icon,
    String? svgAsset,
  }) {
    final fg = isActive ? Colors.white : ClubGlass.t2;
    return GestureDetector(
      onTap: onTap,
      child: _chipContainer(
        isActive: isActive,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (svgAsset != null)
              SvgPicture.asset(
                svgAsset,
                width: 13.r,
                height: 13.r,
                colorFilter: ColorFilter.mode(fg, BlendMode.srcIn),
              )
            else if (icon != null)
              Icon(icon, size: 13.r, color: fg),
            SizedBox(width: 5.w),
            Text(label, style: NearbyGlass.chipText(selected: isActive)),
          ],
        ),
      ),
    );
  }

  // 테두리 없는 글래스 pill — 비활성은 흰색 6% 채움, 활성은 보라 그라데이션.
  Widget _chipContainer({required bool isActive, required Widget child}) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 160),
      height: 34.h,
      alignment: Alignment.center,
      padding: EdgeInsets.symmetric(horizontal: 13.w),
      decoration: BoxDecoration(
        color: isActive ? null : NearbyGlass.chipFill,
        gradient: isActive ? NearbyGlass.activeChip : null,
        borderRadius: BorderRadius.circular(999.r),
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

  static const _lime = VybeColors.mainLime500;

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
