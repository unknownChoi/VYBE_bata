import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vybe/data/models/menu_model.dart';
import 'package:vybe/design_system/colors.dart';
import 'package:vybe/presentation/clubs/viewmodels/club_detail_viewmodel.dart';
import 'package:vybe/presentation/common/widgets/vybe_skeleton.dart';

class DetailMenuTab extends ConsumerStatefulWidget {
  final String clubId;
  const DetailMenuTab({super.key, required this.clubId});

  @override
  ConsumerState<DetailMenuTab> createState() => _DetailMenuTabState();
}

class _DetailMenuTabState extends ConsumerState<DetailMenuTab> {
  int _selectedCategoryIndex = 0;

  static const _categoryOrder = [
    '대표메뉴',
    'SET',
    'HARD',
    'CHAMPAGNE',
    'BEER',
    'COCKTAIL',
  ];


  @override
  Widget build(BuildContext context) {
    final clubAsync = ref.watch(clubDetailProvider(widget.clubId));
    final menusAsync = ref.watch(clubMenusProvider(widget.clubId));

    if (menusAsync.isLoading || clubAsync.isLoading) {
      return const SingleChildScrollView(
        physics: ClampingScrollPhysics(),
        child: MenuTabSkeleton(),
      );
    }
    if (menusAsync.hasError) {
      return Center(
        child: Text(
          '메뉴를 불러올 수 없어요',
          style: TextStyle(
            fontFamily: 'Pretendard',
            fontSize: 14.sp,
            color: VybeColors.gray500,
          ),
        ),
      );
    }

    final menus = menusAsync.value ?? [];
    final boardImages = clubAsync.value?.menuBoardUrls ?? [];
    final groups = _buildGroups(menus);
    final categories = _categoryOrder.where(groups.containsKey).toList();

    return ListView(
      physics: const ClampingScrollPhysics(),
      padding: EdgeInsets.zero,
      children: [
        if (boardImages.isNotEmpty) _buildImageSection(boardImages),
        Container(height: 2, color: VybeColors.gray900),
        _buildCategoryChips(categories),
        _buildMenuSections(groups, categories),
        SizedBox(height: 32.h),
      ],
    );
  }

  Map<String, List<MenuModel>> _buildGroups(List<MenuModel> menus) {
    final groups = <String, List<MenuModel>>{};
    for (final cat in _categoryOrder) {
      final items = menus.where((m) => m.category == cat).toList();
      if (items.isNotEmpty) groups[cat] = items;
    }
    return groups;
  }

  Widget _buildImageSection(List<String> boardImages) {
    return Padding(
      padding: EdgeInsets.only(top: 24.h, bottom: 28.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w),
            child: Text(
              '메뉴 이미지',
              style: TextStyle(
                fontFamily: 'Pretendard',
                fontSize: 18.sp,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),
          SizedBox(height: 16.h),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.symmetric(horizontal: 20.w),
            child: Row(
              children: boardImages.map((url) {
                return Padding(
                  padding: EdgeInsets.only(right: 8.w),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8.r),
                    child: Image.network(
                      url,
                      width: 121.r,
                      height: 121.r,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        width: 121.r,
                        height: 121.r,
                        color: VybeColors.gray800,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryChips(List<String> categories) {
    return Container(
      padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 12.h),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: VybeColors.gray900)),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: List.generate(categories.length, (i) {
            final selected = i == _selectedCategoryIndex;
            return Padding(
              padding: EdgeInsets.only(right: 8.w),
              child: GestureDetector(
                onTap: () => setState(() => _selectedCategoryIndex = i),
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 14.w,
                    vertical: 7.h,
                  ),
                  decoration: BoxDecoration(
                    color: selected
                        ? VybeColors.mainPurple700
                        : VybeColors.gray800,
                    borderRadius: BorderRadius.circular(999.r),
                  ),
                  child: Text(
                    categories[i],
                    style: TextStyle(
                      fontFamily: 'Pretendard',
                      fontSize: 13.sp,
                      fontWeight:
                          selected ? FontWeight.w600 : FontWeight.w500,
                      color: selected ? Colors.white : VybeColors.gray400,
                    ),
                  ),
                ),
              ),
            );
          }),
        ),
      ),
    );
  }

  Widget _buildMenuSections(
    Map<String, List<MenuModel>> groups,
    List<String> categories,
  ) {
    return Padding(
      padding: EdgeInsets.fromLTRB(20.w, 8.h, 20.w, 24.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ...categories.map((cat) {
            return Padding(
              padding: EdgeInsets.only(top: 16.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    cat,
                    style: TextStyle(
                      fontFamily: 'Pretendard',
                      fontSize: 18.sp,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 16.h),
                  ...groups[cat]!.map((item) => _MenuItemWidget(item: item)),
                  Container(height: 1, color: VybeColors.gray800),
                ],
              ),
            );
          }),
          SizedBox(height: 12.h),
          Text(
            '메뉴 항목과 가격은 각 매장 사정에 따라 기재된 내용과 다를 수 있습니다.',
            style: TextStyle(
              fontFamily: 'Pretendard',
              fontSize: 12.sp,
              color: VybeColors.gray500,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}

class _MenuItemWidget extends StatelessWidget {
  final MenuModel item;
  const _MenuItemWidget({required this.item});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 16.h),
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: VybeColors.gray800)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    if (item.isFeatured) ...[
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 7.w,
                          vertical: 2.h,
                        ),
                        decoration: BoxDecoration(
                          color: VybeColors.mainPurple500,
                          borderRadius: BorderRadius.circular(999.r),
                        ),
                        child: Text(
                          '대표',
                          style: TextStyle(
                            fontFamily: 'Pretendard',
                            fontSize: 10.sp,
                            fontWeight: FontWeight.w500,
                            color: VybeColors.gray200,
                          ),
                        ),
                      ),
                      SizedBox(width: 6.w),
                    ],
                    Text(
                      item.name,
                      style: TextStyle(
                        fontFamily: 'Pretendard',
                        fontSize: 14.sp,
                        color: VybeColors.gray200,
                      ),
                    ),
                  ],
                ),
                if (item.description.isNotEmpty) ...[
                  SizedBox(height: 6.h),
                  Text(
                    item.description,
                    style: TextStyle(
                      fontFamily: 'Pretendard',
                      fontSize: 12.sp,
                      color: VybeColors.gray500,
                    ),
                  ),
                ],
                SizedBox(height: 10.h),
                Text(
                  '${_formatPrice(item.price)}원',
                  style: TextStyle(
                    fontFamily: 'Pretendard',
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          if (item.imageUrl.isNotEmpty) ...[
            SizedBox(width: 16.w),
            ClipRRect(
              borderRadius: BorderRadius.circular(6.r),
              child: Image.network(
                item.imageUrl,
                width: 100.r,
                height: 100.r,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) =>
                    SizedBox(width: 100.r, height: 100.r),
              ),
            ),
          ],
        ],
      ),
    );
  }

  String _formatPrice(int price) {
    return price.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (m) => '${m[1]},',
    );
  }
}
