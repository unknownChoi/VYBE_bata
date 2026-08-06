import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:vybe/data/models/club_model.dart';
import 'package:vybe/design_system/colors.dart';
import 'package:vybe/presentation/clubs/widgets/club_glass.dart';
import 'package:vybe/presentation/common/widgets/vybe_recommend_badge.dart';
import 'package:vybe/presentation/common/widgets/vybe_skeleton.dart';
import 'package:vybe/presentation/nearby/widgets/nearby_glass.dart';

/// 주변 리스트 시트의 클럽 카드 (리퀴드 글래스).
///
/// 디자인 nearby_glass.jsx `NGListCard` — 이름/추천 뱃지 · 평점 줄 ·
/// 대표 이미지(+도보 거리 pill, 찜 버튼) · 주소 · 영업/입장료 줄.
/// 지도 핀에서 선택된 클럽이면 왼쪽에서 번지는 보라 wash로 표시한다.
class ClubNearbyListItem extends StatelessWidget {
  final ClubModel club;
  final bool isFavorited;
  final VoidCallback? onFavoriteTap;
  final VoidCallback? onTap;

  /// 내 위치에서의 거리(m). null이면 도보 pill 숨김.
  final double? distanceMeters;

  /// 지도에서 선택된 핀의 클럽인지.
  final bool selected;

  const ClubNearbyListItem({
    super.key,
    required this.club,
    required this.isFavorited,
    this.onFavoriteTap,
    this.onTap,
    this.distanceMeters,
    this.selected = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 18.h),
        decoration: BoxDecoration(
          border: const Border(bottom: BorderSide(color: ClubGlass.hair)),
          gradient: selected
              ? const LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  colors: [Color(0x297731FE), Color(0x007731FE)],
                  stops: [0.0, 0.72],
                )
              : null,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildNameRow(),
            SizedBox(height: 8.h),
            _buildRatingRow(),
            SizedBox(height: 8.h),
            _buildImage(),
            SizedBox(height: 8.h),
            _buildAddressRow(),
            SizedBox(height: 8.h),
            _buildBusinessRow(),
          ],
        ),
      ),
    );
  }

  Widget _buildNameRow() {
    return Row(
      children: [
        Flexible(
          child: Text(
            club.name,
            style: TextStyle(
              fontFamily: 'Pretendard',
              fontSize: 20.sp,
              height: 22 / 20,
              letterSpacing: 20 * -0.025,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        if (club.isVybeRecommended) ...[
          SizedBox(width: 8.w),
          const VybeRecommendBadge(),
        ],
      ],
    );
  }

  Widget _buildRatingRow() {
    return Row(
      children: [
        SvgPicture.asset(
          'assets/icons/common/club_card/star.svg',
          width: 13.r,
          height: 13.r,
        ),
        SizedBox(width: 6.w),
        Text(
          club.rating.toStringAsFixed(2),
          style: ClubGlass.caption(
            color: Colors.white,
            weight: FontWeight.w700,
          ),
        ),
        SizedBox(width: 8.w),
        Text(club.area, style: ClubGlass.caption(color: ClubGlass.t4)),
        SizedBox(width: 6.w),
        Container(width: 1, height: 11.h, color: const Color(0x33FFFFFF)),
        SizedBox(width: 6.w),
        Flexible(
          child: Text(
            club.genre,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: ClubGlass.caption(color: ClubGlass.t4),
          ),
        ),
      ],
    );
  }

  Widget _buildImage() {
    final walk = walkLabel(distanceMeters);
    return SizedBox(
      height: 152.h,
      child: Stack(
        children: [
          Container(
            width: double.infinity,
            height: 152.h,
            decoration: BoxDecoration(
              color: const Color(0xFF1A1A1F),
              borderRadius: BorderRadius.circular(14.r),
              border: Border.all(color: const Color(0x1AFFFFFF)),
            ),
            clipBehavior: Clip.antiAlias,
            child: club.thumbnailUrl.isNotEmpty
                ? SkeletonImage(
                    url: club.thumbnailUrl,
                    width: double.infinity,
                    height: 152.h,
                    fit: BoxFit.cover,
                  )
                : null,
          ),
          // 하단 그라데이션 — pill/찜 버튼 가독성.
          Positioned.fill(
            child: IgnorePointer(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(14.r),
                  gradient: const LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Color(0x00000000), Color(0x80000000)],
                    stops: [0.52, 1.0],
                  ),
                ),
              ),
            ),
          ),
          if (walk != null)
            Positioned(
              left: 10.w,
              bottom: 10.h,
              child: _GlassPill(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.directions_walk_rounded,
                      size: 12.r,
                      color: Colors.white,
                    ),
                    SizedBox(width: 4.w),
                    Text(
                      walk,
                      style: ClubGlass.caption(
                        color: Colors.white,
                        size: 11,
                        lineHeight: 13,
                        weight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          Positioned(
            right: 10.w,
            bottom: 10.h,
            child: GestureDetector(
              onTap: onFavoriteTap,
              behavior: HitTestBehavior.opaque,
              child: ClipOval(
                child: BackdropFilter(
                  filter: ui.ImageFilter.blur(sigmaX: 7, sigmaY: 7),
                  child: Container(
                    width: 38.r,
                    height: 38.r,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: const Color(0x8014121A),
                      shape: BoxShape.circle,
                      border: Border.all(color: const Color(0x2EFFFFFF)),
                    ),
                    // favorite.svg는 stroke만 있는 외곽선이라 찜해도 안이 비어 보인다
                    // → 검색 결과 카드(club_list_item)와 동일하게 Material 하트로 통일.
                    child: Icon(
                      isFavorited
                          ? Icons.favorite_rounded
                          : Icons.favorite_border_rounded,
                      size: 20.r,
                      color: isFavorited ? ClubGlass.saved : Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddressRow() {
    return Row(
      children: [
        SvgPicture.asset(
          'assets/icons/common/club_card/location_pin.svg',
          width: 13.r,
          height: 13.r,
        ),
        SizedBox(width: 6.w),
        Expanded(
          child: Text(
            club.address,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: ClubGlass.caption(color: ClubGlass.t3),
          ),
        ),
      ],
    );
  }

  Widget _buildBusinessRow() {
    final today = club.operatingHours.today;
    final isOpen = today.isCurrentlyOpen;

    return Wrap(
      spacing: 16.w,
      runSpacing: 6.h,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SvgPicture.asset(
              'assets/icons/common/club_card/time.svg',
              width: 13.r,
              height: 13.r,
            ),
            SizedBox(width: 6.w),
            NearbyLiveDot(live: isOpen),
            SizedBox(width: 6.w),
            Text(
              isOpen ? '영업중' : '영업종료',
              style: ClubGlass.caption(
                color: isOpen ? VybeColors.mainLime500 : ClubGlass.t4,
                weight: FontWeight.w700,
              ),
            ),
            SizedBox(width: 6.w),
            const GlassDot(),
            SizedBox(width: 6.w),
            Text(
              todayHoursLabel(today),
              style: ClubGlass.caption(color: ClubGlass.t3),
            ),
          ],
        ),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SvgPicture.asset(
              'assets/icons/common/club_card/won.svg',
              width: 14.r,
              height: 14.r,
            ),
            SizedBox(width: 5.w),
            Text(
              '입장료 ${formatEntryFee(min: club.entryFeeMin, max: club.entryFeeMax)}',
              style: ClubGlass.caption(color: ClubGlass.t3),
            ),
          ],
        ),
      ],
    );
  }
}

/// 이미지 위 작은 글래스 pill (도보 거리).
class _GlassPill extends StatelessWidget {
  final Widget child;

  const _GlassPill({required this.child});

  @override
  Widget build(BuildContext context) {
    final r = BorderRadius.circular(999.r);
    return ClipRRect(
      borderRadius: r,
      child: BackdropFilter(
        filter: ui.ImageFilter.blur(sigmaX: 6, sigmaY: 6),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
          decoration: BoxDecoration(
            color: const Color(0x800E0D12),
            borderRadius: r,
            border: Border.all(color: const Color(0x29FFFFFF)),
          ),
          child: child,
        ),
      ),
    );
  }
}
