import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:vybe/data/models/club_model.dart';
import 'package:vybe/design_system/colors.dart';
import 'package:vybe/design_system/typography.dart';
import 'package:vybe/presentation/clubs/club_detail_screen.dart';
import 'package:vybe/presentation/home/viewmodels/home_nearby_viewmodel.dart';

class HomeNearbyClubs extends ConsumerWidget {
  const HomeNearbyClubs({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final clubsAsync = ref.watch(homeNearbyClubsProvider);

    return Padding(
      padding: EdgeInsets.fromLTRB(24.w, 32.h, 24.w, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '주변 클럽',
                style: VybeTypography.heading4.copyWith(color: Colors.white),
              ),
              Row(
                children: [
                  Text(
                    '전체보기',
                    style: VybeTypography.caption
                        .copyWith(color: VybeColors.gray400),
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
            ],
          ),
          SizedBox(height: 24.h),
          clubsAsync.when(
            data: (clubs) => SingleChildScrollView(
              scrollDirection: Axis.horizontal,
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
              height: 152.h,
              child: const Center(
                child: CircularProgressIndicator(
                  color: VybeColors.mainPurple500,
                ),
              ),
            ),
            error: (_, __) => SizedBox(
              height: 152.h,
              child: Center(
                child: Text(
                  '클럽 정보를 불러올 수 없어요',
                  style:
                      VybeTypography.body2.copyWith(color: VybeColors.gray500),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ClubCard extends StatelessWidget {
  final ClubModel club;
  const _ClubCard({required this.club});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => ClubDetailScreen(clubId: club.clubId),
        ),
      ),
      child: SizedBox(
      width: 112.w,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 112.w,
            height: 112.h,
            decoration: BoxDecoration(
              color: VybeColors.gray800,
              borderRadius: BorderRadius.circular(6.r),
              border: Border.all(color: VybeColors.gray900, width: 1),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(6.r),
              child: club.thumbnailUrl.isNotEmpty
                  ? Image.network(club.thumbnailUrl, fit: BoxFit.cover)
                  : null,
            ),
          ),
          SizedBox(height: 8.h),
          Row(
            children: [
              if (club.isVybeRecommended) ...[
                SvgPicture.asset(
                  'assets/icons/common/club_card/vybe_recommend.svg',
                  width: 14.r,
                  height: 14.r,
                ),
                SizedBox(width: 4.w),
              ],
              Expanded(
                child: Text(
                  club.name,
                  style: TextStyle(
                    fontFamily: 'Pretendard',
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w500,
                    color: Colors.white,
                    letterSpacing: 14 * -0.025,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          SizedBox(height: 4.h),
          Row(
            children: [
              Text(
                club.area,
                style:
                    VybeTypography.caption.copyWith(color: VybeColors.gray500),
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 4.w),
                child: Container(
                  width: 2.r,
                  height: 2.r,
                  decoration: const BoxDecoration(
                    color: VybeColors.gray500,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
              Text(
                club.genre,
                style:
                    VybeTypography.caption.copyWith(color: VybeColors.gray500),
              ),
            ],
          ),
        ],
      ),
      ),
    );
  }
}
