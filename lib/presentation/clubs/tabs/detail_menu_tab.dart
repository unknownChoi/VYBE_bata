import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vybe/data/models/menu_model.dart';
import 'package:vybe/presentation/clubs/tabs/detail_home_tab.dart';
import 'package:vybe/presentation/clubs/viewmodels/club_detail_viewmodel.dart';
import 'package:vybe/presentation/clubs/widgets/club_detail_skeleton.dart';
import 'package:vybe/presentation/clubs/widgets/club_glass.dart';
import 'package:vybe/presentation/common/widgets/vybe_photo_viewer.dart';
import 'package:vybe/presentation/common/widgets/vybe_skeleton.dart';

/// 클럽 상세 · 메뉴 탭 (리퀴드 글래스).
///
/// 디자인 club_glass_tabs.jsx(CGMenuTab) — 메뉴판 이미지 가로 스크롤 →
/// sticky 카테고리 칩 → 카테고리별 섹션이 한 장의 카드 안에 이어진다.
/// 칩을 누르면 해당 섹션으로 스크롤한다.
class DetailMenuTab extends ConsumerStatefulWidget {
  final String clubId;
  const DetailMenuTab({super.key, required this.clubId});

  @override
  ConsumerState<DetailMenuTab> createState() => _DetailMenuTabState();
}

class _DetailMenuTabState extends ConsumerState<DetailMenuTab> {
  String? _activeCategory;
  final Map<String, GlobalKey> _sectionKeys = {};

  void _goToSection(String category) {
    setState(() => _activeCategory = category);
    final sectionContext = _sectionKeys[category]?.currentContext;
    if (sectionContext == null) return;
    Scrollable.ensureVisible(
      sectionContext,
      duration: const Duration(milliseconds: 320),
      curve: Curves.easeOutCubic,
      alignment: 0.02,
    );
  }

  @override
  Widget build(BuildContext context) {
    final menusAsync = ref.watch(clubMenusProvider(widget.clubId));
    final club = ref.watch(clubDetailProvider(widget.clubId)).value;
    final boards = club?.menuBoardUrls ?? const <String>[];

    if (menusAsync.isLoading) {
      return ListView(
        physics: const ClampingScrollPhysics(),
        padding: glassTabPadding(context),
        children: const [DetailMenuTabSkeleton()],
      );
    }

    final menus = menusAsync.value ?? const <MenuModel>[];
    final grouped = _groupByCategory(menus);
    final categories = grouped.keys.toList();

    if (boards.isEmpty && menus.isEmpty) {
      return Center(
        child: Text('등록된 메뉴가 없어요', style: ClubGlass.body(color: ClubGlass.t4)),
      );
    }

    // 첫 렌더 시 활성 칩 초기화 + 섹션 키 확보.
    if (_activeCategory == null && categories.isNotEmpty) {
      _activeCategory = categories.first;
    }
    for (final c in categories) {
      _sectionKeys.putIfAbsent(c, GlobalKey.new);
    }

    // 카테고리 바는 탭 상단에 고정한다. sticky를 pinned SliverPersistentHeader로
    // 만들면 Flutter 3.41 세만틱스 검증이 매 프레임 assert를 던져 화면이 안 그려진다
    // (club_detail_screen 주석 참고) — 그래서 스크롤 밖 고정 행으로 뺐다.
    return Column(
      children: [
        if (categories.length > 1)
          _CategoryBar(
            categories: categories,
            active: _activeCategory,
            onSelect: _goToSection,
          ),
        Expanded(
          child: ListView(
            physics: const ClampingScrollPhysics(),
            padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 28.h),
            children: [
              if (boards.isNotEmpty) ...[
                _buildBoardCard(boards),
                SizedBox(height: 14.h),
              ],
              if (menus.isNotEmpty) _buildSectionsCard(grouped),
              SizedBox(height: 12.h),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 4.w),
                child: Text(
                  '메뉴 항목과 가격은 매장 사정에 따라 다를 수 있습니다.',
                  style: ClubGlass.caption(color: ClubGlass.t4, lineHeight: 17),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// 메뉴판 이미지 — 가로 스크롤, 탭하면 전체 뷰어.
  Widget _buildBoardCard(List<String> boards) {
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const GlassSectionHead(title: '메뉴 이미지'),
          SizedBox(
            height: 104.r,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: boards.length,
              separatorBuilder: (_, __) => SizedBox(width: 8.w),
              itemBuilder: (_, i) => GestureDetector(
                onTap: () => VybePhotoViewer.open(
                  context,
                  imageUrls: boards,
                  initialIndex: i,
                ),
                behavior: HitTestBehavior.opaque,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(14.r),
                  child: SizedBox(
                    width: 104.r,
                    height: 104.r,
                    child: SkeletonImage(url: boards[i], fit: BoxFit.cover),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 카테고리별 섹션이 하나의 카드 안에서 hairline으로 구분된다.
  Widget _buildSectionsCard(Map<String, List<MenuModel>> grouped) {
    final entries = grouped.entries.toList();

    return GlassCard(
      padding: 0,
      child: Column(
        children: [
          for (var i = 0; i < entries.length; i++)
            Container(
              key: _sectionKeys[entries[i].key],
              padding: EdgeInsets.fromLTRB(18.w, 18.h, 18.w, 6.h),
              decoration: BoxDecoration(
                border: i == 0
                    ? null
                    : const Border(top: BorderSide(color: ClubGlass.hair)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  GlassSectionHead(title: entries[i].key),
                  for (var j = 0; j < entries[i].value.length; j++)
                    GlassMenuRow(
                      menu: entries[i].value[j],
                      last: j == entries[i].value.length - 1,
                    ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  /// 등장 순서를 유지하며 카테고리별로 묶는다. 대표 메뉴는 항상 맨 앞 그룹.
  Map<String, List<MenuModel>> _groupByCategory(List<MenuModel> menus) {
    final available = menus.where((m) => m.isAvailable).toList();
    final featured = available.where((m) => m.isFeatured).toList();
    final grouped = <String, List<MenuModel>>{};

    if (featured.isNotEmpty) grouped['대표 메뉴'] = featured;

    for (final m in available) {
      final key = m.category.isEmpty ? '기타' : m.category;
      grouped.putIfAbsent(key, () => []).add(m);
    }
    return grouped;
  }
}

// ============================================================================
// STICKY CATEGORY BAR
// ============================================================================

class _CategoryBar extends StatelessWidget {
  final List<String> categories;
  final String? active;
  final ValueChanged<String> onSelect;

  const _CategoryBar({
    required this.categories,
    required this.active,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return GlassBar(
      padding: EdgeInsets.symmetric(vertical: 10.h),
      child: SizedBox(
        height: 34.h,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          itemCount: categories.length,
          separatorBuilder: (_, __) => SizedBox(width: 8.w),
          itemBuilder: (_, i) => GlassFilterChip(
            label: categories[i],
            selected: categories[i] == active,
            onTap: () => onSelect(categories[i]),
          ),
        ),
      ),
    );
  }
}
