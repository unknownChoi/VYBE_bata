import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart' show ScrollDirection;
import 'package:flutter/services.dart' show SystemChannels;
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
  // 검색 탭 인덱스.
  static const int _searchTabIndex = 3;

  int _currentIndex = 0;
  late final PageController _pageController;
  late final List<Widget> _screens;
  // 한 번이라도 방문한 탭만 빌드 → 미방문 탭은 데이터 접근 안 함.
  // 홈(0)은 초기 화면이라 처음부터 방문 처리.
  final Set<int> _visited = {0};
  // 검색 탭 재진입 시 키보드를 다시 띄우기 위해 여기서 소유.
  final FocusNode _searchFocusNode = FocusNode();

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

  // 탭 클릭: 해당 페이지로 즉시 이동.
  // animateToPage는 사이 페이지(주변·찜 등)를 스크롤하며 빌드 → 불필요한
  // 데이터 접근이 발생하므로 jumpToPage로 중간 페이지를 건너뛴다.
  void _goToTab(int index) {
    _pageController.jumpToPage(index);
  }

  // 스와이프/이동으로 페이지가 바뀐 시점 처리.
  void _onPageChanged(int index) {
    setState(() {
      _currentIndex = index;
      _visited.add(index);
    });
    // 현재 탭 기록 (주변 지도 마커 렌더 가드용).
    ref.read(currentTabIndexProvider.notifier).set(index);
    // 탭 전환 시 축소된 nav를 원래 크기로 복원.
    ref.read(navBarVisibilityProvider.notifier).expand();
    // 탭 안에서 nav를 숨긴 화면(리뷰 작성 등)을 열어둔 채 가로 스와이프로
    // 다른 탭에 가면 nav가 숨은 상태로 남는다 → 탭이 바뀌면 항상 복원.
    ref.read(navBarHiddenProvider.notifier).show();
    // 검색 탭 진입 시 키보드 자동 노출 (KeepAlive라 autofocus는 최초 1회뿐).
    if (index == _searchTabIndex) {
      _focusSearch();
    } else {
      // 다른 탭으로 나가면 검색 키보드 내림.
      _searchFocusNode.unfocus();
    }
  }

  // 검색 탭이 활성 focus scope가 된 뒤 포커스 + 키보드 강제 노출.
  // PageView 페이지가 스크롤 중 빌드되면 autofocus/requestFocus가 무시될 수 있어
  // 애니메이션(300ms) 종료 후 한 번 더 시도하고, 이미 포커스 상태여도
  // TextInput.show로 키보드를 다시 띄운다.
  void _focusSearch() {
    void run() {
      if (!mounted || _currentIndex != _searchTabIndex) return;
      _searchFocusNode.requestFocus();
      SystemChannels.textInput.invokeMethod('TextInput.show');
    }

    WidgetsBinding.instance.addPostFrameCallback((_) => run());
    Future.delayed(const Duration(milliseconds: 350), run);
  }

  // 홈 검색 버튼 → 주변 페이지와 동일한 fade 오버레이로 검색화면 열기.
  void _openHomeSearch(BuildContext ctx) {
    Navigator.of(ctx).push(
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 280),
        reverseTransitionDuration: const Duration(milliseconds: 240),
        pageBuilder: (_, __, ___) => const SearchScreen(showBackButton: true),
        transitionsBuilder: (_, anim, __, child) {
          final curved = CurvedAnimation(
            parent: anim,
            curve: Curves.easeOutCubic,
            reverseCurve: Curves.easeInCubic,
          );
          return FadeTransition(opacity: curved, child: child);
        },
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _screens = [
      _KeepAlivePage(
        child: _TabNavigator(
          builder: (ctx) => HomeScreen(onSearchTap: () => _openHomeSearch(ctx)),
        ),
      ),
      const _KeepAlivePage(child: _TabNavigator(builder: _nearbyBuilder)),
      const _KeepAlivePage(child: _TabNavigator(builder: _savedBuilder)),
      _KeepAlivePage(
        child: _TabNavigator(
          builder: (_) => SearchScreen(focusNode: _searchFocusNode),
        ),
      ),
      const _KeepAlivePage(child: _TabNavigator(builder: _myPageBuilder)),
    ];
  }

  @override
  void dispose() {
    _pageController.dispose();
    _searchFocusNode.dispose();
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
    // 다른 화면발 탭 전환 요청 (예: 힙합 '지도에서 보기' → 주변 탭).
    ref.listen<int?>(tabSwitchRequestProvider, (_, next) {
      if (next == null) return;
      _goToTab(next);
      ref.read(tabSwitchRequestProvider.notifier).consume();
    });
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
                  // 미방문 탭은 빈 위젯으로 두어 데이터 접근을 막고,
                  // 방문 후에는 KeepAlive로 살아남는다.
                  children: List.generate(
                    _screens.length,
                    (i) => _visited.contains(i)
                        ? _screens[i]
                        : const SizedBox.shrink(),
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: AnimatedSlide(
              // 정확히 1.0 — 바 위젯 높이(64.h + bottomInset + 12.h Padding 포함)만큼만
              // 내리면 화면 밖이다. 1.4처럼 오버슈트를 주면 감속 커브(easeOutCubic)에서
              // 71% 지점(≈35% 시간)에 이미 안 보여 내려갈 때만 훨씬 빨라 보인다.
              offset: ref.watch(navBarHiddenProvider)
                  ? const Offset(0, 1)
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
