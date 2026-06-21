import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:vybe/core/providers/auth_providers.dart';
import 'package:vybe/design_system/colors.dart';
import 'package:vybe/presentation/clubs/tabs/detail_gallery_tab.dart';
import 'package:vybe/presentation/clubs/tabs/detail_home_tab.dart';
import 'package:vybe/presentation/clubs/tabs/detail_info_tab.dart';
import 'package:vybe/presentation/clubs/tabs/detail_menu_tab.dart';
import 'package:vybe/presentation/clubs/tabs/detail_review_tab.dart';
import 'package:vybe/presentation/clubs/viewmodels/club_detail_viewmodel.dart';
import 'package:vybe/presentation/clubs/viewmodels/favorite_viewmodel.dart';
import 'package:vybe/presentation/clubs/widgets/club_section_divider.dart';
import 'package:vybe/presentation/common/widgets/vybe_skeleton.dart';

class ClubDetailScreen extends ConsumerStatefulWidget {
  final String clubId;
  // 바텀시트(주변 페이지)로 띄울 때 닫기 동작 주입. null이면 Navigator.maybePop.
  final VoidCallback? onClose;
  const ClubDetailScreen({super.key, required this.clubId, this.onClose});

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
    final clubAsync = ref.watch(clubDetailProvider(widget.clubId));
    final imageUrls = clubAsync.value?.heroImageUrls ?? [];

    // 탭 전환 시 재로딩 방지 — 상세 페이지 진입 시 1회만 fetch
    ref.watch(clubInfoProvider(widget.clubId));
    ref.watch(nearbyClubsProvider(widget.clubId));

    return Scaffold(
      backgroundColor: VybeColors.background,
      body: NestedScrollView(
        physics: const ClampingScrollPhysics(),
        headerSliverBuilder: (context, innerBoxIsScrolled) => [
          SliverToBoxAdapter(
            child: clubAsync.isLoading
                ? const HeroSkeleton()
                : _Hero(
                    onBack: widget.onClose ??
                        () => Navigator.of(context).maybePop(),
                    imageUrls: imageUrls,
                    clubId: widget.clubId,
                  ),
          ),
          SliverToBoxAdapter(
            child: clubAsync.isLoading
                ? const TitleSkeleton()
                : _TitleBlock(clubId: widget.clubId),
          ),
          const SliverToBoxAdapter(child: ClubSectionDivider()),
          SliverToBoxAdapter(
            child: Container(
              color: VybeColors.background,
              child: TabBar(
                controller: _tabController,
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
                tabs: _tabs.map((t) => Tab(text: t, height: 44.h)).toList(),
              ),
            ),
          ),
        ],
        body: TabBarView(
          controller: _tabController,
          children: [
            DetailHomeTab(
              clubId: widget.clubId,
              onViewAllPhotos: () => _tabController.animateTo(2),
              onViewAllMenus: () => _tabController.animateTo(1),
            ),
            _LazyTabBody(
              isSelected: _tabController.index == 1,
              builder: () => DetailMenuTab(clubId: widget.clubId),
            ),
            _LazyTabBody(
              isSelected: _tabController.index == 2,
              builder: () => DetailGalleryTab(clubId: widget.clubId),
            ),
            _LazyTabBody(
              isSelected: _tabController.index == 3,
              builder: () => DetailReviewTab(clubId: widget.clubId),
            ),
            _LazyTabBody(
              isSelected: _tabController.index == 4,
              builder: () => DetailInfoTab(clubId: widget.clubId),
            ),
          ],
        ),
      ),
    );
  }
}

// ============ LAZY TAB BODY ============

class _LazyTabBody extends StatefulWidget {
  final bool isSelected;
  final Widget Function() builder;
  const _LazyTabBody({required this.isSelected, required this.builder});

  @override
  State<_LazyTabBody> createState() => _LazyTabBodyState();
}

class _LazyTabBodyState extends State<_LazyTabBody>
    with AutomaticKeepAliveClientMixin {
  Widget? _cached;

  @override
  bool get wantKeepAlive => _cached != null;

  @override
  void didUpdateWidget(_LazyTabBody old) {
    super.didUpdateWidget(old);
    if (widget.isSelected && _cached == null) {
      setState(() {
        _cached = widget.builder();
        updateKeepAlive();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    if (_cached == null) return const SizedBox.shrink();
    return _cached!;
  }
}

// ============ HERO ============

class _Hero extends ConsumerStatefulWidget {
  final VoidCallback onBack;
  final List<String> imageUrls;
  final String clubId;
  const _Hero({
    required this.onBack,
    required this.imageUrls,
    required this.clubId,
  });

  @override
  ConsumerState<_Hero> createState() => _HeroState();
}

class _HeroState extends ConsumerState<_Hero> {
  int _currentIndex = 0;
  final _pageController = PageController();
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 3), (_) {
      if (!mounted || widget.imageUrls.isEmpty) return;
      final next = (_currentIndex + 1) % widget.imageUrls.length;
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
    final images = widget.imageUrls;
    final total = images.length;

    // 찜 상태 (스트림 + 낙관적 오버라이드 머지)
    final uid = ref.watch(currentUidProvider);
    final streamFavIds = uid != null
        ? ref.watch(favoritedClubIdsProvider(uid)).asData?.value ?? <String>{}
        : <String>{};
    final optimistic = ref.watch(favoriteViewModelProvider);
    final isFavorited = optimistic.containsKey(widget.clubId)
        ? optimistic[widget.clubId]!
        : streamFavIds.contains(widget.clubId);

    if (total == 0) return SizedBox(height: 270.h);
    return SizedBox(
      height: 270.h,
      child: Stack(
        children: [
          PageView.builder(
            controller: _pageController,
            onPageChanged: (i) => setState(() => _currentIndex = i),
            itemCount: total,
            itemBuilder: (_, i) => SkeletonImage(
              url: images[i],
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
            child: IgnorePointer(
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
          ),
          // bottom scrim
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            height: 120.h,
            child: const IgnorePointer(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [Color(0xFF0E0E11), Colors.transparent],
                  ),
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
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _iconButton(Icons.chevron_left_rounded, widget.onBack),
                    Row(
                      children: [
                        _iconButton(Icons.ios_share_rounded, () {}),
                        SizedBox(width: 10.w),
                        _heartButton(isFavorited, uid),
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
            child: IgnorePointer(
              child: Container(
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
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
          ),
          // dot indicators
          Positioned(
            bottom: 18.h,
            left: 0,
            right: 0,
            child: IgnorePointer(
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

  // 찜 하트 버튼 — 찜 상태면 핑크레드(#FF3B6E) 채움 + 바운스 모션
  Widget _heartButton(bool isFavorited, String? uid) {
    return GestureDetector(
      onTap: uid == null
          ? null
          : () => ref
              .read(favoriteViewModelProvider.notifier)
              .toggleFavorite(uid, widget.clubId, isFavorited),
      child: Container(
        width: 36.r,
        height: 36.r,
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.4),
          shape: BoxShape.circle,
        ),
        alignment: Alignment.center,
        child: TweenAnimationBuilder<double>(
          key: ValueKey(isFavorited),
          tween: Tween(begin: isFavorited ? 0.7 : 1, end: 1),
          duration: const Duration(milliseconds: 250),
          curve: Curves.elasticOut,
          builder: (_, scale, child) =>
              Transform.scale(scale: scale, child: child),
          // 주변 페이지와 동일한 outline 하트 — 찜 시 보라 테두리(채움 없음)
          child: SvgPicture.asset(
            'assets/icons/common/club_card/favorite.svg',
            width: 20.r,
            height: 20.r,
            colorFilter: ColorFilter.mode(
              isFavorited ? VybeColors.mainPurple500 : Colors.white,
              BlendMode.srcIn,
            ),
          ),
        ),
      ),
    );
  }
}

// ============ TITLE BLOCK ============

class _TitleBlock extends ConsumerWidget {
  final String clubId;
  const _TitleBlock({required this.clubId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final club = ref.watch(clubDetailProvider(clubId)).value;
    final reviewCount = club?.reviewCount ?? 0;

    final area = club?.area ?? '';
    final genre = club?.genre ?? '';
    final name = club?.name ?? '';
    final rating = club?.rating ?? 0.0;
    final description = club?.description ?? '';
    final tags = club?.tags ?? [];

    return Padding(
      padding: EdgeInsets.fromLTRB(20.w, 20.h, 20.w, 24.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                area,
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
                genre,
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
                name,
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
                rating.toStringAsFixed(2),
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
                '리뷰 $reviewCount',
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
            description,
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
            children: tags.map((tag) {
              return Container(
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
                decoration: BoxDecoration(
                  color: const Color(0x247731FE),
                  borderRadius: BorderRadius.circular(99.r),
                ),
                child: Text(
                  '# $tag',
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

// ============ TAB BAR DELEGATE ============
