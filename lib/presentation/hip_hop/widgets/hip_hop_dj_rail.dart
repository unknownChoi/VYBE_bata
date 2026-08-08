import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vybe/core/navigation/swipe_back_page_route.dart';
import 'package:vybe/design_system/colors.dart';
import 'package:vybe/design_system/typography.dart';
import 'package:vybe/presentation/clubs/club_detail_screen.dart';
import 'package:vybe/presentation/common/widgets/vybe_skeleton.dart';
import 'package:vybe/presentation/hip_hop/hip_hop_style.dart';
import 'package:vybe/presentation/hip_hop/hip_hop_view_models.dart';

// 힙합 DJ rail — 오늘 공연 아티스트 가로 목록.

// ── 아티스트 레일 빈 상태 (오늘 공연 없음) ──
class HipHopRailEmpty extends StatelessWidget {
  const HipHopRailEmpty({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w),
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 22.h),
      decoration: BoxDecoration(
        color: VybeColors.gray900,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: VybeColors.gray800),
      ),
      alignment: Alignment.center,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.album_outlined, size: 16.r, color: VybeColors.gray500),
          SizedBox(width: 8.w),
          Text(
            '오늘 공연 예정인 아티스트가 없어요',
            style: VybeTypography.body4.copyWith(color: VybeColors.gray400),
          ),
        ],
      ),
    );
  }
}

// ── 오늘의 공연 아티스트 레일 ──
class HipHopDjRail extends StatelessWidget {
  final List<HipHopDj> djs;
  const HipHopDjRail({super.key, required this.djs});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: EdgeInsets.only(left: 16.w, right: 16.w, bottom: 4.h),
      child: Row(
        children: [
          for (var i = 0; i < djs.length; i++) ...[
            if (i > 0) SizedBox(width: 14.w),
            _HipHopDjCircle(d: djs[i]),
          ],
        ],
      ),
    );
  }
}

// 아티스트 레일 로딩 스켈레톤.
class HipHopDjRailSkeleton extends StatelessWidget {
  const HipHopDjRailSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const NeverScrollableScrollPhysics(),
      padding: EdgeInsets.only(left: 16.w, right: 16.w, bottom: 4.h),
      child: Row(
        children: [
          for (var i = 0; i < 5; i++) ...[
            if (i > 0) SizedBox(width: 14.w),
            SizedBox(
              width: 76.w,
              child: Column(
                children: [
                  VybeSkel(width: 72.r, height: 72.r, radius: 99),
                  SizedBox(height: 8.h),
                  VybeSkel(width: 56.w, height: 12.h, radius: 6),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _HipHopDjCircle extends StatelessWidget {
  final HipHopDj d;
  const _HipHopDjCircle({required this.d});

  @override
  Widget build(BuildContext context) {
    final grad = LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: d.bg,
    );
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      // 아티스트 탭 → 해당 클럽 상세.
      onTap: () => Navigator.of(context).push(
        SwipeBackPageRoute(builder: (_) => ClubDetailScreen(clubId: d.clubId)),
      ),
      child: SizedBox(
        width: 76.w,
        child: Column(
          children: [
            SizedBox(
              width: 72.r,
              height: 72.r,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  // 외곽 골드 링 + 내부 원.
                  Container(
                    width: 72.r,
                    height: 72.r,
                    padding: EdgeInsets.all(2.r),
                    decoration: BoxDecoration(
                      gradient: grad,
                      shape: BoxShape.circle,
                      border: Border.all(color: kHipAccent, width: 2),
                    ),
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: grad,
                        shape: BoxShape.circle,
                      ),
                      alignment: Alignment.center,
                      child: Icon(
                        d.isDj ? Icons.album_outlined : Icons.mic_none_rounded,
                        size: 24.r,
                        color: Colors.white.withValues(alpha: 0.85),
                      ),
                    ),
                  ),
                  // 시간 배지.
                  Positioned(
                    bottom: -3.h,
                    left: 0,
                    right: 0,
                    child: Center(
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 7.w,
                          vertical: 2.h,
                        ),
                        decoration: BoxDecoration(
                          color: kHipOnAccent,
                          borderRadius: BorderRadius.circular(99.r),
                          border: Border.all(color: kHipAccent),
                        ),
                        child: Text(
                          d.time,
                          style: TextStyle(
                            fontFamily: 'Pretendard',
                            fontSize: 10.sp,
                            height: 12 / 10,
                            fontWeight: FontWeight.w800,
                            color: kHipAccent,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              d.dj,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: VybeTypography.caption.copyWith(
                height: 14 / 12,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
            SizedBox(height: 2.h),
            Text(
              '${d.isDj ? 'DJ · ' : ''}${d.club}',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontFamily: 'Pretendard',
                fontSize: 11.sp,
                height: 13 / 11,
                color: VybeColors.gray500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
