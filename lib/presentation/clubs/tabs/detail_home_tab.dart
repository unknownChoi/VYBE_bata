import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:vybe/core/navigation/swipe_back_page_route.dart';
import 'package:vybe/core/utils/number_format.dart';
import 'package:vybe/core/utils/url_utils.dart';
import 'package:vybe/data/models/club_info_model.dart';
import 'package:vybe/data/models/club_model.dart';
import 'package:vybe/data/models/menu_model.dart';
import 'package:vybe/data/models/operating_hours.dart';
import 'package:vybe/design_system/colors.dart';
import 'package:vybe/presentation/clubs/club_detail_screen.dart';
import 'package:vybe/presentation/clubs/performance_schedule_screen.dart';
import 'package:vybe/presentation/clubs/table_pricing_screen.dart';
import 'package:vybe/presentation/clubs/viewmodels/club_detail_viewmodel.dart';
import 'package:vybe/presentation/clubs/viewmodels/club_schedule_viewmodel.dart';
import 'package:vybe/presentation/clubs/widgets/club_detail_skeleton.dart';
import 'package:vybe/presentation/clubs/widgets/club_glass.dart';
import 'package:vybe/presentation/clubs/widgets/schedule_shared.dart';
import 'package:vybe/presentation/clubs/widgets/table_pricing_section.dart';
import 'package:vybe/presentation/common/widgets/vybe_skeleton.dart';

/// 클럽 상세 · 홈 탭 (리퀴드 글래스).
///
/// 디자인 club_glass.jsx 홈 탭 순서 — 매장 정보 / 오늘의 라인업 / 테이블 /
/// 메뉴(3) / 사진(6) / 주변 클럽. 전부 [GlassCard] 한 장씩.
class DetailHomeTab extends ConsumerStatefulWidget {
  final String clubId;
  final VoidCallback? onViewAllPhotos;
  final VoidCallback? onViewAllMenus;
  final VoidCallback? onViewInfo;
  const DetailHomeTab({
    super.key,
    required this.clubId,
    this.onViewAllPhotos,
    this.onViewAllMenus,
    this.onViewInfo,
  });

  @override
  ConsumerState<DetailHomeTab> createState() => _DetailHomeTabState();
}

class _DetailHomeTabState extends ConsumerState<DetailHomeTab> {
  bool _addrExpanded = false;
  bool _hoursExpanded = false;

  @override
  Widget build(BuildContext context) {
    final clubAsync = ref.watch(clubDetailProvider(widget.clubId));
    final clubInfoAsync = ref.watch(clubInfoProvider(widget.clubId));
    final menusAsync = ref.watch(clubMenusProvider(widget.clubId));
    final club = clubAsync.value;

    return ListView(
      physics: const ClampingScrollPhysics(),
      padding: glassTabPadding(context),
      children: [
        clubAsync.isLoading
            ? const DetailInfoCardSkeleton()
            : _buildInfoCard(club, clubInfoAsync.value),
        glassGap(),
        _buildLineupCard(club),
        _buildTableCard(club),
        menusAsync.isLoading
            ? const DetailMenuCardSkeleton()
            : _buildMenuCard(menusAsync.value ?? const []),
        glassGap(),
        clubAsync.isLoading
            ? const DetailPhotoCardSkeleton()
            : _buildPhotoCard(club?.imageUrls ?? const []),
        glassGap(),
        _buildNearbyCard(club),
      ],
    );
  }

  // ==========================================================================
  // 매장 정보
  // ==========================================================================

  Widget _buildInfoCard(ClubModel? club, ClubInfoModel? clubInfo) {
    final hours = club?.operatingHours ?? const OperatingHours();
    final today = hours.today;
    final igHandle = instagramHandle(club?.instagramUrl ?? '');
    final subways = clubInfo?.nearbySubways ?? const [];

    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const GlassSectionHead(title: '매장 정보'),
          Transform.translate(
            offset: Offset(0, -4.h),
            child: Column(
              children: [
                // 주소 — 탭하면 주변 지하철 상세가 펼쳐진다.
                GlassInfoRow(
                  icon: Icons.place_outlined,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      GestureDetector(
                        onTap: () =>
                            setState(() => _addrExpanded = !_addrExpanded),
                        behavior: HitTestBehavior.opaque,
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Text(
                                club?.address ?? '',
                                style: ClubGlass.body(),
                              ),
                            ),
                            if (subways.isNotEmpty)
                              Padding(
                                padding: EdgeInsets.only(left: 10.w, top: 3.h),
                                child: AnimatedRotation(
                                  turns: _addrExpanded ? 0.5 : 0,
                                  duration: const Duration(milliseconds: 220),
                                  child: Icon(
                                    Icons.keyboard_arrow_down_rounded,
                                    size: 18.r,
                                    color: const Color(0x80FFFFFF),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                      // 접으면 주소 한 줄만 남는다 — 지하철역은 펼쳤을 때만.
                      if (subways.isNotEmpty && _addrExpanded)
                        Padding(
                          padding: EdgeInsets.only(top: 10.h),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              for (var i = 0; i < subways.length; i++)
                                Padding(
                                  padding: EdgeInsets.only(
                                    bottom: i == subways.length - 1 ? 0 : 8.h,
                                  ),
                                  child: SubwayStationLine(subway: subways[i]),
                                ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
                // 영업시간 — 탭하면 요일별 전체가 펼쳐진다.
                GlassInfoRow(
                  icon: Icons.schedule_rounded,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      GestureDetector(
                        onTap: () =>
                            setState(() => _hoursExpanded = !_hoursExpanded),
                        behavior: HitTestBehavior.opaque,
                        child: Row(
                          children: [
                            Expanded(child: OpenHoursLine(today: today)),
                            AnimatedRotation(
                              turns: _hoursExpanded ? 0.5 : 0,
                              duration: const Duration(milliseconds: 220),
                              child: Icon(
                                Icons.keyboard_arrow_down_rounded,
                                size: 18.r,
                                color: const Color(0x80FFFFFF),
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (_hoursExpanded)
                        Padding(
                          padding: EdgeInsets.only(top: 10.h),
                          child: WeekHoursTable(hours: hours, rowGap: 7),
                        ),
                    ],
                  ),
                ),
                // 입장료
                GlassInfoRow(
                  icon: Icons.confirmation_number_outlined,
                  child: Row(
                    children: [
                      Text('입장료 ', style: ClubGlass.body()),
                      Text(
                        formatEntryFee(
                          min: club?.entryFeeMin ?? 0,
                          max: club?.entryFeeMax ?? 0,
                        ),
                        style: TextStyle(
                          fontFamily: 'Pretendard',
                          fontSize: 14.sp,
                          height: 20 / 14,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
                // 인스타그램
                GlassInfoRow(
                  icon: Icons.link_rounded,
                  last: true,
                  child: Text(
                    igHandle.isEmpty ? '등록된 링크가 없어요' : '@$igHandle',
                    style: ClubGlass.body(
                      color: igHandle.isEmpty ? ClubGlass.t4 : ClubGlass.link,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================================================
  // 오늘의 라인업
  // ==========================================================================

  Widget _buildLineupCard(ClubModel? club) {
    final async = ref.watch(clubScheduleProvider(widget.clubId));
    // 카드 뒤 간격까지 같이 내보내야 로딩 → 콘텐츠 전환에서 간격이 안 튄다.
    if (async.isLoading) {
      return Column(children: [const DetailLineupCardSkeleton(), glassGap()]);
    }

    final days = async.value ?? const <ScheduleDay>[];
    if (days.isEmpty) return const SizedBox.shrink();

    final day = days.first;
    if (day.acts.isEmpty) return const SizedBox.shrink();

    return Column(
      children: [
        GlassCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GlassSectionHead(
                title: day.dday == 0 ? '오늘의 라인업' : '다가오는 라인업',
                sub: '${day.month}월 ${day.day}일 (${day.dow})',
                onAction: () => Navigator.of(context).push(
                  SwipeBackPageRoute(
                    builder: (_) => PerformanceScheduleScreen(
                      clubId: widget.clubId,
                      clubName: club?.name,
                      area: club?.area,
                    ),
                  ),
                ),
              ),
              for (var i = 0; i < day.acts.length; i++)
                Padding(
                  padding: EdgeInsets.only(
                    bottom: i == day.acts.length - 1 ? 0 : 10.h,
                  ),
                  child: _lineupRow(day.acts[i]),
                ),
            ],
          ),
        ),
        glassGap(),
      ],
    );
  }

  Widget _lineupRow(ScheduleAct act) {
    final type = scheduleActTypes[act.type];
    return Container(
      padding: EdgeInsets.all(10.r),
      decoration: BoxDecoration(
        color: act.headline
            ? VybeColors.mainPurple500.withValues(alpha: 0.16)
            : const Color(0x0DFFFFFF),
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(
          color: act.headline
              ? VybeColors.mainLime500.withValues(alpha: 0.22)
              : const Color(0x17FFFFFF),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 44.r,
            height: 44.r,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12.r),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: act.gradient,
              ),
            ),
            alignment: Alignment.center,
            child: Icon(
              type?.icon ?? Icons.music_note_rounded,
              size: 20.r,
              color: Colors.white.withValues(alpha: 0.9),
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        act.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontFamily: 'Pretendard',
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    if (act.headline) ...[
                      SizedBox(width: 7.w),
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 7.w,
                          vertical: 2.h,
                        ),
                        decoration: BoxDecoration(
                          color: VybeColors.mainLime500,
                          borderRadius: BorderRadius.circular(5.r),
                        ),
                        child: Text(
                          'HEADLINE',
                          style: ClubGlass.caption(
                            color: ClubGlass.ink,
                            size: 10,
                            lineHeight: 12,
                            weight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                SizedBox(height: 4.h),
                Text(
                  '${act.time} · ${type?.label ?? act.type}',
                  style: ClubGlass.caption(lineHeight: 13),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================================================
  // 테이블
  // ==========================================================================

  Widget _buildTableCard(ClubModel? club) {
    return Column(
      children: [
        GlassCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GlassSectionHead(
                title: '테이블',
                sub: '예약은 매장 전화로 문의해주세요',
                actionLabel: '가격표',
                onAction: () => TablePricingScreen.push(
                  context,
                  clubName: club?.name ?? '',
                ),
              ),
              const TableTierSummary(),
            ],
          ),
        ),
        glassGap(),
      ],
    );
  }

  // ==========================================================================
  // 메뉴 (미리보기 3개)
  // ==========================================================================

  Widget _buildMenuCard(List<MenuModel> menus) {
    if (menus.isEmpty) return const SizedBox.shrink();
    final preview = menus.take(3).toList();

    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GlassSectionHead(
            title: '메뉴',
            sub: '가격은 매장 사정에 따라 달라질 수 있어요',
            actionLabel: '더보기',
            onAction: widget.onViewAllMenus,
          ),
          for (var i = 0; i < preview.length; i++)
            GlassMenuRow(menu: preview[i], last: i == preview.length - 1),
        ],
      ),
    );
  }

  // ==========================================================================
  // 사진 (미리보기 6장)
  // ==========================================================================

  Widget _buildPhotoCard(List<String> imageUrls) {
    if (imageUrls.isEmpty) return const SizedBox.shrink();
    final preview = imageUrls.take(6).toList();

    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GlassSectionHead(
            title: '사진',
            sub: '${imageUrls.length}장',
            onAction: widget.onViewAllPhotos,
          ),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: EdgeInsets.zero,
            itemCount: preview.length,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              mainAxisSpacing: 6.w,
              crossAxisSpacing: 6.w,
            ),
            itemBuilder: (_, i) => ClipRRect(
              borderRadius: BorderRadius.circular(14.r),
              child: SkeletonImage(url: preview[i], fit: BoxFit.cover),
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================================================
  // 주변 클럽
  // ==========================================================================

  Widget _buildNearbyCard(ClubModel? club) {
    final nearbyAsync = ref.watch(nearbyClubsProvider(widget.clubId));
    final nearby = nearbyAsync.value ?? const <ClubModel>[];
    if (nearbyAsync.isLoading) return const DetailNearbyCardSkeleton();
    if (nearby.isEmpty) return const SizedBox.shrink();

    return GlassCard(
      padding: 0,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(18.w, 18.h, 18.w, 0),
            child: GlassSectionHead(
              title: '주변 클럽',
              sub: '${club?.area ?? ''} · ${nearby.length}곳',
              onAction: null,
            ),
          ),
          SizedBox(
            // 썸네일은 .w(가로 스케일), 나머지는 .h(세로 스케일)이라 상수 하나로
            // 높이를 잡으면 기기별로 어긋나 오버플로우가 난다 → 실제 구성요소를
            // 그대로 더한다: 썸네일 + 간격 + 텍스트 블록 + 리스트 하단 패딩.
            height: kNearbyThumbSize.w + 9.h + kNearbyTextBlock.h + 18.h,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.fromLTRB(18.w, 0, 18.w, 18.h),
              itemCount: nearby.length,
              separatorBuilder: (_, __) => SizedBox(width: 10.w),
              itemBuilder: (_, i) => _nearbyCard(nearby[i]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _nearbyCard(ClubModel club) {
    final isOpen = club.operatingHours.today.isCurrentlyOpen;

    return GestureDetector(
      onTap: () => _openClubDetail(club.clubId),
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: kNearbyThumbSize.w,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: kNearbyThumbSize.w,
              height: kNearbyThumbSize.w,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(16.r),
                    child: SkeletonImage(
                      url: club.thumbnailUrl,
                      fit: BoxFit.cover,
                    ),
                  ),
                  IgnorePointer(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16.r),
                        gradient: const LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [Color(0x00000000), Color(0x99000000)],
                          stops: [0.48, 1.0],
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 7.h,
                    left: 7.w,
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 8.w,
                        vertical: 3.h,
                      ),
                      decoration: BoxDecoration(
                        color: ClubGlass.barFill,
                        borderRadius: BorderRadius.circular(999.r),
                        border: Border.all(color: const Color(0x24FFFFFF)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SvgPicture.asset(
                            'assets/icons/common/club_card/star.svg',
                            width: 10.r,
                            height: 10.r,
                          ),
                          SizedBox(width: 3.w),
                          Text(
                            club.rating.toStringAsFixed(1),
                            style: ClubGlass.caption(
                              color: Colors.white,
                              size: 10.5,
                              lineHeight: 12,
                              weight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Positioned(
                    left: 8.w,
                    bottom: 8.h,
                    child: Row(
                      children: [
                        Container(
                          width: 5.r,
                          height: 5.r,
                          decoration: BoxDecoration(
                            color: isOpen
                                ? VybeColors.mainLime500
                                : const Color(0x66FFFFFF),
                            shape: BoxShape.circle,
                          ),
                        ),
                        SizedBox(width: 4.w),
                        Text(
                          isOpen ? '영업중' : '영업종료',
                          style: ClubGlass.caption(
                            color: Colors.white,
                            size: 10.5,
                            lineHeight: 12,
                            weight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 9.h),
            // 남은 높이를 텍스트가 나눠 갖게 해 폰트 스케일이 커져도 넘치지 않게 한다.
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    club.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontFamily: 'Pretendard',
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 3.h),
                  Flexible(
                    child: Text(
                      '${club.area} · ${club.genre}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: ClubGlass.caption(),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 주변 클럽 카드 탭 → 해당 클럽 상세로 이동.
  // 상세가 바텀시트(주변 페이지)로 떠 있어도 전체 화면으로 열리도록 root navigator 사용.
  void _openClubDetail(String clubId) {
    Navigator.of(
      context,
      rootNavigator: true,
    ).push(SwipeBackPageRoute(builder: (_) => ClubDetailScreen(clubId: clubId)));
  }
}

// ============================================================================
// 메뉴 한 줄 (홈 미리보기 · 메뉴 탭 공용)
// ============================================================================

/// 디자인 CGMenuList의 한 행 — 좌측 텍스트, 우측 78x78 썸네일.
class GlassMenuRow extends StatelessWidget {
  final MenuModel menu;
  final bool last;

  const GlassMenuRow({super.key, required this.menu, this.last = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 14.h),
      decoration: BoxDecoration(
        border: last
            ? null
            : const Border(bottom: BorderSide(color: ClubGlass.hair)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    if (menu.isFeatured) ...[
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 7.w,
                          vertical: 2.h,
                        ),
                        decoration: BoxDecoration(
                          color: VybeColors.mainPurple500,
                          borderRadius: BorderRadius.circular(5.r),
                        ),
                        child: Text(
                          '대표',
                          style: ClubGlass.caption(
                            color: Colors.white,
                            size: 10,
                            lineHeight: 13,
                            weight: FontWeight.w800,
                          ),
                        ),
                      ),
                      SizedBox(width: 6.w),
                    ],
                    Flexible(
                      child: Text(
                        menu.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontFamily: 'Pretendard',
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
                if (menu.description.isNotEmpty) ...[
                  SizedBox(height: 5.h),
                  Text(
                    menu.description,
                    style: ClubGlass.caption(lineHeight: 15),
                  ),
                ],
                SizedBox(height: 7.h),
                Text(
                  '${formatThousands(menu.price)}원',
                  style: TextStyle(
                    fontFamily: 'Pretendard',
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          if (menu.imageUrl.isNotEmpty) ...[
            SizedBox(width: 14.w),
            ClipRRect(
              borderRadius: BorderRadius.circular(14.r),
              child: SizedBox(
                width: 78.r,
                height: 78.r,
                child: SkeletonImage(url: menu.imageUrl, fit: BoxFit.cover),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
