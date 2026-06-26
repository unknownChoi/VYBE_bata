import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:vybe/design_system/colors.dart';
import 'package:vybe/design_system/typography.dart';

/// 검색 결과 상단 바. 검색창을 탭하면 검색 입력 화면(최근 검색어)으로 돌아간다.
class ResultGnb extends StatelessWidget {
  final String query;
  final VoidCallback? onBack;

  const ResultGnb({super.key, required this.query, this.onBack});

  @override
  Widget build(BuildContext context) {
    final back = onBack ?? () => Navigator.of(context).pop();
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 10.h),
      child: Row(
        children: [
          GestureDetector(
            onTap: back,
            behavior: HitTestBehavior.opaque,
            child: SvgPicture.asset(
              'assets/icons/common/arrow_back.svg',
              width: 24.r,
              height: 24.r,
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: GestureDetector(
              onTap: back,
              behavior: HitTestBehavior.opaque,
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
                      child: Text(
                        query,
                        style:
                            VybeTypography.body4.copyWith(color: Colors.white),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    SvgPicture.asset(
                      'assets/icons/common/search.svg',
                      width: 18.r,
                      height: 18.r,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
