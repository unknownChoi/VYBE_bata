import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:vybe/design_system/colors.dart';
import 'package:vybe/presentation/clubs/viewmodels/club_detail_viewmodel.dart';
import 'package:vybe/presentation/common/widgets/vybe_skeleton.dart';

class DetailGalleryTab extends ConsumerStatefulWidget {
  final String clubId;
  const DetailGalleryTab({super.key, required this.clubId});

  @override
  ConsumerState<DetailGalleryTab> createState() => _DetailGalleryTabState();
}

class _DetailGalleryTabState extends ConsumerState<DetailGalleryTab> {
  int _selectedCategoryIndex = 0;

  static const _categories = ['전체', '업체', '음식', '내부'];

  @override
  Widget build(BuildContext context) {
    final clubAsync = ref.watch(clubDetailProvider(widget.clubId));
    final images = clubAsync.value?.imageUrls ?? [];
    final total = images.length;

    return CustomScrollView(
      physics: const ClampingScrollPhysics(),
      slivers: [
        SliverToBoxAdapter(
          child: Container(
            padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 12.h),
            decoration: BoxDecoration(
              border: Border(bottom: BorderSide(color: VybeColors.gray900)),
            ),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: List.generate(_categories.length, (i) {
                  final selected = i == _selectedCategoryIndex;
                  final label = _categories[i];
                  final count = i == 0 ? total : 0;
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
                          count > 0 ? '$label $count' : label,
                          style: TextStyle(
                            fontFamily: 'Pretendard',
                            fontSize: 13.sp,
                            fontWeight:
                                selected ? FontWeight.w600 : FontWeight.w500,
                            color:
                                selected ? Colors.white : VybeColors.gray400,
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
        if (clubAsync.isLoading)
          const SliverToBoxAdapter(child: PhotosTabSkeleton())
        else if (images.isEmpty)
          SliverFillRemaining(
            child: Center(
              child: Text(
                '사진이 없어요',
                style: TextStyle(
                  fontFamily: 'Pretendard',
                  fontSize: 14.sp,
                  color: VybeColors.gray500,
                ),
              ),
            ),
          )
        else
          SliverPadding(
            padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 0),
            sliver: SliverMasonryGrid.count(
              crossAxisCount: 2,
              mainAxisSpacing: 8,
              crossAxisSpacing: 8,
              childCount: images.length,
              itemBuilder: (context, index) {
                final isEven = index % 2 == 0;
                return ClipRRect(
                  borderRadius: BorderRadius.circular(6.r),
                  child: Image.network(
                    images[index],
                    width: double.infinity,
                    height: isEven ? 180.h : 130.h,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      height: isEven ? 180.h : 130.h,
                      color: VybeColors.gray800,
                    ),
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
