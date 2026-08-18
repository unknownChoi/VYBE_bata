import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vybe/design_system/colors.dart';
import 'package:vybe/presentation/clubs/widgets/club_glass.dart';
import 'package:vybe/presentation/saved/saved_common.dart';

// 찜 탭 상단 — 헤더 · 정렬/뷰 전환 툴바 · 정렬 메뉴.

class SavedHeader extends StatelessWidget {
  final int count;
  final int openCount;

  const SavedHeader({super.key, required this.count, required this.openCount});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(16.w, 10.h, 16.w, 18.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Flexible(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text(
                  '$count',
                  style: TextStyle(
                    fontFamily: 'Pretendard',
                    fontSize: 32.sp,
                    height: 34 / 32,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 32 * -0.025,
                    color: Colors.white,
                  ),
                ),
                SizedBox(width: 8.w),
                Text(
                  '곳을 찜했어요',
                  style: TextStyle(
                    fontFamily: 'Pretendard',
                    fontSize: 20.sp,
                    height: 22 / 20,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 20 * -0.025,
                    color: ClubGlass.t3,
                  ),
                ),
              ],
            ),
          ),
          if (count > 0)
            Padding(
              padding: EdgeInsets.only(left: 12.w, bottom: 3.h),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 7.r,
                    height: 7.r,
                    decoration: BoxDecoration(
                      color: VybeColors.mainLime500,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: VybeColors.mainLime500,
                          blurRadius: 8.r,
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: 7.w),
                  Text.rich(
                    TextSpan(
                      children: [
                        const TextSpan(text: '지금 '),
                        TextSpan(
                          text: '$openCount곳',
                          style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                        const TextSpan(text: ' 영업중'),
                      ],
                    ),
                    style: TextStyle(
                      fontFamily: 'Pretendard',
                      fontSize: 14.sp,
                      height: 16 / 14,
                      letterSpacing: 14 * -0.025,
                      color: ClubGlass.t2,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

// ============ 정렬 + 뷰 전환 툴바 ============

class SavedToolbar extends StatefulWidget {
  final bool isGrid;
  final SavedSortOption sort;
  final ValueChanged<bool> onView;
  final ValueChanged<SavedSortOption> onSort;

  const SavedToolbar({super.key, 
    required this.isGrid,
    required this.sort,
    required this.onView,
    required this.onSort,
  });

  @override
  State<SavedToolbar> createState() => _SavedToolbarState();
}

class _SavedToolbarState extends State<SavedToolbar> {
  // 정렬 버튼 아래에 붙는 드롭다운 오버레이.
  final LayerLink _link = LayerLink();
  OverlayEntry? _overlay;
  bool _open = false;

  @override
  void dispose() {
    _remove();
    super.dispose();
  }

  void _toggle() => _overlay == null ? _openMenu() : _close();

  void _openMenu() {
    _overlay = OverlayEntry(
      builder: (_) => Stack(
        children: [
          // 바깥 탭 → 닫기.
          Positioned.fill(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: _close,
            ),
          ),
          CompositedTransformFollower(
            link: _link,
            showWhenUnlinked: false,
            targetAnchor: Alignment.bottomLeft,
            followerAnchor: Alignment.topLeft,
            offset: Offset(0, 8.h),
            child: _SavedSortMenu(current: widget.sort, onSelect: _select),
          ),
        ],
      ),
    );
    Overlay.of(context).insert(_overlay!);
    setState(() => _open = true);
  }

  void _close() {
    _remove();
    if (mounted) setState(() => _open = false);
  }

  void _remove() {
    _overlay?.remove();
    _overlay = null;
  }

  void _select(SavedSortOption opt) {
    _remove();
    if (!mounted) return;
    setState(() => _open = false);
    widget.onSort(opt);
  }

  @override
  Widget build(BuildContext context) {
    // 배경 없음 — GlassBar(블러 + fill + hairline)를 쓰면 이 줄만 오로라 위에
    // 밝은 띠로 떠서 위(헤더)·아래(목록)와 색이 어긋난다. 화면 배경을 그대로
    // 통과시키려면 칠하지도, 블러하지도 않아야 한다.
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 11.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          CompositedTransformTarget(
            link: _link,
            child: GestureDetector(
              onTap: _toggle,
              behavior: HitTestBehavior.opaque,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 13.w, vertical: 7.h),
                decoration: BoxDecoration(
                  color: ClubGlass.tileFill,
                  borderRadius: BorderRadius.circular(999.r),
                  border: Border.all(color: ClubGlass.tileBorder),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      kSavedSortLabels[widget.sort]!,
                      style: TextStyle(
                        fontFamily: 'Pretendard',
                        fontSize: 14.sp,
                        height: 16 / 14,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 14 * -0.025,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(width: 4.w),
                    AnimatedRotation(
                      turns: _open ? 0.5 : 0,
                      duration: const Duration(milliseconds: 200),
                      child: Icon(
                        Icons.keyboard_arrow_down_rounded,
                        size: 14.r,
                        color: ClubGlass.t3,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Container(
            padding: EdgeInsets.all(3.r),
            decoration: BoxDecoration(
              color: const Color(0x0FFFFFFF),
              borderRadius: BorderRadius.circular(999.r),
              border: Border.all(color: const Color(0x1AFFFFFF)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _viewButton(
                  icon: Icons.format_list_bulleted_rounded,
                  active: !widget.isGrid,
                  onTap: () => widget.onView(false),
                ),
                SizedBox(width: 3.w),
                _viewButton(
                  icon: Icons.grid_view_rounded,
                  active: widget.isGrid,
                  onTap: () => widget.onView(true),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _viewButton({
    required IconData icon,
    required bool active,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        width: 34.w,
        height: 28.h,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: active ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(999.r),
        ),
        child: Icon(
          icon,
          size: 14.r,
          color: active ? ClubGlass.ink : ClubGlass.t3,
        ),
      ),
    );
  }
}

/// 정렬 드롭다운 패널 — 선택 항목은 보라 배경 + 라임 체크.
class _SavedSortMenu extends StatelessWidget {
  final SavedSortOption current;
  final ValueChanged<SavedSortOption> onSelect;

  const _SavedSortMenu({required this.current, required this.onSelect});

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
            for (final o in SavedSortOption.values)
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
                        kSavedSortLabels[o]!,
                        style: TextStyle(
                          fontFamily: 'Pretendard',
                          fontSize: 14.sp,
                          height: 16 / 14,
                          letterSpacing: 14 * -0.025,
                          fontWeight:
                              o == current ? FontWeight.w700 : FontWeight.w500,
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

// ============ 리스트 카드 ============
