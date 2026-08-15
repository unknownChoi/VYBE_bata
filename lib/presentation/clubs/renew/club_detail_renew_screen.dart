import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vybe/core/providers/auth_providers.dart';
import 'package:vybe/core/providers/location_providers.dart';
import 'package:vybe/core/utils/geohash_utils.dart';
import 'package:vybe/core/utils/map_launcher.dart';
import 'package:vybe/core/utils/phone_launcher.dart';
import 'package:vybe/data/models/club_model.dart';
import 'package:vybe/presentation/clubs/renew/renew_home_tab.dart';
import 'package:vybe/presentation/clubs/renew/renew_info_tab.dart';
import 'package:vybe/presentation/clubs/renew/renew_menu_tab.dart';
import 'package:vybe/presentation/clubs/renew/renew_photo_tab.dart';
import 'package:vybe/presentation/clubs/renew/renew_review_tab.dart';
import 'package:vybe/presentation/clubs/renew/widgets/renew_chrome.dart';
import 'package:vybe/presentation/clubs/renew/widgets/renew_glass.dart';
import 'package:vybe/presentation/clubs/renew/widgets/renew_header.dart';
import 'package:vybe/presentation/clubs/renew/widgets/renew_lazy_tab.dart';
import 'package:vybe/presentation/clubs/viewmodels/club_detail_viewmodel.dart';
import 'package:vybe/presentation/clubs/viewmodels/favorite_viewmodel.dart';
import 'package:vybe/presentation/common/widgets/vybe_toast.dart';
import 'package:vybe/presentation/nearby/widgets/nearby_glass.dart'
    show formatDistance;

/// 클럽 상세 — **리뉴얼**.
///
/// 디자인: club_detail_renew.html
/// (`club_renew.jsx` · `club_renew_shell.jsx` · `club_renew_sections.jsx` ·
///  `club_renew_tabs.jsx`).
///
/// 구성 — 히어로(356) → 히어로를 24 덮는 타이틀 블록 → sticky 탭 5개 →
/// 탭 패널. 상단바(뒤로/공유/찜)와 하단 액션바(찜·길찾기·전화)는 스크롤 위에 뜬다.
///
/// 스크롤 구조 —
/// 히어로가 상단바 **뒤까지** 올라와야 해서 스크롤 뷰는 상단바 아래에서 시작하고,
/// 히어로만 루트 [Stack]에 따로 그려 스크롤한 만큼 위로 옮긴다.
/// 탭 바는 [NestedScrollView.body] 최상단에 둬서 헤더가 사라지면 자연히 고정된다
/// (headerSliverBuilder에 pinned sliver를 넣으면 Flutter 3.41에서 화면이
///  통째로 안 그려진다 — CLAUDE.md 참고).
class ClubDetailRenewScreen extends ConsumerStatefulWidget {
  final String clubId;

  /// 바텀시트 등으로 띄울 때 닫기 동작 주입. null이면 `Navigator.maybePop`.
  final VoidCallback? onClose;

  const ClubDetailRenewScreen({super.key, required this.clubId, this.onClose});

  // 화면 진입은 `openClubDetail`(club_detail_route.dart) 한 곳으로만 한다 —
  // 하단 액션 바가 MainScaffold의 floating nav와 겹쳐 nav를 내려야 하기 때문.

  @override
  ConsumerState<ClubDetailRenewScreen> createState() =>
      _ClubDetailRenewScreenState();
}

class _ClubDetailRenewScreenState extends ConsumerState<ClubDetailRenewScreen>
    with SingleTickerProviderStateMixin {
  static const List<String> _tabs = ['홈', '사진', '메뉴', '리뷰', '매장정보'];

  late final TabController _tabController;
  final ScrollController _outer = ScrollController();

  /// 헤더가 스크롤된 양. 히어로 위치와 상단바 상태만 쓰므로 [ValueNotifier]로
  /// 흘려보낸다 — setState로 돌리면 탭 콘텐츠까지 매 프레임 다시 그린다.
  final ValueNotifier<double> _scrollY = ValueNotifier(0);

  int _activeIndex = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this);
    _tabController.addListener(() {
      if (_tabController.index == _activeIndex) return;
      setState(() => _activeIndex = _tabController.index);
    });
    _outer.addListener(() {
      _scrollY.value = _outer.offset < 0 ? 0 : _outer.offset;
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _outer.dispose();
    _scrollY.dispose();
    super.dispose();
  }

  void _goToTab(int index) => _tabController.animateTo(index);

  @override
  Widget build(BuildContext context) {
    final clubAsync = ref.watch(clubDetailProvider(widget.clubId));
    final club = clubAsync.value;

    // 탭 전환 시 재로딩 방지 — 상세 진입 시 1회만 fetch.
    ref.watch(clubInfoProvider(widget.clubId));
    ref.watch(nearbyClubsProvider(widget.clubId));

    final saved = ref.watch(mergedFavoriteIdsProvider).contains(widget.clubId);
    final chromeH = MediaQuery.paddingOf(context).top + kRenewChromeRow.h;
    // 히어로 아래 24가 타이틀에 덮이고, 스크롤 뷰는 상단바 아래에서 시작한다.
    final heroSpacer = (kRenewHeroHeight - kRenewTitleOverlap).h - chromeH;

    final tabPadding = EdgeInsets.fromLTRB(
      RenewGlass.pagePad.w,
      24.h,
      RenewGlass.pagePad.w,
      RenewBottomBar.height(context) + 34.h,
    );

    return Scaffold(
      backgroundColor: RenewGlass.ink,
      body: Stack(
        children: [
          const Positioned.fill(child: RenewAurora()),
          // 히어로 — 스크롤한 만큼 위로 밀린다.
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: ValueListenableBuilder<double>(
              valueListenable: _scrollY,
              builder: (_, y, child) =>
                  Transform.translate(offset: Offset(0, -y), child: child),
              child: RenewHero(
                imageUrls: club?.heroImageUrls ?? const [],
                loading: clubAsync.isLoading,
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.only(top: chromeH),
            child: NestedScrollView(
              controller: _outer,
              physics: const ClampingScrollPhysics(),
              headerSliverBuilder: (_, __) => [
                SliverToBoxAdapter(
                  child: SizedBox(height: heroSpacer < 0 ? 0 : heroSpacer),
                ),
                SliverToBoxAdapter(
                  child: club == null
                      ? SizedBox(height: 120.h)
                      : RenewTitleBlock(
                          club: club,
                          distanceLabel: _distanceLabel(club),
                        ),
                ),
                // 탭 바 위 여백 (디자인 marginTop 20)
                SliverToBoxAdapter(child: SizedBox(height: 20.h)),
              ],
              body: Column(
                children: [
                  RenewTabBar(
                    tabs: _tabs,
                    activeIndex: _activeIndex,
                    onSelect: _goToTab,
                  ),
                  Expanded(child: _tabViews(tabPadding)),
                ],
              ),
            ),
          ),
          // 상단바
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: ValueListenableBuilder<double>(
              valueListenable: _scrollY,
              builder: (_, y, __) => RenewChrome(
                scrollY: y,
                clubName: club?.name ?? '',
                onBack:
                    widget.onClose ?? () => Navigator.of(context).maybePop(),
                onShare: () =>
                    VybeToast.show(context, message: '공유 기능은 준비 중이에요'),
              ),
            ),
          ),
          // 하단 액션 바
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: RenewBottomBar(
              saved: saved,
              onSave: () => _toggleSave(saved),
              onDirections: () => launchDirections(
                context,
                lat: club?.lat ?? 0,
                lng: club?.lng ?? 0,
                // 목적지 라벨은 주소 — 주소가 비면 클럽 이름으로 폴백
                destination: (club?.address.isNotEmpty ?? false)
                    ? club!.address
                    : (club?.name ?? ''),
              ),
              onCall: () => launchPhoneCall(context, club?.phone ?? ''),
            ),
          ),
        ],
      ),
    );
  }

  Widget _tabViews(EdgeInsets padding) {
    return TabBarView(
      controller: _tabController,
      children: [
        RenewHomeTab(
          clubId: widget.clubId,
          padding: padding,
          onViewAllPhotos: () => _goToTab(1),
          onViewAllMenus: () => _goToTab(2),
        ),
        RenewLazyTab(
          selected: _activeIndex == 1,
          builder: () => RenewPhotoTab(clubId: widget.clubId, padding: padding),
        ),
        RenewLazyTab(
          selected: _activeIndex == 2,
          builder: () => RenewMenuTab(clubId: widget.clubId, padding: padding),
        ),
        RenewLazyTab(
          selected: _activeIndex == 3,
          builder: () =>
              RenewReviewTab(clubId: widget.clubId, padding: padding),
        ),
        RenewLazyTab(
          selected: _activeIndex == 4,
          builder: () => RenewInfoTab(clubId: widget.clubId, padding: padding),
        ),
      ],
    );
  }

  /// 내 위치 기준 거리. 좌표가 없는 클럽(0,0)은 표기를 생략한다.
  String? _distanceLabel(ClubModel club) {
    if (club.lat == 0 && club.lng == 0) return null;
    final me = ref.read(userLocationProvider);
    final km = GeohashUtils.haversineKm(me.lat, me.lng, club.lat, club.lng);
    return formatDistance(km * 1000);
  }

  void _toggleSave(bool saved) {
    final uid = ref.read(currentUidProvider);
    if (uid == null) {
      VybeToast.show(context, message: '로그인 후 저장할 수 있어요');
      return;
    }
    ref
        .read(favoriteViewModelProvider.notifier)
        .toggleFavorite(uid, widget.clubId, saved);
    VybeToast.show(context, message: saved ? '찜 목록에서 빼놨어요' : '찜 목록에 담았어요');
  }
}
