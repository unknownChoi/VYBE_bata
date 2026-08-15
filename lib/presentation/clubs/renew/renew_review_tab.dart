import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vybe/core/utils/gradient_palette.dart';
import 'package:vybe/data/models/review_model.dart';
import 'package:vybe/design_system/colors.dart';
import 'package:vybe/design_system/typography.dart';
import 'package:vybe/presentation/clubs/review_write_screen.dart';
import 'package:vybe/presentation/clubs/viewmodels/review_viewmodel.dart';
import 'package:vybe/presentation/common/renew/renew_button.dart';
import 'package:vybe/presentation/common/renew/renew_glass.dart';
import 'package:vybe/presentation/common/widgets/vybe_photo_viewer.dart';
import 'package:vybe/presentation/common/widgets/vybe_skeleton.dart';
import 'package:vybe/presentation/common/widgets/vybe_spinner.dart';
import 'package:vybe/presentation/common/widgets/vybe_toast.dart';

/// 리뷰 정렬 기준 (디자인 최신순 · 평점순 · 사진).
enum _ReviewSort { latest, rating, photo }

/// 클럽 상세 리뉴얼 · 리뷰 탭.
///
/// 디자인 VRReviewTab — 평점 요약 → 리뷰 작성(라임) → 정렬 칩 → 리뷰 카드 →
/// 5개씩 더 보기.
class RenewReviewTab extends ConsumerStatefulWidget {
  final String clubId;
  final EdgeInsets padding;

  const RenewReviewTab({
    super.key,
    required this.clubId,
    required this.padding,
  });

  @override
  ConsumerState<RenewReviewTab> createState() => _RenewReviewTabState();
}

class _RenewReviewTabState extends ConsumerState<RenewReviewTab> {
  _ReviewSort _sort = _ReviewSort.latest;
  int _shown = _pageSize;

  static const int _pageSize = 5;

  /// 아바타 배경 (디자인 VRT_REVIEWS `av` 그라데이션).
  static const _avatars = <List<Color>>[
    [VybeColors.mainPurple500, Color(0xFFC04BD0)],
    [VybeColors.accentBlue500, Color(0xFF3F8FD0)],
    [Color(0xFF25503A), Color(0xFF7FC06A)],
    [Color(0xFF6B2233), Color(0xFFD0644B)],
    [Color(0xFF1B1030), Color(0xFF5A2B9E)],
    [Color(0xFF2C3E50), Color(0xFF0A0A1F)],
    [Color(0xFFFF4D8D), VybeColors.mainPurple500],
    [Color(0xFFFB5607), Color(0xFFFFBE0B)],
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

    return reviewsAsync.when(
      loading: () => const Center(child: VybeSpinner(size: 40)),
      error: (_, __) =>
          Center(child: Text('리뷰를 불러올 수 없어요', style: RenewGlass.body())),
      data: _buildList,
    );
  }

  Widget _buildList(List<ReviewModel> reviews) {
    final sorted = _sorted(reviews);
    final visible = sorted.take(_shown).toList();
    final more = sorted.length - visible.length;

    return ListView(
      physics: const ClampingScrollPhysics(),
      padding: widget.padding,
      children: [
        if (reviews.isNotEmpty) ...[_summary(reviews), SizedBox(height: 16.h)],
        RenewButton(
          label: '리뷰 작성하기',
          icon: Icons.edit_outlined,
          variant: RenewButtonVariant.lime,
          onTap: _openWritePage,
        ),
        SizedBox(height: 16.h),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '리뷰 ${sorted.length}',
              style: RenewGlass.body(
                color: RenewGlass.t1,
                weight: FontWeight.w600,
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
        SizedBox(height: 16.h),
        if (visible.isEmpty)
          Padding(
            padding: EdgeInsets.symmetric(vertical: 28.h),
            child: Center(
              child: Text(
                _sort == _ReviewSort.photo ? '사진이 있는 리뷰가 없어요' : '첫 리뷰를 남겨주세요',
                style: RenewGlass.body(),
              ),
            ),
          )
        else
          for (var i = 0; i < visible.length; i++)
            Padding(
              padding: EdgeInsets.only(bottom: 12.h),
              child: _reviewCard(visible[i]),
            ),
        if (visible.isNotEmpty)
          Padding(
            padding: EdgeInsets.only(top: 4.h),
            child: RenewMoreButton(
              label: more > 0 ? '리뷰 $more개 더 보기' : '모든 리뷰를 봤어요',
              onTap: more > 0
                  ? () => setState(() => _shown += _pageSize)
                  : null,
            ),
          ),
      ],
    );
  }

  // ==========================================================================
  // 평점 요약 (VRReviewSummary)
  // ==========================================================================

  Widget _summary(List<ReviewModel> reviews) {
    final total = reviews.length;
    final avg = reviews.map((r) => r.rating).reduce((a, b) => a + b) / total;
    // 0.5 단위 별점이라 반올림해 정수 버킷(5~1)에 담는다.
    final dist = [5, 4, 3, 2, 1]
        .map(
          (s) => (
            star: s,
            count: reviews.where((r) => r.rating.round() == s).length,
          ),
        )
        .toList();

    return RenewGlassCard(
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
                      style: VybeTypography.heading2.copyWith(
                        color: RenewGlass.t1,
                      ),
                    ),
                    SizedBox(width: 2.w),
                    Text('/5', style: RenewGlass.body()),
                  ],
                ),
                SizedBox(height: 5.h),
                RenewStarRow(rating: avg),
                SizedBox(height: 5.h),
                Text('방문자 $total명', style: RenewGlass.caption()),
              ],
            ),
          ),
          SizedBox(width: 20.w),
          Expanded(
            child: Column(
              children: [
                for (final d in dist)
                  Padding(
                    padding: EdgeInsets.only(bottom: d.star == 1 ? 0 : 5.h),
                    child: Row(
                      children: [
                        SizedBox(
                          width: 10.w,
                          child: Text(
                            '${d.star}',
                            style: RenewGlass.caption(
                              color: RenewGlass.t3,
                              lineHeight: 14,
                            ),
                          ),
                        ),
                        SizedBox(width: 8.w),
                        Expanded(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(99.r),
                            child: LinearProgressIndicator(
                              value: total == 0 ? 0 : d.count / total,
                              minHeight: 5.h,
                              backgroundColor: const Color(0x1AFFFFFF),
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
                            style: RenewGlass.caption(lineHeight: 14),
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================================================
  // 리뷰 카드
  // ==========================================================================

  Widget _reviewCard(ReviewModel r) {
    final date =
        '${r.createdAt.year}.${r.createdAt.month.toString().padLeft(2, '0')}'
        '.${r.createdAt.day.toString().padLeft(2, '0')}';
    final name = r.userName.isNotEmpty ? r.userName : '익명';
    // 디자인 아바타는 그라데이션 원. 실제 유저는 구분이 필요해 첫 글자를 얹는다.
    final gradient = gradientForKey(_avatars, r.userId);

    return RenewGlassCard(
      quiet: true,
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
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: gradient,
                  ),
                ),
                child: Text(
                  name.characters.first,
                  style: RenewGlass.body(
                    color: Colors.white,
                    weight: FontWeight.w600,
                  ),
                ),
              ),
              SizedBox(width: 8.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: RenewGlass.body(
                        color: RenewGlass.t1,
                        weight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: 3.h),
                    RenewStarRow(rating: r.rating, size: 10),
                  ],
                ),
              ),
              SizedBox(width: 8.w),
              Text(date, style: RenewGlass.caption(lineHeight: 14)),
            ],
          ),
          SizedBox(height: 12.h),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(r.content, style: RenewGlass.body(lineHeight: 21)),
              ),
              if (r.imageUrls.isNotEmpty) ...[
                SizedBox(width: 12.w),
                _reviewPhoto(r.imageUrls),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _reviewPhoto(List<String> urls) {
    return GestureDetector(
      onTap: () => VybePhotoViewer.open(context, imageUrls: urls),
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 72.r,
        height: 72.r,
        child: Stack(
          fit: StackFit.expand,
          children: [
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(color: RenewGlass.tileBorder),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(11.r),
                child: SkeletonImage(url: urls.first, fit: BoxFit.cover),
              ),
            ),
            // 여러 장이면 몇 장 더 있는지 알려준다 (디자인 목업은 1장 기준).
            if (urls.length > 1)
              Positioned(
                right: 5.r,
                bottom: 5.r,
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                  decoration: BoxDecoration(
                    color: const Color(0x9E000000),
                    borderRadius: BorderRadius.circular(999.r),
                  ),
                  child: Text(
                    '+${urls.length - 1}',
                    style: RenewGlass.caption(
                      color: Colors.white,
                      size: 10,
                      lineHeight: 12,
                      weight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  // ==========================================================================
  // 정렬 · 작성
  // ==========================================================================

  Widget _sortChip(String label, _ReviewSort sort) {
    final selected = _sort == sort;
    return GestureDetector(
      onTap: () => _pickSort(sort),
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 11.w, vertical: 5.h),
        decoration: BoxDecoration(
          color: selected ? RenewGlass.tileFill : Colors.transparent,
          borderRadius: BorderRadius.circular(999.r),
          border: Border.all(
            color: selected ? RenewGlass.tileBorder : Colors.transparent,
          ),
        ),
        child: Text(
          label,
          style: RenewGlass.caption(
            color: selected ? RenewGlass.t1 : RenewGlass.t3,
            lineHeight: 14,
            weight: selected ? FontWeight.w600 : FontWeight.w400,
          ),
        ),
      ),
    );
  }

  List<ReviewModel> _sorted(List<ReviewModel> reviews) {
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
}
