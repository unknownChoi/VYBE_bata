import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:vybe/data/models/club_model.dart';
import 'package:vybe/data/models/menu_model.dart';
import 'package:vybe/design_system/colors.dart';
import 'package:vybe/presentation/clubs/renew/widgets/renew_menu_rows.dart';
import 'package:vybe/presentation/clubs/widgets/schedule_shared.dart';
import 'package:vybe/presentation/clubs/widgets/table_pricing_data.dart';
import 'package:vybe/presentation/common/renew/renew_glass.dart';
import 'package:vybe/presentation/common/widgets/vybe_skeleton.dart';

// 클럽 상세 리뉴얼 · 홈 탭 섹션들.
// 디자인: club_renew_tabs.jsx (VRLineupToday · VRTables · VRNearby) +
//         club_renew_sections.jsx (VRMenu · VRPhotos).

// ============================================================================
// 오늘의 라인업 (VRLineupToday)
// ============================================================================

class RenewLineupSection extends StatelessWidget {
  final ScheduleDay day;
  final VoidCallback? onViewAll;

  const RenewLineupSection({super.key, required this.day, this.onViewAll});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RenewSectionHead(
          title: day.dday == 0 ? '오늘의 라인업' : '다가오는 라인업',
          sub: '${day.month}월 ${day.day}일 (${day.dow})',
          onAction: onViewAll,
        ),
        for (var i = 0; i < day.acts.length; i++)
          Padding(
            padding: EdgeInsets.only(
              bottom: i == day.acts.length - 1 ? 0 : 8.h,
            ),
            child: _actRow(day.acts[i]),
          ),
      ],
    );
  }

  Widget _actRow(ScheduleAct act) {
    final type = scheduleActTypes[act.type];
    return RenewGlassCard(
      quiet: true,
      radius: 14,
      padding: 12,
      fill: act.headline
          ? VybeColors.mainPurple500.withValues(alpha: 0.16)
          : null,
      border: act.headline
          ? VybeColors.mainLime500.withValues(alpha: 0.22)
          : null,
      child: Row(
        children: [
          Container(
            width: 44.r,
            height: 44.r,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12.r),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: act.gradient,
              ),
            ),
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
                        style: RenewGlass.body(
                          color: RenewGlass.t1,
                          weight: FontWeight.w600,
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
                          borderRadius: BorderRadius.circular(6.r),
                        ),
                        child: Text(
                          'HEADLINE',
                          style: RenewGlass.caption(
                            color: RenewGlass.ink,
                            size: 10,
                            lineHeight: 13,
                            weight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                SizedBox(height: 2.h),
                Text(
                  '${act.time} · ${type?.label ?? act.type}',
                  style: RenewGlass.caption(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// 테이블 (VRTables)
// ============================================================================

class RenewTableSection extends StatelessWidget {
  final VoidCallback? onViewPricing;

  const RenewTableSection({super.key, this.onViewPricing});

  @override
  Widget build(BuildContext context) {
    final keys = kTableTiers.keys
        .where((k) => kClubFloorTables.any((t) => t.tierKey == k))
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RenewSectionHead(
          title: '테이블',
          sub: '예약은 매장 전화로 문의해주세요',
          actionLabel: '가격표',
          onAction: onViewPricing,
        ),
        for (var i = 0; i < keys.length; i++)
          Padding(
            padding: EdgeInsets.only(bottom: i == keys.length - 1 ? 0 : 8.h),
            child: _tierRow(keys[i]),
          ),
      ],
    );
  }

  Widget _tierRow(String key) {
    final tier = kTableTiers[key]!;
    final rows = kClubFloorTables.where((t) => t.tierKey == key).toList();

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: tier.soft,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: tier.ring),
      ),
      child: Row(
        children: [
          Container(
            width: 8.r,
            height: 8.r,
            decoration: BoxDecoration(color: tier.dot, shape: BoxShape.circle),
          ),
          SizedBox(width: 12.w),
          SizedBox(
            width: 46.w,
            child: Text(
              tier.short,
              style: RenewGlass.body(
                color: tier.color,
                weight: FontWeight.w600,
              ),
            ),
          ),
          Expanded(
            child: Text(
              '${rows.length}석 · 최소 ${rows.first.minPeople}인',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: RenewGlass.caption(),
            ),
          ),
          Text(
            rows.first.price,
            style: RenewGlass.body(
              color: RenewGlass.t1,
              weight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// 메뉴 미리보기 (VRMenu)
// ============================================================================

class RenewMenuSection extends StatelessWidget {
  final List<MenuModel> menus;
  final VoidCallback? onViewAll;

  const RenewMenuSection({super.key, required this.menus, this.onViewAll});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RenewSectionHead(
          title: '메뉴',
          sub: '가격은 달라질 수 있어요',
          onAction: onViewAll,
        ),
        RenewMenuRows(menus: menus.take(3).toList()),
      ],
    );
  }
}

// ============================================================================
// 사진 미리보기 (VRPhotos)
// ============================================================================

/// 4×2 그리드 — 첫 장이 2×2로 크게 들어가고 마지막 칸에 총 장수 오버레이.
class RenewPhotoSection extends StatelessWidget {
  final List<String> imageUrls;
  final VoidCallback? onViewAll;
  final void Function(int index) onOpen;

  const RenewPhotoSection({
    super.key,
    required this.imageUrls,
    required this.onOpen,
    this.onViewAll,
  });

  @override
  Widget build(BuildContext context) {
    final preview = imageUrls.take(5).toList();
    final hidden = imageUrls.length - preview.length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RenewSectionHead(
          title: '사진',
          sub: '${imageUrls.length}장',
          onAction: onViewAll,
        ),
        LayoutBuilder(
          builder: (_, c) {
            final gap = 8.w;
            final total = c.maxWidth;
            // grid-template-columns: repeat(4,1fr) / rows: repeat(2,1fr)
            // aspect-ratio 2/1 → 전체 높이 = 폭 / 2.
            final height = total / 2;
            final colW = (total - gap * 3) / 4;
            final rowH = (height - gap) / 2;
            final bigW = colW * 2 + gap;

            Widget tile(int i, double w, double h) {
              if (i >= preview.length) return SizedBox(width: w, height: h);
              final isLast = i == preview.length - 1 && hidden > 0;
              return GestureDetector(
                onTap: () => onOpen(i),
                behavior: HitTestBehavior.opaque,
                child: SizedBox(
                  width: w,
                  height: h,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10.r),
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        SkeletonImage(url: preview[i], fit: BoxFit.cover),
                        if (isLast)
                          ColoredBox(
                            color: const Color(0x940E0D12),
                            child: Center(
                              child: Text(
                                '${imageUrls.length}장',
                                style: RenewGlass.body(
                                  color: Colors.white,
                                  weight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              );
            }

            return SizedBox(
              height: height,
              child: Row(
                children: [
                  tile(0, bigW, height),
                  SizedBox(width: gap),
                  Column(
                    children: [
                      tile(1, colW, rowH),
                      SizedBox(height: gap),
                      tile(3, colW, rowH),
                    ],
                  ),
                  SizedBox(width: gap),
                  Column(
                    children: [
                      tile(2, colW, rowH),
                      SizedBox(height: gap),
                      tile(4, colW, rowH),
                    ],
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }
}

// ============================================================================
// 주변 클럽 (VRNearby)
// ============================================================================

class RenewNearbySection extends StatelessWidget {
  final String area;
  final List<ClubModel> clubs;
  final void Function(ClubModel club) onTapClub;

  const RenewNearbySection({
    super.key,
    required this.area,
    required this.clubs,
    required this.onTapClub,
  });

  /// 카드 썸네일 한 변 (디자인 134).
  static const double _thumb = 134;

  /// 이름 + 지역·장르 두 줄 높이.
  static const double _textBlock = 42;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RenewSectionHead(title: '주변 클럽', sub: '$area · ${clubs.length}곳'),
        RenewEdgeBleed(
          height: _thumb.w + 9.h + _textBlock.h,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.symmetric(horizontal: RenewGlass.pagePad.w),
            itemCount: clubs.length,
            separatorBuilder: (_, __) => SizedBox(width: 12.w),
            itemBuilder: (_, i) => _card(clubs[i]),
          ),
        ),
      ],
    );
  }

  Widget _card(ClubModel club) {
    final isOpen = club.operatingHours.today.isCurrentlyOpen;

    return GestureDetector(
      onTap: () => onTapClub(club),
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: _thumb.w,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: _thumb.w,
              height: _thumb.w,
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
                        border: Border.all(color: RenewGlass.tileBorder),
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
                        color: RenewGlass.barFill,
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
                            style: RenewGlass.caption(
                              color: Colors.white,
                              size: 10.5,
                              lineHeight: 12,
                              weight: FontWeight.w600,
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
                          style: RenewGlass.caption(
                            color: Colors.white,
                            size: 10.5,
                            lineHeight: 12,
                            weight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 9.h),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    club.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: RenewGlass.body(
                      color: RenewGlass.t1,
                      weight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Flexible(
                    child: Text(
                      '${club.area} · ${club.genre}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: RenewGlass.caption(),
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
}
