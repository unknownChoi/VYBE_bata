import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:vybe/data/models/photo_model.dart';
import 'package:vybe/design_system/colors.dart';
import 'package:vybe/presentation/clubs/viewmodels/club_detail_viewmodel.dart';
import 'package:vybe/presentation/common/widgets/vybe_photo_viewer.dart';
import 'package:vybe/presentation/common/widgets/vybe_skeleton.dart';

class DetailGalleryTab extends ConsumerStatefulWidget {
  final String clubId;
  const DetailGalleryTab({super.key, required this.clubId});

  @override
  ConsumerState<DetailGalleryTab> createState() => _DetailGalleryTabState();
}

class _DetailGalleryTabState extends ConsumerState<DetailGalleryTab> {
  // null = 전체, 그 외 = 해당 카테고리 필터
  PhotoCategory? _selected;

  @override
  Widget build(BuildContext context) {
    final photosAsync = ref.watch(clubPhotosProvider(widget.clubId));
    final photos = photosAsync.value ?? [];

    // 선택 카테고리로 필터
    final filtered = _selected == null
        ? photos
        : photos.where((p) => p.category == _selected).toList();

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
                children: [
                  _chip(label: '전체', count: photos.length, category: null),
                  ...PhotoCategory.values.map((c) {
                    final count = photos.where((p) => p.category == c).length;
                    return _chip(label: c.label, count: count, category: c);
                  }),
                ],
              ),
            ),
          ),
        ),
        if (photosAsync.isLoading)
          const SliverToBoxAdapter(child: PhotosTabSkeleton())
        else if (filtered.isEmpty)
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
              childCount: filtered.length,
              itemBuilder: (context, index) {
                final isEven = index % 2 == 0;
                return GestureDetector(
                  onTap: () => VybePhotoViewer.open(
                    context,
                    imageUrls: filtered.map((p) => p.url).toList(),
                    initialIndex: index,
                  ),
                  child: SkeletonImage(
                    url: filtered[index].url,
                    width: double.infinity,
                    height: isEven ? 180.h : 130.h,
                    fit: BoxFit.cover,
                    borderRadius: BorderRadius.circular(6.r),
                  ),
                );
              },
            ),
          ),
        SliverToBoxAdapter(child: SizedBox(height: 32.h)),
      ],
    );
  }

  Widget _chip({
    required String label,
    required int count,
    required PhotoCategory? category,
  }) {
    final selected = category == _selected;
    return Padding(
      padding: EdgeInsets.only(right: 8.w),
      child: GestureDetector(
        onTap: () => setState(() => _selected = category),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 7.h),
          decoration: BoxDecoration(
            color: selected ? VybeColors.mainPurple700 : VybeColors.gray800,
            borderRadius: BorderRadius.circular(999.r),
          ),
          child: Text(
            count > 0 ? '$label $count' : label,
            style: TextStyle(
              fontFamily: 'Pretendard',
              fontSize: 13.sp,
              fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
              color: selected ? Colors.white : VybeColors.gray400,
            ),
          ),
        ),
      ),
    );
  }
}
