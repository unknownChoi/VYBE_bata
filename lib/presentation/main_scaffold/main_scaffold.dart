import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart' show ScrollDirection;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:liquid_glass_renderer/liquid_glass_renderer.dart';
import 'package:vybe/design_system/colors.dart';
import 'package:vybe/presentation/main_scaffold/nav_bar_visibility_provider.dart';
import 'package:vybe/presentation/home/home_screen.dart';
import 'package:vybe/presentation/my_page/my_page_screen.dart';
import 'package:vybe/presentation/nearby/nearby_screen.dart';
import 'package:vybe/presentation/saved/saved_screen.dart';
import 'package:vybe/presentation/search/search_screen.dart';

/// 탭별 중첩 Navigator.
/// 상세 페이지 등 화면 전환이 탭 영역(IndexedStack) 안에서만 일어나
/// body 위에 floating된 바텀 nav가 가려지지 않고 유지된다.
class _TabNavigator extends StatelessWidget {
  final WidgetBuilder builder;
  const _TabNavigator({required this.builder});

  @override
  Widget build(BuildContext context) {
    return Navigator(
      onGenerateRoute: (_) => MaterialPageRoute(builder: builder),
    );
  }
}

Widget _nearbyBuilder(BuildContext _) => const NearbyScreen();
Widget _savedBuilder(BuildContext _) => const SavedScreen();
Widget _searchBuilder(BuildContext _) => const SearchScreen();
Widget _myPageBuilder(BuildContext _) => const MyPageScreen();

/// PageView로 탭 전환 시 화면 밖 페이지(중첩 Navigator 상태)를 살려둔다.
class _KeepAlivePage extends StatefulWidget {
  final Widget child;
  const _KeepAlivePage({required this.child});

  @override
  State<_KeepAlivePage> createState() => _KeepAlivePageState();
}

class _KeepAlivePageState extends State<_KeepAlivePage>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return widget.child;
  }
}

class MainScaffold extends ConsumerStatefulWidget {
  const MainScaffold({super.key});

  @override
  ConsumerState<MainScaffold> createState() => _MainScaffoldState();
}

class _MainScaffoldState extends ConsumerState<MainScaffold> {
  int _currentIndex = 0;
  late final PageController _pageController;
  late final List<Widget> _screens;

  bool _onScroll(UserScrollNotification n) {
    // PageView의 가로 스크롤은 무시 — nav 표시는 세로 스크롤로만 제어.
    if (n.metrics.axis != Axis.vertical) return false;
    // depth 0만 처리하면 좋지만 탭마다 구조가 달라 방향만 본다.
    if (n.direction == ScrollDirection.reverse) {
      ref.read(navBarVisibilityProvider.notifier).collapse();
    } else if (n.direction == ScrollDirection.forward) {
      ref.read(navBarVisibilityProvider.notifier).expand();
    }
    return false;
  }

  // DraggableScrollableSheet(주변 바텀시트)를 드래그로 키우면(위로) nav 축소,
  // 내리면 nav 확대. extent 증감 방향으로 판단.
  double _lastSheetExtent = 0;

  bool _onSheetDrag(DraggableScrollableNotification n) {
    final e = n.extent;
    if (e > _lastSheetExtent + 0.001) {
      ref.read(navBarVisibilityProvider.notifier).collapse();
    } else if (e < _lastSheetExtent - 0.001) {
      ref.read(navBarVisibilityProvider.notifier).expand();
    }
    _lastSheetExtent = e;
    return false;
  }

  // 탭 클릭: 해당 페이지로 애니메이션 이동.
  void _goToTab(int index) {
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOutCubic,
    );
  }

  // 스와이프/이동으로 페이지가 바뀐 시점 처리.
  void _onPageChanged(int index) {
    setState(() => _currentIndex = index);
    // 탭 전환 시 축소된 nav를 원래 크기로 복원.
    ref.read(navBarVisibilityProvider.notifier).expand();
  }

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _screens = [
      _KeepAlivePage(
        child: _TabNavigator(
          builder: (_) => HomeScreen(onSearchTap: () => _goToTab(3)),
        ),
      ),
      const _KeepAlivePage(child: _TabNavigator(builder: _nearbyBuilder)),
      const _KeepAlivePage(child: _TabNavigator(builder: _savedBuilder)),
      const _KeepAlivePage(child: _TabNavigator(builder: _searchBuilder)),
      const _KeepAlivePage(child: _TabNavigator(builder: _myPageBuilder)),
    ];
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
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
      // Liquid Glass 굴절은 바 뒤 콘텐츠가 비쳐야 하므로 bottomNavigationBar
      // 슬롯(분리 레이어) 대신 body 위로 floating 시킨다.
      body: Stack(
        children: [
          Positioned.fill(
            child: NotificationListener<DraggableScrollableNotification>(
              onNotification: _onSheetDrag,
              child: NotificationListener<UserScrollNotification>(
                onNotification: _onScroll,
                child: PageView(
                  controller: _pageController,
                  onPageChanged: _onPageChanged,
                  // 주변 탭의 지도는 forceGesture로 팬을 선점하고, 시트 영역에선
                  // 이 PageView가 가로 스와이프를 받아 탭 전환된다.
                  children: _screens,
                ),
              ),
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: AnimatedSlide(
              offset: ref.watch(navBarHiddenProvider)
                  ? const Offset(0, 1.4)
                  : Offset.zero,
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOutCubic,
              child: _BottomNavBar(
                currentIndex: _currentIndex,
                onTap: _goToTab,
                items: _navItems,
                expanded: ref.watch(navBarVisibilityProvider),
              ),
            ),
          ),
        ],
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
  final bool expanded;

  const _BottomNavBar({
    required this.currentIndex,
    required this.onTap,
    required this.items,
    required this.expanded,
  });

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).padding.bottom;
    return Padding(
      padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, bottomInset + 12.h),
      child: AnimatedScale(
        scale: expanded ? 1.0 : 0.7,
        alignment: Alignment.bottomCenter,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOutCubic,
        // 배경 캡슐 + 활성 탭 indicator 캡슐을 같은 레이어에서 블렌드 →
        // 유리끼리 녹아드는 iOS Liquid Glass 탭 강조 효과.
        child: LiquidGlassLayer(
          settings: LiquidGlassSettings(
            thickness: 16,
            blur: 8,
            glassColor: const Color(0x14FFFFFF),
            refractiveIndex: 1.25,
            chromaticAberration: 0.03,
            lightAngle: 1.2,
            lightIntensity: 0.6,
            ambientStrength: 0.2,
            saturation: 1.2,
          ),
          child: SizedBox(
            height: 64.h,
            child: LayoutBuilder(
              builder: (context, c) {
                const innerPad = 8.0;
                final tabW = (c.maxWidth - innerPad * 2) / items.length;
                final indW = tabW * 0.78;
                final indH = 48.h;
                return Stack(
                  children: [
                    // 배경 바.
                    Positioned.fill(
                      child: LiquidGlass.grouped(
                        shape:
                            LiquidRoundedSuperellipse(borderRadius: 32.r),
                        child: const SizedBox.expand(),
                      ),
                    ),
                    // 활성 탭 글래스 indicator (블렌드되어 강조).
                    AnimatedPositioned(
                      duration: const Duration(milliseconds: 280),
                      curve: Curves.easeOutCubic,
                      left: innerPad + tabW * currentIndex + (tabW - indW) / 2,
                      top: (64.h - indH) / 2,
                      width: indW,
                      height: indH,
                      child: LiquidGlass.grouped(
                        glassContainsChild: true,
                        shape:
                            LiquidRoundedSuperellipse(borderRadius: 18.r),
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            color: const Color(0x24FFFFFF),
                            borderRadius: BorderRadius.circular(18.r),
                          ),
                        ),
                      ),
                    ),
                    // 아이콘 (유리 위에 표시).
                    Padding(
                      padding:
                          const EdgeInsets.symmetric(horizontal: innerPad),
                      child: Row(
                        children: List.generate(items.length, (i) {
                          final active = i == currentIndex;
                          return Expanded(
                            child: GestureDetector(
                              behavior: HitTestBehavior.opaque,
                              onTap: () => onTap(i),
                              child: Center(
                                child: SvgPicture.asset(
                                  items[i].icon,
                                  width: 24.r,
                                  height: 24.r,
                                  colorFilter: ColorFilter.mode(
                                    active
                                        ? VybeColors.mainLime500
                                        : Colors.white,
                                    BlendMode.srcIn,
                                  ),
                                ),
                              ),
                            ),
                          );
                        }),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
