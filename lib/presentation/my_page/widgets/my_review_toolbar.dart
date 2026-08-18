import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vybe/presentation/common/renew/renew_glass.dart';
import 'package:vybe/presentation/common/renew/renew_icons.dart';
import 'package:vybe/presentation/my_page/viewmodels/my_page_viewmodel.dart';
import 'package:vybe/presentation/my_page/widgets/my_page_common.dart';

/// '내 리뷰' 목록 위 정렬·필터 칩 줄 (디자인 MRReviewBar).
///
/// 스크롤 밖 **고정 행** — sticky `SliverPersistentHeader`로 만들면
/// 세만틱스 검증에 걸려 화면이 통째로 안 그려진다(CLAUDE.md 참고).
///
/// 디자인의 '좋아요순'은 reviews 스키마에 좋아요 필드가 없어 뺐다
/// ([MyReviewSort] 참고).
class MyReviewToolbar extends ConsumerWidget {
  const MyReviewToolbar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filter = ref.watch(myReviewFilterControllerProvider);
    final controller = ref.read(myReviewFilterControllerProvider.notifier);

    return Padding(
      padding: EdgeInsets.fromLTRB(kMyPagePad.w, 18.h, kMyPagePad.w, 0),
      child: Row(
        children: [
          for (final sort in MyReviewSort.values) ...[
            RenewChip(
              label: sort.label,
              selected: filter.sort == sort,
              onTap: () => controller.setSort(sort),
            ),
            SizedBox(width: 8.w),
          ],
          RenewChip(
            label: '사진',
            iconPath: RenewIcons.camera,
            selected: filter.photoOnly,
            onTap: controller.togglePhotoOnly,
          ),
        ],
      ),
    );
  }
}
