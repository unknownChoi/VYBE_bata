import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vybe/presentation/clubs/widgets/club_glass.dart';
import 'package:vybe/presentation/common/widgets/vybe_aurora.dart';
import 'package:vybe/presentation/main_scaffold/nav_bar_visibility_provider.dart';
import 'package:vybe/presentation/saved/saved_common.dart';
import 'package:vybe/presentation/saved/viewmodels/saved_viewmodel.dart';
import 'package:vybe/presentation/saved/widgets/saved_empty_state.dart';
import 'package:vybe/presentation/saved/widgets/saved_grid_card.dart';
import 'package:vybe/presentation/saved/widgets/saved_list_card.dart';
import 'package:vybe/presentation/saved/widgets/saved_skeleton.dart';
import 'package:vybe/presentation/saved/widgets/saved_toolbar.dart';

// ============================================================
// 찜한 클럽 화면 (saved_glass.html · Liquid Glass 리뉴얼)
//
// 배경·카드·바는 클럽 상세와 같은 글래스 요소(club_glass.dart) 재사용.
// favorites Firestore 연동. 정렬, 리스트↔그리드 뷰 지원.
// ============================================================

/// 홈 탭 인덱스 (빈 화면 CTA에서 사용).
const int _kHomeTabIndex = 0;

class SavedScreen extends ConsumerStatefulWidget {
  const SavedScreen({super.key});

  @override
  ConsumerState<SavedScreen> createState() => _SavedScreenState();
}

class _SavedScreenState extends ConsumerState<SavedScreen> {
  bool _isGrid = false;
  SavedSortOption _sort = SavedSortOption.recent;

  List<SavedEntry> _applySort(List<SavedEntry> all) {
    final list = List.of(all);
    switch (_sort) {
      case SavedSortOption.rating:
        list.sort((a, b) => b.club.rating.compareTo(a.club.rating));
        break;
      case SavedSortOption.name:
        list.sort((a, b) => a.club.name.compareTo(b.club.name));
        break;
      case SavedSortOption.open:
        list.sort((a, b) {
          final byOpen = (b.isOpen ? 1 : 0) - (a.isOpen ? 1 : 0);
          return byOpen != 0 ? byOpen : b.club.rating.compareTo(a.club.rating);
        });
        break;
      case SavedSortOption.recent:
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
          const Positioned.fill(child: IgnorePointer(child: VybeAurora())),
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
              child: SavedHeader(
                count: all.length,
                openCount: all.where((e) => e.isOpen).length,
              ),
            ),
            // 찜이 없으면 정렬·뷰 전환이 무의미해 툴바를 숨긴다 (디자인과 다름).
            if (!isEmpty)
              SliverPersistentHeader(
                pinned: true,
                delegate: SavedToolbarDelegate(
                  isGrid: _isGrid,
                  sort: _sort,
                  onView: (g) => setState(() => _isGrid = g),
                  onSort: (s) => setState(() => _sort = s),
                ),
              ),
            if (isEmpty)
              SliverToBoxAdapter(
                child: SavedEmptyState(
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
                    (_, i) => SavedGridCard(
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
                  itemBuilder: (_, i) => SavedListCard(
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
