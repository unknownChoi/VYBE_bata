import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vybe/data/models/search_hashtag_model.dart';
import 'package:vybe/design_system/colors.dart';
import 'package:vybe/presentation/search/widgets/hashtag_chip.dart';
import 'package:vybe/presentation/search/widgets/search_section_head.dart';

/// 인기 해시태그 섹션. 노출 개수 제한·정렬은 호출측이 끝내고 넘긴다.
class PopularHashtagsSection extends StatelessWidget {
  final List<SearchHashtagModel> tags;
  final ValueChanged<SearchHashtagModel> onTap;

  const PopularHashtagsSection({
    super.key,
    required this.tags,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SearchSectionHead(
          icon: Text(
            '#',
            style: TextStyle(
              fontFamily: 'Pretendard',
              fontSize: 17.sp,
              fontWeight: FontWeight.w800,
              color: VybeColors.mainLime700,
            ),
          ),
          title: '인기 해시태그',
        ),
        Wrap(
          spacing: 8.w,
          runSpacing: 8.h,
          children: [
            for (final tag in tags)
              HashtagChip(label: tag.label, onTap: () => onTap(tag)),
          ],
        ),
      ],
    );
  }
}
