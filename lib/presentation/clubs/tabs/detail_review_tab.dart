import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vybe/data/models/review_model.dart';
import 'package:vybe/design_system/colors.dart';
import 'package:vybe/presentation/clubs/viewmodels/review_viewmodel.dart';
import 'package:vybe/presentation/common/widgets/vybe_photo_viewer.dart';
import 'package:vybe/presentation/common/widgets/vybe_skeleton.dart';

class DetailReviewTab extends ConsumerStatefulWidget {
  final String clubId;
  const DetailReviewTab({super.key, required this.clubId});

  @override
  ConsumerState<DetailReviewTab> createState() => _DetailReviewTabState();
}

class _DetailReviewTabState extends ConsumerState<DetailReviewTab> {
  int _toggleIndex = 0;
  int _sortIndex = 0;

  static const _avatarColors = [
    Color(0xFF6622CC),
    Color(0xFF3A86FF),
    Color(0xFF8338EC),
    Color(0xFFFB5607),
    Color(0xFF94CF51),
    Color(0xFFFF006E),
    Color(0xFFFFBE0B),
  ];

  static const List<_BlogData> _blogs = [
    _BlogData(
      blogger: '클럽 탐험가',
      subtitle: 'NAVER 블로그',
      date: '2025.06.10',
      title: '홍대에서 입문자가 가기 좋은 클럽 TOP 5',
      preview: '어썸 레드는 입장료가 무료라서 처음 클럽에 가는 사람도 부담 없이 즐길 수 있는 곳이다...',
      cover: 'assets/club_detail/images/home_tab_image_1.jpg',
    ),
    _BlogData(
      blogger: '주말의기록',
      subtitle: 'Tistory',
      date: '2025.06.02',
      title: '어썸 레드 방문 후기 - 힙합 좋아하는 사람 모여라',
      preview: '드디어 다녀온 어썸 레드! 디제이 셀렉이 정말 취향 저격이었다. 입장하자마자...',
      cover: 'assets/club_detail/images/home_tab_image_2.png',
    ),
    _BlogData(
      blogger: 'night_seoul',
      subtitle: 'Instagram',
      date: '2025.05.20',
      title: '홍대 클럽 어썸 레드 솔직 후기',
      preview: '오늘은 홍대에 새로 생긴 클럽 어썸 레드에 다녀왔어요. 분위기 짱이고 음악이...',
      cover: 'assets/club_detail/images/image_tab_image_1.png',
    ),
    _BlogData(
      blogger: '서울나잇라이프',
      subtitle: 'NAVER 블로그',
      date: '2025.05.15',
      title: '입장료 없는 홍대 클럽 추천 BEST 3',
      preview: '주말 밤 놀거리 찾으시는 분들께 추천드리는 무료 입장 클럽들. 어썸 레드는 분위기가...',
      cover: 'assets/club_detail/images/image_tab_image_2.png',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final reviewsAsync = ref.watch(reviewListProvider(widget.clubId));

    return ListView(
      physics: const ClampingScrollPhysics(),
      padding: EdgeInsets.fromLTRB(20.w, 20.h, 20.w, 32.h),
      children: [
        // segmented toggle
        Container(
          height: 44.h,
          decoration: BoxDecoration(
            color: VybeColors.gray900,
            borderRadius: BorderRadius.circular(999.r),
          ),
          padding: EdgeInsets.all(4.r),
          child: Row(
            children: [_toggleBtn('방문자 리뷰', 0), _toggleBtn('블로그 리뷰', 1)],
          ),
        ),
        SizedBox(height: 20.h),

        if (_toggleIndex == 0)
          reviewsAsync.when(
            loading: () => const ReviewsTabSkeleton(),
            error: (_, __) => Center(
              child: Text(
                '리뷰를 불러올 수 없어요',
                style: TextStyle(
                  fontFamily: 'Pretendard',
                  fontSize: 14.sp,
                  color: VybeColors.gray500,
                ),
              ),
            ),
            data: (reviews) {
              final sorted = _sortedReviews(reviews);
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _RatingSummary(reviews: reviews),
                  SizedBox(height: 20.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '리뷰 ${reviews.length}',
                        style: TextStyle(
                          fontFamily: 'Pretendard',
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                      Row(
                        children: [
                          _sortChip('최신순', 0),
                          _sortChip('평점순', 1),
                          _sortChip('사진', 2),
                        ],
                      ),
                    ],
                  ),
                  SizedBox(height: 4.h),
                  ...sorted.asMap().entries.map(
                    (e) => _ReviewCard(
                      review: e.value,
                      avatarColor: _avatarColors[e.key % _avatarColors.length],
                    ),
                  ),
                ],
              );
            },
          ),

        if (_toggleIndex == 1) ..._blogs.map((b) => _BlogCard(blog: b)),
      ],
    );
  }

  List<ReviewModel> _sortedReviews(List<ReviewModel> reviews) {
    final list = List<ReviewModel>.from(reviews);
    if (_sortIndex == 0) {
      list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    } else if (_sortIndex == 1) {
      list.sort((a, b) => b.rating.compareTo(a.rating));
    } else {
      list.sort((a, b) => b.imageUrls.length.compareTo(a.imageUrls.length));
    }
    return list;
  }

  Widget _toggleBtn(String label, int index) {
    final selected = _toggleIndex == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _toggleIndex = index),
        child: Container(
          decoration: BoxDecoration(
            color: selected ? VybeColors.gray700 : Colors.transparent,
            borderRadius: BorderRadius.circular(999.r),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: TextStyle(
              fontFamily: 'Pretendard',
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
              color: selected ? Colors.white : VybeColors.gray400,
            ),
          ),
        ),
      ),
    );
  }

  Widget _sortChip(String label, int index) {
    final selected = _sortIndex == index;
    return GestureDetector(
      onTap: () => setState(() => _sortIndex = index),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
        decoration: BoxDecoration(
          color: selected ? VybeColors.gray800 : Colors.transparent,
          borderRadius: BorderRadius.circular(999.r),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontFamily: 'Pretendard',
            fontSize: 12.sp,
            fontWeight: FontWeight.w500,
            color: selected ? Colors.white : VybeColors.gray500,
          ),
        ),
      ),
    );
  }
}

// ── RATING SUMMARY ──

class _RatingSummary extends StatelessWidget {
  final List<ReviewModel> reviews;
  const _RatingSummary({required this.reviews});

  @override
  Widget build(BuildContext context) {
    if (reviews.isEmpty) return const SizedBox.shrink();

    final total = reviews.length;
    final avg = reviews.map((r) => r.rating).reduce((a, b) => a + b) / total;

    final dist = [5, 4, 3, 2, 1].map((star) {
      final count = reviews.where((r) => r.rating.floor() == star).length;
      return (star: star, count: count);
    }).toList();

    return Container(
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: VybeColors.gray900,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: VybeColors.gray800),
      ),
      child: Row(
        children: [
          Column(
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text(
                    avg.toStringAsFixed(1),
                    style: TextStyle(
                      fontFamily: 'Pretendard',
                      fontSize: 28.sp,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    '/5',
                    style: TextStyle(
                      fontFamily: 'Pretendard',
                      fontSize: 14.sp,
                      color: VybeColors.gray500,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 4.h),
              Row(
                children: List.generate(5, (i) {
                  // 평균 평점만큼 채워진 별 (반올림 0.5 단위)
                  final filled = avg >= i + 1;
                  final half = !filled && avg >= i + 0.5;
                  return Icon(
                    half ? Icons.star_half_rounded : Icons.star_rounded,
                    size: 12.r,
                    color: (filled || half)
                        ? VybeColors.mainLime500
                        : VybeColors.gray700,
                  );
                }),
              ),
              SizedBox(height: 4.h),
              Text(
                '방문자 $total명',
                style: TextStyle(
                  fontFamily: 'Pretendard',
                  fontSize: 12.sp,
                  color: VybeColors.gray500,
                ),
              ),
            ],
          ),
          SizedBox(width: 18.w),
          Expanded(
            child: Column(
              children: dist.map((d) {
                final pct = total > 0 ? d.count / total : 0.0;
                return Padding(
                  padding: EdgeInsets.only(bottom: 4.h),
                  child: Row(
                    children: [
                      SizedBox(
                        width: 12.w,
                        child: Text(
                          '${d.star}',
                          style: TextStyle(
                            fontFamily: 'Pretendard',
                            fontSize: 12.sp,
                            color: VybeColors.gray400,
                          ),
                        ),
                      ),
                      SizedBox(width: 8.w),
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(99.r),
                          child: LinearProgressIndicator(
                            value: pct,
                            minHeight: 4.h,
                            backgroundColor: VybeColors.gray800,
                            valueColor: const AlwaysStoppedAnimation(
                              VybeColors.mainLime500,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 8.w),
                      SizedBox(
                        width: 18.w,
                        child: Text(
                          '${d.count}',
                          textAlign: TextAlign.right,
                          style: TextStyle(
                            fontFamily: 'Pretendard',
                            fontSize: 12.sp,
                            color: VybeColors.gray500,
                          ),
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

// ── REVIEW CARD ──

class _ReviewCard extends StatefulWidget {
  final ReviewModel review;
  final Color avatarColor;
  const _ReviewCard({required this.review, required this.avatarColor});

  @override
  State<_ReviewCard> createState() => _ReviewCardState();
}

class _ReviewCardState extends State<_ReviewCard> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final r = widget.review;
    final isLong = r.content.length > 60;
    final showExpand = isLong && !_expanded;
    final displayText = showExpand
        ? '${r.content.substring(0, 60)}...'
        : r.content;
    final dateStr =
        '${r.createdAt.year}.${r.createdAt.month.toString().padLeft(2, '0')}.${r.createdAt.day.toString().padLeft(2, '0')}';
    final initial = r.userName.isNotEmpty ? r.userName.substring(0, 1) : '?';
    final firstImage = r.imageUrls.isNotEmpty ? r.imageUrls.first : null;

    return Container(
      padding: EdgeInsets.symmetric(vertical: 16.h),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: VybeColors.gray900)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 32.r,
                    height: 32.r,
                    decoration: BoxDecoration(
                      color: widget.avatarColor,
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
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
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        r.userName.isNotEmpty ? r.userName : '익명',
                        style: TextStyle(
                          fontFamily: 'Pretendard',
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(height: 2.h),
                      Row(
                        children: [
                          Icon(
                            Icons.star_rounded,
                            size: 12.r,
                            color: VybeColors.mainLime500,
                          ),
                          SizedBox(width: 4.w),
                          Text(
                            r.rating.toStringAsFixed(1),
                            style: TextStyle(
                              fontFamily: 'Pretendard',
                              fontSize: 12.sp,
                              fontWeight: FontWeight.w600,
                              color: VybeColors.gray300,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
              Text(
                dateStr,
                style: TextStyle(
                  fontFamily: 'Pretendard',
                  fontSize: 12.sp,
                  color: VybeColors.gray500,
                ),
              ),
            ],
          ),
          SizedBox(height: 10.h),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      displayText,
                      style: TextStyle(
                        fontFamily: 'Pretendard',
                        fontSize: 14.sp,
                        color: VybeColors.gray200,
                        height: 1.55,
                      ),
                    ),
                    if (showExpand) ...[
                      SizedBox(height: 6.h),
                      GestureDetector(
                        onTap: () => setState(() => _expanded = true),
                        child: Row(
                          children: [
                            Text(
                              '자세히 보기',
                              style: TextStyle(
                                fontFamily: 'Pretendard',
                                fontSize: 12.sp,
                                color: VybeColors.gray500,
                              ),
                            ),
                            Icon(
                              Icons.keyboard_arrow_down_rounded,
                              size: 10.r,
                              color: VybeColors.gray500,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              if (firstImage != null) ...[
                SizedBox(width: 14.w),
                GestureDetector(
                  onTap: () => VybePhotoViewer.open(
                    context,
                    imageUrls: r.imageUrls,
                  ),
                  child: SizedBox(
                  width: 90.r,
                  height: 90.r,
                  child: Stack(
                    children: [
                      SkeletonImage(
                        url: firstImage,
                        width: 90.r,
                        height: 90.r,
                        fit: BoxFit.cover,
                        borderRadius: BorderRadius.circular(6.r),
                      ),
                      if (r.imageUrls.length > 1)
                        Positioned(
                          right: 6.w,
                          bottom: 6.h,
                          child: Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 8.w,
                              vertical: 3.h,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.7),
                              borderRadius: BorderRadius.circular(999.r),
                            ),
                            child: Text(
                              '+${r.imageUrls.length - 1}',
                              style: TextStyle(
                                fontFamily: 'Pretendard',
                                fontSize: 12.sp,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
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

// ── BLOG CARD ──

class _BlogCard extends StatelessWidget {
  final _BlogData blog;
  const _BlogCard({required this.blog});

  @override
  Widget build(BuildContext context) {
    final b = blog;
    return Container(
      padding: EdgeInsets.symmetric(vertical: 16.h),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: VybeColors.gray900)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      b.subtitle,
                      style: TextStyle(
                        fontFamily: 'Pretendard',
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w600,
                        color: VybeColors.mainLime500,
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 6.w),
                      child: Container(
                        width: 2.r,
                        height: 2.r,
                        decoration: const BoxDecoration(
                          color: VybeColors.gray600,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                    Text(
                      b.blogger,
                      style: TextStyle(
                        fontFamily: 'Pretendard',
                        fontSize: 12.sp,
                        color: VybeColors.gray500,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 8.h),
                Text(
                  b.title,
                  style: TextStyle(
                    fontFamily: 'Pretendard',
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                    height: 1.4,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 6.h),
                Text(
                  b.preview,
                  style: TextStyle(
                    fontFamily: 'Pretendard',
                    fontSize: 12.sp,
                    color: VybeColors.gray400,
                    height: 1.4,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 8.h),
                Text(
                  b.date,
                  style: TextStyle(
                    fontFamily: 'Pretendard',
                    fontSize: 12.sp,
                    color: VybeColors.gray600,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: 14.w),
          ClipRRect(
            borderRadius: BorderRadius.circular(8.r),
            child: Image.asset(
              b.cover,
              width: 80.r,
              height: 80.r,
              fit: BoxFit.cover,
            ),
          ),
        ],
      ),
    );
  }
}

class _BlogData {
  final String blogger;
  final String subtitle;
  final String date;
  final String title;
  final String preview;
  final String cover;

  const _BlogData({
    required this.blogger,
    required this.subtitle,
    required this.date,
    required this.title,
    required this.preview,
    required this.cover,
  });
}
