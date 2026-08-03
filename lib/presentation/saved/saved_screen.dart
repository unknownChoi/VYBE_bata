import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vybe/design_system/colors.dart';
import 'package:vybe/presentation/clubs/club_detail_screen.dart';
import 'package:vybe/presentation/clubs/widgets/club_glass.dart';
import 'package:vybe/presentation/common/widgets/vybe_recommend_badge.dart';
import 'package:vybe/presentation/common/widgets/vybe_skeleton.dart';
import 'package:vybe/presentation/main_scaffold/nav_bar_visibility_provider.dart';
import 'package:vybe/presentation/saved/viewmodels/saved_viewmodel.dart';

// ============================================================
// 찜한 클럽 화면 (saved_glass.html · Liquid Glass 리뉴얼)
//
// 배경·카드·바는 클럽 상세와 같은 글래스 요소(club_glass.dart) 재사용.
// favorites Firestore 연동. 정렬, 리스트↔그리드 뷰 지원.
// ============================================================

enum _SortOption { recent, rating, name, open }

const Map<_SortOption, String> _kSortLabels = {
  _SortOption.recent: '최근 찜한 순',
  _SortOption.rating: '평점 높은 순',
  _SortOption.name: '가나다 순',
  _SortOption.open: '영업중 먼저',
};

/// 그라데이션 fallback 색 — 썸네일 없을 때/로딩 중 placeholder.
const List<List<Color>> _kGradients = [
  [VybeColors.mainPurple500, Color(0xFFFF4D8D)],
  [Color(0xFFFF006E), Color(0xFF8338EC)],
  [Color(0xFF06FFA5), Color(0xFF3A86FF)],
  [Color(0xFFFB5607), Color(0xFFFFBE0B)],
  [Color(0xFF2A2D34), Color(0xFF6C757D)],
  [VybeColors.accentBlue500, VybeColors.mainPurple500],
];

List<Color> _gradientFor(String key) =>
    _kGradients[key.hashCode.abs() % _kGradients.length];

/// 홈 탭 인덱스 (빈 화면 CTA에서 사용).
const int _kHomeTabIndex = 0;

/// 탭 내부 Navigator로 클럽 상세 push.
void _openClubDetail(BuildContext context, String clubId) {
  Navigator.of(context).push(
    MaterialPageRoute(builder: (_) => ClubDetailScreen(clubId: clubId)),
  );
}

TextStyle _caption({
  Color color = ClubGlass.t3,
  double size = 12,
  double lineHeight = 14,
  FontWeight weight = FontWeight.w400,
}) => ClubGlass.caption(
  color: color,
  size: size,
  lineHeight: lineHeight,
  weight: weight,
);

// ============ 화면 ============

class SavedScreen extends ConsumerStatefulWidget {
  const SavedScreen({super.key});

  @override
  ConsumerState<SavedScreen> createState() => _SavedScreenState();
}

class _SavedScreenState extends ConsumerState<SavedScreen> {
  bool _isGrid = false;
  _SortOption _sort = _SortOption.recent;

  List<SavedEntry> _applySort(List<SavedEntry> all) {
    final list = List.of(all);
    switch (_sort) {
      case _SortOption.rating:
        list.sort((a, b) => b.club.rating.compareTo(a.club.rating));
        break;
      case _SortOption.name:
        list.sort((a, b) => a.club.name.compareTo(b.club.name));
        break;
      case _SortOption.open:
        list.sort((a, b) {
          final byOpen = (b.isOpen ? 1 : 0) - (a.isOpen ? 1 : 0);
          return byOpen != 0 ? byOpen : b.club.rating.compareTo(a.club.rating);
        });
        break;
      case _SortOption.recent:
        list.sort((a, b) => b.savedAt.compareTo(a.savedAt));
        break;
    }
    return list;
  }

  @override
  Widget build(BuildContext context) {
    final savedAsync = ref.watch(savedClubsProvider);
    final media = MediaQuery.of(context);
    // 하단 floating nav(64.h + safe inset + 12.h) 아래로 콘텐츠가 숨지 않게.
    final bottomPad = media.padding.bottom + 96.h;

    return Scaffold(
      backgroundColor: ClubGlass.ink,
      body: Stack(
        children: [
          const Positioned.fill(child: IgnorePointer(child: ClubAurora())),
          // 오로라는 상태바 뒤까지 깔되, 콘텐츠는 인셋 아래에서 시작한다
          // (sticky 툴바가 노치·시계 뒤로 들어가지 않도록).
          Positioned.fill(
            child: SafeArea(
              bottom: false,
              child: _buildContent(savedAsync, bottomPad, media.size),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(
    AsyncValue<List<SavedEntry>> savedAsync,
    double bottomPad,
    Size screen,
  ) {
    return savedAsync.when(
      loading: () => ListView(
        padding: EdgeInsets.zero,
        physics: const NeverScrollableScrollPhysics(),
        children: const [SavedSkeleton()],
      ),
      error: (e, _) => Center(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 32.w),
          child: Text(
            '찜 목록을 불러오지 못했어요',
            style: ClubGlass.body(color: ClubGlass.t4),
          ),
        ),
      ),
      data: (all) {
        final isEmpty = all.isEmpty;
        final sorted = _applySort(all);
        // 그리드 셀 높이 = 정사각 이미지 + 이름/메타 영역(46).
        final cellWidth = (screen.width - 32.w - 14.w) / 2;

        return CustomScrollView(
          physics: const ClampingScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(
              child: _Header(
                count: all.length,
                openCount: all.where((e) => e.isOpen).length,
              ),
            ),
            // 찜이 없으면 정렬·뷰 전환이 무의미해 툴바를 숨긴다 (디자인과 다름).
            if (!isEmpty)
              SliverPersistentHeader(
                pinned: true,
                delegate: _ToolbarDelegate(
                  isGrid: _isGrid,
                  sort: _sort,
                  onView: (g) => setState(() => _isGrid = g),
                  onSort: (s) => setState(() => _sort = s),
                ),
              ),
            if (isEmpty)
              SliverToBoxAdapter(
                child: _EmptyState(
                  onExplore: () => ref
                      .read(tabSwitchRequestProvider.notifier)
                      .request(_kHomeTabIndex),
                ),
              )
            else if (_isGrid)
              SliverPadding(
                padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 28.h),
                sliver: SliverGrid(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 14.h,
                    crossAxisSpacing: 14.w,
                    mainAxisExtent: cellWidth + 46.h,
                  ),
                  delegate: SliverChildBuilderDelegate(
                    (_, i) => _GridCard(
                      entry: sorted[i],
                      onUnsave: _unsave,
                    ),
                    childCount: sorted.length,
                  ),
                ),
              )
            else
              SliverPadding(
                padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 28.h),
                sliver: SliverList.separated(
                  itemCount: sorted.length,
                  separatorBuilder: (_, __) => SizedBox(height: 12.h),
                  itemBuilder: (_, i) => _ListCard(
                    entry: sorted[i],
                    onUnsave: _unsave,
                  ),
                ),
              ),
            SliverToBoxAdapter(child: SizedBox(height: bottomPad)),
          ],
        );
      },
    );
  }

  void _unsave(String clubId) =>
      ref.read(savedActionsProvider.notifier).unsave(clubId);
}

// ============ 헤더 (찜 개수 + 영업중 카운트) ============

class _Header extends StatelessWidget {
  final int count;
  final int openCount;

  const _Header({required this.count, required this.openCount});

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

// ============ 정렬 + 뷰 전환 툴바 (sticky) ============

class _ToolbarDelegate extends SliverPersistentHeaderDelegate {
  final bool isGrid;
  final _SortOption sort;
  final ValueChanged<bool> onView;
  final ValueChanged<_SortOption> onSort;

  _ToolbarDelegate({
    required this.isGrid,
    required this.sort,
    required this.onView,
    required this.onSort,
  });

  // 11(pad) + 34(컨트롤) + 11(pad) + 상하 hairline.
  double get _extent => 58.h;

  @override
  double get maxExtent => _extent;

  @override
  double get minExtent => _extent;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlaps) {
    return _Toolbar(
      isGrid: isGrid,
      sort: sort,
      onView: onView,
      onSort: onSort,
    );
  }

  @override
  bool shouldRebuild(covariant _ToolbarDelegate old) =>
      old.isGrid != isGrid || old.sort != sort;
}

class _Toolbar extends StatefulWidget {
  final bool isGrid;
  final _SortOption sort;
  final ValueChanged<bool> onView;
  final ValueChanged<_SortOption> onSort;

  const _Toolbar({
    required this.isGrid,
    required this.sort,
    required this.onView,
    required this.onSort,
  });

  @override
  State<_Toolbar> createState() => _ToolbarState();
}

class _ToolbarState extends State<_Toolbar> {
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
            child: _SortMenu(current: widget.sort, onSelect: _select),
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

  void _select(_SortOption opt) {
    _remove();
    if (!mounted) return;
    setState(() => _open = false);
    widget.onSort(opt);
  }

  @override
  Widget build(BuildContext context) {
    return GlassBar(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 11.h),
      topBorder: true,
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
                      _kSortLabels[widget.sort]!,
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
class _SortMenu extends StatelessWidget {
  final _SortOption current;
  final ValueChanged<_SortOption> onSelect;

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
            for (final o in _SortOption.values)
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
                        _kSortLabels[o]!,
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

class _ListCard extends StatelessWidget {
  final SavedEntry entry;
  final ValueChanged<String> onUnsave;

  const _ListCard({required this.entry, required this.onUnsave});

  @override
  Widget build(BuildContext context) {
    final club = entry.club;

    return GestureDetector(
      onTap: () => _openClubDetail(context, club.clubId),
      behavior: HitTestBehavior.opaque,
      child: GlassCard(
        padding: 12,
        radius: 18,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _Thumb(entry: entry, size: 92, radius: 14),
            SizedBox(width: 13.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Padding(
                          padding: EdgeInsets.only(top: 2.h),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Flexible(
                                child: Text(
                                  club.name,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontFamily: 'Pretendard',
                                    fontSize: 16.sp,
                                    height: 18 / 16,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: 16 * -0.025,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                              // VYBE 추천 뱃지 — 클럽 이름 옆.
                              if (club.isVybeRecommended) ...[
                                SizedBox(width: 6.w),
                                const VybeRecommendBadge(size: 10),
                              ],
                            ],
                          ),
                        ),
                      ),
                      SizedBox(width: 8.w),
                      _UnsaveButton(onTap: () => onUnsave(club.clubId)),
                    ],
                  ),
                  SizedBox(height: 6.h),
                  Row(
                    children: [
                      Icon(Icons.star_rounded,
                          size: 12.r, color: VybeColors.mainLime500),
                      SizedBox(width: 5.w),
                      Text(
                        club.rating.toStringAsFixed(2),
                        style: _caption(
                          color: Colors.white,
                          weight: FontWeight.w700,
                        ),
                      ),
                      Container(
                        width: 1,
                        height: 9.h,
                        margin: EdgeInsets.symmetric(horizontal: 6.w),
                        color: const Color(0x33FFFFFF),
                      ),
                      Flexible(
                        child: Text(
                          club.area,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: _caption(),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 6.w),
                        child: const GlassDot(),
                      ),
                      Flexible(
                        child: Text(
                          club.genre,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: _caption(),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 6.h),
                  _OpenHoursPill(isOpen: entry.isOpen, hours: entry.hoursLabel),
                  SizedBox(height: 6.h),
                  Text(
                    entry.savedAtLabel,
                    style: _caption(color: ClubGlass.t4),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// 찜 해제 버튼 (리스트 카드용 글래스 타일 원형).
class _UnsaveButton extends StatelessWidget {
  final VoidCallback onTap;

  const _UnsaveButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        width: 30.r,
        height: 30.r,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: ClubGlass.tileFill,
          shape: BoxShape.circle,
          border: Border.all(color: ClubGlass.tileBorder),
        ),
        child: Icon(
          Icons.favorite_rounded,
          size: 15.r,
          color: ClubGlass.saved,
        ),
      ),
    );
  }
}

/// 영업 상태 + 마감/오픈 시각을 한 pill 안에 담는다 (찜 리스트 전용).
class _OpenHoursPill extends StatelessWidget {
  final bool isOpen;
  final String hours;

  const _OpenHoursPill({required this.isOpen, required this.hours});

  @override
  Widget build(BuildContext context) {
    final accent = isOpen ? VybeColors.mainLime500 : ClubGlass.t4;
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 9.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: isOpen
            ? VybeColors.mainLime500.withValues(alpha: 0.13)
            : const Color(0x0FFFFFFF),
        borderRadius: BorderRadius.circular(999.r),
        border: Border.all(
          color: isOpen
              ? VybeColors.mainLime500.withValues(alpha: 0.28)
              : const Color(0x1AFFFFFF),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 5.r,
            height: 5.r,
            decoration: BoxDecoration(
              color: isOpen ? VybeColors.mainLime500 : const Color(0x59FFFFFF),
              shape: BoxShape.circle,
            ),
          ),
          SizedBox(width: 5.w),
          Text(
            isOpen ? '영업중' : '영업종료',
            style: _caption(
              color: accent,
              lineHeight: 13,
              weight: FontWeight.w700,
            ),
          ),
          SizedBox(width: 5.w),
          Flexible(
            child: Text(
              hours,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: _caption(lineHeight: 13),
            ),
          ),
        ],
      ),
    );
  }
}

// ============ 그리드 카드 ============

class _GridCard extends StatelessWidget {
  final SavedEntry entry;
  final ValueChanged<String> onUnsave;

  const _GridCard({required this.entry, required this.onUnsave});

  @override
  Widget build(BuildContext context) {
    final club = entry.club;

    return GestureDetector(
      onTap: () => _openClubDetail(context, club.clubId),
      behavior: HitTestBehavior.opaque,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AspectRatio(
            aspectRatio: 1,
            child: _Thumb(
              entry: entry,
              radius: 18,
              isGrid: true,
              onUnsave: () => onUnsave(club.clubId),
            ),
          ),
          SizedBox(height: 9.h),
          Row(
            children: [
              Flexible(
                child: Text(
                  club.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontFamily: 'Pretendard',
                    fontSize: 14.sp,
                    height: 16 / 14,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 14 * -0.025,
                    color: Colors.white,
                  ),
                ),
              ),
              // VYBE 추천 뱃지 — 클럽 이름 옆.
              if (club.isVybeRecommended) ...[
                SizedBox(width: 5.w),
                const VybeRecommendBadge(size: 9),
              ],
            ],
          ),
          SizedBox(height: 3.h),
          Text(
            '${club.area} · ${club.genre}',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: _caption(),
          ),
        ],
      ),
    );
  }
}

// ============ 썸네일 ============

class _Thumb extends StatelessWidget {
  final SavedEntry entry;

  /// 리스트용 고정 한 변 길이 (그리드는 부모가 정한다).
  final double size;
  final double radius;
  final bool isGrid;
  final VoidCallback? onUnsave;

  const _Thumb({
    required this.entry,
    this.size = 92,
    this.radius = 14,
    this.isGrid = false,
    this.onUnsave,
  });

  @override
  Widget build(BuildContext context) {
    final club = entry.club;
    final gradient = _gradientFor(club.clubId);
    final url = club.thumbnailUrl;

    final thumb = ClipRRect(
      borderRadius: BorderRadius.circular(radius.r),
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: gradient,
          ),
          border: Border.all(color: const Color(0x1AFFFFFF)),
        ),
        child: Stack(
          fit: StackFit.expand,
          children: [
            if (url.isNotEmpty)
              SkeletonImage(
                url: url,
                fit: BoxFit.cover,
                // 최초 로드 시 최소 1초 shimmer 후 페이드 — 검정 화면 깜빡임 방지.
                minSkeleton: const Duration(seconds: 1),
              ),
            // 좌상단에서 번지는 광택.
            const DecoratedBox(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment(-0.4, -0.44),
                  radius: 0.86,
                  colors: [Color(0x42FFFFFF), Color(0x00FFFFFF)],
                  stops: [0.0, 0.62],
                ),
              ),
            ),
            if (isGrid) ...[
              // 하단 정보가 읽히도록 어둡게 깔아준다.
              const DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Color(0x00000000), Color(0xAD000000)],
                    stops: [0.46, 1.0],
                  ),
                ),
              ),
              Positioned(
                top: 8.h,
                right: 8.w,
                child: GestureDetector(
                  onTap: onUnsave,
                  behavior: HitTestBehavior.opaque,
                  child: Container(
                    width: 30.r,
                    height: 30.r,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      // 이미지 위 blur는 비용이 커 반투명 채움으로 대체.
                      color: const Color(0x8014121A),
                      shape: BoxShape.circle,
                      border: Border.all(color: const Color(0x29FFFFFF)),
                    ),
                    child: Icon(
                      Icons.favorite_rounded,
                      size: 15.r,
                      color: ClubGlass.saved,
                    ),
                  ),
                ),
              ),
              Positioned(
                left: 9.w,
                right: 9.w,
                bottom: 9.h,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 5.r,
                            height: 5.r,
                            decoration: BoxDecoration(
                              color: entry.isOpen
                                  ? VybeColors.mainLime500
                                  : const Color(0x73FFFFFF),
                              shape: BoxShape.circle,
                            ),
                          ),
                          SizedBox(width: 4.w),
                          Text(
                            entry.isOpen ? '영업중' : '영업종료',
                            style: _caption(
                              color: Colors.white,
                              size: 10.5,
                              lineHeight: 12,
                              weight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 8.w,
                        vertical: 3.h,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0x800E0D12),
                        borderRadius: BorderRadius.circular(999.r),
                        border: Border.all(color: const Color(0x24FFFFFF)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.star_rounded,
                              size: 10.r, color: VybeColors.mainLime500),
                          SizedBox(width: 3.w),
                          Text(
                            entry.club.rating.toStringAsFixed(1),
                            style: _caption(
                              color: Colors.white,
                              size: 10.5,
                              lineHeight: 12,
                              weight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );

    if (isGrid) return thumb;
    return SizedBox(width: size.w, height: size.w, child: thumb);
  }
}

// ============ 전체 비었을 때 ============

class _EmptyState extends StatelessWidget {
  final VoidCallback onExplore;

  const _EmptyState({required this.onExplore});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 0),
      child: GlassCard(
        padding: 32,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 76.r,
              height: 76.r,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: VybeColors.mainPurple500.withValues(alpha: 0.16),
                shape: BoxShape.circle,
                border: Border.all(
                  color: VybeColors.mainPurple500.withValues(alpha: 0.3),
                ),
              ),
              child: Icon(
                Icons.favorite_border_rounded,
                size: 30.r,
                color: Colors.white,
              ),
            ),
            SizedBox(height: 14.h),
            Text(
              '아직 찜한 클럽이 없어요',
              style: TextStyle(
                fontFamily: 'Pretendard',
                fontSize: 20.sp,
                height: 22 / 20,
                fontWeight: FontWeight.w600,
                letterSpacing: 20 * -0.025,
                color: Colors.white,
              ),
            ),
            SizedBox(height: 14.h),
            Text(
              '마음에 드는 클럽의 하트를 눌러서\n나만의 리스트를 만들어보세요',
              textAlign: TextAlign.center,
              style: ClubGlass.body(color: ClubGlass.t3),
            ),
            SizedBox(height: 16.h),
            GestureDetector(
              onTap: onExplore,
              behavior: HitTestBehavior.opaque,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 26.w, vertical: 13.h),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      VybeColors.mainLime500,
                      VybeColors.mainLime700,
                    ],
                  ),
                  borderRadius: BorderRadius.circular(14.r),
                  boxShadow: [
                    BoxShadow(
                      color: VybeColors.mainLime500.withValues(alpha: 0.2),
                      blurRadius: 26.r,
                      offset: Offset(0, 10.h),
                    ),
                  ],
                ),
                child: Text(
                  '클럽 둘러보기',
                  style: TextStyle(
                    fontFamily: 'Pretendard',
                    fontSize: 16.sp,
                    height: 18 / 16,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 16 * -0.025,
                    color: ClubGlass.ink,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
