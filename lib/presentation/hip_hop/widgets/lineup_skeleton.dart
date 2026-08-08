import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vybe/design_system/colors.dart';
import 'package:vybe/presentation/common/widgets/vybe_skeleton.dart';

// 오늘의 라인업 로딩 스켈레톤.

// ── 로딩 스켈레톤 (디자인 today_lineup LineupSkeleton 기반) ──
// 인트로 메타 · 지금 공연 배너 · 타입 필터 · 타임라인 5행을 전부 shimmer로.
// 실제 레이아웃과 동일 구조라 로드 완료 시 자리 이동(레이아웃 점프)이 적다.
class LineupSkeleton extends StatelessWidget {
  const LineupSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 인트로 메타
        Padding(
          padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 12.h),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  VybeSkel(width: 130.w, height: 24.h, radius: 8),
                  SizedBox(height: 8.h),
                  VybeSkel(width: 180.w, height: 13.h),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  VybeSkel(width: 44.w, height: 20.h, radius: 6),
                  SizedBox(height: 8.h),
                  VybeSkel(width: 52.w, height: 12.h),
                ],
              ),
            ],
          ),
        ),
        // 지금 공연 배너
        Container(
          margin: EdgeInsets.fromLTRB(16.w, 4.h, 16.w, 6.h),
          padding: EdgeInsets.all(14.r),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18.r),
            border: Border.all(color: VybeColors.gray800),
          ),
          child: Row(
            children: [
              VybeSkel(width: 54.r, height: 54.r, radius: 99),
              SizedBox(width: 13.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    VybeSkel(width: 90.w, height: 12.h),
                    SizedBox(height: 9.h),
                    VybeSkel(width: 150.w, height: 20.h, radius: 6),
                    SizedBox(height: 9.h),
                    VybeSkel(width: 120.w, height: 12.h),
                  ],
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 12.h),
        // 타입 필터
        Padding(
          padding: EdgeInsets.only(left: 16.w, right: 16.w, bottom: 14.h),
          child: Row(
            children: [
              VybeSkel(width: 60.w, height: 34.h, radius: 999),
              SizedBox(width: 8.w),
              VybeSkel(width: 64.w, height: 34.h, radius: 999),
              SizedBox(width: 8.w),
              VybeSkel(width: 54.w, height: 34.h, radius: 999),
              const Spacer(),
              VybeSkel(width: 56.w, height: 14.h),
            ],
          ),
        ),
        // 타임라인 5행
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          child: Column(
            children: [
              for (var i = 0; i < 5; i++)
                _LineupTimelineRowSkeleton(isFirst: i == 0, isLast: i == 4),
            ],
          ),
        ),
      ],
    );
  }
}

// ── 타임라인 행 스켈레톤 (레일 구조 유지 + 카드 shimmer) ──
class _LineupTimelineRowSkeleton extends StatelessWidget {
  final bool isFirst;
  final bool isLast;
  const _LineupTimelineRowSkeleton({required this.isFirst, required this.isLast});

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 시간
          SizedBox(
            width: 46.w,
            child: Padding(
              padding: EdgeInsets.only(top: 20.h, right: 4.w),
              child: Align(
                alignment: Alignment.centerRight,
                child: VybeSkel(width: 34.w, height: 13.h),
              ),
            ),
          ),
          // 레일 (세로선 + 정적 점)
          SizedBox(
            width: 24.w,
            child: Stack(
              children: [
                if (!isFirst)
                  Positioned(
                    left: 11.w,
                    top: 0,
                    height: 20.h,
                    child: Container(width: 2.w, color: VybeColors.gray800),
                  ),
                if (!isLast)
                  Positioned(
                    left: 11.w,
                    top: 32.h,
                    bottom: 0,
                    child: Container(width: 2.w, color: VybeColors.gray800),
                  ),
                Positioned(
                  left: 6.w,
                  top: 18.h,
                  child: Container(
                    width: 12.r,
                    height: 12.r,
                    decoration: const BoxDecoration(
                      color: VybeColors.gray700,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ],
            ),
          ),
          // 카드
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: 14.h),
              child: Container(
                padding: EdgeInsets.all(12.r),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.03),
                  borderRadius: BorderRadius.circular(16.r),
                  border: Border.all(color: VybeColors.gray800),
                ),
                child: Row(
                  children: [
                    VybeSkel(width: 46.r, height: 46.r, radius: 99),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          FractionallySizedBox(
                            widthFactor: 0.46,
                            child: VybeSkel(height: 16.h),
                          ),
                          SizedBox(height: 8.h),
                          FractionallySizedBox(
                            widthFactor: 0.62,
                            child: VybeSkel(height: 12.h),
                          ),
                          SizedBox(height: 8.h),
                          Row(
                            children: [
                              VybeSkel(width: 44.w, height: 16.h),
                              SizedBox(width: 5.w),
                              VybeSkel(width: 38.w, height: 16.h),
                            ],
                          ),
                        ],
                      ),
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
