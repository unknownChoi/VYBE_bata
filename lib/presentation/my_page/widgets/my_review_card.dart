import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vybe/design_system/colors.dart';
import 'package:vybe/design_system/typography.dart';
import 'package:vybe/presentation/my_page/viewmodels/my_page_viewmodel.dart';
import 'package:vybe/presentation/my_page/widgets/my_page_common.dart';

/// '내 리뷰 관리' 목록의 리뷰 카드 1장.
///
/// 클럽명·지역·별점·작성일 / 본문 / 첨부 사진 / [수정][삭제].
/// 디자인의 '좋아요 수'는 reviews 스키마에 없어 제외.
class MyReviewCard extends StatelessWidget {
  final MyReviewEntry entry;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const MyReviewCard({
    super.key,
    required this.entry,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final review = entry.review;

    return Container(
      padding: EdgeInsets.all(16.r),
      decoration: glassDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _header(),
          SizedBox(height: 10.h),
          Text(
            review.content,
            style: VybeTypography.body4.copyWith(
              height: 21 / 14,
              color: VybeColors.gray200,
            ),
          ),
          if (review.imageUrls.isNotEmpty) ...[
            SizedBox(height: 12.h),
            _PhotoStrip(imageUrls: review.imageUrls),
          ],
          SizedBox(height: 14.h),
          Divider(height: 1, thickness: 1, color: hairColor),
          SizedBox(height: 13.h),
          _actions(),
        ],
      ),
    );
  }

  /// 클럽명 + 지역 + 별점 / 오른쪽 작성일.
  Widget _header() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Flexible(
                    child: Text(
                      entry.clubName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: VybeTypography.body3.copyWith(
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  if (entry.clubArea.isNotEmpty) ...[
                    SizedBox(width: 6.w),
                    Text(
                      '· ${entry.clubArea}',
                      style: TextStyle(
                        fontFamily: 'Pretendard',
                        fontSize: 12.sp,
                        color: VybeColors.gray500,
                      ),
                    ),
                  ],
                ],
              ),
              SizedBox(height: 6.h),
              _Stars(rating: entry.review.rating),
            ],
          ),
        ),
        Text(
          entry.dateLabel,
          style: TextStyle(
            fontFamily: 'Pretendard',
            fontSize: 12.sp,
            color: VybeColors.gray600,
          ),
        ),
      ],
    );
  }

  Widget _actions() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        _ActionChip(
          icon: Icons.edit_outlined,
          label: '수정',
          color: Colors.white,
          background: glassTileDecoration(radius: 8),
          onTap: onEdit,
        ),
        SizedBox(width: 8.w),
        _ActionChip(
          icon: Icons.delete_outline_rounded,
          label: '삭제',
          color: VybeColors.accentRed500,
          background: BoxDecoration(
            color: VybeColors.accentRed500.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8.r),
            border: Border.all(
              color: VybeColors.accentRed500.withValues(alpha: 0.3),
            ),
          ),
          onTap: onDelete,
        ),
      ],
    );
  }
}

/// 첨부 사진 가로 목록.
class _PhotoStrip extends StatelessWidget {
  final List<String> imageUrls;

  const _PhotoStrip({required this.imageUrls});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 74.r,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: imageUrls.length,
        separatorBuilder: (_, __) => SizedBox(width: 8.w),
        itemBuilder: (_, i) => ClipRRect(
          borderRadius: BorderRadius.circular(10.r),
          child: Image.network(
            imageUrls[i],
            width: 74.r,
            height: 74.r,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) =>
                Container(width: 74.r, height: 74.r, color: VybeColors.surface),
          ),
        ),
      ),
    );
  }
}

class _ActionChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final BoxDecoration background;
  final VoidCallback onTap;

  const _ActionChip({
    required this.icon,
    required this.label,
    required this.color,
    required this.background,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 30.h,
        padding: EdgeInsets.symmetric(horizontal: 12.w),
        decoration: background,
        child: Row(
          children: [
            Icon(icon, size: 13.r, color: color),
            SizedBox(width: 5.w),
            Text(label, style: VybeTypography.button2.copyWith(color: color)),
          ],
        ),
      ),
    );
  }
}

/// 별 5개 + 숫자 (0.5 이상이면 채움).
class _Stars extends StatelessWidget {
  final double rating;

  const _Stars({required this.rating});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        for (var i = 0; i < 5; i++)
          Padding(
            padding: EdgeInsets.only(right: 2.w),
            child: Icon(
              Icons.star_rounded,
              size: 14.r,
              color: rating - i >= 0.5
                  ? VybeColors.mainLime500
                  : VybeColors.gray700,
            ),
          ),
        SizedBox(width: 4.w),
        Text(
          rating.toStringAsFixed(1),
          style: TextStyle(
            fontFamily: 'Pretendard',
            fontSize: 12.sp,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
      ],
    );
  }
}
