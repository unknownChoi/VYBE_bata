import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:vybe/core/utils/number_format.dart';
import 'package:vybe/core/utils/url_utils.dart';
import 'package:vybe/data/models/club_info_model.dart';
import 'package:vybe/data/models/club_model.dart';
import 'package:vybe/data/models/menu_model.dart';
import 'package:vybe/data/models/operating_hours.dart';
import 'package:vybe/design_system/colors.dart';
import 'package:vybe/presentation/clubs/viewmodels/club_detail_viewmodel.dart';
import 'package:vybe/presentation/clubs/widgets/club_section_divider.dart';
import 'package:vybe/presentation/clubs/widgets/performance_schedule_section.dart';
import 'package:vybe/presentation/clubs/widgets/subway_line_badge.dart';
import 'package:vybe/presentation/clubs/widgets/table_pricing_section.dart';
import 'package:vybe/presentation/common/widgets/vybe_skeleton.dart';

class DetailHomeTab extends ConsumerStatefulWidget {
  final String clubId;
  final VoidCallback? onViewAllPhotos;
  final VoidCallback? onViewAllMenus;
  const DetailHomeTab({
    super.key,
    required this.clubId,
    this.onViewAllPhotos,
    this.onViewAllMenus,
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

    return ListView(
      physics: const ClampingScrollPhysics(),
      padding: EdgeInsets.zero,
      children: [
        clubAsync.isLoading
            ? const InfoSkeleton()
            : _buildInfoSection(clubAsync.value, clubInfoAsync.value),
        const ClubSectionDivider(),
        PerformanceScheduleSection(
          clubId: widget.clubId,
          clubName: clubAsync.value?.name,
          area: clubAsync.value?.area,
        ),
        const ClubSectionDivider(),
        clubAsync.isLoading
            ? const TableSkeleton()
            : const TablePricingSection(),
        const ClubSectionDivider(),
        menusAsync.isLoading
            ? const MenuSkeleton()
            : _buildMenuPreviewSection(menusAsync.value ?? []),
        const ClubSectionDivider(),
        clubAsync.isLoading
            ? const PhotosSkeleton()
            : _buildPhotoPreviewSection(clubAsync.value?.imageUrls ?? []),
        const ClubSectionDivider(),
        _buildNearbyClubsSection(ref.watch(nearbyClubsProvider(widget.clubId))),
        SizedBox(height: 32.h),
      ],
    );
  }

  // ── INFO SECTION ──

  Widget _buildInfoSection(ClubModel? club, ClubInfoModel? clubInfo) {
    final address = club?.address ?? '';
    final hours = club?.operatingHours ?? const OperatingHours();
    final todayHours = hours.today;
    final isOpen = todayHours.isCurrentlyOpen;
    final entryFeeMin = club?.entryFeeMin ?? 0;
    final entryFeeMax = club?.entryFeeMax ?? 0;
    final instagramUrl = club?.instagramUrl ?? '';
    final igHandle = instagramHandle(instagramUrl);
    final nearbySubways = (clubInfo?.nearbySubways ?? []);

    final weekdays = [
      ('월', hours.mon),
      ('화', hours.tue),
      ('수', hours.wed),
      ('목', hours.thu),
      ('금', hours.fri),
      ('토', hours.sat),
      ('일', hours.sun),
    ];
    final todayIndex = DateTime.now().weekday - 1; // 0=월~6=일

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 24.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Address row
          _infoRow(
            icon: SvgPicture.asset(
              'assets/icons/common/club_card/location_pin.svg',
              width: 17.r,
              height: 17.r,
              colorFilter: const ColorFilter.mode(
                VybeColors.gray500,
                BlendMode.srcIn,
              ),
            ),
            onTap: () => setState(() => _addrExpanded = !_addrExpanded),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        address,
                        style: TextStyle(
                          fontFamily: 'Pretendard',
                          fontSize: 14.sp,
                          color: VybeColors.gray200,
                          height: 1.5,
                        ),
                      ),
                    ),
                    AnimatedRotation(
                      turns: _addrExpanded ? 0.5 : 0,
                      duration: const Duration(milliseconds: 200),
                      child: Icon(
                        Icons.keyboard_arrow_down_rounded,
                        color: VybeColors.gray500,
                        size: 16.r,
                      ),
                    ),
                  ],
                ),
                AnimatedSize(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                  alignment: Alignment.topCenter,
                  child: ClipRect(
                    child: Align(
                      alignment: Alignment.topCenter,
                      heightFactor: _addrExpanded ? 1 : 0,
                      child: Padding(
                        padding: EdgeInsets.only(top: 10.h),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: nearbySubways.map<Widget>((s) {
                              final name = s['stationName'] as String? ?? '';
                              final dist = s['distanceM'] as int? ?? 0;
                              final lines =
                                  (s['lines'] as List?)?.cast<String>() ??
                                  const <String>[];
                              return Padding(
                                padding: EdgeInsets.only(bottom: 4.h),
                                child: Row(
                                  children: [
                                    ...lines.map(
                                      (l) => Padding(
                                        padding: EdgeInsets.only(right: 4.w),
                                        child: SubwayLineBadge(line: l),
                                      ),
                                    ),
                                    if (lines.isNotEmpty) SizedBox(width: 2.w),
                                    Text(
                                      '$name에서 ${dist}m',
                                      style: TextStyle(
                                        fontFamily: 'Pretendard',
                                        fontSize: 13.sp,
                                        color: VybeColors.gray300,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          SizedBox(height: 16.h),
          // Hours row
          _infoRow(
            icon: SvgPicture.asset(
              'assets/icons/common/club_card/time.svg',
              width: 17.r,
              height: 17.r,
              colorFilter: const ColorFilter.mode(
                VybeColors.gray500,
                BlendMode.srcIn,
              ),
            ),
            onTap: () => setState(() => _hoursExpanded = !_hoursExpanded),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Text(
                          isOpen ? '영업중' : '영업종료',
                          style: TextStyle(
                            fontFamily: 'Pretendard',
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w600,
                            color: isOpen
                                ? VybeColors.mainLime500
                                : VybeColors.gray500,
                          ),
                        ),
                        if (isOpen && todayHours.close != null) ...[
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 6.w),
                            child: Container(
                              width: 2.r,
                              height: 2.r,
                              decoration: const BoxDecoration(
                                color: VybeColors.gray700,
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),
                          Text(
                            '${todayHours.close}에 영업 종료',
                            style: TextStyle(
                              fontFamily: 'Pretendard',
                              fontSize: 14.sp,
                              color: VybeColors.gray400,
                            ),
                          ),
                        ],
                      ],
                    ),
                    AnimatedRotation(
                      turns: _hoursExpanded ? 0.5 : 0,
                      duration: const Duration(milliseconds: 200),
                      child: Icon(
                        Icons.keyboard_arrow_down_rounded,
                        color: VybeColors.gray500,
                        size: 16.r,
                      ),
                    ),
                  ],
                ),
                AnimatedSize(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                  alignment: Alignment.topCenter,
                  child: ClipRect(
                    child: Align(
                      alignment: Alignment.topCenter,
                      heightFactor: _hoursExpanded ? 1 : 0,
                      child: Padding(
                        padding: EdgeInsets.only(top: 10.h),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: weekdays.asMap().entries.map((e) {
                              final i = e.key;
                              final label = e.value.$1;
                              final day = e.value.$2;
                              final isToday = i == todayIndex;
                              final timeStr = day.isOpen
                                  ? '${day.open} - ${day.close}'
                                  : '정기휴무';
                              return Padding(
                                padding: EdgeInsets.only(bottom: 6.h),
                                child: Row(
                                  children: [
                                    SizedBox(
                                      width: 18.w,
                                      child: Text(
                                        label,
                                        style: TextStyle(
                                          fontFamily: 'Pretendard',
                                          fontSize: 13.sp,
                                          fontWeight: isToday
                                              ? FontWeight.w700
                                              : FontWeight.w400,
                                          color: isToday
                                              ? Colors.white
                                              : VybeColors.gray500,
                                        ),
                                      ),
                                    ),
                                    SizedBox(width: 10.w),
                                    Text(
                                      timeStr,
                                      style: TextStyle(
                                        fontFamily: 'Pretendard',
                                        fontSize: 13.sp,
                                        fontWeight: isToday
                                            ? FontWeight.w600
                                            : FontWeight.w400,
                                        color: isToday
                                            ? Colors.white
                                            : VybeColors.gray500,
                                      ),
                                    ),
                                    if (isToday) ...[
                                      SizedBox(width: 8.w),
                                      Container(
                                        padding: EdgeInsets.symmetric(
                                          horizontal: 6.w,
                                          vertical: 1.h,
                                        ),
                                        decoration: BoxDecoration(
                                          color: const Color(0x247731FE),
                                          borderRadius: BorderRadius.circular(
                                            4.r,
                                          ),
                                        ),
                                        child: Text(
                                          '오늘',
                                          style: TextStyle(
                                            fontFamily: 'Pretendard',
                                            fontSize: 10.sp,
                                            fontWeight: FontWeight.w700,
                                            color: VybeColors.mainPurple500,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          SizedBox(height: 16.h),
          // Entry fee row
          _infoRow(
            icon: SvgPicture.asset(
              'assets/icons/common/club_card/won.svg',
              width: 17.r,
              height: 17.r,
              colorFilter: const ColorFilter.mode(
                VybeColors.gray500,
                BlendMode.srcIn,
              ),
            ),
            child: RichText(
              text: TextSpan(
                style: TextStyle(
                  fontFamily: 'Pretendard',
                  fontSize: 14.sp,
                  color: VybeColors.gray200,
                ),
                children: [
                  const TextSpan(text: '입장료 '),
                  TextSpan(
                    text: _formatEntryFee(entryFeeMin, entryFeeMax),
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: 16.h),
          // Instagram row
          _infoRow(
            icon: SvgPicture.asset(
              'assets/club_detail/icons/sns_url.svg',
              width: 17.r,
              height: 17.r,
              colorFilter: const ColorFilter.mode(
                VybeColors.gray500,
                BlendMode.srcIn,
              ),
            ),
            child: Text(
              igHandle,
              style: TextStyle(
                fontFamily: 'Pretendard',
                fontSize: 14.sp,
                color: VybeColors.accentBlue500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatEntryFee(int min, int max) {
    if (min == 0 && max == 0) return '무료';
    final maxStr = formatThousands(max);
    return min == 0 ? '0 ~ $maxStr원' : '${formatThousands(min)} ~ $maxStr원';
  }

  Widget _infoRow({
    required Widget icon,
    required Widget child,
    VoidCallback? onTap,
  }) {
    final row = Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 20.w,
          child: Padding(
            padding: EdgeInsets.only(top: 1.h),
            child: Center(child: icon),
          ),
        ),
        SizedBox(width: 12.w),
        Expanded(child: child),
      ],
    );
    if (onTap == null) return row;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: row,
    );
  }

  // ── MENU PREVIEW ──

  Widget _buildMenuPreviewSection(List<MenuModel> menus) {
    final featured = menus.where((m) => m.isFeatured).take(3).toList();
    if (featured.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 24.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionHeader('메뉴', onViewAll: widget.onViewAllMenus),
          SizedBox(height: 4.h),
          ...featured.asMap().entries.map(
            (e) =>
                _menuPreviewItem(e.value, isLast: e.key == featured.length - 1),
          ),
          SizedBox(height: 12.h),
          Text(
            '메뉴 항목과 가격은 매장 사정에 따라 다를 수 있습니다.',
            style: TextStyle(
              fontFamily: 'Pretendard',
              fontSize: 11.sp,
              color: VybeColors.gray600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _menuPreviewItem(MenuModel item, {bool isLast = false}) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 16.h),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(color: VybeColors.gray800),
          bottom: isLast
              ? BorderSide(color: VybeColors.gray800)
              : BorderSide.none,
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 7.w,
                        vertical: 2.h,
                      ),
                      decoration: BoxDecoration(
                        color: VybeColors.mainPurple500,
                        borderRadius: BorderRadius.circular(999.r),
                      ),
                      child: Text(
                        '대표',
                        style: TextStyle(
                          fontFamily: 'Pretendard',
                          fontSize: 10.sp,
                          fontWeight: FontWeight.w500,
                          color: VybeColors.gray200,
                        ),
                      ),
                    ),
                    SizedBox(width: 6.w),
                    Text(
                      item.name,
                      style: TextStyle(
                        fontFamily: 'Pretendard',
                        fontSize: 14.sp,
                        color: VybeColors.gray200,
                      ),
                    ),
                  ],
                ),
                if (item.description.isNotEmpty) ...[
                  SizedBox(height: 6.h),
                  Text(
                    item.description,
                    style: TextStyle(
                      fontFamily: 'Pretendard',
                      fontSize: 12.sp,
                      color: VybeColors.gray500,
                    ),
                  ),
                ],
                SizedBox(height: 10.h),
                Text(
                  '${formatThousands(item.price)}원',
                  style: TextStyle(
                    fontFamily: 'Pretendard',
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          if (item.imageUrl.isNotEmpty) ...[
            SizedBox(width: 16.w),
            SkeletonImage(
              url: item.imageUrl,
              width: 100.r,
              height: 100.r,
              fit: BoxFit.cover,
              borderRadius: BorderRadius.circular(6.r),
            ),
          ],
        ],
      ),
    );
  }

  // ── PHOTO PREVIEW ──

  Widget _buildPhotoPreviewSection(List<String> imageUrls) {
    if (imageUrls.isEmpty) return const SizedBox.shrink();

    final total = imageUrls.length;
    final countLabel = total > 99 ? '99+' : '$total';
    final remaining = total - 4;

    Widget networkImage(String url, {double radius = 8, double opacity = 1.0}) {
      Widget img = SkeletonImage(
        url: url,
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
        borderRadius: BorderRadius.circular(radius.r),
      );
      return opacity < 1.0 ? Opacity(opacity: opacity, child: img) : img;
    }

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 24.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionHeader(
            '사진',
            count: countLabel,
            onViewAll: widget.onViewAllPhotos,
          ),
          SizedBox(height: 14.h),
          SizedBox(
            height: 110.h,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // big left image
                Expanded(
                  flex: 2,
                  child: networkImage(imageUrls[0], radius: 10),
                ),
                SizedBox(width: 6.w),
                // right 2×2 grid
                Expanded(
                  flex: 2,
                  child: Column(
                    children: [
                      Expanded(
                        child: Row(
                          children: [
                            Expanded(
                              child: imageUrls.length > 1
                                  ? networkImage(imageUrls[1])
                                  : Container(color: VybeColors.gray800),
                            ),
                            SizedBox(width: 6.w),
                            Expanded(
                              child: imageUrls.length > 2
                                  ? networkImage(imageUrls[2])
                                  : Container(color: VybeColors.gray800),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 6.h),
                      Expanded(
                        child: Row(
                          children: [
                            // "+N 더보기" overlay cell
                            Expanded(
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(8.r),
                                child: Stack(
                                  fit: StackFit.expand,
                                  children: [
                                    Container(
                                      color: const Color(0xFF1A1A20),
                                      child: DecoratedBox(
                                        decoration: BoxDecoration(
                                          gradient: RadialGradient(
                                            colors: [
                                              VybeColors.mainPurple500
                                                  .withValues(alpha: 0.4),
                                              Colors.transparent,
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                    Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          '+$remaining',
                                          style: TextStyle(
                                            fontFamily: 'Pretendard',
                                            fontSize: 16.sp,
                                            fontWeight: FontWeight.w700,
                                            color: Colors.white,
                                          ),
                                        ),
                                        Text(
                                          '더보기',
                                          style: TextStyle(
                                            fontFamily: 'Pretendard',
                                            fontSize: 11.sp,
                                            color: VybeColors.gray400,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            SizedBox(width: 6.w),
                            Expanded(
                              child: imageUrls.length > 3
                                  ? networkImage(imageUrls[3], opacity: 0.7)
                                  : Container(color: VybeColors.gray800),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── NEARBY CLUBS ──

  Widget _buildNearbyClubsSection(AsyncValue<List<ClubModel>> nearbyAsync) {
    if (nearbyAsync.isLoading) return const NearbySkeleton();

    final clubs = nearbyAsync.value ?? [];
    if (clubs.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: EdgeInsets.only(top: 24.h, bottom: 24.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w),
            child: _sectionHeader('주변 클럽'),
          ),
          SizedBox(height: 14.h),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.symmetric(horizontal: 20.w),
            child: Row(
              children: clubs.map((club) {
                return Padding(
                  padding: EdgeInsets.only(right: 12.w),
                  child: SizedBox(
                    width: 124.w,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Stack(
                          children: [
                            club.thumbnailUrl.isNotEmpty
                                ? SkeletonImage(
                                    url: club.thumbnailUrl,
                                    width: 124.w,
                                    height: 124.h,
                                    fit: BoxFit.cover,
                                    borderRadius: BorderRadius.circular(10.r),
                                  )
                                : Container(
                                    width: 124.w,
                                    height: 124.h,
                                    color: VybeColors.gray800,
                                  ),
                            Positioned(
                              top: 6.h,
                              left: 6.w,
                              child: Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 6.w,
                                  vertical: 2.h,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.black.withValues(alpha: 0.6),
                                  borderRadius: BorderRadius.circular(4.r),
                                ),
                                child: Row(
                                  children: [
                                    SvgPicture.asset(
                                      'assets/icons/common/club_card/star.svg',
                                      width: 10.r,
                                      height: 10.r,
                                    ),
                                    SizedBox(width: 3.w),
                                    Text(
                                      club.rating.toStringAsFixed(1),
                                      style: TextStyle(
                                        fontFamily: 'Pretendard',
                                        fontSize: 10.sp,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 8.h),
                        Text(
                          club.name,
                          style: TextStyle(
                            fontFamily: 'Pretendard',
                            fontSize: 13.sp,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(height: 2.h),
                        Row(
                          children: [
                            Text(
                              club.area,
                              style: TextStyle(
                                fontFamily: 'Pretendard',
                                fontSize: 11.sp,
                                color: VybeColors.gray500,
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 4.w),
                              child: Container(
                                width: 2.r,
                                height: 2.r,
                                decoration: const BoxDecoration(
                                  color: VybeColors.gray700,
                                  shape: BoxShape.circle,
                                ),
                              ),
                            ),
                            Text(
                              club.genre,
                              style: TextStyle(
                                fontFamily: 'Pretendard',
                                fontSize: 11.sp,
                                color: VybeColors.gray500,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  // ── HELPERS ──

  Widget _sectionHeader(
    String title, {
    String? count,
    VoidCallback? onViewAll,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Text(
              title,
              style: TextStyle(
                fontFamily: 'Pretendard',
                fontSize: 18.sp,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
            if (count != null) ...[
              SizedBox(width: 6.w),
              Text(
                count,
                style: TextStyle(
                  fontFamily: 'Pretendard',
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w500,
                  color: VybeColors.gray500,
                ),
              ),
            ],
          ],
        ),
        GestureDetector(
          onTap: onViewAll,
          child: Row(
            children: [
              Text(
                '전체보기',
                style: TextStyle(
                  fontFamily: 'Pretendard',
                  fontSize: 12.sp,
                  color: VybeColors.gray500,
                ),
              ),
              Icon(
                Icons.chevron_right_rounded,
                size: 14.r,
                color: VybeColors.gray500,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
