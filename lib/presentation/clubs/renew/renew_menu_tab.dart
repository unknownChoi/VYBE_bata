import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vybe/data/models/menu_model.dart';
import 'package:vybe/presentation/clubs/renew/widgets/renew_glass.dart';
import 'package:vybe/presentation/clubs/renew/widgets/renew_menu_rows.dart';
import 'package:vybe/presentation/clubs/renew/widgets/renew_sticky_bar.dart';
import 'package:vybe/presentation/clubs/viewmodels/club_detail_viewmodel.dart';
import 'package:vybe/presentation/common/widgets/vybe_photo_viewer.dart';
import 'package:vybe/presentation/common/widgets/vybe_skeleton.dart';
import 'package:vybe/presentation/common/widgets/vybe_spinner.dart';

/// 클럽 상세 리뉴얼 · 메뉴 탭.
///
/// 디자인 VRMenuTab — 메뉴판 이미지 가로 스크롤 → sticky 카테고리 칩 →
/// 카테고리별 섹션(hairline 구분) → 안내 문구.
/// 칩을 누르면 해당 섹션이 칩 줄 바로 아래로 오도록 스크롤한다.
class RenewMenuTab extends ConsumerStatefulWidget {
  final String clubId;
  final EdgeInsets padding;

  const RenewMenuTab({super.key, required this.clubId, required this.padding});

  @override
  ConsumerState<RenewMenuTab> createState() => _RenewMenuTabState();
}

class _RenewMenuTabState extends ConsumerState<RenewMenuTab> {
  String? _active;
  final Map<String, GlobalKey> _sectionKeys = {};

  /// 칩 줄 높이 (padding 10 + 칩 34 + padding 10 + hairline).
  double get _chipBarHeight => 55.h;

  void _goTo(String category) {
    setState(() => _active = category);
    final ctx = _sectionKeys[category]?.currentContext;
    if (ctx == null) return;
    // 섹션 머리가 sticky 칩 줄에 가리지 않도록 칩 높이만큼 아래에 맞춘다.
    final viewport = MediaQuery.sizeOf(context).height;
    Scrollable.ensureVisible(
      ctx,
      duration: const Duration(milliseconds: 320),
      curve: Curves.easeOutCubic,
      alignment: viewport == 0 ? 0 : (_chipBarHeight / viewport).clamp(0, 0.5),
    );
  }

  @override
  Widget build(BuildContext context) {
    final menusAsync = ref.watch(clubMenusProvider(widget.clubId));
    final club = ref.watch(clubDetailProvider(widget.clubId)).value;
    final boards = club?.menuBoardUrls ?? const <String>[];

    if (menusAsync.isLoading) {
      return const Center(child: VybeSpinner(size: 40));
    }

    final menus = menusAsync.value ?? const <MenuModel>[];
    final grouped = _groupByCategory(menus);
    final categories = grouped.keys.toList();

    if (boards.isEmpty && menus.isEmpty) {
      return Center(child: Text('등록된 메뉴가 없어요', style: RenewGlass.body()));
    }

    if (_active == null && categories.isNotEmpty) _active = categories.first;
    for (final c in categories) {
      _sectionKeys.putIfAbsent(c, GlobalKey.new);
    }

    // 칩이 한 종류뿐이면 고정할 이유가 없다 — 스크롤만.
    if (categories.length <= 1) {
      return _list(boards, categories, grouped, barKey: null);
    }
    return RenewStickyBarHost(
      bar: _chipBar(categories),
      scrollBuilder: (barKey) =>
          _list(boards, categories, grouped, barKey: barKey),
    );
  }

  Widget _list(
    List<String> boards,
    List<String> categories,
    Map<String, List<MenuModel>> grouped, {
    required GlobalKey? barKey,
  }) {
    return ListView(
      physics: const ClampingScrollPhysics(),
      padding: EdgeInsets.only(top: widget.padding.top),
      children: [
        if (boards.isNotEmpty) ...[
          Padding(
            padding: EdgeInsets.symmetric(horizontal: widget.padding.left),
            child: const RenewSectionHead(title: '메뉴 이미지'),
          ),
          _boardRail(boards),
          SizedBox(height: 20.h),
        ],
        // 카테고리 칩 — 위로 올라가면 [RenewStickyBarHost]가 복제본을 고정한다.
        if (barKey != null) ...[
          KeyedSubtree(key: barKey, child: _chipBar(categories)),
          SizedBox(height: 20.h),
        ],
        for (var i = 0; i < categories.length; i++)
          _section(categories[i], grouped[categories[i]]!, first: i == 0),
        SizedBox(height: 20.h),
        Padding(
          padding: EdgeInsets.only(
            left: widget.padding.left,
            right: widget.padding.right,
            bottom: widget.padding.bottom,
          ),
          child: const RenewFooterNote(text: '메뉴 항목과 가격은 매장 사정에 따라 다를 수 있습니다.'),
        ),
      ],
    );
  }

  /// 메뉴판 이미지 가로 rail — 화면 양끝까지 흐른다.
  Widget _boardRail(List<String> boards) {
    return RenewEdgeBleed(
      height: 104.r,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: RenewGlass.pagePad.w),
        itemCount: boards.length,
        separatorBuilder: (_, __) => SizedBox(width: 8.w),
        itemBuilder: (_, i) => GestureDetector(
          onTap: () =>
              VybePhotoViewer.open(context, imageUrls: boards, initialIndex: i),
          behavior: HitTestBehavior.opaque,
          child: Container(
            width: 104.r,
            height: 104.r,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14.r),
              border: Border.all(color: RenewGlass.tileBorder),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(13.r),
              child: SkeletonImage(url: boards[i], fit: BoxFit.cover),
            ),
          ),
        ),
      ),
    );
  }

  Widget _chipBar(List<String> categories) {
    return RenewBar(
      padding: EdgeInsets.symmetric(vertical: 10.h),
      child: SizedBox(
        height: 34.h,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          padding: EdgeInsets.symmetric(horizontal: RenewGlass.pagePad.w),
          itemCount: categories.length,
          separatorBuilder: (_, __) => SizedBox(width: 8.w),
          itemBuilder: (_, i) => RenewChip(
            label: categories[i],
            selected: categories[i] == _active,
            onTap: () => _goTo(categories[i]),
          ),
        ),
      ),
    );
  }

  Widget _section(String title, List<MenuModel> menus, {required bool first}) {
    return Container(
      key: _sectionKeys[title],
      margin: EdgeInsets.only(top: first ? 0 : 20.h),
      padding: EdgeInsets.fromLTRB(
        widget.padding.left,
        first ? 0 : 20.h,
        widget.padding.right,
        0,
      ),
      decoration: BoxDecoration(
        border: first
            ? null
            : const Border(top: BorderSide(color: RenewGlass.hair)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          RenewSectionHead(title: title),
          RenewMenuRows(menus: menus),
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
