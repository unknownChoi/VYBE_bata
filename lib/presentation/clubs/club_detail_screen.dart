import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:vybe/design_system/colors.dart';
import 'package:vybe/presentation/clubs/tabs/detail_gallery_tab.dart';
import 'package:vybe/presentation/clubs/tabs/detail_home_tab.dart';
import 'package:vybe/presentation/clubs/tabs/detail_info_tab.dart';
import 'package:vybe/presentation/clubs/tabs/detail_menu_tab.dart';
import 'package:vybe/presentation/clubs/tabs/detail_review_tab.dart';

class ClubDetailScreen extends ConsumerStatefulWidget {
  const ClubDetailScreen({super.key});

  @override
  ConsumerState<ClubDetailScreen> createState() => _ClubDetailScreenState();
}

class _ClubDetailScreenState extends ConsumerState<ClubDetailScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  static const List<String> _tabs = ['홈', '메뉴', '사진', '리뷰', '매장 정보'];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this);
    _tabController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: VybeColors.background,
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) => [
          SliverToBoxAdapter(
            child: _Hero(onBack: () => Navigator.of(context).maybePop()),
          ),
          const SliverToBoxAdapter(child: _TitleBlock()),
          const SliverToBoxAdapter(child: _SectionDivider()),
          SliverPersistentHeader(
            pinned: true,
            delegate: _TabBarDelegate(
              tabController: _tabController,
              tabs: _tabs,
            ),
          ),
        ],
        body: TabBarView(
          controller: _tabController,
          children: const [
            DetailHomeTab(),
            DetailMenuTab(),
            DetailGalleryTab(),
            DetailReviewTab(),
            DetailInfoTab(),
          ],
        ),
      ),
      bottomNavigationBar: const _BottomNav(),
    );
  }
}

// ============ HERO ============

class _Hero extends StatefulWidget {
  final VoidCallback onBack;
  const _Hero({required this.onBack});

  @override
  State<_Hero> createState() => _HeroState();
}

class _HeroState extends State<_Hero> {
  int _currentIndex = 0;
  final _pageController = PageController();
  Timer? _timer;

  static const _heroImages = [
    'assets/club_detail/images/home_tab_image_1.jpg',
    'assets/club_detail/images/home_tab_image_2.png',
    'assets/club_detail/images/image_tab_image_1.png',
    'assets/club_detail/images/image_tab_image_2.png',
    'assets/club_detail/images/home_tab_image_3.png',
  ];

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 3), (_) {
      if (!mounted) return;
      final next = (_currentIndex + 1) % _heroImages.length;
      _pageController.animateToPage(
        next,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final total = _heroImages.length;
    return SizedBox(
      height: 270.h,
      child: Stack(
        children: [
          PageView.builder(
            controller: _pageController,
            onPageChanged: (i) => setState(() => _currentIndex = i),
            itemCount: total,
            itemBuilder: (_, i) => Image.asset(
              _heroImages[i],
              fit: BoxFit.cover,
              width: double.infinity,
              height: 270.h,
            ),
          ),
          // top scrim
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: 130.h,
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withValues(alpha: 0.6),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          // bottom scrim
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            height: 120.h,
            child: const DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [Color(0xFF0E0E11), Colors.transparent],
                ),
              ),
            ),
          ),
          // nav bar
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding:
                    EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _iconButton(Icons.chevron_left_rounded, widget.onBack),
                    Row(
                      children: [
                        _iconButton(Icons.ios_share_rounded, () {}),
                        SizedBox(width: 10.w),
                        _iconButton(Icons.favorite_border_rounded, () {}),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
          // counter
          Positioned(
            right: 16.w,
            bottom: 40.h,
            child: Container(
              padding:
                  EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.55),
                borderRadius: BorderRadius.circular(999.r),
              ),
              child: Text(
                '${_currentIndex + 1} / $total',
                style: TextStyle(
                  fontFamily: 'Pretendard',
                  fontSize: 12.sp,
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
          // dot indicators
          Positioned(
            bottom: 18.h,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(total, (i) {
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  margin: EdgeInsets.symmetric(horizontal: 2.5.w),
                  width: i == _currentIndex ? 16.w : 5.w,
                  height: 5.h,
                  decoration: BoxDecoration(
                    color: i == _currentIndex
                        ? Colors.white
                        : Colors.white.withValues(alpha: 0.4),
                    borderRadius: BorderRadius.circular(999.r),
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }

  Widget _iconButton(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 36.r,
        height: 36.r,
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.4),
          shape: BoxShape.circle,
        ),
        alignment: Alignment.center,
        child: Icon(icon, color: Colors.white, size: 20.r),
      ),
    );
  }
}

// ============ TITLE BLOCK ============

class _TitleBlock extends StatelessWidget {
  const _TitleBlock();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(20.w, 20.h, 20.w, 24.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                '홍대',
                style: TextStyle(
                  fontFamily: 'Pretendard',
                  fontSize: 12.sp,
                  color: VybeColors.gray500,
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 6.w),
                child: Container(
                  width: 1.w,
                  height: 10.h,
                  color: VybeColors.gray700,
                ),
              ),
              Text(
                '힙합 클럽',
                style: TextStyle(
                  fontFamily: 'Pretendard',
                  fontSize: 12.sp,
                  color: VybeColors.gray500,
                ),
              ),
            ],
          ),
          SizedBox(height: 8.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '어썸 레드',
                style: TextStyle(
                  fontFamily: 'Pretendard',
                  fontSize: 24.sp,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
              GestureDetector(
                onTap: () {},
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 12.w,
                    vertical: 7.h,
                  ),
                  decoration: BoxDecoration(
                    border: Border.all(color: VybeColors.gray800),
                    borderRadius: BorderRadius.circular(999.r),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.phone_rounded,
                        size: 13.r,
                        color: VybeColors.gray400,
                      ),
                      SizedBox(width: 5.w),
                      Text(
                        '전화',
                        style: TextStyle(
                          fontFamily: 'Pretendard',
                          fontSize: 13.sp,
                          fontWeight: FontWeight.w600,
                          color: VybeColors.gray400,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 14.h),
          Row(
            children: [
              SvgPicture.asset(
                'assets/icons/common/club_card/star.svg',
                width: 15.r,
                height: 15.r,
              ),
              SizedBox(width: 4.w),
              Text(
                '4.76',
                style: TextStyle(
                  fontFamily: 'Pretendard',
                  fontSize: 15.sp,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
              SizedBox(width: 8.w),
              Container(
                width: 2.r,
                height: 2.r,
                decoration: const BoxDecoration(
                  color: VybeColors.gray700,
                  shape: BoxShape.circle,
                ),
              ),
              SizedBox(width: 8.w),
              Text(
                '리뷰 13',
                style: TextStyle(
                  fontFamily: 'Pretendard',
                  fontSize: 14.sp,
                  color: VybeColors.gray400,
                ),
              ),
            ],
          ),
          SizedBox(height: 10.h),
          Text(
            '홍대역 인근 입문자에게 좋은 힙합 클럽',
            style: TextStyle(
              fontFamily: 'Pretendard',
              fontSize: 15.sp,
              color: VybeColors.gray400,
              height: 1.5,
            ),
          ),
          SizedBox(height: 14.h),
          Wrap(
            spacing: 6.w,
            runSpacing: 6.h,
            children: ['#힙합', '#대중적', '#무료입장', '#홍대'].map((tag) {
              return Container(
                padding: EdgeInsets.symmetric(
                  horizontal: 10.w,
                  vertical: 5.h,
                ),
                decoration: BoxDecoration(
                  color: const Color(0x247731FE),
                  borderRadius: BorderRadius.circular(99.r),
                ),
                child: Text(
                  tag,
                  style: TextStyle(
                    fontFamily: 'Pretendard',
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFFC8A8FF),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

// ============ SECTION DIVIDER ============

class _SectionDivider extends StatelessWidget {
  const _SectionDivider();

  @override
  Widget build(BuildContext context) {
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
}

// ============ TAB BAR DELEGATE ============

class _TabBarDelegate extends SliverPersistentHeaderDelegate {
  final TabController tabController;
  final List<String> tabs;

  const _TabBarDelegate({required this.tabController, required this.tabs});

  @override
  double get minExtent => 44.h;

  @override
  double get maxExtent => 44.h;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return Container(
      color: VybeColors.background,
      child: TabBar(
        controller: tabController,
        padding: EdgeInsets.zero,
        labelPadding: EdgeInsets.zero,
        indicatorColor: VybeColors.mainPurple500,
        indicatorWeight: 2,
        dividerColor: VybeColors.gray900,
        dividerHeight: 1,
        labelStyle: TextStyle(
          fontFamily: 'Pretendard',
          fontSize: 14.sp,
          fontWeight: FontWeight.w700,
        ),
        unselectedLabelStyle: TextStyle(
          fontFamily: 'Pretendard',
          fontSize: 14.sp,
          fontWeight: FontWeight.w500,
        ),
        labelColor: Colors.white,
        unselectedLabelColor: VybeColors.gray500,
        tabs: tabs.map((t) => Tab(text: t, height: 44.h)).toList(),
      ),
    );
  }

  @override
  bool shouldRebuild(_TabBarDelegate oldDelegate) =>
      oldDelegate.tabController != tabController ||
      oldDelegate.tabs != tabs;
}

// ============ BOTTOM NAV ============

class _BottomNav extends StatefulWidget {
  const _BottomNav();

  @override
  State<_BottomNav> createState() => _BottomNavState();
}

class _BottomNavState extends State<_BottomNav>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _bob;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
    _bob = Tween<double>(begin: 0, end: -3).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xD90E0E11),
        border: Border(top: BorderSide(color: Color(0xFF1F1F23))),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 8.h),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AnimatedBuilder(
                animation: _bob,
                builder: (_, __) => Transform.translate(
                  offset: Offset(0, _bob.value),
                  child: _TooltipBubble(),
                ),
              ),
              SizedBox(height: 10.h),
              Row(
                children: [
                  Expanded(
                    flex: 10,
                    child: SizedBox(
                      height: 48.h,
                      child: OutlinedButton(
                        onPressed: () {},
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(
                            color: VybeColors.mainPurple500,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.r),
                          ),
                          padding: EdgeInsets.zero,
                        ),
                        child: Text(
                          '웨이팅 등록',
                          style: TextStyle(
                            fontFamily: 'Pretendard',
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 8.w),
                  Expanded(
                    flex: 13,
                    child: SizedBox(
                      height: 48.h,
                      child: ElevatedButton(
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(
                          backgroundColor: VybeColors.mainPurple700,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.r),
                          ),
                          padding: EdgeInsets.zero,
                          elevation: 0,
                        ),
                        child: Text(
                          '테이블 예약',
                          style: TextStyle(
                            fontFamily: 'Pretendard',
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TooltipBubble extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(6.r),
          ),
          child: Text(
            '온라인 웨이팅 가능',
            style: TextStyle(
              fontFamily: 'Pretendard',
              fontSize: 12.sp,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF0E0E11),
            ),
          ),
        ),
        Padding(
          padding: EdgeInsets.only(left: 22.w),
          child: Container(
            width: 8.r,
            height: 5.r,
            color: Colors.white,
            child: CustomPaint(painter: _ArrowPainter()),
          ),
        ),
      ],
    );
  }
}

class _ArrowPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.white;
    final path = Path()
      ..moveTo(0, 0)
      ..lineTo(size.width, 0)
      ..lineTo(size.width / 2, size.height)
      ..close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_ArrowPainter old) => false;
}
