import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:vybe/design_system/colors.dart';
import 'package:vybe/design_system/typography.dart';

class ClubItem {
  final String image;
  final String name;
  final String area;
  final String genre;
  const ClubItem({
    required this.image,
    required this.name,
    required this.area,
    required this.genre,
  });
}

const _nearbyClubs = [
  ClubItem(
    image: 'assets/images/home_screen/club_image_1.png',
    name: '홍대 클럽 레이저',
    area: '홍대',
    genre: '힙합',
  ),
  ClubItem(
    image: 'assets/images/home_screen/club_image_2.png',
    name: '버뮤다',
    area: '홍대',
    genre: '힙합',
  ),
  ClubItem(
    image: 'assets/images/home_screen/club_image_3.png',
    name: '인클',
    area: '홍대',
    genre: '힙합',
  ),
];

class HomeNearbyClubs extends StatelessWidget {
  const HomeNearbyClubs({super.key});

  @override
  Widget build(BuildContext context) {
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
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: List.generate(_nearbyClubs.length, (i) {
                return Padding(
                  padding: EdgeInsets.only(
                    right: i < _nearbyClubs.length - 1 ? 12.w : 0,
                  ),
                  child: _ClubCard(club: _nearbyClubs[i]),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }
}

class _ClubCard extends StatelessWidget {
  final ClubItem club;
  const _ClubCard({required this.club});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 112.w,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 112.w,
            height: 112.h,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(6.r),
              border: Border.all(color: VybeColors.gray900, width: 1),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(6.r),
              child: Image.asset(club.image, fit: BoxFit.cover),
            ),
          ),
          SizedBox(height: 8.h),
          Text(
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
          SizedBox(height: 4.h),
          Row(
            children: [
              Text(
                club.area,
                style: VybeTypography.caption
                    .copyWith(color: VybeColors.gray500),
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
                style: VybeTypography.caption
                    .copyWith(color: VybeColors.gray500),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
