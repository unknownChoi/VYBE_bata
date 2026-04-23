import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:vybe/design_system/colors.dart';
import 'package:vybe/presentation/home/home_screen.dart';
import 'package:vybe/presentation/my_page/my_page_screen.dart';
import 'package:vybe/presentation/nearby/nearby_screen.dart';
import 'package:vybe/presentation/pass_wallet/pass_wallet_screen.dart';
import 'package:vybe/presentation/search/search_screen.dart';

class MainScaffold extends StatefulWidget {
  const MainScaffold({super.key});

  @override
  State<MainScaffold> createState() => _MainScaffoldState();
}

class _MainScaffoldState extends State<MainScaffold> {
  int _currentIndex = 0;
  late final List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    _screens = [
      HomeScreen(onSearchTap: () => setState(() => _currentIndex = 3)),
      const NearbyScreen(),
      const PassWalletScreen(),
      const SearchScreen(),
      const MyPageScreen(),
    ];
  }

  static const _navItems = [
    _NavItem(icon: 'assets/icons/bottom_nav/home_page.svg', label: '홈'),
    _NavItem(icon: 'assets/icons/bottom_nav/map_page.svg', label: '주변'),
    _NavItem(icon: 'assets/icons/bottom_nav/bookmark.svg', label: '찜'),
    _NavItem(icon: 'assets/icons/bottom_nav/search_page.svg', label: '검색'),
    _NavItem(icon: 'assets/icons/bottom_nav/my_page.svg', label: '내 정보'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: VybeColors.background,
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: _BottomNavBar(
        currentIndex: _currentIndex,
        onTap: (i) => setState(() => _currentIndex = i),
        items: _navItems,
      ),
    );
  }
}

class _NavItem {
  final String icon;
  final String label;
  const _NavItem({required this.icon, required this.label});
}

class _BottomNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;
  final List<_NavItem> items;

  const _BottomNavBar({
    required this.currentIndex,
    required this.onTap,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 92.h,
      decoration: const BoxDecoration(
        color: VybeColors.background,
        border: Border(
          top: BorderSide(color: VybeColors.gray900, width: 1),
        ),
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 24.w),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(items.length, (i) {
            final active = i == currentIndex;
            return GestureDetector(
              onTap: () => onTap(i),
              behavior: HitTestBehavior.opaque,
              child: SizedBox(
                width: 40.w,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SvgPicture.asset(
                      items[i].icon,
                      width: 24.r,
                      height: 24.r,
                      colorFilter: ColorFilter.mode(
                        active ? VybeColors.mainLime500 : Colors.white,
                        BlendMode.srcIn,
                      ),
                    ),
                    SizedBox(height: 8.h),
                    Text(
                      items[i].label,
                      style: TextStyle(
                        fontFamily: 'Pretendard',
                        fontSize: 12.sp,
                        fontWeight:
                            active ? FontWeight.w600 : FontWeight.w400,
                        color:
                            active ? VybeColors.mainLime500 : Colors.white,
                        letterSpacing: 12 * -0.025,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
        ),
      ),
    );
  }
}
