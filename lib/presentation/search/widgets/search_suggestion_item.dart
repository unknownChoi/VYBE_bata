import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vybe/design_system/colors.dart';

class SearchSuggestionItem extends StatelessWidget {
  final String keyword;
  final String query;
  final VoidCallback? onTap;

  const SearchSuggestionItem({
    super.key,
    required this.keyword,
    required this.query,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final baseStyle = TextStyle(
      fontFamily: 'Pretendard',
      fontWeight: FontWeight.w400,
      fontSize: 17.sp,
      height: 22 / 17,
      letterSpacing: 17 * -0.025,
    );

    final lowerKeyword = keyword.toLowerCase();
    final lowerQuery = query.toLowerCase();

    InlineSpan textSpan;
    if (query.isNotEmpty && lowerKeyword.startsWith(lowerQuery)) {
      textSpan = TextSpan(
        children: [
          TextSpan(
            text: keyword.substring(0, query.length),
            style: baseStyle.copyWith(color: VybeColors.mainLime700),
          ),
          TextSpan(
            text: keyword.substring(query.length),
            style: baseStyle.copyWith(color: VybeColors.gray200),
          ),
        ],
      );
    } else {
      textSpan = TextSpan(
        text: keyword,
        style: baseStyle.copyWith(color: VybeColors.gray200),
      );
    }

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        height: 50.h,
        width: double.infinity,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 9.h),
          child: RichText(text: textSpan),
        ),
      ),
    );
  }
}
