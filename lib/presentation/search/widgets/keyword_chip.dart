import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vybe/data/models/search_history_model.dart';
import 'package:vybe/design_system/colors.dart';
import 'package:vybe/design_system/typography.dart';

class KeywordChip extends StatelessWidget {
  final SearchHistoryModel item;
  final VoidCallback onDelete;
  final VoidCallback? onTap;

  const KeywordChip({
    super.key,
    required this.item,
    required this.onDelete,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(13.w, 8.h, 9.w, 8.h),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(999.r),
        border: Border.all(color: VybeColors.gray800),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          GestureDetector(
            onTap: onTap,
            behavior: HitTestBehavior.opaque,
            child: Text(
              item.keyword,
              style: VybeTypography.body4.copyWith(
                color: VybeColors.gray200,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          SizedBox(width: 7.w),
          GestureDetector(
            onTap: onDelete,
            behavior: HitTestBehavior.opaque,
            child: Icon(
              Icons.close_rounded,
              size: 14.r,
              color: VybeColors.gray500,
            ),
          ),
        ],
      ),
    );
  }
}
