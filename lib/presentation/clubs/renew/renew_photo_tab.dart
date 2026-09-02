import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:vybe/data/models/photo_model.dart';
import 'package:vybe/presentation/clubs/renew/widgets/renew_sticky_bar.dart';
import 'package:vybe/presentation/clubs/viewmodels/club_detail_viewmodel.dart';
import 'package:vybe/presentation/clubs/renew/widgets/renew_skeleton.dart';
import 'package:vybe/presentation/common/renew/renew_button.dart';
import 'package:vybe/presentation/common/renew/renew_glass.dart';
import 'package:vybe/presentation/common/widgets/vybe_photo_viewer.dart';
import 'package:vybe/presentation/common/widgets/vybe_skeleton.dart';

/// 클럽 상세 리뉴얼 · 사진 탭.
///
/// 디자인 VRPhotoTab — sticky 카테고리 칩(개수 포함) + 2열 매스너리 +
/// 12장씩 더 보기.
class RenewPhotoTab extends ConsumerStatefulWidget {
  final String clubId;

  /// 탭 콘텐츠 패딩 (좌우 24, 하단은 액션 바 높이만큼 확보).
  final EdgeInsets padding;

  const RenewPhotoTab({super.key, required this.clubId, required this.padding});

  @override
  ConsumerState<RenewPhotoTab> createState() => _RenewPhotoTabState();
}

class _RenewPhotoTabState extends ConsumerState<RenewPhotoTab> {
  /// null = 전체.
  PhotoCategory? _filter;
  int _shown = _pageSize;

  static const int _pageSize = 12;

  /// 매스너리 높이 리듬 (디자인 VRT_PHOTO_DATA). 네트워크 이미지의 원본 비율을
  /// 모르므로 디자인 높이를 순환시켜 벽돌 느낌을 낸다.
  static const List<double> _heights = [
    262,
    180,
    180,
    180,
    220,
    180,
    270,
    180,
    200,
    220,
    180,
    200,
    240,
    180,
    200,
    260,
    180,
    220,
    200,
    180,
    240,
    200,
    280,
    180,
    220,
    200,
    180,
    240,
    200,
    220,
    180,
    200,
  ];

  void _pick(PhotoCategory? category) {
    setState(() {
      _filter = category;
      _shown = _pageSize;
    });
  }

  @override
  Widget build(BuildContext context) {
    final photosAsync = ref.watch(clubPhotosProvider(widget.clubId));

    if (photosAsync.isLoading) {
      return RenewPhotoSkeleton(padding: widget.padding);
    }

    final photos = photosAsync.value ?? const <PhotoModel>[];
    if (photos.isEmpty) {
      return Center(child: Text('등록된 사진이 없어요', style: RenewGlass.body()));
    }

    final filtered = _filter == null
        ? photos
        : photos.where((p) => p.category == _filter).toList();
    final visible = filtered.take(_shown).toList();
    final more = filtered.length - visible.length;

    return RenewStickyBarHost(
      // 고정될 때만 불투명 — 스크롤 안의 원본은 배경 없이 오로라를 통과시킨다.
      bar: _filterBar(photos, floating: true),
      scrollBuilder: (barKey) => CustomScrollView(
        physics: const ClampingScrollPhysics(),
        slivers: [
          SliverToBoxAdapter(child: SizedBox(height: widget.padding.top)),
          SliverToBoxAdapter(
            child: KeyedSubtree(key: barKey, child: _filterBar(photos)),
          ),
          SliverPadding(
            padding: EdgeInsets.fromLTRB(
              widget.padding.left,
              16.h,
              widget.padding.right,
              0,
            ),
            sliver: SliverMasonryGrid.count(
              crossAxisCount: 2,
              mainAxisSpacing: 8.h,
              crossAxisSpacing: 8.w,
              childCount: visible.length,
              itemBuilder: (_, i) => _tile(visible, i),
            ),
          ),
          SliverPadding(
            padding: EdgeInsets.fromLTRB(
              widget.padding.left,
              16.h,
              widget.padding.right,
              widget.padding.bottom,
            ),
            sliver: SliverToBoxAdapter(
              child: RenewMoreButton(
                label: more > 0 ? '사진 $more장 더 보기' : '모든 사진을 봤어요',
                onTap: more > 0
                    ? () => setState(() => _shown += _pageSize)
                    : null,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _filterBar(List<PhotoModel> photos, {bool floating = false}) {
    // 전체 + 카테고리별. 0장인 카테고리는 칩 자체를 숨긴다.
    final entries = <(PhotoCategory?, String, int)>[
      (null, '전체', photos.length),
      for (final c in PhotoCategory.values)
        (c, c.label, photos.where((p) => p.category == c).length),
    ].where((e) => e.$1 == null || e.$3 > 0).toList();

    return RenewBar(
      fill: floating ? RenewGlass.barFill : Colors.transparent,
      padding: EdgeInsets.symmetric(vertical: 10.h),
      child: SizedBox(
        height: 34.h,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          padding: EdgeInsets.symmetric(horizontal: RenewGlass.pagePad.w),
          itemCount: entries.length,
          separatorBuilder: (_, __) => SizedBox(width: 8.w),
          itemBuilder: (_, i) => RenewChip(
            label: '${entries[i].$2} ${entries[i].$3}',
            selected: entries[i].$1 == _filter,
            onTap: () => _pick(entries[i].$1),
          ),
        ),
      ),
    );
  }

  Widget _tile(List<PhotoModel> visible, int index) {
    return GestureDetector(
      onTap: () => VybePhotoViewer.open(
        context,
        imageUrls: visible.map((p) => p.url).toList(),
        initialIndex: index,
      ),
      behavior: HitTestBehavior.opaque,
      child: Container(
        height: _heights[index % _heights.length].h,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14.r),
          border: Border.all(color: RenewGlass.tileBorder),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(13.r),
          child: SkeletonImage(url: visible[index].url, fit: BoxFit.cover),
        ),
      ),
    );
  }
}
