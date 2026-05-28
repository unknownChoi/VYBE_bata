import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:vybe/design_system/colors.dart';
import 'package:vybe/presentation/clubs/widgets/subway_line_badge.dart';

class DetailHomeTab extends StatefulWidget {
  const DetailHomeTab({super.key});

  @override
  State<DetailHomeTab> createState() => _DetailHomeTabState();
}

class _DetailHomeTabState extends State<DetailHomeTab> {
  bool _addrExpanded = false;
  bool _hoursExpanded = false;

  static const List<List<String>> _hours = [
    ['월', '11:00 - 02:00'],
    ['화', '11:00 - 02:00'],
    ['수', '11:00 - 02:00'],
    ['목', '11:00 - 02:00'],
    ['금', '11:00 - 02:00'],
    ['토', '11:00 - 02:00'],
    ['일', '정기휴무'],
  ];

  @override
  Widget build(BuildContext context) {
    return ListView(
      physics: const ClampingScrollPhysics(),
      padding: EdgeInsets.zero,
      children: [
        _buildInfoSection(),
        _sectionDivider(),
        _buildMenuPreviewSection(),
        _sectionDivider(),
        _buildPhotoPreviewSection(),
        _sectionDivider(),
        _buildNearbyClubsSection(),
        SizedBox(height: 32.h),
      ],
    );
  }

  Widget _sectionDivider() {
    return Container(
      height: 8.h,
      decoration: const BoxDecoration(
        color: Colors.black,
        border: Border.symmetric(
          horizontal: BorderSide(color: Color(0xFF1F1F23)),
        ),
      ),
    );
  }

  // ── INFO SECTION ──

  Widget _buildInfoSection() {
    final today = DateTime.now().weekday - 1; // 0=월 ~ 6=일
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 24.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Address row
          _infoRow(
            icon: SvgPicture.asset(
              'assets/icons/common/club_card/location_pin.svg',
              width: 17.r,
              height: 17.r,
              colorFilter: const ColorFilter.mode(
                VybeColors.gray500,
                BlendMode.srcIn,
              ),
            ),
            child: GestureDetector(
              onTap: () => setState(() => _addrExpanded = !_addrExpanded),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '서울 마포구 잔다리로 12 지하 1층',
                        style: TextStyle(
                          fontFamily: 'Pretendard',
                          fontSize: 14.sp,
                          color: VybeColors.gray200,
                          height: 1.5,
                        ),
                      ),
                      AnimatedRotation(
                        turns: _addrExpanded ? 0.5 : 0,
                        duration: const Duration(milliseconds: 200),
                        child: Icon(
                          Icons.keyboard_arrow_down_rounded,
                          color: VybeColors.gray500,
                          size: 16.r,
                        ),
                      ),
                    ],
                  ),
                  AnimatedCrossFade(
                    firstChild: const SizedBox.shrink(),
                    secondChild: Padding(
                      padding: EdgeInsets.only(top: 10.h),
                      child: Row(
                        children: [
                          const SubwayLineBadge(line: 9),
                          SizedBox(width: 6.w),
                          Text(
                            '상수역 1번 출구에서 422m',
                            style: TextStyle(
                              fontFamily: 'Pretendard',
                              fontSize: 13.sp,
                              color: VybeColors.gray300,
                            ),
                          ),
                        ],
                      ),
                    ),
                    crossFadeState: _addrExpanded
                        ? CrossFadeState.showSecond
                        : CrossFadeState.showFirst,
                    duration: const Duration(milliseconds: 300),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: 16.h),
          // Hours row
          _infoRow(
            icon: SvgPicture.asset(
              'assets/icons/common/club_card/time.svg',
              width: 17.r,
              height: 17.r,
              colorFilter: const ColorFilter.mode(
                VybeColors.gray500,
                BlendMode.srcIn,
              ),
            ),
            child: GestureDetector(
              onTap: () =>
                  setState(() => _hoursExpanded = !_hoursExpanded),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Text(
                            '영업중',
                            style: TextStyle(
                              fontFamily: 'Pretendard',
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w600,
                              color: VybeColors.mainLime500,
                            ),
                          ),
                          Padding(
                            padding:
                                EdgeInsets.symmetric(horizontal: 6.w),
                            child: Container(
                              width: 2.r,
                              height: 2.r,
                              decoration: const BoxDecoration(
                                color: VybeColors.gray700,
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),
                          Text(
                            '02:00에 영업 종료',
                            style: TextStyle(
                              fontFamily: 'Pretendard',
                              fontSize: 14.sp,
                              color: VybeColors.gray400,
                            ),
                          ),
                        ],
                      ),
                      AnimatedRotation(
                        turns: _hoursExpanded ? 0.5 : 0,
                        duration: const Duration(milliseconds: 200),
                        child: Icon(
                          Icons.keyboard_arrow_down_rounded,
                          color: VybeColors.gray500,
                          size: 16.r,
                        ),
                      ),
                    ],
                  ),
                  if (_hoursExpanded) ...[
                    SizedBox(height: 10.h),
                    ...List.generate(_hours.length, (i) {
                      final isToday = i == today;
                      return Padding(
                        padding: EdgeInsets.only(bottom: 6.h),
                        child: Row(
                          children: [
                            SizedBox(
                              width: 18.w,
                              child: Text(
                                _hours[i][0],
                                style: TextStyle(
                                  fontFamily: 'Pretendard',
                                  fontSize: 13.sp,
                                  fontWeight: isToday
                                      ? FontWeight.w700
                                      : FontWeight.w400,
                                  color: isToday
                                      ? Colors.white
                                      : VybeColors.gray500,
                                ),
                              ),
                            ),
                            SizedBox(width: 10.w),
                            Text(
                              _hours[i][1],
                              style: TextStyle(
                                fontFamily: 'Pretendard',
                                fontSize: 13.sp,
                                fontWeight: isToday
                                    ? FontWeight.w600
                                    : FontWeight.w400,
                                color: isToday
                                    ? Colors.white
                                    : VybeColors.gray500,
                              ),
                            ),
                            if (isToday) ...[
                              SizedBox(width: 8.w),
                              Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 6.w,
                                  vertical: 1.h,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0x247731FE),
                                  borderRadius:
                                      BorderRadius.circular(4.r),
                                ),
                                child: Text(
                                  '오늘',
                                  style: TextStyle(
                                    fontFamily: 'Pretendard',
                                    fontSize: 10.sp,
                                    fontWeight: FontWeight.w700,
                                    color: VybeColors.mainPurple500,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      );
                    }),
                  ],
                ],
              ),
            ),
          ),
          SizedBox(height: 16.h),
          // Entry fee row
          _infoRow(
            icon: SvgPicture.asset(
              'assets/icons/common/club_card/won.svg',
              width: 17.r,
              height: 17.r,
              colorFilter: const ColorFilter.mode(
                VybeColors.gray500,
                BlendMode.srcIn,
              ),
            ),
            child: RichText(
              text: TextSpan(
                style: TextStyle(
                  fontFamily: 'Pretendard',
                  fontSize: 14.sp,
                  color: VybeColors.gray200,
                ),
                children: [
                  const TextSpan(text: '입장료 '),
                  TextSpan(
                    text: '0 ~ 10,000원',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: 16.h),
          // Instagram row
          _infoRow(
            icon: SvgPicture.asset(
              'assets/club_detail/icons/sns_url.svg',
              width: 17.r,
              height: 17.r,
              colorFilter: const ColorFilter.mode(
                VybeColors.gray500,
                BlendMode.srcIn,
              ),
            ),
            child: Text(
              '@awesomered_omg',
              style: TextStyle(
                fontFamily: 'Pretendard',
                fontSize: 14.sp,
                color: VybeColors.accentBlue500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoRow({required Widget icon, required Widget child}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 20.w,
          child: Padding(
            padding: EdgeInsets.only(top: 1.h),
            child: Center(child: icon),
          ),
        ),
        SizedBox(width: 12.w),
        Expanded(child: child),
      ],
    );
  }

  // ── MENU PREVIEW ──

  Widget _buildMenuPreviewSection() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 24.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionHeader('메뉴'),
          SizedBox(height: 4.h),
          _menuPreviewItem(
            badge: '대표',
            name: 'LEMON DROP',
            desc: '레몬 보드카 베이스 · 새콤달콤',
            price: '15,000원',
            image: 'assets/club_detail/images/menu_image.png',
          ),
          _menuPreviewItem(
            badge: '대표',
            name: 'PURPLE HAZE',
            desc: '블루베리 진 토닉',
            price: '16,000원',
            image: 'assets/club_detail/images/menu_image.png',
          ),
          SizedBox(height: 12.h),
          Text(
            '메뉴 항목과 가격은 매장 사정에 따라 다를 수 있습니다.',
            style: TextStyle(
              fontFamily: 'Pretendard',
              fontSize: 11.sp,
              color: VybeColors.gray600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _menuPreviewItem({
    required String badge,
    required String name,
    required String desc,
    required String price,
    required String image,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 16.h),
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: VybeColors.gray800)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 7.w,
                        vertical: 2.h,
                      ),
                      decoration: BoxDecoration(
                        color: VybeColors.mainPurple500,
                        borderRadius: BorderRadius.circular(999.r),
                      ),
                      child: Text(
                        badge,
                        style: TextStyle(
                          fontFamily: 'Pretendard',
                          fontSize: 10.sp,
                          fontWeight: FontWeight.w500,
                          color: VybeColors.gray200,
                        ),
                      ),
                    ),
                    SizedBox(width: 6.w),
                    Text(
                      name,
                      style: TextStyle(
                        fontFamily: 'Pretendard',
                        fontSize: 14.sp,
                        color: VybeColors.gray200,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 6.h),
                Text(
                  desc,
                  style: TextStyle(
                    fontFamily: 'Pretendard',
                    fontSize: 12.sp,
                    color: VybeColors.gray500,
                  ),
                ),
                SizedBox(height: 10.h),
                Text(
                  price,
                  style: TextStyle(
                    fontFamily: 'Pretendard',
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: 16.w),
          ClipRRect(
            borderRadius: BorderRadius.circular(6.r),
            child: Image.asset(
              image,
              width: 100.r,
              height: 100.r,
              fit: BoxFit.cover,
            ),
          ),
        ],
      ),
    );
  }

  // ── PHOTO PREVIEW ──

  Widget _buildPhotoPreviewSection() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 24.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionHeader('사진', count: '28'),
          SizedBox(height: 14.h),
          SizedBox(
            height: 110.h,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // big left image
                Expanded(
                  flex: 2,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10.r),
                    child: Image.asset(
                      'assets/club_detail/images/home_tab_image_1.jpg',
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                SizedBox(width: 6.w),
                // right 2×2 grid
                Expanded(
                  flex: 2,
                  child: Column(
                    children: [
                      Expanded(
                        child: Row(
                          children: [
                            Expanded(
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(8.r),
                                child: Image.asset(
                                  'assets/club_detail/images/home_tab_image_2.png',
                                  fit: BoxFit.cover,
                                  width: double.infinity,
                                  height: double.infinity,
                                ),
                              ),
                            ),
                            SizedBox(width: 6.w),
                            Expanded(
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(8.r),
                                child: Image.asset(
                                  'assets/club_detail/images/home_tab_image_3.png',
                                  fit: BoxFit.cover,
                                  width: double.infinity,
                                  height: double.infinity,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 6.h),
                      Expanded(
                        child: Row(
                          children: [
                            // "+24" overlay cell
                            Expanded(
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(8.r),
                                child: Stack(
                                  fit: StackFit.expand,
                                  children: [
                                    Container(
                                      color: const Color(0xFF1A1A20),
                                      child: DecoratedBox(
                                        decoration: BoxDecoration(
                                          gradient: RadialGradient(
                                            colors: [
                                              VybeColors.mainPurple500
                                                  .withValues(alpha: 0.4),
                                              Colors.transparent,
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                    Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          '+24',
                                          style: TextStyle(
                                            fontFamily: 'Pretendard',
                                            fontSize: 16.sp,
                                            fontWeight: FontWeight.w700,
                                            color: Colors.white,
                                          ),
                                        ),
                                        Text(
                                          '더보기',
                                          style: TextStyle(
                                            fontFamily: 'Pretendard',
                                            fontSize: 11.sp,
                                            color: VybeColors.gray400,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            SizedBox(width: 6.w),
                            Expanded(
                              child: Opacity(
                                opacity: 0.7,
                                child: ClipRRect(
                                  borderRadius:
                                      BorderRadius.circular(8.r),
                                  child: Image.asset(
                                    'assets/club_detail/images/image_tab_image_1.png',
                                    fit: BoxFit.cover,
                                    width: double.infinity,
                                    height: double.infinity,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── NEARBY CLUBS ──

  static const _clubs = [
    {
      'image': 'assets/club_detail/images/home_tab_image_1.jpg',
      'name': '홍대 클럽 레이저',
      'area': '홍대',
      'genre': '힙합',
      'rating': '4.5',
    },
    {
      'image': 'assets/club_detail/images/home_tab_image_2.png',
      'name': '버뮤다',
      'area': '홍대',
      'genre': '힙합',
      'rating': '4.3',
    },
    {
      'image': 'assets/club_detail/images/home_tab_image_3.png',
      'name': '인클',
      'area': '홍대',
      'genre': '힙합',
      'rating': '4.7',
    },
    {
      'image': 'assets/club_detail/images/image_tab_image_1.png',
      'name': '벨로주',
      'area': '홍대',
      'genre': '재즈',
      'rating': '4.6',
    },
  ];

  Widget _buildNearbyClubsSection() {
    return Padding(
      padding: EdgeInsets.only(top: 24.h, bottom: 24.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w),
            child: _sectionHeader('주변 클럽'),
          ),
          SizedBox(height: 14.h),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.symmetric(horizontal: 20.w),
            child: Row(
              children: _clubs.map((club) {
                return Padding(
                  padding: EdgeInsets.only(right: 12.w),
                  child: SizedBox(
                    width: 124.w,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Stack(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(10.r),
                              child: Image.asset(
                                club['image']!,
                                width: 124.w,
                                height: 124.h,
                                fit: BoxFit.cover,
                              ),
                            ),
                            Positioned(
                              top: 6.h,
                              left: 6.w,
                              child: Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 6.w,
                                  vertical: 2.h,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.black
                                      .withValues(alpha: 0.6),
                                  borderRadius:
                                      BorderRadius.circular(4.r),
                                ),
                                child: Row(
                                  children: [
                                    SvgPicture.asset(
                                      'assets/icons/common/club_card/star.svg',
                                      width: 10.r,
                                      height: 10.r,
                                    ),
                                    SizedBox(width: 3.w),
                                    Text(
                                      club['rating']!,
                                      style: TextStyle(
                                        fontFamily: 'Pretendard',
                                        fontSize: 10.sp,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 8.h),
                        Text(
                          club['name']!,
                          style: TextStyle(
                            fontFamily: 'Pretendard',
                            fontSize: 13.sp,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(height: 2.h),
                        Row(
                          children: [
                            Text(
                              club['area']!,
                              style: TextStyle(
                                fontFamily: 'Pretendard',
                                fontSize: 11.sp,
                                color: VybeColors.gray500,
                              ),
                            ),
                            Padding(
                              padding:
                                  EdgeInsets.symmetric(horizontal: 4.w),
                              child: Container(
                                width: 2.r,
                                height: 2.r,
                                decoration: const BoxDecoration(
                                  color: VybeColors.gray700,
                                  shape: BoxShape.circle,
                                ),
                              ),
                            ),
                            Text(
                              club['genre']!,
                              style: TextStyle(
                                fontFamily: 'Pretendard',
                                fontSize: 11.sp,
                                color: VybeColors.gray500,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  // ── HELPERS ──

  Widget _sectionHeader(String title, {String? count}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Text(
              title,
              style: TextStyle(
                fontFamily: 'Pretendard',
                fontSize: 18.sp,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
            if (count != null) ...[
              SizedBox(width: 6.w),
              Text(
                count,
                style: TextStyle(
                  fontFamily: 'Pretendard',
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w500,
                  color: VybeColors.gray500,
                ),
              ),
            ],
          ],
        ),
        Row(
          children: [
            Text(
              '전체보기',
              style: TextStyle(
                fontFamily: 'Pretendard',
                fontSize: 12.sp,
                color: VybeColors.gray500,
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              size: 14.r,
              color: VybeColors.gray500,
            ),
          ],
        ),
      ],
    );
  }
}
