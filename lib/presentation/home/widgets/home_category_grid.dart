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

  /// 탭했을 때 열 화면. null이면 아직 연결된 화면이 없어 눌리지 않는다.
  ///
  /// ⚠ 목적지를 **항목이 직접 들고 있다** — 예전에는 그리기 쪽에서
  /// `label == 'VYBE 추천'` 처럼 라벨 문자열로 분기해서, 라벨 한 글자만 고쳐도
  /// 화면 이동이 조용히 사라졌다.
  final WidgetBuilder? destination;

  /// 그라데이션으로 꽉 채우는 강조 타일인지 (VYBE 추천 전용).
  final bool highlighted;

  const CategoryItem({
    required this.icon,
    required this.label,
    this.destination,
    this.highlighted = false,
  });
}

// 목적지 빌더 — const 목록에 넣을 수 있도록 top-level 함수로 둔다.
Widget _vybeRecommend(BuildContext _) => const VybeRecommendScreen();
Widget _hotPlaces(BuildContext _) => const HotPlacesScreen();
Widget _freeEntry(BuildContext _) => const FreeEntryScreen();
Widget _serviceDrinks(BuildContext _) => const ServiceDrinksScreen();
Widget _hipHop(BuildContext _) => const HipHopScreen();

const _categories = [
  CategoryItem(
    icon: 'assets/icons/home_screen/category_grid/lounge.svg',
    label: 'VYBE 추천',
    destination: _vybeRecommend,
    highlighted: true,
  ),
  CategoryItem(
    icon: 'assets/icons/home_screen/category_grid/kpop.svg',
    label: '핫플레이스',
    destination: _hotPlaces,
  ),
  CategoryItem(
    icon: 'assets/icons/home_screen/category_grid/free_entry.svg',
    label: '입장료 무료',
    destination: _freeEntry,
  ),
  CategoryItem(
    icon: 'assets/icons/home_screen/category_grid/service_drink.svg',
    label: '서비스 음료',
    destination: _serviceDrinks,
  ),
  CategoryItem(
    icon: 'assets/icons/home_screen/category_grid/hiphop.svg',
    label: '힙합',
    destination: _hipHop,
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
        children: [for (final item in _categories) _CategoryTile(item: item)],
      ),
    );
  }
}

/// 카테고리 타일 1칸 — 아이콘 박스 + 라벨.
class _CategoryTile extends StatelessWidget {
  final CategoryItem item;

  const _CategoryTile({required this.item});

  @override
  Widget build(BuildContext context) {
    final destination = item.destination;
    return GestureDetector(
      onTap: destination == null
          ? null
          : () => Navigator.of(
              context,
            ).push(SwipeBackPageRoute(builder: destination)),
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // ⚠ 정사각 타일이라 가로·세로 **둘 다 `.w`** 로 잰다.
          // `.h`(세로 비)는 `.w`(가로 비)와 계수가 달라 화면비가 다른 기기에서
          // 정사각이 직사각으로 찌그러진다 — iPhone SE(375x667)에서 59x49.
          SizedBox(
            width: 62.w,
            height: 62.w,
            child: _CategoryIconBox(item: item),
          ),
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

/// 아이콘 판 — 강조 항목은 그라데이션으로 꽉 채우고, 나머지는 리퀴드 글래스.
class _CategoryIconBox extends StatelessWidget {
  final CategoryItem item;

  const _CategoryIconBox({required this.item});

  @override
  Widget build(BuildContext context) {
    // 판이 `.w` 로 잡히므로 라운드·아이콘도 같은 축으로 재야 비율이 유지된다.
    // `.r` 은 min(가로비, 세로비)라 세로가 짧은 기기에서 판보다 더 줄어든다.
    final radius = BorderRadius.circular(18.w);
    final icon = SvgPicture.asset(
      item.icon,
      width: 34.w,
      height: 34.w,
      colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn),
    );

    // 강조 타일 — 그라데이션으로 꽉 채우고 아이콘만 얹는다. 안쪽 글래스 판은
    // 두지 않아 그라데이션이 테두리가 아니라 타일 전체가 된다.
    if (item.highlighted) {
      return Container(
        decoration: BoxDecoration(
          gradient: _borderGradient,
          borderRadius: radius,
        ),
        alignment: Alignment.center,
        child: icon,
      );
    }

    // 나머지 타일 — 리퀴드 글래스. 배경을 블러로 통과시키고 흰색 틴트만 얹는다.
    // 보라 글로우는 제거 — 색이 도는 대신 투명.
    return ClipRRect(
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
            border: Border.all(color: RenewGlass.tileBorder, width: 1),
          ),
          alignment: Alignment.center,
          child: icon,
        ),
      ),
    );
  }
}
