import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// 검색 기본 화면의 섹션 헤더 — `아이콘 + 제목` (오른쪽에 보조 액션).
class SearchSectionHead extends StatelessWidget {
  final Widget icon;
  final String title;

  /// 오른쪽 끝 요소 (예: '전체 삭제', '갱신 시각'). 없으면 제목만.
  final Widget? right;

  const SearchSectionHead({
    super.key,
    required this.icon,
    required this.title,
    this.right,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 16.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              icon,
              SizedBox(width: 7.w),
              Text(
                title,
                style: TextStyle(
                  fontFamily: 'Pretendard',
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                  letterSpacing: 18 * -0.025,
                ),
              ),
            ],
          ),
          if (right != null) right!,
        ],
      ),
    );
  }
}
