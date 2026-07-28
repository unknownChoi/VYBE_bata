import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:vybe/data/models/photo_model.dart';
import 'package:vybe/presentation/clubs/viewmodels/club_detail_viewmodel.dart';
import 'package:vybe/presentation/clubs/widgets/club_glass.dart';
import 'package:vybe/presentation/common/widgets/vybe_photo_viewer.dart';
import 'package:vybe/presentation/common/widgets/vybe_skeleton.dart';

/// 클럽 상세 · 사진 탭 (리퀴드 글래스).
///
/// 디자인 club_glass_tabs.jsx(CGPhotoMasonry) — sticky 필터 칩(개수 포함) +
/// 2열 벽돌 매스너리 + 12장씩 더 보기.
class DetailGalleryTab extends ConsumerStatefulWidget {
  final String clubId;
  const DetailGalleryTab({super.key, required this.clubId});

  @override
  ConsumerState<DetailGalleryTab> createState() => _DetailGalleryTabState();
}

class _DetailGalleryTabState extends ConsumerState<DetailGalleryTab> {
  /// null = 전체, 그 외 = 해당 카테고리 필터.
  PhotoCategory? _selected;

  /// 한 번에 보여줄 장수 (디자인 12장 단위).
  int _shown = _pageSize;

  static const int _pageSize = 12;

  /// 매스너리 높이 패턴 — 네트워크 이미지의 원본 비율을 모르므로
  /// 디자인(CG_PHOTO_DATA)의 높이 리듬을 순환시켜 벽돌 느낌을 낸다.
  static const List<double> _heightPattern = [
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
  ];

  void _pick(PhotoCategory? category) {
    setState(() {
      _selected = category;
      _shown = _pageSize;
    });
  }

  @override
  Widget build(BuildContext context) {
    final photosAsync = ref.watch(clubPhotosProvider(widget.clubId));

    if (photosAsync.isLoading) {
      return ListView(
        physics: const ClampingScrollPhysics(),
        padding: glassTabPadding(context),
        children: const [PhotosTabSkeleton()],
      );
    }

    final photos = photosAsync.value ?? const <PhotoModel>[];
    if (photos.isEmpty) {
      return Center(
        child: Text('등록된 사진이 없어요', style: ClubGlass.body(color: ClubGlass.t4)),
      );
    }

    final filtered = _selected == null
        ? photos
        : photos.where((p) => p.category == _selected).toList();
    final visible = filtered.take(_shown).toList();
    final more = filtered.length - visible.length;

    // 필터 바는 탭 상단 고정. sticky를 pinned SliverPersistentHeader로 만들면
    // Flutter 3.41 세만틱스 검증이 매 프레임 assert를 던져 화면이 안 그려진다
    // (club_detail_screen 주석 참고) — 그래서 스크롤 밖 고정 행으로 뺐다.
    return Column(
      children: [
        _PhotoFilterBar(photos: photos, selected: _selected, onSelect: _pick),
        Expanded(
          child: CustomScrollView(
            physics: const ClampingScrollPhysics(),
            slivers: [
              SliverPadding(
                padding: EdgeInsets.fromLTRB(16.w, 14.h, 16.w, 0),
                sliver: SliverMasonryGrid.count(
                  crossAxisCount: 2,
                  mainAxisSpacing: 8.h,
                  crossAxisSpacing: 8.w,
                  childCount: visible.length,
                  itemBuilder: (_, i) => _photoTile(visible, i),
                ),
              ),
              SliverPadding(
                padding: EdgeInsets.fromLTRB(16.w, 14.h, 16.w, 28.h),
                sliver: SliverToBoxAdapter(
                  child: GlassMoreButton(
                    label: more > 0 ? '사진 $more장 더 보기' : '모든 사진을 봤어요',
                    onTap: more > 0
                        ? () => setState(() => _shown += _pageSize)
                        : null,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _photoTile(List<PhotoModel> visible, int index) {
    return GestureDetector(
      onTap: () => VybePhotoViewer.open(
        context,
        imageUrls: visible.map((p) => p.url).toList(),
        initialIndex: index,
      ),
      behavior: HitTestBehavior.opaque,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(14.r),
        child: SizedBox(
          height: _heightPattern[index % _heightPattern.length].h,
          child: SkeletonImage(url: visible[index].url, fit: BoxFit.cover),
        ),
      ),
    );
  }
}

// ============================================================================
// STICKY FILTER BAR
// ============================================================================

class _PhotoFilterBar extends StatelessWidget {
  final List<PhotoModel> photos;
  final PhotoCategory? selected;
  final ValueChanged<PhotoCategory?> onSelect;

  const _PhotoFilterBar({
    required this.photos,
    required this.selected,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    // 전체 + 카테고리별. 개수가 0인 카테고리는 칩 자체를 숨긴다.
    final entries = <(PhotoCategory?, String, int)>[
      (null, '전체', photos.length),
      for (final c in PhotoCategory.values)
        (c, c.label, photos.where((p) => p.category == c).length),
    ].where((e) => e.$1 == null || e.$3 > 0).toList();

    return GlassBar(
      padding: EdgeInsets.symmetric(vertical: 10.h),
      child: SizedBox(
        height: 34.h,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          itemCount: entries.length,
          separatorBuilder: (_, __) => SizedBox(width: 8.w),
          itemBuilder: (_, i) => GlassFilterChip(
            label: '${entries[i].$2} ${entries[i].$3}',
            selected: entries[i].$1 == selected,
            onTap: () => onSelect(entries[i].$1),
          ),
        ),
      ),
    );
  }
}
