import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vybe/design_system/colors.dart';
import 'package:vybe/design_system/typography.dart';
import 'package:vybe/presentation/clubs/review_write_screen.dart';
import 'package:vybe/presentation/common/renew/renew_glass.dart';
import 'package:vybe/presentation/common/renew/renew_icons.dart';
import 'package:vybe/presentation/common/widgets/vybe_confirm_dialog.dart';
import 'package:vybe/presentation/common/widgets/vybe_spinner.dart';
import 'package:vybe/presentation/common/widgets/vybe_toast.dart';
import 'package:vybe/presentation/my_page/viewmodels/my_page_viewmodel.dart';
import 'package:vybe/presentation/my_page/widgets/my_page_common.dart';
import 'package:vybe/presentation/my_page/widgets/my_review_card.dart';

// ============================================================
// 내 리뷰 관리 — 리뉴얼 (my_renew.html · MRReviewsScreen)
//
// collectionGroup 쿼리로 전 클럽에서 내 리뷰를 모아 보여주고
// 수정(리뷰 작성 화면 재사용)과 삭제(확인 다이얼로그)를 지원한다.
// 카드는 widgets/my_review_card.dart.
//
// 배경은 오로라 없이 잉크 단색 — 디자인의 푸시 화면(MRScreen)이
// 배경을 깔아 뒤 화면과 겹쳐 보이지 않게 하는 것과 같은 의도.
// ============================================================

class MyReviewsScreen extends ConsumerWidget {
  const MyReviewsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reviewsAsync = ref.watch(myReviewsProvider);

    return Scaffold(
      backgroundColor: RenewGlass.ink,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const MyPushHeader(title: '내 리뷰 관리'),
          Expanded(
            child: reviewsAsync.when(
              loading: () => const Center(child: VybeSpinner()),
              error: (_, __) => _message('리뷰를 불러오지 못했어요'),
              data: (entries) => entries.isEmpty
                  ? _empty()
                  : ListView.builder(
                      padding: EdgeInsets.fromLTRB(
                        kMyPagePad.w,
                        0,
                        kMyPagePad.w,
                        40.h,
                      ),
                      itemCount: entries.length + 1,
                      itemBuilder: (context, i) {
                        if (i == 0) return _countHeader(entries.length);
                        final entry = entries[i - 1];
                        return MyReviewCard(
                          entry: entry,
                          onEdit: () => _openEdit(context, entry),
                          onDelete: () => _confirmDelete(context, ref, entry),
                        );
                      },
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _countHeader(int count) {
    return Padding(
      padding: EdgeInsets.fromLTRB(0, 16.h, 0, 4.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.baseline,
        textBaseline: TextBaseline.alphabetic,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text.rich(
            TextSpan(
              text: '작성한 리뷰 ',
              style: VybeTypography.body3.copyWith(
                fontWeight: FontWeight.w700,
                color: RenewGlass.t1,
              ),
              children: [
                TextSpan(
                  text: '$count',
                  style: const TextStyle(color: VybeColors.mainLime500),
                ),
              ],
            ),
          ),
          Text('최신순', style: RenewGlass.caption(lineHeight: 14)),
        ],
      ),
    );
  }

  Widget _message(String text) {
    return Center(
      child: Text(text, style: RenewGlass.body(color: RenewGlass.t4)),
    );
  }

  Widget _empty() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const MyGlassTile(icon: RenewIcons.review),
          SizedBox(height: 16.h),
          Text(
            '작성한 리뷰가 없어요',
            style: VybeTypography.body3.copyWith(
              fontWeight: FontWeight.w600,
              color: RenewGlass.t1,
            ),
          ),
          SizedBox(height: 7.h),
          Text(
            '다녀온 클럽의 후기를 남겨보세요',
            style: RenewGlass.body(color: RenewGlass.t4, lineHeight: 20),
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
