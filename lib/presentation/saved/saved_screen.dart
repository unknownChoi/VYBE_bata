import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vybe/design_system/colors.dart';
import 'package:vybe/design_system/typography.dart';
import 'package:vybe/presentation/clubs/club_detail_screen.dart';
import 'package:vybe/presentation/common/widgets/vybe_skeleton.dart';
import 'package:vybe/presentation/saved/viewmodels/saved_viewmodel.dart';

// ============================================================
// 찜한 클럽 화면 (saved.html 디자인 기반)
//
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
  [Color(0xFF7731FE), Color(0xFFFF4D8D)],
  [Color(0xFFFF006E), Color(0xFF8338EC)],
  [Color(0xFF06FFA5), Color(0xFF3A86FF)],
  [Color(0xFFFB5607), Color(0xFFFFBE0B)],
  [Color(0xFF2A2D34), Color(0xFF6C757D)],
  [Color(0xFF2B6BFF), Color(0xFF7731FE)],
];

List<Color> _gradientFor(String key) =>
    _kGradients[key.hashCode.abs() % _kGradients.length];

/// 탭 내부 Navigator로 클럽 상세 push.
void _openClubDetail(BuildContext context, String clubId) {
  Navigator.of(context).push(
    MaterialPageRoute(builder: (_) => ClubDetailScreen(clubId: clubId)),
  );
}

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
    final topInset = MediaQuery.of(context).padding.top;
    const bottomPad = 100.0;

    return Scaffold(
      backgroundColor: VybeColors.background,
      body: savedAsync.when(
        loading: () => ListView(
          padding: EdgeInsets.only(top: topInset),
          physics: const NeverScrollableScrollPhysics(),
          children: const [SavedSkeleton()],
        ),
        error: (e, _) => Center(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 32.w),
            child: Text(
              '찜 목록을 불러오지 못했어요',
              style: VybeTypography.body3.copyWith(color: VybeColors.gray400),
            ),
          ),
        ),
        data: (all) {
          if (all.isEmpty) {
            return Padding(
              padding: EdgeInsets.only(top: topInset),
              child: const _EmptyState(),
            );
          }
          final openCount = all.where((e) => e.isOpen).length;
          final sorted = _applySort(all);

          return ListView(
            padding: EdgeInsets.only(top: topInset),
            children: [
              _StatsBar(count: all.length, openCount: openCount),
              SizedBox(height: 8.h),
              _ToolBar(
                isGrid: _isGrid,
                sort: _sort,
                onView: (g) => setState(() => _isGrid = g),
                onSort: (s) => setState(() => _sort = s),
              ),
              if (_isGrid)
                _GridList(
                  entries: sorted,
                  onUnsave: (id) =>
                      ref.read(savedActionsProvider.notifier).unsave(id),
                )
              else
                _CardList(
                  entries: sorted,
                  onUnsave: (id) =>
                      ref.read(savedActionsProvider.notifier).unsave(id),
                ),
              SizedBox(height: bottomPad.h),
            ],
          );
        },
      ),
    );
  }
}

// ============ 통계 바 ============

class _StatsBar extends StatelessWidget {
  final int count;
  final int openCount;
  const _StatsBar({required this.count, required this.openCount});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(20.w, 28.h, 20.w, 12.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '$count',
                style: VybeTypography.heading2.copyWith(color: Colors.white),
              ),
              SizedBox(width: 8.w),
              Padding(
                padding: EdgeInsets.only(bottom: 2.h),
                child: Text(
                  '곳을 찜했어요',
                  style: VybeTypography.body3.copyWith(color: VybeColors.gray400),
                ),
              ),
            ],
          ),
          Row(
            children: [
              Container(
                width: 6.r,
                height: 6.r,
                decoration: BoxDecoration(
                  color: VybeColors.mainLime500,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: VybeColors.mainLime500.withValues(alpha: 0.6),
                      blurRadius: 6,
                    ),
                  ],
                ),
              ),
              SizedBox(width: 6.w),
              Text(
                '지금 $openCount곳 영업중',
                style: VybeTypography.caption.copyWith(
                  color: VybeColors.gray300,
                  fontWeight: FontWeight.w600,
                  height: 14 / 12,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ============ 정렬 + 뷰 전환 툴바 ============

class _ToolBar extends StatelessWidget {
  final bool isGrid;
  final _SortOption sort;
  final ValueChanged<bool> onView;
  final ValueChanged<_SortOption> onSort;

  const _ToolBar({
    required this.isGrid,
    required this.sort,
    required this.onView,
    required this.onSort,
  });

  Future<void> _openSortMenu(BuildContext context) async {
    final box = context.findRenderObject() as RenderBox;
    final offset = box.localToGlobal(Offset.zero);
    final selected = await showMenu<_SortOption>(
      context: context,
      color: VybeColors.gray900,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14.r),
        side: BorderSide(color: VybeColors.gray800),
      ),
      position: RelativeRect.fromLTRB(
        offset.dx + 20.w,
        offset.dy + 28.h,
        offset.dx + box.size.width,
        offset.dy,
      ),
      items: [
        for (final o in _SortOption.values)
          PopupMenuItem<_SortOption>(
            value: o,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _kSortLabels[o]!,
                  style: VybeTypography.body4.copyWith(
                    color: o == sort ? Colors.white : VybeColors.gray300,
                    fontWeight: o == sort ? FontWeight.w600 : FontWeight.w500,
                  ),
                ),
                if (o == sort)
                  Icon(Icons.check, size: 15.r, color: VybeColors.mainPurple500),
              ],
            ),
          ),
      ],
    );
    if (selected != null) onSort(selected);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 16.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          GestureDetector(
            onTap: () => _openSortMenu(context),
            child: Row(
              children: [
                Text(
                  _kSortLabels[sort]!,
                  style: VybeTypography.caption.copyWith(
                    color: VybeColors.gray300,
                    fontWeight: FontWeight.w500,
                    height: 14 / 12,
                  ),
                ),
                Icon(Icons.keyboard_arrow_down,
                    size: 16.r, color: VybeColors.gray300),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.all(3.r),
            decoration: BoxDecoration(
              color: VybeColors.gray900,
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Row(
              children: [
                _viewBtn(
                  icon: Icons.format_list_bulleted,
                  active: !isGrid,
                  onTap: () => onView(false),
                ),
                SizedBox(width: 2.w),
                _viewBtn(
                  icon: Icons.grid_view,
                  active: isGrid,
                  onTap: () => onView(true),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _viewBtn({
    required IconData icon,
    required bool active,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 30.w,
        height: 26.h,
        decoration: BoxDecoration(
          color: active ? VybeColors.gray700 : Colors.transparent,
          borderRadius: BorderRadius.circular(6.r),
        ),
        child: Icon(icon,
            size: 14.r, color: active ? Colors.white : VybeColors.gray500),
      ),
    );
  }
}

// ============ 리스트(세로) 카드 ============

class _CardList extends StatelessWidget {
  final List<SavedEntry> entries;
  final ValueChanged<String> onUnsave;
  const _CardList({required this.entries, required this.onUnsave});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (final e in entries) _ListCard(entry: e, onUnsave: onUnsave)
      ],
    );
  }
}

class _ListCard extends StatelessWidget {
  final SavedEntry entry;
  final ValueChanged<String> onUnsave;
  const _ListCard({required this.entry, required this.onUnsave});

  @override
  Widget build(BuildContext context) {
    final club = entry.club;
    return GestureDetector(
      onTap: () => _openClubDetail(context, club.clubId),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 14.h),
        decoration: BoxDecoration(
          border: Border(bottom: BorderSide(color: VybeColors.gray900)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _Thumb(entry: entry, size: 96),
            SizedBox(width: 14.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          club.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: VybeTypography.body3.copyWith(
                              color: Colors.white, fontWeight: FontWeight.w600),
                        ),
                      ),
                      GestureDetector(
                        onTap: () => onUnsave(club.clubId),
                        child: Padding(
                          padding: EdgeInsets.all(4.r),
                          child: Icon(Icons.favorite,
                              size: 20.r, color: VybeColors.mainPurple500),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 6.h),
                  Row(
                    children: [
                      Icon(Icons.star, size: 12.r, color: VybeColors.mainLime500),
                      SizedBox(width: 6.w),
                      Text(
                        club.rating.toStringAsFixed(2),
                        style: VybeTypography.caption.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          height: 14 / 12,
                        ),
                      ),
                      _dotDivider(),
                      Flexible(
                        child: Text(club.area,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: _metaStyle()),
                      ),
                      _smallDot(),
                      Flexible(
                        child: Text(club.genre,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: _metaStyle()),
                      ),
                    ],
                  ),
                  SizedBox(height: 6.h),
                  Row(
                    children: [
                      Icon(Icons.access_time,
                          size: 12.r,
                          color: entry.isOpen
                              ? VybeColors.mainLime500
                              : VybeColors.gray600),
                      SizedBox(width: 6.w),
                      Text(
                        entry.isOpen ? '영업중' : '영업종료',
                        style: VybeTypography.caption.copyWith(
                          color: entry.isOpen
                              ? VybeColors.mainLime500
                              : VybeColors.gray500,
                          fontWeight: FontWeight.w600,
                          height: 14 / 12,
                        ),
                      ),
                      _smallDot(),
                      Flexible(
                        child: Text(entry.hoursLabel,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style:
                                _metaStyle().copyWith(color: VybeColors.gray400)),
                      ),
                    ],
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    entry.savedAtLabel,
                    style: VybeTypography.caption
                        .copyWith(color: VybeColors.gray600, height: 14 / 12),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  TextStyle _metaStyle() =>
      VybeTypography.caption.copyWith(color: VybeColors.gray500, height: 14 / 12);

  Widget _dotDivider() => Padding(
        padding: EdgeInsets.symmetric(horizontal: 6.w),
        child: Container(width: 1, height: 10.h, color: VybeColors.gray700),
      );

  Widget _smallDot() => Padding(
        padding: EdgeInsets.symmetric(horizontal: 6.w),
        child: Container(
          width: 2.r,
          height: 2.r,
          decoration: const BoxDecoration(
              color: VybeColors.gray600, shape: BoxShape.circle),
        ),
      );
}

// ============ 그리드 카드 ============

class _GridList extends StatelessWidget {
  final List<SavedEntry> entries;
  final ValueChanged<String> onUnsave;
  const _GridList({required this.entries, required this.onUnsave});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 24.h),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: entries.length,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 14.h,
          crossAxisSpacing: 14.w,
          childAspectRatio: 0.78,
        ),
        itemBuilder: (_, i) =>
            _GridCard(entry: entries[i], onUnsave: onUnsave),
      ),
    );
  }
}

class _GridCard extends StatelessWidget {
  final SavedEntry entry;
  final ValueChanged<String> onUnsave;
  const _GridCard({required this.entry, required this.onUnsave});

  @override
  Widget build(BuildContext context) {
    final club = entry.club;
    return GestureDetector(
      onTap: () => _openClubDetail(context, club.clubId),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: _Thumb(
              entry: entry,
              isGrid: true,
              onUnsave: () => onUnsave(club.clubId),
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            club.name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: VybeTypography.body4
                .copyWith(color: Colors.white, fontWeight: FontWeight.w600),
          ),
          SizedBox(height: 2.h),
          Row(
            children: [
              Flexible(
                child: Text(club.area,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: VybeTypography.caption
                        .copyWith(color: VybeColors.gray500, height: 14 / 12)),
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 4.w),
                child: Container(
                  width: 2.r,
                  height: 2.r,
                  decoration: const BoxDecoration(
                      color: VybeColors.gray600, shape: BoxShape.circle),
                ),
              ),
              Flexible(
                child: Text(club.genre,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: VybeTypography.caption
                        .copyWith(color: VybeColors.gray500, height: 14 / 12)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ============ 썸네일 ============

class _Thumb extends StatelessWidget {
  final SavedEntry entry;
  final double size; // 리스트용 고정 크기
  final bool isGrid;
  final VoidCallback? onUnsave;

  const _Thumb({
    required this.entry,
    this.size = 96,
    this.isGrid = false,
    this.onUnsave,
  });

  @override
  Widget build(BuildContext context) {
    final club = entry.club;
    final radius = isGrid ? 12.r : 10.r;
    final gradient = _gradientFor(club.clubId);
    final url = club.thumbnailUrl;

    final thumb = ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: gradient,
          ),
          border: Border.all(color: VybeColors.gray900),
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
            // 광택.
            DecoratedBox(
              decoration: const BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment(-0.4, -0.4),
                  radius: 0.9,
                  colors: [Color(0x22FFFFFF), Color(0x00FFFFFF)],
                ),
              ),
            ),
            if (entry.tag != null) _TagBadge(tag: entry.tag!, isGrid: isGrid),
            if (isGrid) ...[
              Positioned(
                top: 6.h,
                right: 6.w,
                child: GestureDetector(
                  onTap: onUnsave,
                  child: Container(
                    width: 32.r,
                    height: 32.r,
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.5),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.favorite,
                        size: 16.r, color: VybeColors.mainPurple500),
                  ),
                ),
              ),
              Positioned(
                left: 8.w,
                bottom: 8.h,
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.65),
                    borderRadius: BorderRadius.circular(999.r),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.star,
                          size: 10.r, color: VybeColors.mainLime500),
                      SizedBox(width: 3.w),
                      Text(
                        club.rating.toStringAsFixed(2),
                        style: VybeTypography.caption.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          height: 12 / 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              if (!entry.isOpen)
                DecoratedBox(
                  decoration: const BoxDecoration(color: Color(0x80101013)),
                  child: Center(
                    child: Text(
                      '영업 종료',
                      style: VybeTypography.caption.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        height: 14 / 12,
                      ),
                    ),
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

class _TagBadge extends StatelessWidget {
  final String tag;
  final bool isGrid;
  const _TagBadge({required this.tag, required this.isGrid});

  @override
  Widget build(BuildContext context) {
    final isHot = tag == 'HOT';
    return Positioned(
      top: isGrid ? 8.h : 6.h,
      left: isGrid ? 8.w : 6.w,
      child: Container(
        padding:
            EdgeInsets.symmetric(horizontal: isGrid ? 7.w : 6.w, vertical: 2.h),
        decoration: BoxDecoration(
          color: isHot
              ? const Color(0xFFFF3B6E)
              : Colors.black.withValues(alpha: 0.7),
          borderRadius: BorderRadius.circular(4.r),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (!isHot) ...[
              Icon(Icons.star, size: 9.r, color: VybeColors.mainLime500),
              SizedBox(width: 3.w),
            ],
            Text(
              tag,
              style: VybeTypography.caption.copyWith(
                color: isHot ? Colors.white : VybeColors.mainLime500,
                fontWeight: FontWeight.w700,
                height: 12 / 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ============ 전체 비었을 때 ============

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 24.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.favorite_border, size: 80.r, color: VybeColors.gray700),
            SizedBox(height: 20.h),
            Text(
              '아직 찜한 클럽이 없어요',
              style: VybeTypography.heading4
                  .copyWith(color: Colors.white, fontWeight: FontWeight.w600),
            ),
            SizedBox(height: 6.h),
            Text(
              '마음에 드는 클럽의 하트를 눌러서\n나만의 리스트를 만들어보세요',
              textAlign: TextAlign.center,
              style: VybeTypography.body4
                  .copyWith(color: VybeColors.gray500, height: 20 / 14),
            ),
          ],
        ),
      ),
    );
  }
}
