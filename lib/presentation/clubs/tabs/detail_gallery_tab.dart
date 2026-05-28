import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:vybe/design_system/colors.dart';

class DetailGalleryTab extends StatefulWidget {
  const DetailGalleryTab({super.key});

  @override
  State<DetailGalleryTab> createState() => _DetailGalleryTabState();
}

class _DetailGalleryTabState extends State<DetailGalleryTab> {
  int _selectedCategoryIndex = 0;

  static const _categories = [
    ('전체', 32),
    ('업체', 8),
    ('음식', 14),
    ('내부', 10),
  ];

  static const List<String> _images = [
    'assets/club_detail/images/image_tab_image_1.png',
    'assets/club_detail/images/image_tab_image_2.png',
    'assets/club_detail/images/image_tab_image_3.png',
    'assets/club_detail/images/image_tab_image_4.png',
    'assets/club_detail/images/home_tab_image_1.jpg',
    'assets/club_detail/images/home_tab_image_2.png',
    'assets/club_detail/images/home_tab_image_3.png',
    'assets/club_detail/images/menu_image.png',
  ];

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      physics: const ClampingScrollPhysics(),
      slivers: [
        SliverToBoxAdapter(
          child: Container(
            padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 12.h),
            decoration: BoxDecoration(
              border:
                  Border(bottom: BorderSide(color: VybeColors.gray900)),
            ),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children:
                    List.generate(_categories.length, (i) {
                  final selected = i == _selectedCategoryIndex;
                  final (label, count) = _categories[i];
                  return Padding(
                    padding: EdgeInsets.only(right: 8.w),
                    child: GestureDetector(
                      onTap: () =>
                          setState(() => _selectedCategoryIndex = i),
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
                          '$label $count',
                          style: TextStyle(
                            fontFamily: 'Pretendard',
                            fontSize: 13.sp,
                            fontWeight: selected
                                ? FontWeight.w600
                                : FontWeight.w500,
                            color: selected
                                ? Colors.white
                                : VybeColors.gray400,
                          ),
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ),
          ),
        ),
        SliverPadding(
          padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 0),
          sliver: SliverMasonryGrid.count(
            crossAxisCount: 2,
            mainAxisSpacing: 8,
            crossAxisSpacing: 8,
            childCount: _images.length,
            itemBuilder: (context, index) {
              final isEven = index % 2 == 0;
              return ClipRRect(
                borderRadius: BorderRadius.circular(6.r),
                child: Image.asset(
                  _images[index],
                  width: double.infinity,
                  height: isEven ? 180.h : 130.h,
                  fit: BoxFit.cover,
                ),
              );
            },
          ),
        ),
        SliverToBoxAdapter(child: SizedBox(height: 32.h)),
      ],
    );
  }
}
