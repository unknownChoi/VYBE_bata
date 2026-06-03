import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:vybe/data/models/club_model.dart';
import 'package:vybe/design_system/colors.dart';
import 'package:vybe/design_system/typography.dart';

class ClubNearbyListItem extends StatelessWidget {
  final ClubModel club;
  final bool isFavorited;
  final VoidCallback? onFavoriteTap;

  const ClubNearbyListItem({
    super.key,
    required this.club,
    required this.isFavorited,
    this.onFavoriteTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(color: VybeColors.gray800, width: 1),
        ),
      ),
      padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 24.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildNameRow(),
          SizedBox(height: 8.h),
          _buildRatingTagRow(),
          SizedBox(height: 8.h),
          _buildImage(),
          SizedBox(height: 8.h),
          _buildAddressRow(),
          SizedBox(height: 4.h),
          _buildBusinessRow(),
        ],
      ),
    );
  }

  Widget _buildNameRow() {
    return Row(
      children: [
        Flexible(
          child: Text(
            club.name,
            style: VybeTypography.heading4.copyWith(color: Colors.white),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        if (club.isVybeRecommended) ...[
          SizedBox(width: 8.w),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              SvgPicture.asset(
                'assets/icons/common/club_card/vybe_recommend.svg',
                width: 12.r,
                height: 12.r,
              ),
              SizedBox(width: 2.w),
              Text(
                'VYBE 추천 클럽',
                style: TextStyle(
                  fontFamily: 'Pretendard',
                  fontWeight: FontWeight.w600,
                  fontSize: 12.sp,
                  height: 14 / 12,
                  letterSpacing: 12 * -0.025,
                  color: VybeColors.mainLime500,
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }

  Widget _buildRatingTagRow() {
    final tagStyle = TextStyle(
      fontFamily: 'Pretendard',
      fontWeight: FontWeight.w400,
      fontSize: 12.sp,
      height: 14 / 12,
      letterSpacing: 12 * -0.025,
      color: VybeColors.gray500,
    );

    return Row(
      children: [
        SvgPicture.asset(
          'assets/icons/common/club_card/star.svg',
          width: 14.r,
          height: 14.r,
        ),
        SizedBox(width: 4.w),
        Text(
          club.rating.toStringAsFixed(2),
          style: TextStyle(
            fontFamily: 'Pretendard',
            fontWeight: FontWeight.w600,
            fontSize: 12.sp,
            height: 14 / 12,
            letterSpacing: 12 * -0.025,
            color: Colors.white,
          ),
        ),
        SizedBox(width: 8.w),
        Text(club.area, style: tagStyle),
        SizedBox(width: 4.w),
        Container(width: 1, height: 12.h, color: VybeColors.gray700),
        SizedBox(width: 4.w),
        Text(club.genre, style: tagStyle),
      ],
    );
  }

  Widget _buildImage() {
    return SizedBox(
      height: 152.h,
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12.r),
            child: Container(
              width: double.infinity,
              height: 152.h,
              decoration: BoxDecoration(
                color: VybeColors.gray800,
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(color: VybeColors.gray900, width: 1),
              ),
              child: club.thumbnailUrl.isNotEmpty
                  ? Image.network(club.thumbnailUrl, fit: BoxFit.cover)
                  : null,
            ),
          ),
          Positioned(
            bottom: 8.h,
            right: 8.w,
            child: GestureDetector(
              onTap: onFavoriteTap,
              child: Container(
                width: 40.r,
                height: 40.r,
                decoration: BoxDecoration(
                  color: const Color(0xCC191919),
                  borderRadius: BorderRadius.circular(20.r),
                ),
                padding: EdgeInsets.all(8.r),
                child: SvgPicture.asset(
                  'assets/icons/common/club_card/favorite.svg',
                  width: 24.r,
                  height: 24.r,
                  colorFilter: ColorFilter.mode(
                    isFavorited ? VybeColors.mainPurple500 : Colors.white,
                    BlendMode.srcIn,
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
          width: 14.r,
          height: 14.r,
        ),
        SizedBox(width: 6.w),
        Expanded(
          child: Text(
            club.address,
            style: VybeTypography.caption.copyWith(color: VybeColors.gray400),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildBusinessRow() {
    final infoStyle =
        VybeTypography.caption.copyWith(color: VybeColors.gray400);

    return Row(
      children: [
        SvgPicture.asset(
          'assets/icons/common/club_card/time.svg',
          width: 14.r,
          height: 14.r,
        ),
        SizedBox(width: 6.w),
        Text(_isOpenNow(club) ? '영업중' : '영업종료', style: infoStyle),
        if (_isOpenNow(club)) ...[
          SizedBox(width: 4.w),
          Container(
            width: 2.r,
            height: 2.r,
            decoration: const BoxDecoration(
              color: VybeColors.gray700,
              shape: BoxShape.circle,
            ),
          ),
          SizedBox(width: 4.w),
          Text(
            () {
              final h = club.operatingHours.today;
              return h.isOpen && h.close != null
                  ? '${h.close}에 영업 종료'
                  : '오늘 휴무';
            }(),
            style: infoStyle,
          ),
        ],
        SizedBox(width: 24.w),
        SvgPicture.asset(
          'assets/icons/common/club_card/won.svg',
          width: 16.r,
          height: 16.r,
        ),
        SizedBox(width: 4.w),
        Text(
          '입장료 ${_formatPrice(club.entryFeeMin)} ~ ${_formatPrice(club.entryFeeMax)}원',
          style: infoStyle,
        ),
      ],
    );
  }

  bool _isOpenNow(ClubModel club) =>
      club.operatingHours.today.isCurrentlyOpen;

  String _formatPrice(int price) {
    if (price == 0) return '0';
    final thousands = price ~/ 1000;
    final remainder = price % 1000;
    return remainder == 0
        ? '$thousands,000'
        : '$thousands,${remainder.toString().padLeft(3, '0')}';
  }
}
