import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vybe/design_system/colors.dart';
import 'package:vybe/design_system/typography.dart';
import 'package:vybe/presentation/common/widgets/ambient_backdrop.dart';
import 'package:vybe/presentation/common/widgets/vybe_confirm_sheet.dart';
import 'package:vybe/presentation/common/widgets/vybe_spinner.dart';
import 'package:vybe/presentation/common/widgets/vybe_toast.dart';
import 'package:vybe/presentation/my_page/viewmodels/my_page_viewmodel.dart';
import 'package:vybe/presentation/my_page/widgets/my_page_common.dart';

// ============================================================
// 내 리뷰 관리 화면 (my.html 디자인 기반)
//
// collectionGroup 쿼리로 전 클럽에서 내 리뷰를 모아 보여주고
// 삭제(확인 바텀시트)를 지원한다. 리뷰 수정은 베타 범위 외 — 준비 중 토스트.
// 디자인의 '좋아요 수'는 reviews 스키마에 없어 제외.
// ============================================================

class MyReviewsScreen extends ConsumerWidget {
  const MyReviewsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reviewsAsync = ref.watch(myReviewsProvider);

    return Scaffold(
      backgroundColor: VybeColors.background,
      body: Stack(
        children: [
          const Positioned.fill(child: AmbientBackdrop()),
          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SubScreenHeader(title: '내 리뷰 관리'),
                Expanded(
                  child: reviewsAsync.when(
                    loading: () => const Center(child: VybeSpinner()),
                    error: (_, __) => _message('리뷰를 불러오지 못했어요'),
                    data: (entries) => entries.isEmpty
                        ? _empty()
                        : ListView.separated(
                            padding:
                                EdgeInsets.fromLTRB(16.w, 4.h, 16.w, 32.h),
                            itemCount: entries.length + 1,
                            separatorBuilder: (_, __) =>
                                SizedBox(height: 12.h),
                            itemBuilder: (context, i) {
                              if (i == 0) return _countHeader(entries.length);
                              final entry = entries[i - 1];
                              return _ReviewCard(
                                entry: entry,
                                onDelete: () =>
                                    _confirmDelete(context, ref, entry),
                              );
                            },
                          ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _countHeader(int count) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 10.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text.rich(
            TextSpan(
              text: '작성한 리뷰 ',
              style: VybeTypography.body3.copyWith(
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
              children: [
                TextSpan(
                  text: '$count',
                  style: const TextStyle(color: VybeColors.mainLime500),
                ),
              ],
            ),
          ),
          Text(
            '최신순',
            style: TextStyle(
              fontFamily: 'Pretendard',
              fontSize: 12.sp,
              color: VybeColors.gray500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _message(String text) {
    return Center(
      child: Text(
        text,
        style: VybeTypography.body4.copyWith(color: VybeColors.gray500),
      ),
    );
  }

  Widget _empty() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 60.r,
            height: 60.r,
            decoration: glassTileDecoration(radius: 18),
            child: Icon(
              Icons.chat_bubble_outline_rounded,
              size: 26.r,
              color: VybeColors.gray600,
            ),
          ),
          SizedBox(height: 16.h),
          Text(
            '작성한 리뷰가 없어요',
            style: VybeTypography.body3.copyWith(
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 7.h),
          Text(
            '다녀온 클럽의 후기를 남겨보세요',
            style: VybeTypography.body4.copyWith(color: VybeColors.gray500),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(
      BuildContext context, WidgetRef ref, MyReviewEntry entry) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withValues(alpha: 0.6),
      builder: (sheetContext) => VybeConfirmSheet(
        title: '리뷰를 삭제할까요?',
        message: '${entry.clubName} 리뷰가 삭제되며\n되돌릴 수 없어요.',
        messageHeight: 20 / 14,
        // 핸들·취소 버튼은 기존 화면 값 유지 (공통 기본값과 다름).
        handleColor: VybeColors.gray700,
        cancelDecoration: glassTileDecoration(radius: 14),
        confirmLabel: '삭제',
        onConfirm: () async {
          Navigator.of(sheetContext).pop();
          await ref
              .read(myPageActionsProvider.notifier)
              .deleteReview(entry.review.clubId, entry.review.reviewId);
          if (!context.mounted) return;
          VybeToast.show(context, message: '리뷰를 삭제했어요');
        },
      ),
    );
  }
}

class _ReviewCard extends StatelessWidget {
  final MyReviewEntry entry;
  final VoidCallback onDelete;

  const _ReviewCard({required this.entry, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    final r = entry.review;
    return Container(
      padding: EdgeInsets.all(16.r),
      decoration: glassDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 클럽명 + 별점 / 날짜
          Row(
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
                    _Stars(rating: r.rating),
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
          ),
          SizedBox(height: 10.h),
          Text(
            r.content,
            style: VybeTypography.body4.copyWith(
              height: 21 / 14,
              color: VybeColors.gray200,
            ),
          ),
          if (r.imageUrls.isNotEmpty) ...[
            SizedBox(height: 12.h),
            SizedBox(
              height: 74.r,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: r.imageUrls.length,
                separatorBuilder: (_, __) => SizedBox(width: 8.w),
                itemBuilder: (_, i) => ClipRRect(
                  borderRadius: BorderRadius.circular(10.r),
                  child: Image.network(
                    r.imageUrls[i],
                    width: 74.r,
                    height: 74.r,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      width: 74.r,
                      height: 74.r,
                      color: VybeColors.surface,
                    ),
                  ),
                ),
              ),
            ),
          ],
          SizedBox(height: 14.h),
          Divider(height: 1, thickness: 1, color: hairColor),
          SizedBox(height: 13.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              _actionChip(
                icon: Icons.edit_outlined,
                label: '수정',
                color: Colors.white,
                background: glassTileDecoration(radius: 8),
                onTap: () =>
                    VybeToast.show(context, message: '리뷰 수정은 준비 중이에요'),
              ),
              SizedBox(width: 8.w),
              _actionChip(
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
          ),
        ],
      ),
    );
  }

  Widget _actionChip({
    required IconData icon,
    required String label,
    required Color color,
    required BoxDecoration background,
    required VoidCallback onTap,
  }) {
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
