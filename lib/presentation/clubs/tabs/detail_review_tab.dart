import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vybe/data/models/review_model.dart';
import 'package:vybe/design_system/colors.dart';
import 'package:vybe/presentation/clubs/review_write_screen.dart';
import 'package:vybe/presentation/clubs/viewmodels/review_viewmodel.dart';
import 'package:vybe/presentation/clubs/widgets/club_detail_skeleton.dart';
import 'package:vybe/presentation/clubs/widgets/club_glass.dart';
import 'package:vybe/presentation/common/widgets/vybe_photo_viewer.dart';
import 'package:vybe/presentation/common/widgets/vybe_skeleton.dart';
import 'package:vybe/presentation/common/widgets/vybe_toast.dart';

/// 클럽 상세 · 리뷰 탭 (리퀴드 글래스).
///
/// 디자인 club_glass.jsx(CGReviewTab) — 평점 요약 카드 → 리뷰 작성 버튼 →
/// 정렬 칩 → 리뷰 카드 → 5개씩 더 보기.
class DetailReviewTab extends ConsumerStatefulWidget {
  final String clubId;
  const DetailReviewTab({super.key, required this.clubId});

  @override
  ConsumerState<DetailReviewTab> createState() => _DetailReviewTabState();
}

enum _ReviewSort { latest, rating, photo }

class _DetailReviewTabState extends ConsumerState<DetailReviewTab> {
  _ReviewSort _sort = _ReviewSort.latest;
  int _shown = _pageSize;

  static const int _pageSize = 5;

  static const _avatarColors = [
    Color(0xFF6622CC),
    Color(0xFF3A86FF),
    Color(0xFF8338EC),
    Color(0xFFFB5607),
    Color(0xFF94CF51),
    Color(0xFFFF006E),
    Color(0xFFFFBE0B),
  ];

  void _pickSort(_ReviewSort sort) {
    setState(() {
      _sort = sort;
      _shown = _pageSize;
    });
  }

  @override
  Widget build(BuildContext context) {
    final reviewsAsync = ref.watch(reviewListProvider(widget.clubId));

    return ListView(
      physics: const ClampingScrollPhysics(),
      padding: glassTabPadding(context),
      children: [
        reviewsAsync.when(
          loading: () => const DetailReviewTabSkeleton(),
          error: (_, __) => Center(
            child: Text(
              '리뷰를 불러올 수 없어요',
              style: ClubGlass.body(color: ClubGlass.t4),
            ),
          ),
          data: _buildContent,
        ),
      ],
    );
  }

  Widget _buildContent(List<ReviewModel> reviews) {
    final sorted = _sortedReviews(reviews);
    final visible = sorted.take(_shown).toList();
    final more = sorted.length - visible.length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (reviews.isNotEmpty) ...[
          _RatingSummaryCard(reviews: reviews),
          glassGap(),
        ],
        _buildWriteButton(),
        SizedBox(height: 16.h),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '리뷰 ${sorted.length}',
              style: TextStyle(
                fontFamily: 'Pretendard',
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
            Row(
              children: [
                _sortChip('최신순', _ReviewSort.latest),
                SizedBox(width: 4.w),
                _sortChip('평점순', _ReviewSort.rating),
                SizedBox(width: 4.w),
                _sortChip('사진', _ReviewSort.photo),
              ],
            ),
          ],
        ),
        SizedBox(height: 14.h),
        if (visible.isEmpty)
          Padding(
            padding: EdgeInsets.symmetric(vertical: 28.h),
            child: Center(
              child: Text(
                _sort == _ReviewSort.photo ? '사진이 있는 리뷰가 없어요' : '첫 리뷰를 남겨주세요',
                style: ClubGlass.body(color: ClubGlass.t4),
              ),
            ),
          )
        else
          for (var i = 0; i < visible.length; i++) ...[
            _ReviewCard(
              review: visible[i],
              avatarColor: _avatarColors[i % _avatarColors.length],
            ),
            SizedBox(height: 14.h),
          ],
        if (visible.isNotEmpty)
          GlassMoreButton(
            label: more > 0 ? '리뷰 $more개 더 보기' : '모든 리뷰를 봤어요',
            onTap: more > 0 ? () => setState(() => _shown += _pageSize) : null,
          ),
      ],
    );
  }

  /// 리뷰 작성하기 — 라임 그라데이션 풀와이드 버튼.
  Widget _buildWriteButton() {
    return GestureDetector(
      onTap: _openWritePage,
      behavior: HitTestBehavior.opaque,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(vertical: 15.h),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [VybeColors.mainLime500, VybeColors.mainLime700],
          ),
          borderRadius: BorderRadius.circular(16.r),
          boxShadow: [
            BoxShadow(
              color: VybeColors.mainLime500.withValues(alpha: 0.22),
              blurRadius: 30.r,
              offset: Offset(0, 10.h),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.edit_outlined, size: 17.r, color: ClubGlass.ink),
            SizedBox(width: 8.w),
            Text(
              '리뷰 작성하기',
              style: TextStyle(
                fontFamily: 'Pretendard',
                fontSize: 16.sp,
                fontWeight: FontWeight.w700,
                color: ClubGlass.ink,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _openWritePage() async {
    final created = await ReviewWriteScreen.push(
      context,
      ref,
      clubId: widget.clubId,
    );
    // 등록 완료 안내는 작성 페이지가 아니라 돌아온 이 화면에서 띄운다.
    if (created == true && mounted) {
      VybeToast.show(context, message: '리뷰가 등록됐어요');
    }
  }

  List<ReviewModel> _sortedReviews(List<ReviewModel> reviews) {
    switch (_sort) {
      case _ReviewSort.latest:
        return List<ReviewModel>.from(reviews)
          ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
      case _ReviewSort.rating:
        return List<ReviewModel>.from(reviews)
          ..sort((a, b) => b.rating.compareTo(a.rating));
      case _ReviewSort.photo:
        return reviews.where((r) => r.imageUrls.isNotEmpty).toList()
          ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    }
  }

  Widget _sortChip(String label, _ReviewSort sort) {
    final selected = _sort == sort;
    return GestureDetector(
      onTap: () => _pickSort(sort),
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 11.w, vertical: 5.h),
        decoration: BoxDecoration(
          color: selected ? const Color(0x1FFFFFFF) : Colors.transparent,
          borderRadius: BorderRadius.circular(999.r),
          border: Border.all(
            color: selected ? const Color(0x29FFFFFF) : Colors.transparent,
          ),
        ),
        child: Text(
          label,
          style: ClubGlass.caption(
            color: selected ? Colors.white : ClubGlass.t3,
            weight: selected ? FontWeight.w700 : FontWeight.w500,
          ),
        ),
      ),
    );
  }
}

// ============================================================================
// RATING SUMMARY
// ============================================================================

class _RatingSummaryCard extends StatelessWidget {
  final List<ReviewModel> reviews;
  const _RatingSummaryCard({required this.reviews});

  @override
  Widget build(BuildContext context) {
    final total = reviews.length;
    final avg = reviews.map((r) => r.rating).reduce((a, b) => a + b) / total;

    // 0.5 단위 별점이라 반올림해서 정수 버킷(5~1)에 담는다.
    final dist = [5, 4, 3, 2, 1].map((star) {
      final count = reviews.where((r) => r.rating.round() == star).length;
      return (star: star, count: count);
    }).toList();

    return GlassCard(
      padding: 20,
      child: Row(
        children: [
          SizedBox(
            width: 78.w,
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text(
                      avg.toStringAsFixed(2),
                      style: TextStyle(
                        fontFamily: 'Pretendard',
                        fontSize: 28.sp,
                        height: 30 / 28,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                    Text('/5', style: ClubGlass.body(color: ClubGlass.t4)),
                  ],
                ),
                SizedBox(height: 5.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(5, (i) {
                    final filled = avg >= i + 1;
                    final half = !filled && avg >= i + 0.5;
                    return Icon(
                      half ? Icons.star_half_rounded : Icons.star_rounded,
                      size: 12.r,
                      color: (filled || half)
                          ? VybeColors.mainLime500
                          : const Color(0x26FFFFFF),
                    );
                  }),
                ),
                SizedBox(height: 5.h),
                Text('방문자 $total명', style: ClubGlass.caption()),
              ],
            ),
          ),
          SizedBox(width: 20.w),
          Expanded(
            child: Column(
              children: dist.map((d) {
                return Padding(
                  padding: EdgeInsets.only(bottom: d.star == 1 ? 0 : 5.h),
                  child: Row(
                    children: [
                      SizedBox(
                        width: 10.w,
                        child: Text('${d.star}', style: ClubGlass.caption()),
                      ),
                      SizedBox(width: 8.w),
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(99.r),
                          child: LinearProgressIndicator(
                            value: total == 0 ? 0 : d.count / total,
                            minHeight: 5.h,
                            backgroundColor: const Color(0x17FFFFFF),
                            valueColor: const AlwaysStoppedAnimation(
                              VybeColors.mainLime500,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 8.w),
                      SizedBox(
                        width: 14.w,
                        child: Text(
                          '${d.count}',
                          textAlign: TextAlign.right,
                          style: ClubGlass.caption(color: ClubGlass.t4),
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// REVIEW CARD
// ============================================================================

class _ReviewCard extends StatefulWidget {
  final ReviewModel review;
  final Color avatarColor;
  const _ReviewCard({required this.review, required this.avatarColor});

  @override
  State<_ReviewCard> createState() => _ReviewCardState();
}

class _ReviewCardState extends State<_ReviewCard> {
  bool _expanded = false;

  static const int _collapsedLength = 90;

  @override
  Widget build(BuildContext context) {
    final r = widget.review;
    final isLong = r.content.length > _collapsedLength;
    final collapsed = isLong && !_expanded;
    final text = collapsed
        ? '${r.content.substring(0, _collapsedLength)}...'
        : r.content;
    final date =
        '${r.createdAt.year}.${r.createdAt.month.toString().padLeft(2, '0')}'
        '.${r.createdAt.day.toString().padLeft(2, '0')}';
    final initial = r.userName.isNotEmpty ? r.userName.characters.first : '?';

    return GlassCard(
      padding: 16,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 34.r,
                height: 34.r,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: widget.avatarColor,
                  shape: BoxShape.circle,
                ),
                child: Text(
                  initial,
                  style: TextStyle(
                    fontFamily: 'Pretendard',
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ),
              SizedBox(width: 10.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      r.userName.isNotEmpty ? r.userName : '익명',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontFamily: 'Pretendard',
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: 3.h),
                    Row(
                      children: List.generate(5, (i) {
                        final filled = r.rating >= i + 1;
                        final half = !filled && r.rating >= i + 0.5;
                        return Icon(
                          half ? Icons.star_half_rounded : Icons.star_rounded,
                          size: 10.r,
                          color: (filled || half)
                              ? VybeColors.mainLime500
                              : const Color(0x26FFFFFF),
                        );
                      }),
                    ),
                  ],
                ),
              ),
              Text(date, style: ClubGlass.caption(color: ClubGlass.t4)),
            ],
          ),
          SizedBox(height: 10.h),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: isLong
                      ? () => setState(() => _expanded = !_expanded)
                      : null,
                  behavior: HitTestBehavior.opaque,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        text,
                        style: ClubGlass.body().copyWith(height: 21 / 14),
                      ),
                      if (isLong) ...[
                        SizedBox(height: 6.h),
                        Text(
                          collapsed ? '더 보기' : '접기',
                          style: ClubGlass.caption(
                            color: ClubGlass.accentLavender,
                            weight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              if (r.imageUrls.isNotEmpty) ...[
                SizedBox(width: 12.w),
                GestureDetector(
                  onTap: () =>
                      VybePhotoViewer.open(context, imageUrls: r.imageUrls),
                  behavior: HitTestBehavior.opaque,
                  child: Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12.r),
                        child: SizedBox(
                          width: 72.r,
                          height: 72.r,
                          child: SkeletonImage(
                            url: r.imageUrls.first,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      if (r.imageUrls.length > 1)
                        Positioned(
                          right: 5.r,
                          bottom: 5.r,
                          child: Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 6.w,
                              vertical: 2.h,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0x9E000000),
                              borderRadius: BorderRadius.circular(999.r),
                            ),
                            child: Text(
                              '+${r.imageUrls.length - 1}',
                              style: ClubGlass.caption(
                                color: Colors.white,
                                size: 10,
                                lineHeight: 12,
                                weight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}
