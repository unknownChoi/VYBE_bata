import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:vybe/core/providers/auth_providers.dart';
import 'package:vybe/core/utils/map_launcher.dart';
import 'package:vybe/core/utils/phone_launcher.dart';
import 'package:vybe/data/models/club_model.dart';
import 'package:vybe/design_system/colors.dart';
import 'package:vybe/presentation/clubs/tabs/detail_gallery_tab.dart';
import 'package:vybe/presentation/clubs/tabs/detail_home_tab.dart';
import 'package:vybe/presentation/clubs/tabs/detail_info_tab.dart';
import 'package:vybe/presentation/clubs/tabs/detail_menu_tab.dart';
import 'package:vybe/presentation/clubs/tabs/detail_review_tab.dart';
import 'package:vybe/presentation/clubs/viewmodels/club_detail_viewmodel.dart';
import 'package:vybe/presentation/clubs/viewmodels/favorite_viewmodel.dart';
import 'package:vybe/presentation/clubs/widgets/club_glass.dart';
import 'package:vybe/presentation/common/widgets/vybe_glass_button.dart';
import 'package:vybe/presentation/common/widgets/vybe_skeleton.dart';
import 'package:vybe/presentation/common/widgets/vybe_toast.dart';

/// 클럽 상세 — 리퀴드 글래스 리뉴얼.
///
/// 디자인: club_detail_glass.html (club_glass_shell.jsx · club_glass_tabs.jsx).
/// 히어로(320) 위로 -34 겹치는 아이덴티티 글래스 카드 → 퀵 액션 4칸 →
/// sticky 글래스 세그먼트 탭 순서.
class ClubDetailScreen extends ConsumerStatefulWidget {
  final String clubId;
  // 바텀시트(주변 페이지)로 띄울 때 닫기 동작 주입. null이면 Navigator.maybePop.
  final VoidCallback? onClose;
  // 바텀시트(DraggableScrollableSheet)에 넣을 때 시트의 scrollController 주입.
  // NestedScrollView outer에 연결돼 시트 드래그가 native로 동작. null이면 자체 스크롤.
  final ScrollController? scrollController;
  const ClubDetailScreen({
    super.key,
    required this.clubId,
    this.onClose,
    this.scrollController,
  });

  @override
  ConsumerState<ClubDetailScreen> createState() => _ClubDetailScreenState();
}

class _ClubDetailScreenState extends ConsumerState<ClubDetailScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  static const List<String> _tabs = ['홈', '메뉴', '사진', '리뷰', '매장 정보'];

  /// 히어로 높이 (디자인 320px).
  static const double _heroHeight = 320;

  /// 아이덴티티 카드가 히어로를 덮는 깊이 (디자인 -34px).
  static const double _identityOverlap = 34;

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

  void _goToTab(int index) => _tabController.animateTo(index);

  @override
  Widget build(BuildContext context) {
    final clubAsync = ref.watch(clubDetailProvider(widget.clubId));
    final club = clubAsync.value;

    // 탭 전환 시 재로딩 방지 — 상세 페이지 진입 시 1회만 fetch
    ref.watch(clubInfoProvider(widget.clubId));
    ref.watch(nearbyClubsProvider(widget.clubId));

    return Scaffold(
      backgroundColor: ClubGlass.ink,
      body: Stack(
        children: [
          const Positioned.fill(child: ClubAurora()),
          NestedScrollView(
            controller: widget.scrollController,
            physics: const ClampingScrollPhysics(),
            headerSliverBuilder: (context, innerBoxIsScrolled) => [
              SliverToBoxAdapter(
                child: clubAsync.isLoading
                    ? const HeroSkeleton()
                    : _buildHeader(club),
              ),
            ],
            // 탭바를 body 최상단에 두면 헤더가 스크롤되어 사라진 뒤 자연히 화면
            // 맨 위에 고정된다(sticky). headerSliverBuilder에 pinned
            // SliverPersistentHeader를 쓰면 Flutter 3.41 세만틱스 검증
            // (debugCheckForParentData)이 매 프레임 assert를 던져 화면이 통째로
            // 안 그려진다 — 그래서 pinned sliver를 쓰지 않는다.
            body: Column(
              children: [
                _GlassTabs(
                  tabs: _tabs,
                  activeIndex: _tabController.index,
                  onSelect: _goToTab,
                ),
                Expanded(child: _buildTabViews()),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabViews() {
    return TabBarView(
      controller: _tabController,
      children: [
                DetailHomeTab(
                  clubId: widget.clubId,
                  onViewAllPhotos: () => _goToTab(2),
                  onViewAllMenus: () => _goToTab(1),
                  onViewInfo: () => _goToTab(4),
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
    );
  }

  /// 히어로 + 아이덴티티 카드 + 퀵 액션.
  ///
  /// 카드가 히어로를 [_identityOverlap] 만큼 덮어야 해서 Column 대신 Stack —
  /// 아래 블록을 `히어로 높이 - 겹침` 위치에서 시작시키면 전체 높이가
  /// 자연스럽게 맞는다(음수 마진 불가 대응).
  Widget _buildHeader(ClubModel? club) {
    return Stack(
      children: [
        SizedBox(
          width: double.infinity,
          height: _heroHeight.h,
          child: _Hero(
            onBack: widget.onClose ?? () => Navigator.of(context).maybePop(),
            imageUrls: club?.heroImageUrls ?? const [],
          ),
        ),
        Padding(
          padding: EdgeInsets.only(top: (_heroHeight - _identityOverlap).h),
          child: Column(
            children: [
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                child: _IdentityCard(clubId: widget.clubId),
              ),
              _QuickActions(clubId: widget.clubId),
              SizedBox(height: 16.h),
            ],
          ),
        ),
      ],
    );
  }
}

// ============================================================================
// STICKY GLASS TABS
// ============================================================================

class _GlassTabs extends StatelessWidget {
  final List<String> tabs;
  final int activeIndex;
  final ValueChanged<int> onSelect;

  const _GlassTabs({
    required this.tabs,
    required this.activeIndex,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return GlassBar(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      child: Container(
        padding: EdgeInsets.all(4.r),
        decoration: BoxDecoration(
          color: const Color(0x0FFFFFFF),
          borderRadius: BorderRadius.circular(999.r),
          border: Border.all(color: const Color(0x1AFFFFFF)),
        ),
        child: Row(
          children: List.generate(tabs.length, (i) {
            final selected = i == activeIndex;
            return Expanded(
              child: GestureDetector(
                onTap: () => onSelect(i),
                behavior: HitTestBehavior.opaque,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: EdgeInsets.symmetric(vertical: 8.h),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: selected ? Colors.white : Colors.transparent,
                    borderRadius: BorderRadius.circular(999.r),
                    boxShadow: selected
                        ? [
                            BoxShadow(
                              color: const Color(0x59000000),
                              blurRadius: 14.r,
                              offset: Offset(0, 4.h),
                            ),
                          ]
                        : null,
                  ),
                  child: Text(
                    tabs[i],
                    maxLines: 1,
                    style: TextStyle(
                      fontFamily: 'Pretendard',
                      fontSize: 12.5.sp,
                      height: 14 / 12.5,
                      fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                      color: selected ? ClubGlass.ink : ClubGlass.t2,
                    ),
                  ),
                ),
              ),
            );
          }),
        ),
      ),
    );
  }
}

// ============================================================================
// LAZY TAB BODY
// ============================================================================

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

// ============================================================================
// HERO
// ============================================================================

class _Hero extends StatefulWidget {
  final VoidCallback onBack;
  final List<String> imageUrls;
  const _Hero({required this.onBack, required this.imageUrls});

  @override
  State<_Hero> createState() => _HeroState();
}

class _HeroState extends State<_Hero> {
  int _currentIndex = 0;
  final _pageController = PageController();
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    // 디자인 4.2초 간격 자동 전환.
    _timer = Timer.periodic(const Duration(milliseconds: 4200), (_) {
      if (!mounted || widget.imageUrls.length < 2) return;
      final next = (_currentIndex + 1) % widget.imageUrls.length;
      _pageController.animateToPage(
        next,
        duration: const Duration(milliseconds: 900),
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

    return Stack(
      fit: StackFit.expand,
      children: [
        if (total > 0)
          PageView.builder(
            controller: _pageController,
            onPageChanged: (i) => setState(() => _currentIndex = i),
            itemCount: total,
            itemBuilder: (_, i) =>
                SkeletonImage(url: images[i], fit: BoxFit.cover),
          ),
        // 상단 하이라이트 — 유리에 빛이 도는 느낌.
        const IgnorePointer(
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: Alignment(-0.48, -0.56),
                radius: 0.9,
                colors: [Color(0x3DFFFFFF), Color(0x00FFFFFF)],
                stops: [0.0, 0.62],
              ),
            ),
          ),
        ),
        // 상·하단 스크림 (디자인 linear-gradient 4-stop).
        const IgnorePointer(
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0x8C08070C),
                  Color(0x00000000),
                  Color(0x730D0C11),
                  Color(0xFF0D0C11),
                ],
                stops: [0.0, 0.32, 0.74, 1.0],
              ),
            ),
          ),
        ),
        // 뒤로가기 — 공유/찜은 퀵 액션 줄에 있어 히어로 위에는 두지 않는다.
        Positioned(
          top: 0,
          left: 0,
          child: SafeArea(
            bottom: false,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
              child: VybeGlassButton(onTap: widget.onBack),
            ),
          ),
        ),
        if (total > 1) ...[
          // 카운터
          Positioned(
            right: 16.w,
            bottom: 76.h,
            child: IgnorePointer(
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 11.w, vertical: 5.h),
                decoration: BoxDecoration(
                  color: ClubGlass.barFill,
                  borderRadius: BorderRadius.circular(999.r),
                  border: Border.all(color: const Color(0x24FFFFFF)),
                ),
                child: Text(
                  '${_currentIndex + 1} / $total',
                  style: ClubGlass.caption(
                    color: Colors.white,
                    lineHeight: 15,
                    weight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
          // 도트 인디케이터
          Positioned(
            left: 0,
            right: 0,
            bottom: 52.h,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(total, (i) {
                final on = i == _currentIndex;
                return GestureDetector(
                  onTap: () => _pageController.animateToPage(
                    i,
                    duration: const Duration(milliseconds: 320),
                    curve: Curves.easeOutCubic,
                  ),
                  behavior: HitTestBehavior.opaque,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 280),
                    margin: EdgeInsets.symmetric(horizontal: 2.5.w),
                    width: on ? 18.w : 5.w,
                    height: 5.h,
                    decoration: BoxDecoration(
                      color: on ? Colors.white : const Color(0x61FFFFFF),
                      borderRadius: BorderRadius.circular(99.r),
                    ),
                  ),
                );
              }),
            ),
          ),
        ],
      ],
    );
  }
}

// ============================================================================
// IDENTITY CARD
// ============================================================================

class _IdentityCard extends ConsumerWidget {
  final String clubId;
  const _IdentityCard({required this.clubId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final club = ref.watch(clubDetailProvider(clubId)).value;
    if (club == null) return const TitleSkeleton();

    final isOpen = club.operatingHours.today.isCurrentlyOpen;

    return GlassCard(
      padding: 20,
      radius: 24,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 지역 · 장르 + 영업 상태
          // 영업 상태 pill은 항상 오른쪽 끝(디자인 margin-left: auto).
          // 지역·장르를 Expanded로 묶어야 남는 폭을 전부 왼쪽이 먹고 pill이
          // 끝에 붙는다 — Flexible 텍스트 + Spacer를 나란히 두면 Spacer가
          // 여유 폭의 일부만 가져가 pill이 가운데로 밀린다.
          Row(
            children: [
              Expanded(
                child: Row(
                  children: [
                    Flexible(
                      child: Text(
                        club.area,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: ClubGlass.caption(),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 7.w),
                      child: Container(
                        width: 1,
                        height: 9.h,
                        color: const Color(0x38FFFFFF),
                      ),
                    ),
                    Flexible(
                      child: Text(
                        '${club.genre} 클럽',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: ClubGlass.caption(),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(width: 8.w),
              OpenStatusPill(isOpen: isOpen),
            ],
          ),
          SizedBox(height: 9.h),
          // 이름 + VYBE 추천 뱃지
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Flexible(
                child: Text(
                  club.name,
                  maxLines: 2,
                  style: TextStyle(
                    fontFamily: 'Pretendard',
                    fontSize: 28.sp,
                    height: 30 / 28,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 28 * -0.025,
                    color: Colors.white,
                  ),
                ),
              ),
              if (club.isVybeRecommended) ...[
                SizedBox(width: 8.w),
                const _VybeRecommendBadge(),
              ],
            ],
          ),
          SizedBox(height: 10.h),
          // 평점 · 리뷰 수
          Row(
            children: [
              SvgPicture.asset(
                'assets/icons/common/club_card/star.svg',
                width: 15.r,
                height: 15.r,
              ),
              SizedBox(width: 8.w),
              Text(
                club.rating.toStringAsFixed(2),
                style: TextStyle(
                  fontFamily: 'Pretendard',
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
              SizedBox(width: 8.w),
              const GlassDot(),
              SizedBox(width: 8.w),
              Text('리뷰 ${club.reviewCount}', style: ClubGlass.body()),
            ],
          ),
          if (club.description.isNotEmpty) ...[
            SizedBox(height: 12.h),
            Text(club.description, style: ClubGlass.body()),
          ],
          if (club.tags.isNotEmpty) ...[
            SizedBox(height: 14.h),
            Wrap(
              spacing: 6.w,
              runSpacing: 6.h,
              children: club.tags
                  .map(
                    (tag) => Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 11.w,
                        vertical: 5.h,
                      ),
                      decoration: BoxDecoration(
                        color: ClubGlass.tileFill,
                        borderRadius: BorderRadius.circular(99.r),
                        border: Border.all(color: const Color(0x1CFFFFFF)),
                      ),
                      child: Text(
                        '#$tag',
                        style: ClubGlass.caption(
                          color: ClubGlass.accentLavender,
                          weight: FontWeight.w500,
                        ),
                      ),
                    ),
                  )
                  .toList(),
            ),
          ],
        ],
      ),
    );
  }
}

/// VYBE 추천 클럽 뱃지 — 보라 그라데이션 + 라임 테두리 pill.
class _VybeRecommendBadge extends StatelessWidget {
  const _VybeRecommendBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(8.w, 5.h, 10.w, 5.h),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            VybeColors.mainPurple500.withValues(alpha: 0.92),
            VybeColors.mainPurple500.withValues(alpha: 0.5),
          ],
        ),
        borderRadius: BorderRadius.circular(999.r),
        border: Border.all(
          color: VybeColors.mainLime500.withValues(alpha: 0.5),
        ),
        boxShadow: [
          BoxShadow(
            color: VybeColors.mainPurple500.withValues(alpha: 0.35),
            blurRadius: 18.r,
            offset: Offset(0, 6.h),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SvgPicture.asset(
            'assets/icons/common/club_card/vybe_recommend.svg',
            width: 11.r,
            height: 11.r,
          ),
          SizedBox(width: 5.w),
          Text(
            'VYBE 추천클럽',
            style: TextStyle(
              fontFamily: 'Pretendard',
              fontSize: 11.sp,
              height: 12 / 11,
              fontWeight: FontWeight.w800,
              letterSpacing: 11 * 0.02,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// QUICK ACTIONS
// ============================================================================

class _QuickActions extends ConsumerWidget {
  final String clubId;
  const _QuickActions({required this.clubId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final club = ref.watch(clubDetailProvider(clubId)).value;

    final uid = ref.watch(currentUidProvider);
    final streamFavIds = uid != null
        ? ref.watch(favoritedClubIdsProvider(uid)).asData?.value ?? <String>{}
        : <String>{};
    final optimistic = ref.watch(favoriteViewModelProvider);
    final isFavorited = optimistic.containsKey(clubId)
        ? optimistic[clubId]!
        : streamFavIds.contains(clubId);

    return Padding(
      padding: EdgeInsets.fromLTRB(16.w, 14.h, 16.w, 0),
      child: Row(
        children: [
          _action(
            icon: Icons.phone_rounded,
            label: '전화',
            onTap: () => launchPhoneCall(context, club?.phone ?? ''),
          ),
          SizedBox(width: 8.w),
          _action(
            icon: Icons.near_me_outlined,
            label: '길찾기',
            onTap: () => launchDirections(
              context,
              lat: club?.lat ?? 0,
              lng: club?.lng ?? 0,
              name: club?.name ?? '',
            ),
          ),
          SizedBox(width: 8.w),
          _action(
            icon: Icons.ios_share_rounded,
            label: '공유',
            onTap: () => VybeToast.show(context, message: '공유 기능은 준비 중이에요'),
          ),
          SizedBox(width: 8.w),
          _action(
            icon: isFavorited ? Icons.favorite_rounded : Icons.favorite_border,
            label: isFavorited ? '저장됨' : '저장',
            active: isFavorited,
            onTap: uid == null
                ? () => VybeToast.show(context, message: '로그인 후 저장할 수 있어요')
                : () => ref
                      .read(favoriteViewModelProvider.notifier)
                      .toggleFavorite(uid, clubId, isFavorited),
          ),
        ],
      ),
    );
  }

  Widget _action({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    bool active = false,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 13.h),
          decoration: BoxDecoration(
            color: ClubGlass.tileFill,
            borderRadius: BorderRadius.circular(16.r),
            border: Border.all(color: ClubGlass.tileBorder),
          ),
          child: Column(
            children: [
              Icon(
                icon,
                size: 18.r,
                color: active ? ClubGlass.saved : const Color(0xD1FFFFFF),
              ),
              SizedBox(height: 7.h),
              Text(
                label,
                style: ClubGlass.caption(
                  color: active ? ClubGlass.accentLavender : ClubGlass.t2,
                  lineHeight: 12,
                  weight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
