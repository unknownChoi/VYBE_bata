import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vybe/core/navigation/swipe_back_page_route.dart';
import 'package:vybe/data/models/club_model.dart';
import 'package:vybe/presentation/clubs/club_detail_route.dart';
import 'package:vybe/presentation/clubs/performance_schedule_screen.dart';
import 'package:vybe/presentation/clubs/renew/widgets/renew_free_entry.dart';
import 'package:vybe/presentation/clubs/renew/widgets/renew_home_sections.dart';
import 'package:vybe/presentation/clubs/renew/widgets/renew_skeleton.dart';
import 'package:vybe/presentation/clubs/renew/widgets/renew_store_info_card.dart';
import 'package:vybe/presentation/clubs/table_pricing_screen.dart';
import 'package:vybe/presentation/clubs/viewmodels/club_detail_viewmodel.dart';
import 'package:vybe/presentation/clubs/viewmodels/club_schedule_viewmodel.dart';
import 'package:vybe/presentation/common/renew/renew_glass.dart';
import 'package:vybe/presentation/common/widgets/vybe_fade_in_up.dart';
import 'package:vybe/presentation/common/widgets/vybe_photo_viewer.dart';

/// 클럽 상세 리뉴얼 · 홈 탭.
///
/// 디자인 club_renew.jsx 홈 패널 순서 —
/// 시간대별 무료입장 / 매장 정보 / 오늘의 라인업 / 테이블 / 메뉴 / 사진 /
/// 주변 클럽 + 안내 문구.
///
/// 무료입장 섹션은 정책이 있는 클럽에서만 나온다 (없으면 자리 자체가 없다).
/// 카드 한 장씩 감싸지 않고 배경 위에 섹션을 32 간격으로 쌓는다.
class RenewHomeTab extends ConsumerWidget {
  final String clubId;
  final EdgeInsets padding;
  final VoidCallback onViewAllPhotos;
  final VoidCallback onViewAllMenus;

  /// 상세 셸이 판단한 진입 로딩 — true면 섹션 대신 스켈레톤.
  /// 히어로·타이틀과 같은 플래그를 써야 세 곳이 동시에 내용으로 바뀐다.
  final bool showSkeleton;

  const RenewHomeTab({
    super.key,
    required this.clubId,
    required this.padding,
    required this.onViewAllPhotos,
    required this.onViewAllMenus,
    this.showSkeleton = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final clubAsync = ref.watch(clubDetailProvider(clubId));
    final club = clubAsync.value;

    if (showSkeleton || clubAsync.isLoading) {
      return RenewHomeSkeleton(padding: padding);
    }
    if (club == null) {
      return Center(
        child: Text('클럽 정보를 불러올 수 없어요', style: RenewGlass.body()),
      );
    }

    final info = ref.watch(clubInfoProvider(clubId)).value;
    final menus = ref.watch(clubMenusProvider(clubId)).value ?? const [];
    final nearby = ref.watch(nearbyClubsProvider(clubId)).value ?? const [];
    final days = ref.watch(clubScheduleProvider(clubId)).value ?? const [];
    final lineup = days.isEmpty || days.first.acts.isEmpty ? null : days.first;

    final freeEntry = RenewFreeEntrySection.maybeBuild(club);
    final tableLayout = ref.watch(clubTableLayoutProvider(clubId)).value;

    final sections = <Widget>[
      if (freeEntry != null) freeEntry,
      RenewStoreInfoCard(club: club, info: info),
      if (lineup != null)
        RenewLineupSection(
          day: lineup,
          onViewAll: () => _openSchedule(context, club),
        ),
      // 배치도가 없는 클럽은 섹션 자체를 뺀다 — 빈 카드는 '테이블 없음'과 구분이 안 된다.
      if (tableLayout != null)
        RenewTableSection(
          layout: tableLayout,
          onViewPricing: () => TablePricingScreen.push(
            context,
            clubId: clubId,
            clubName: club.name,
          ),
        ),
      if (menus.isNotEmpty)
        RenewMenuSection(menus: menus, onViewAll: onViewAllMenus),
      if (club.imageUrls.isNotEmpty)
        RenewPhotoSection(
          imageUrls: club.imageUrls,
          onViewAll: onViewAllPhotos,
          onOpen: (i) => VybePhotoViewer.open(
            context,
            imageUrls: club.imageUrls,
            initialIndex: i,
          ),
        ),
      if (nearby.isNotEmpty)
        RenewNearbySection(
          area: club.area,
          clubs: nearby,
          onTapClub: (c) => _openClub(context, c.clubId),
        ),
      const RenewFooterNote(
        text: '영업시간 · 입장료 · 라인업은 매장 사정에 따라 달라질 수 있으니 방문 전 확인해 주세요.',
      ),
    ];

    return ListView.separated(
      physics: const ClampingScrollPhysics(),
      padding: padding,
      itemCount: sections.length,
      separatorBuilder: (_, __) => SizedBox(height: RenewGlass.sectionGap.h),
      // 디자인 VFadeUp — 섹션마다 45ms씩 늦게 떠오른다.
      itemBuilder: (_, i) => VybeFadeInUp(
        delay: Duration(milliseconds: 40 + i * 45),
        child: sections[i],
      ),
    );
  }

  void _openSchedule(BuildContext context, ClubModel club) {
    Navigator.of(context).push(
      SwipeBackPageRoute(
        builder: (_) => PerformanceScheduleScreen(
          clubId: clubId,
          clubName: club.name,
          area: club.area,
        ),
      ),
    );
  }

  // 주변 클럽 → 같은 리뉴얼 상세로 이동.
  // 상세가 바텀시트로 떠 있어도 전체 화면으로 열리도록 root navigator 사용.
  void _openClub(BuildContext context, String id) {
    openClubDetail(context, id, rootNavigator: true);
  }
}
