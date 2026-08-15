import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vybe/core/navigation/swipe_back_page_route.dart';
import 'package:vybe/data/models/club_model.dart';
import 'package:vybe/presentation/clubs/club_detail_route.dart';
import 'package:vybe/presentation/clubs/performance_schedule_screen.dart';
import 'package:vybe/presentation/clubs/renew/widgets/renew_home_sections.dart';
import 'package:vybe/presentation/clubs/renew/widgets/renew_store_info_card.dart';
import 'package:vybe/presentation/clubs/table_pricing_screen.dart';
import 'package:vybe/presentation/clubs/viewmodels/club_detail_viewmodel.dart';
import 'package:vybe/presentation/clubs/viewmodels/club_schedule_viewmodel.dart';
import 'package:vybe/presentation/common/renew/renew_glass.dart';
import 'package:vybe/presentation/common/widgets/vybe_fade_in_up.dart';
import 'package:vybe/presentation/common/widgets/vybe_photo_viewer.dart';
import 'package:vybe/presentation/common/widgets/vybe_spinner.dart';

/// 클럽 상세 리뉴얼 · 홈 탭.
///
/// 디자인 club_renew.jsx 홈 패널 순서 —
/// 매장 정보 / 오늘의 라인업 / 테이블 / 메뉴 / 사진 / 주변 클럽 + 안내 문구.
/// 카드 한 장씩 감싸지 않고 배경 위에 섹션을 32 간격으로 쌓는다.
class RenewHomeTab extends ConsumerWidget {
  final String clubId;
  final EdgeInsets padding;
  final VoidCallback onViewAllPhotos;
  final VoidCallback onViewAllMenus;

  const RenewHomeTab({
    super.key,
    required this.clubId,
    required this.padding,
    required this.onViewAllPhotos,
    required this.onViewAllMenus,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final clubAsync = ref.watch(clubDetailProvider(clubId));
    final club = clubAsync.value;

    if (club == null) {
      return Center(
        child: clubAsync.isLoading
            ? const VybeSpinner(size: 40)
            : Text('클럽 정보를 불러올 수 없어요', style: RenewGlass.body()),
      );
    }

    final info = ref.watch(clubInfoProvider(clubId)).value;
    final menus = ref.watch(clubMenusProvider(clubId)).value ?? const [];
    final nearby = ref.watch(nearbyClubsProvider(clubId)).value ?? const [];
    final days = ref.watch(clubScheduleProvider(clubId)).value ?? const [];
    final lineup = days.isEmpty || days.first.acts.isEmpty ? null : days.first;

    final sections = <Widget>[
      RenewStoreInfoCard(club: club, info: info),
      if (lineup != null)
        RenewLineupSection(
          day: lineup,
          onViewAll: () => _openSchedule(context, club),
        ),
      RenewTableSection(
        onViewPricing: () =>
            TablePricingScreen.push(context, clubName: club.name),
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
