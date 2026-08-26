import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vybe/design_system/colors.dart';
import 'package:vybe/presentation/common/widgets/vybe_skeleton.dart';
import 'package:vybe/presentation/home/widgets/home_banner_skeleton.dart';

/// 홈 화면 전체 스켈레톤.
///
/// 회원가입 완료 → 홈 진입 시 데이터(배너·주변 클럽·유저 이름)가 채워지기 전
/// 레이아웃이 비어 보이는 구간을 덮는다. 실제 홈(`HomeScreen`) 구성 순서·여백과
/// 동일하게 맞춰 스켈레톤 → 실제 화면 전환 시 위치 점프가 없도록 함.
///
/// 구성: 위치 칩 + 인사말 / 배너 / 카테고리 그리드 / 주변 클럽
class HomeScreenSkeleton extends StatelessWidget {
  const HomeScreenSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    final top = MediaQuery.paddingOf(context).top;

    return ListView(
      physics: const NeverScrollableScrollPhysics(),
      padding: EdgeInsets.only(
        top: top + 52.h,
        bottom: MediaQuery.paddingOf(context).bottom + 100.h,
      ),
      children: const [
        _GreetingSkeleton(),
        HomeBannerSkeleton(),
        _CategoryGridSkeleton(),
        _NearbyClubsSkeleton(),
      ],
    );
  }
}

// ── 인사말 (HomeLocationGreeting) ────────────────────────────────

class _GreetingSkeleton extends StatelessWidget {
  const _GreetingSkeleton();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(24.w, 6.h, 24.w, 16.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 위치 칩 (pill)
          Padding(
            padding: EdgeInsets.only(bottom: 12.h),
            child: VybeSkel(width: 84.w, height: 30.h, radius: 999),
          ),
          // "오늘 밤, OO님은 / 어디서 놀까요?" 2줄
          VybeSkel(width: 200.w, height: 26.h, radius: 8),
          SizedBox(height: 8.h),
          VybeSkel(width: 150.w, height: 26.h, radius: 8),
        ],
      ),
    );
  }
}

// ── 배너 (HomeBanner) ────────────────────────────────────────────
// ── 카테고리 그리드 (HomeCategoryGrid) ───────────────────────────

class _CategoryGridSkeleton extends StatelessWidget {
  const _CategoryGridSkeleton();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 12.h),
      child: GridView.count(
        crossAxisCount: 4,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        mainAxisSpacing: 18.h,
        crossAxisSpacing: 8.w,
        childAspectRatio: 0.8,
        children: List.generate(8, (_) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 실제 타일과 같은 정사각 규칙 — 둘 다 `.w` (home_category_grid 참고)
              VybeSkel(width: 62.w, height: 62.w, radius: 18),
              SizedBox(height: 8.h),
              VybeSkel(width: 44.w, height: 12.h, radius: 4),
            ],
          );
        }),
      ),
    );
  }
}

// ── 주변 클럽 (HomeNearbyClubs) ──────────────────────────────────

class _NearbyClubsSkeleton extends StatelessWidget {
  const _NearbyClubsSkeleton();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(0, 8.h, 0, 8.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(24.w, 0, 24.w, 16.h),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                VybeSkel(width: 76.w, height: 18.h, radius: 6),
                VybeSkel(width: 52.w, height: 12.h, radius: 6),
              ],
            ),
          ),
          // 가로 카드 2.5장 — 스크롤 없이 클립(실제 카드 250x156).
          SizedBox(
            height: 156.h,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              physics: const NeverScrollableScrollPhysics(),
              padding: EdgeInsets.symmetric(horizontal: 24.w),
              itemCount: 3,
              separatorBuilder: (_, __) => SizedBox(width: 12.w),
              itemBuilder: (_, __) => _ClubCardSkeleton(),
            ),
          ),
        ],
      ),
    );
  }
}

class _ClubCardSkeleton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 250.w,
      height: 156.h,
      child: Stack(
        children: [
          const Positioned.fill(child: VybeSkel(radius: 16)),
          // 카드 하단 텍스트 영역(클럽명·지역) 자리 표시.
          Positioned(
            left: 14.w,
            right: 14.w,
            bottom: 14.h,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 120.w,
                  height: 14.h,
                  decoration: BoxDecoration(
                    color: VybeColors.gray800,
                    borderRadius: BorderRadius.circular(4.r),
                  ),
                ),
                SizedBox(height: 6.h),
                Container(
                  width: 78.w,
                  height: 11.h,
                  decoration: BoxDecoration(
                    color: VybeColors.gray800,
                    borderRadius: BorderRadius.circular(4.r),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
