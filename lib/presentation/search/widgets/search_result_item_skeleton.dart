import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vybe/presentation/common/widgets/vybe_skeleton.dart';

// 검색 결과 카드 로딩 스켈레톤.

class SearchResultItemSkeleton extends StatelessWidget {
  const SearchResultItemSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(24.w, 0, 24.w, 14.h),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18.r),
        child: SizedBox(
          height: 208.h,
          child: Stack(
            fit: StackFit.expand,
            children: [
              // 썸네일 자리 (카드 전체).
              const VybeSkel(
                width: double.infinity,
                height: double.infinity,
                radius: 0,
              ),
              // 하단 글래스 바 — 실제 카드와 같은 그라데이션/패딩.
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: Container(
                  padding: EdgeInsets.fromLTRB(16.w, 34.h, 16.w, 15.h),
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                      colors: [Color(0xD1101015), Color(0x001C1C26)],
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 이름 · 평점 · 리뷰 수
                      Row(
                        children: [
                          VybeSkel(width: 116.w, height: 18.h),
                          SizedBox(width: 8.w),
                          VybeSkel(width: 44.w, height: 12.h),
                          SizedBox(width: 6.w),
                          VybeSkel(width: 42.w, height: 12.h),
                        ],
                      ),
                      SizedBox(height: 8.h),
                      // 지역 · 장르 · 영업종료 시각
                      Row(
                        children: [
                          VybeSkel(width: 48.w, height: 12.h),
                          SizedBox(width: 10.w),
                          VybeSkel(width: 38.w, height: 12.h),
                          SizedBox(width: 10.w),
                          VybeSkel(width: 82.w, height: 12.h),
                        ],
                      ),
                      SizedBox(height: 8.h),
                      // 입장료 칩
                      VybeSkel(width: 118.w, height: 22.h, radius: 8),
                    ],
                  ),
                ),
              ),
              // 영업 상태 pill
              Positioned(
                top: 12.h,
                right: 52.w,
                child: VybeSkel(width: 72.w, height: 32.r, radius: 99),
              ),
              // 찜 버튼
              Positioned(
                top: 12.h,
                right: 12.w,
                child: VybeSkel(width: 32.r, height: 32.r, radius: 99),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
