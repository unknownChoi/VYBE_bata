import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:vybe/core/navigation/swipe_back_page_route.dart';
import 'package:vybe/design_system/colors.dart';
import 'package:vybe/presentation/common/renew/renew_glass.dart';
import 'package:vybe/presentation/free_entry/free_entry_screen.dart';
import 'package:vybe/presentation/hip_hop/hip_hop_screen.dart';
import 'package:vybe/presentation/hot_places/hot_places_screen.dart';
import 'package:vybe/presentation/recommend/vybe_recommend_screen.dart';
import 'package:vybe/presentation/service_drinks/service_drinks_screen.dart';

const _borderGradient = LinearGradient(
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
  colors: [
    VybeColors.mainLime500,
    Color(0xFFC8E77F),
    Color(0xFFDACA9E),
    Color(0xFFFF9EDB),
    Color(0xFFDD82E4),
    Color(0xFFBB67ED),
    Color(0xFF994CF5),
    VybeColors.mainPurple500,
  ],
  stops: [0.0, 0.142, 0.285, 0.569, 0.677, 0.785, 0.892, 1.0],
);

class CategoryItem {
  final String icon;
  final String label;
  const CategoryItem({required this.icon, required this.label});
}

const _categories = [
  CategoryItem(
    icon: 'assets/icons/home_screen/category_grid/lounge.svg',
    label: 'VYBE 추천',
  ),
  CategoryItem(
    icon: 'assets/icons/home_screen/category_grid/kpop.svg',
    label: '핫플레이스',
  ),
  CategoryItem(
    icon: 'assets/icons/home_screen/category_grid/free_entry.svg',
    label: '입장료 무료',
  ),
  CategoryItem(
    icon: 'assets/icons/home_screen/category_grid/service_drink.svg',
    label: '서비스 음료',
  ),
  CategoryItem(
    icon: 'assets/icons/home_screen/category_grid/hiphop.svg',
    label: '힙합',
  ),
  CategoryItem(
    icon: 'assets/icons/home_screen/category_grid/edm.svg',
    label: 'EDM',
  ),
  CategoryItem(
    icon: 'assets/icons/home_screen/category_grid/hot_place.svg',
    label: 'K-POP',
  ),
  CategoryItem(
    icon: 'assets/icons/home_screen/category_grid/vybe_recommend.svg',
    label: '라운지',
  ),
];

class HomeCategoryGrid extends StatelessWidget {
  const HomeCategoryGrid({super.key});

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
        children: _categories.map((c) => _buildItem(context, c)).toList(),
      ),
    );
  }

  Widget _buildItem(BuildContext context, CategoryItem item) {
    final isVybe = item.label == 'VYBE 추천';
    final isHot = item.label == '핫플레이스';
    final isDrink = item.label == '서비스 음료';
    final isFree = item.label == '입장료 무료';
    final isHiphop = item.label == '힙합';

    final radius = BorderRadius.circular(isVybe ? 16.5.r : 18.r);

    // 리퀴드 글래스 — 배경을 블러로 통과시키고 흰색 틴트만 얹는다.
    // 보라 글로우(배경 RadialGradient · 아이콘 상단 스팟)는 제거 — 색이 도는 대신 투명.
    final iconInner = ClipRRect(
      borderRadius: radius,
      child: BackdropFilter(
        filter: ui.ImageFilter.blur(
          sigmaX: RenewGlass.quietBlur,
          sigmaY: RenewGlass.quietBlur,
        ),
        child: Container(
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0x1FFFFFFF), Color(0x0AFFFFFF)],
            ),
            borderRadius: radius,
            border: isVybe
                ? null
                : Border.all(color: RenewGlass.tileBorder, width: 1),
          ),
          alignment: Alignment.center,
          child: SvgPicture.asset(
            item.icon,
            width: 34.r,
            height: 34.r,
            colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn),
          ),
        ),
      ),
    );

    final iconBox = SizedBox(
      width: 62.w,
      height: 62.h,
      child: isVybe
          ? Container(
              decoration: BoxDecoration(
                gradient: _borderGradient,
                borderRadius: BorderRadius.circular(18.r),
              ),
              padding: const EdgeInsets.all(1.5),
              child: iconInner,
            )
          : iconInner,
    );

    return GestureDetector(
      onTap: isVybe
          ? () => Navigator.of(context).push(
              SwipeBackPageRoute(builder: (_) => const VybeRecommendScreen()),
            )
          : isHot
          ? () => Navigator.of(
              context,
            ).push(SwipeBackPageRoute(builder: (_) => const HotPlacesScreen()))
          : isDrink
          ? () => Navigator.of(context).push(
              SwipeBackPageRoute(builder: (_) => const ServiceDrinksScreen()),
            )
          : isFree
          ? () => Navigator.of(
              context,
            ).push(SwipeBackPageRoute(builder: (_) => const FreeEntryScreen()))
          : isHiphop
          ? () => Navigator.of(
              context,
            ).push(SwipeBackPageRoute(builder: (_) => const HipHopScreen()))
          : null,
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          iconBox,
          SizedBox(height: 8.h),
          Text(
            item.label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'Pretendard',
              fontSize: 12.sp,
              height: 14 / 12,
              fontWeight: FontWeight.w600,
              color: VybeColors.gray200,
              letterSpacing: 12 * -0.025,
            ),
          ),
        ],
      ),
    );
  }
}
