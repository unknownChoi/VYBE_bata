import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vybe/design_system/typography.dart';
import 'package:vybe/presentation/common/renew/renew_glass.dart';
import 'package:vybe/presentation/my_page/viewmodels/my_page_viewmodel.dart';
import 'package:vybe/presentation/my_page/widgets/my_page_common.dart';

/// '내 리뷰 관리' 목록의 리뷰 카드 1장 (디자인 MRReviewCard).
///
/// 유리 카드로 감싸지 않고 헤어라인으로만 나눈다 — 카드가 겹겹이 쌓이면
/// 글래스 배경이 탁해져 본문이 읽히지 않는다.
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
      padding: EdgeInsets.symmetric(vertical: 16.h),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: RenewGlass.hair)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _header(),
          SizedBox(height: 8.h),
          Text(
            review.content,
            style: RenewGlass.body(color: RenewGlass.t2, lineHeight: 21),
          ),
          if (review.imageUrls.isNotEmpty) ...[
            SizedBox(height: 12.h),
            _PhotoStrip(imageUrls: review.imageUrls),
          ],
          SizedBox(height: 12.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              _ActionChip(label: '수정', onTap: onEdit),
              SizedBox(width: 8.w),
              _ActionChip(label: '삭제', danger: true, onTap: onDelete),
            ],
          ),
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
          child: Wrap(
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 8.w,
            runSpacing: 4.h,
            children: [
              Text(
                entry.clubName,
                style: VybeTypography.body3.copyWith(
                  fontWeight: FontWeight.w700,
                  color: RenewGlass.t1,
                ),
              ),
              if (entry.clubArea.isNotEmpty)
                Text(entry.clubArea, style: RenewGlass.caption(lineHeight: 14)),
              _RatingBadge(rating: entry.review.rating),
            ],
          ),
        ),
        SizedBox(width: 12.w),
        Text(entry.dateLabel, style: RenewGlass.caption(lineHeight: 14)),
      ],
    );
  }
}

/// 별 하나 + 숫자 (디자인 MRStars) — 5개를 다 그리면 한 줄에 정보가 너무 많다.
class _RatingBadge extends StatelessWidget {
  final double rating;

  const _RatingBadge({required this.rating});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const RenewStar(size: 13),
        SizedBox(width: 5.w),
        Text(
          rating.toStringAsFixed(1),
          style: RenewGlass.caption(
            color: RenewGlass.t1,
            lineHeight: 13,
            weight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

/// 첨부 사진 가로 목록.
class _PhotoStrip extends StatelessWidget {
  final List<String> imageUrls;

  const _PhotoStrip({required this.imageUrls});

  static const double _side = 76;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: _side.r,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: imageUrls.length,
        separatorBuilder: (_, __) => SizedBox(width: 8.w),
        itemBuilder: (_, i) => Container(
          width: _side.r,
          height: _side.r,
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10.r),
            border: Border.all(color: RenewGlass.quietBorder),
          ),
          child: Image.network(
            imageUrls[i],
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) =>
                const ColoredBox(color: RenewGlass.tileFill),
          ),
        ),
      ),
    );
  }
}

/// 카드 하단 [수정]/[삭제] 작은 버튼 — 높이 30 · radius 8.
class _ActionChip extends StatelessWidget {
  final String label;
  final bool danger;
  final VoidCallback onTap;

  const _ActionChip({
    required this.label,
    required this.onTap,
    this.danger = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        height: 30.h,
        padding: EdgeInsets.symmetric(horizontal: 13.w),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: danger
              ? kMyDanger.withValues(alpha: 0.10)
              : RenewGlass.tileFill,
          borderRadius: BorderRadius.circular(8.r),
          border: Border.all(
            color: danger
                ? kMyDanger.withValues(alpha: 0.30)
                : RenewGlass.tileBorder,
          ),
        ),
        child: Text(
          label,
          style: VybeTypography.button2.copyWith(
            color: danger ? kMyDanger : RenewGlass.t1,
          ),
        ),
      ),
    );
  }
}
