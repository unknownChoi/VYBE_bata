import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:vybe/design_system/colors.dart';
import 'package:vybe/design_system/typography.dart';

class SearchInputBar extends StatelessWidget {
  final TextEditingController? controller;
  final FocusNode? focusNode;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;

  const SearchInputBar({
    super.key,
    this.controller,
    this.focusNode,
    this.onChanged,
    this.onSubmitted,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 10.h),
      child: Container(
        height: 44.h,
        decoration: BoxDecoration(
          color: VybeColors.gray800,
          borderRadius: BorderRadius.circular(999.r),
        ),
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: controller,
                focusNode: focusNode,
                style:
                    VybeTypography.body4.copyWith(color: VybeColors.gray200),
                onChanged: onChanged,
                onSubmitted: onSubmitted,
                decoration: InputDecoration(
                  hintText: '클럽, 지역, 장르 검색',
                  hintStyle: VybeTypography.body4
                      .copyWith(color: VybeColors.gray600),
                  border: InputBorder.none,
                  isDense: true,
                  contentPadding: EdgeInsets.zero,
                ),
              ),
            ),
            GestureDetector(
              onTap: () {
                final query = controller?.text ?? '';
                onSubmitted?.call(query);
              },
              behavior: HitTestBehavior.opaque,
              child: SvgPicture.asset(
                'assets/icons/common/search.svg',
                width: 18.r,
                height: 18.r,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
