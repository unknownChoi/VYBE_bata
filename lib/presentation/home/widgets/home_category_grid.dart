import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:vybe/design_system/colors.dart';
import 'package:vybe/presentation/hot_places/hot_places_screen.dart';
import 'package:vybe/presentation/recommend/vybe_recommend_screen.dart';

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
      padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 24.h),
      child: Wrap(
        spacing: 24.w,
        runSpacing: 24.h,
        alignment: WrapAlignment.center,
        children: _categories.map((c) => _buildItem(context, c)).toList(),
      ),
    );
  }

  Widget _buildItem(BuildContext context, CategoryItem item) {
    final isVybe = item.label == 'VYBE 추천';
    final isHot = item.label == '핫플레이스';

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

    return GestureDetector(
      onTap: isVybe
          ? () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const VybeRecommendScreen(),
                ),
              )
          : isHot
              ? () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const HotPlacesScreen(),
                    ),
                  )
              : null,
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
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
      ),
    );
  }
}
