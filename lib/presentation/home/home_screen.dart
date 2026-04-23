import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:vybe/design_system/colors.dart';
import 'package:vybe/design_system/typography.dart';

// ── 배너 데이터 ──
const _banners = [
  'assets/images/home_screen/banner_ad_1.png',
  'assets/images/home_screen/banner_ad_2.png',
  'assets/images/home_screen/banner_ad_3.png',
  'assets/images/home_screen/banner_ad_4.png',
];

// ── 카테고리 데이터 ──
class _CategoryItem {
  final String icon;
  final String label;
  const _CategoryItem({required this.icon, required this.label});
}

const _categories = [
  _CategoryItem(
    icon: 'assets/icons/home_screen/category_grid/lounge.svg',
    label: 'VYBE 추천',
  ),
  _CategoryItem(
    icon: 'assets/icons/home_screen/category_grid/hot_place.svg',
    label: '핫플레이스',
  ),
  _CategoryItem(
    icon: 'assets/icons/home_screen/category_grid/free_entry.svg',
    label: '입장료 무료',
  ),
  _CategoryItem(
    icon: 'assets/icons/home_screen/category_grid/service_drink.svg',
    label: '서비스 음료',
  ),
  _CategoryItem(
    icon: 'assets/icons/home_screen/category_grid/hiphop.svg',
    label: '힙합',
  ),
  _CategoryItem(
    icon: 'assets/icons/home_screen/category_grid/edm.svg',
    label: 'EDM',
  ),
  _CategoryItem(
    icon: 'assets/icons/home_screen/category_grid/kpop.svg',
    label: 'K-POP',
  ),
  _CategoryItem(
    icon: 'assets/icons/home_screen/category_grid/vybe_recommend.svg',
    label: '라운지',
  ),
];

// ── 클럽 더미 데이터 ──
class _ClubItem {
  final String image;
  final String name;
  final String area;
  final String genre;
  const _ClubItem({
    required this.image,
    required this.name,
    required this.area,
    required this.genre,
  });
}

const _nearbyClubs = [
  _ClubItem(
    image: 'assets/images/home_screen/club_image_1.png',
    name: '홍대 클럽 레이저',
    area: '홍대',
    genre: '힙합',
  ),
  _ClubItem(
    image: 'assets/images/home_screen/club_image_2.png',
    name: '버뮤다',
    area: '홍대',
    genre: '힙합',
  ),
  _ClubItem(
    image: 'assets/images/home_screen/club_image_3.png',
    name: '인클',
    area: '홍대',
    genre: '힙합',
  ),
];

class HomeScreen extends StatefulWidget {
  final VoidCallback? onSearchTap;
  const HomeScreen({super.key, this.onSearchTap});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

// VybeButton.special과 동일한 그라데이션
const _borderGradient = LinearGradient(
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
  colors: [
    Color(0xFFB5FF60),
    Color(0xFFC8E77F),
    Color(0xFFDACA9E),
    Color(0xFFFF9EDB),
    Color(0xFFDD82E4),
    Color(0xFFBB67ED),
    Color(0xFF994CF5),
    Color(0xFF7731FE),
  ],
  stops: [0.0, 0.142, 0.285, 0.569, 0.677, 0.785, 0.892, 1.0],
);

class _HomeScreenState extends State<HomeScreen> {
  late final PageController _bannerController;
  late final Timer _bannerTimer;
  int _bannerIndex = 0;

  @override
  void initState() {
    super.initState();
    _bannerController = PageController();
    _bannerTimer = Timer.periodic(const Duration(seconds: 4), (_) {
      final next = (_bannerIndex + 1) % _banners.length;
      _bannerController.animateToPage(
        next,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    });
  }

  @override
  void dispose() {
    _bannerTimer.cancel();
    _bannerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: VybeColors.background,
      body: SafeArea(
        bottom: false,
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(child: _buildGnb()),
            SliverToBoxAdapter(child: _buildLocationBar()),
            SliverToBoxAdapter(child: _buildBanner()),
            SliverToBoxAdapter(child: _buildCategoryGrid()),
            SliverToBoxAdapter(
              child: Container(height: 8.h, color: VybeColors.gray900),
            ),
            SliverToBoxAdapter(child: _buildNearbyClubs()),
            SliverToBoxAdapter(child: SizedBox(height: 32.h)),
          ],
        ),
      ),
    );
  }

  // ── GNB ──

  Widget _buildGnb() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 10.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          SvgPicture.asset(
            'assets/icons/common/vybe_white_logo.svg',
            height: 20.h,
          ),
          Row(
            children: [
              GestureDetector(
                onTap: widget.onSearchTap,
                child: SvgPicture.asset(
                  'assets/icons/home_screen/search.svg',
                  width: 24.r,
                  height: 24.r,
                  colorFilter: const ColorFilter.mode(
                    Colors.white,
                    BlendMode.srcIn,
                  ),
                ),
              ),
              SizedBox(width: 12.w),
              GestureDetector(
                onTap: () {},
                child: SvgPicture.asset(
                  'assets/icons/home_screen/notification.svg',
                  width: 24.r,
                  height: 24.r,
                  colorFilter: const ColorFilter.mode(
                    Colors.white,
                    BlendMode.srcIn,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── 위치 바 ──

  Widget _buildLocationBar() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 10.h),
      child: Row(
        children: [
          SvgPicture.asset(
            'assets/icons/home_screen/loaction_pin.svg',
            width: 16.r,
            height: 16.r,
            colorFilter: const ColorFilter.mode(
              VybeColors.gray200,
              BlendMode.srcIn,
            ),
          ),
          SizedBox(width: 4.w),
          Text(
            '내 주변 검색',
            style: VybeTypography.body3.copyWith(color: VybeColors.gray200),
          ),
        ],
      ),
    );
  }

  // ── 배너 ──

  Widget _buildBanner() {
    return SizedBox(
      height: 228.h,
      child: Stack(
        children: [
          PageView.builder(
            controller: _bannerController,
            itemCount: _banners.length,
            onPageChanged: (i) => setState(() => _bannerIndex = i),
            itemBuilder: (_, i) => Image.asset(
              _banners[i],
              fit: BoxFit.cover,
            ),
          ),
          // 페이지 인디케이터
          Positioned(
            right: 14.w,
            bottom: 14.h,
            child: Container(
              padding:
                  EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.6),
                borderRadius: BorderRadius.circular(999.r),
              ),
              child: Text(
                '${_bannerIndex + 1}/${_banners.length}',
                style: TextStyle(
                  fontFamily: 'Pretendard',
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w400,
                  color: Colors.white,
                  letterSpacing: 12 * -0.025,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── 카테고리 그리드 ──

  Widget _buildCategoryGrid() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 24.h),
      child: Wrap(
        spacing: 24.w,
        runSpacing: 24.h,
        alignment: WrapAlignment.center,
        children: _categories.map(_buildCategoryItem).toList(),
      ),
    );
  }

  Widget _buildCategoryItem(_CategoryItem item) {
    final isVybe = item.label == 'VYBE 추천';

    final iconInner = Container(
      decoration: BoxDecoration(
        color: VybeColors.gray900,
        borderRadius: BorderRadius.circular(isVybe ? 11.r : 12.r),
      ),
      child: Center(
        child: SvgPicture.asset(
          item.icon,
          width: 40.r,
          height: 40.r,
          colorFilter: const ColorFilter.mode(
            Colors.white,
            BlendMode.srcIn,
          ),
        ),
      ),
    );

    final iconBox = isVybe
        ? Container(
            width: 60.w,
            height: 60.h,
            decoration: BoxDecoration(
              gradient: _borderGradient,
              borderRadius: BorderRadius.circular(12.r),
            ),
            padding: const EdgeInsets.all(1),
            child: iconInner,
          )
        : Container(
            width: 60.w,
            height: 60.h,
            decoration: BoxDecoration(
              color: VybeColors.gray900,
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: iconInner,
          );

    return SizedBox(
      width: 60.w,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          iconBox,
          SizedBox(height: 4.h),
          Text(
            item.label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'Pretendard',
              fontSize: 12.sp,
              fontWeight: FontWeight.w600,
              color: VybeColors.gray200,
              letterSpacing: 12 * -0.025,
            ),
          ),
        ],
      ),
    );
  }

  // ── 주변 클럽 ──

  Widget _buildNearbyClubs() {
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
                style:
                    VybeTypography.heading4.copyWith(color: Colors.white),
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
                  child: _buildClubCard(_nearbyClubs[i]),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildClubCard(_ClubItem club) {
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
