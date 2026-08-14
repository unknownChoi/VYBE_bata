import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vybe/design_system/colors.dart';
import 'package:vybe/design_system/typography.dart';
import 'package:vybe/presentation/clubs/review_write_screen.dart';
import 'package:vybe/presentation/common/widgets/ambient_backdrop.dart';
import 'package:vybe/presentation/common/widgets/vybe_confirm_dialog.dart';
import 'package:vybe/presentation/common/widgets/vybe_spinner.dart';
import 'package:vybe/presentation/common/widgets/vybe_toast.dart';
import 'package:vybe/presentation/my_page/viewmodels/my_page_viewmodel.dart';
import 'package:vybe/presentation/my_page/widgets/my_page_common.dart';
import 'package:vybe/presentation/my_page/widgets/my_review_card.dart';

// ============================================================
// 내 리뷰 관리 화면 (my.html 디자인 기반)
//
// collectionGroup 쿼리로 전 클럽에서 내 리뷰를 모아 보여주고
// 수정(리뷰 작성 화면 재사용)과 삭제(확인 다이얼로그)를 지원한다.
// 카드는 widgets/my_review_card.dart.
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
                            padding: EdgeInsets.fromLTRB(16.w, 4.h, 16.w, 32.h),
                            itemCount: entries.length + 1,
                            separatorBuilder: (_, __) => SizedBox(height: 12.h),
                            itemBuilder: (context, i) {
                              if (i == 0) return _countHeader(entries.length);
                              final entry = entries[i - 1];
                              return MyReviewCard(
                                entry: entry,
                                onEdit: () => _openEdit(context, entry),
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

  /// 리뷰 수정 — 작성 화면을 수정 모드로 연다.
  /// 목록은 collectionGroup 스트림이라 저장되면 저절로 갱신된다(수동 새로고침 불필요).
  Future<void> _openEdit(BuildContext context, MyReviewEntry entry) async {
    final updated = await ReviewWriteScreen.pushEdit(
      context,
      review: entry.review,
    );
    if (updated != true || !context.mounted) return;
    VybeToast.show(context, message: '리뷰를 수정했어요');
  }

  Future<void> _confirmDelete(
    BuildContext context,
    WidgetRef ref,
    MyReviewEntry entry,
  ) async {
    final confirmed = await VybeConfirmDialog.show(
      context,
      title: '리뷰를 삭제할까요?',
      message: '${entry.clubName} 리뷰가 삭제되며\n되돌릴 수 없어요.',
      confirmLabel: '삭제',
    );
    if (!confirmed || !context.mounted) return;

    await ref
        .read(myPageActionsProvider.notifier)
        .deleteReview(entry.review.clubId, entry.review.reviewId);
    if (!context.mounted) return;
    VybeToast.show(context, message: '리뷰를 삭제했어요');
  }
}
