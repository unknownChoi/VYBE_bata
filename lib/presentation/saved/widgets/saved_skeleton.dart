import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vybe/presentation/common/widgets/vybe_skeleton.dart';

// 찜 목록 로딩 스켈레톤.

class _SavedItemSkeleton extends StatelessWidget {
  const _SavedItemSkeleton();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.all(12.r),
      decoration: BoxDecoration(
        // GlassCard와 같은 톤 (블러는 스켈레톤에 불필요).
        color: const Color(0x29787880),
        borderRadius: BorderRadius.circular(18.r),
        border: Border.all(color: const Color(0x1AFFFFFF)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          VybeSkel(width: 92.w, height: 92.w, radius: 14),
          SizedBox(width: 13.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                VybeSkel(width: 130.w, height: 16.h),
                SizedBox(height: 10.h),
                VybeSkel(width: 170.w, height: 12.h),
                SizedBox(height: 10.h),
                VybeSkel(width: 132.w, height: 21.h, radius: 99),
                SizedBox(height: 8.h),
                VybeSkel(width: 64.w, height: 11.h),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class SavedSkeleton extends StatelessWidget {
  const SavedSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 헤더 (찜 개수 + 영업중)
        Padding(
          padding: EdgeInsets.fromLTRB(16.w, 10.h, 16.w, 18.h),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              VybeSkel(width: 176.w, height: 32.h, radius: 8),
              VybeSkel(width: 96.w, height: 14.h, radius: 99),
            ],
          ),
        ),
        // 툴바 (정렬 + 뷰 전환)
        Container(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 11.h),
          decoration: const BoxDecoration(
            color: Color(0x8C0E0D12),
            border: Border(
              top: BorderSide(color: Color(0x17FFFFFF)),
              bottom: BorderSide(color: Color(0x17FFFFFF)),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              VybeSkel(width: 116.w, height: 34.h, radius: 99),
              VybeSkel(width: 74.w, height: 34.h, radius: 99),
            ],
          ),
        ),
        // 리스트 카드 4개
        Padding(
          padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 0),
          child: Column(
            children: List.generate(4, (_) => const _SavedItemSkeleton()),
          ),
        ),
      ],
    );
  }
}
