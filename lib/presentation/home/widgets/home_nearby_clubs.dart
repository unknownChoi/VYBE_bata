import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:vybe/data/models/club_model.dart';
import 'package:vybe/design_system/colors.dart';
import 'package:vybe/design_system/typography.dart';
import 'package:vybe/presentation/common/widgets/vybe_meta_dot.dart';
import 'package:vybe/presentation/clubs/club_detail_screen.dart';
import 'package:vybe/presentation/common/widgets/vybe_recommend_badge.dart';
import 'package:vybe/presentation/home/viewmodels/home_nearby_viewmodel.dart';
import 'package:vybe/presentation/main_scaffold/nav_bar_visibility_provider.dart';

class HomeNearbyClubs extends ConsumerWidget {
  const HomeNearbyClubs({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final clubsAsync = ref.watch(homeNearbyClubsProvider);

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
                Text(
                  '주변 클럽',
                  style: VybeTypography.heading4.copyWith(color: Colors.white),
                ),
                GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  // 주변 탭(index 1)으로 전환 — MainScaffold가 listen해 점프.
                  onTap: () =>
                      ref.read(tabSwitchRequestProvider.notifier).request(1),
                  child: Row(
                    children: [
                      Text(
                        '전체보기',
                        style: VybeTypography.caption.copyWith(
                          color: VybeColors.gray400,
                        ),
                      ),
                      SizedBox(width: 4.w),
                      SvgPicture.asset(
                        'assets/icons/home_screen/add_content.svg',
                        width: 4.w,
                        height: 8.h,
                        colorFilter: const ColorFilter.mode(
                          VybeColors.gray400,
                          BlendMode.srcIn,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          clubsAsync.when(
            data: (clubs) => SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.symmetric(horizontal: 24.w),
              child: Row(
                children: List.generate(clubs.length, (i) {
                  return Padding(
                    padding: EdgeInsets.only(
                      right: i < clubs.length - 1 ? 12.w : 0,
                    ),
                    child: _ClubCard(club: clubs[i]),
                  );
                }),
              ),
            ),
            loading: () => SizedBox(
              height: 156.h,
              child: const Center(
                child: CircularProgressIndicator(
                  color: VybeColors.mainPurple500,
                ),
              ),
            ),
            error: (_, __) => SizedBox(
              height: 156.h,
              child: Center(
                child: Text(
                  '클럽 정보를 불러올 수 없어요',
                  style: VybeTypography.body2.copyWith(
                    color: VybeColors.gray500,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// 썸네일 없을 때 클럽별 일관된 그라데이션 (clubId 해시 기반).
const _fallbackGradients = [
  [Color(0xFF2B1655), VybeColors.mainPurple500, Color(0xFFFF4D8D)],
  [Color(0xFF06FFA5), Color(0xFF3A86FF), Color(0xFF3A86FF)],
  [Color(0xFFFB5607), Color(0xFFFFBE0B), Color(0xFFFFBE0B)],
  [Color(0xFF06FFA5), Color(0xFF1B9AAA), Color(0xFF1B9AAA)],
  [Color(0xFF6D4C91), Color(0xFF2A2D34), Color(0xFF2A2D34)],
];

class _ClubCard extends StatelessWidget {
  final ClubModel club;
  const _ClubCard({required this.club});

  @override
  Widget build(BuildContext context) {
    final grad =
        _fallbackGradients[club.clubId.hashCode.abs() %
            _fallbackGradients.length];

    return GestureDetector(
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => ClubDetailScreen(clubId: club.clubId),
        ),
      ),
      // ClipRRect로 감싸지 않고 Container 자체 클립 사용 —
      // 바깥 클립이 코너 호에서 1px 테두리를 깎아 모서리가 안 보이던 문제 방지.
      child: Container(
        width: 250.w,
        height: 156.h,
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: grad,
          ),
          // 카드 하단이 배경색과 거의 같아 라운딩이 안 보여 테두리를 한 단계 밝게.
          border: Border.all(color: VybeColors.gray700),
          borderRadius: BorderRadius.circular(16.r),
        ),
        child: Stack(
          fit: StackFit.expand,
          children: [
            if (club.thumbnailUrl.isNotEmpty)
              Image.network(
                club.thumbnailUrl,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => const SizedBox.shrink(),
              ),
            // 하단 가독성 그라데이션
            const DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.transparent, Color(0xF00A0A0E)],
                  stops: [0.32, 1.0],
                ),
              ),
            ),
            // 평점 배지 (우상단)
            Positioned(
              top: 12.h,
              right: 12.w,
              child: _Pill(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.star_rounded,
                      size: 13.r,
                      color: VybeColors.mainLime500,
                    ),
                    SizedBox(width: 3.w),
                    Text(club.rating.toStringAsFixed(1), style: _badgeText),
                  ],
                ),
              ),
            ),
            // 정보 (하단)
            Positioned(
              left: 14.w,
              right: 14.w,
              bottom: 13.h,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          club.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontFamily: 'Pretendard',
                            fontSize: 18.sp,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                            letterSpacing: 18 * -0.025,
                          ),
                        ),
                      ),
                      // VYBE 추천 뱃지 — 클럽 이름 옆.
                      if (club.isVybeRecommended) ...[
                        SizedBox(width: 6.w),
                        const VybeRecommendBadge(size: 10),
                      ],
                    ],
                  ),
                  SizedBox(height: 5.h),
                  Row(
                    children: [
                      Text(
                        club.area,
                        style: VybeTypography.caption.copyWith(
                          color: VybeColors.gray300,
                        ),
                      ),
                      const VybeMetaDot(),
                      Text(
                        club.genre,
                        style: VybeTypography.caption.copyWith(
                          color: VybeColors.gray400,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

final _badgeText = TextStyle(
  fontFamily: 'Pretendard',
  fontSize: 11.sp,
  height: 12 / 11,
  fontWeight: FontWeight.w700,
  color: Colors.white,
);

class _Pill extends StatelessWidget {
  final Widget child;
  const _Pill({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 9.w, vertical: 5.h),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(99.r),
      ),
      child: child,
    );
  }
}
