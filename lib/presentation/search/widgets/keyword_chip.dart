import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:vybe/data/models/search_history_model.dart';
import 'package:vybe/design_system/colors.dart';
import 'package:vybe/design_system/typography.dart';

class KeywordChip extends StatelessWidget {
  final SearchHistoryModel item;
  final VoidCallback onDelete;

  const KeywordChip({super.key, required this.item, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 24.h,
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: VybeColors.gray900,
        borderRadius: BorderRadius.circular(999.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            item.keyword,
            style: VybeTypography.body4.copyWith(color: VybeColors.gray400),
          ),
          SizedBox(width: 8.w),
          GestureDetector(
            onTap: onDelete,
            child: SvgPicture.asset(
              'assets/icons/search_screen/delete_search_history.svg',
              width: 9.r,
              height: 9.r,
            ),
          ),
        ],
      ),
    );
  }
}
