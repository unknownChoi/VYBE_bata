import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vybe/design_system/colors.dart';
import 'package:vybe/design_system/typography.dart';
import 'package:vybe/presentation/common/widgets/vybe_meta_dot.dart';
import 'package:vybe/presentation/common/widgets/vybe_recommend_badge.dart';
import 'package:vybe/presentation/recommend/recommend_models.dart';

// VYBE 추천 NO.1 PICK 히어로 카드.

// ── Featured 히어로 (1위) ──
class RecommendFeatured extends StatelessWidget {
  final RecommendClub club;
  final bool saved;
  final VoidCallback onSave;
  final VoidCallback onOpen;
  const RecommendFeatured(
      {super.key, required this.club,
      required this.saved,
      required this.onSave,
      required this.onOpen});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 4.h),
      child: GestureDetector(
        onTap: onOpen,
        behavior: HitTestBehavior.opaque,
        child: Container(
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: VybeColors.gray900,
          borderRadius: BorderRadius.circular(20.r),
          border: Border.all(color: VybeColors.gray800),
        ),
        child: Column(
          children: [
            _heroImage(),
            _curatorNote(),
          ],
        ),
      ),
      ),
    );
  }

  Widget _heroImage() {
    return SizedBox(
      height: 230.h,
      child: Stack(
        fit: StackFit.expand,
        children: [
          recommendImageOrGradient(club.imageUrl, club.bg),
          // 하단 어둡게 (텍스트 가독성).
          const DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
                colors: [Color(0xEB101013), Color(0x1A101013), Color(0x00101013)],
                stops: [0.06, 0.5, 0.8],
              ),
            ),
          ),
          // NO.1 PICK 배지 (+ VYBE 추천 뱃지).
          Positioned(
            top: 14.h,
            left: 14.w,
            child: Row(
              children: [
                _glassBadge(
                  child: Text('NO.1 PICK',
                      style: VybeTypography.caption.copyWith(
                        height: 14 / 12,
                        fontWeight: FontWeight.w800,
                        color: VybeColors.mainLime500,
                      )),
                ),
              ],
            ),
          ),
          // VYBE 매치 배지.
          Positioned(
            top: 14.h,
            right: 14.w,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 11.w, vertical: 7.h),
              decoration: BoxDecoration(
                color: VybeColors.mainPurple500.withValues(alpha: 0.42),
                borderRadius: BorderRadius.circular(999.r),
                border: Border.all(color: VybeColors.mainPurple500),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.auto_awesome,
                      size: 11.r, color: VybeColors.mainLime500),
                  SizedBox(width: 5.w),
                  Text('VYBE 매치 ${club.match}%',
                      style: VybeTypography.caption.copyWith(
                        height: 14 / 12,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      )),
                ],
              ),
            ),
          ),
          // 이름 + 메타.
          Positioned(
            left: 18.w,
            right: 18.w,
            bottom: 16.h,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  spacing: 7.w,
                  children: club.tags
                      .map((t) => Text(t,
                          style: VybeTypography.caption.copyWith(
                            height: 14 / 12,
                            fontWeight: FontWeight.w600,
                            color: VybeColors.mainLime500,
                          )))
                      .toList(),
                ),
                SizedBox(height: 8.h),
                Row(
                  children: [
                    Flexible(
                      child: Text(club.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: VybeTypography.heading2
                              .copyWith(fontSize: 27.sp, color: Colors.white)),
                    ),
                    // VYBE 추천 뱃지 — 클럽 이름 옆.
                    if (club.vybeRecommended) ...[
                      SizedBox(width: 7.w),
                      const VybeRecommendBadge(size: 11),
                    ],
                  ],
                ),
                SizedBox(height: 8.h),
                _metaRow(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _metaRow() {
    return Row(
      children: [
        Icon(Icons.star_rounded, size: 13.r, color: VybeColors.mainLime500),
        SizedBox(width: 7.w),
        Text(club.rating.toStringAsFixed(2),
            style: VybeTypography.body4
                .copyWith(color: Colors.white, fontWeight: FontWeight.w700)),
        SizedBox(width: 7.w),
        Text('리뷰 ${club.reviews}',
            style: VybeTypography.caption
                .copyWith(height: 14 / 12, color: VybeColors.gray400)),
        const VybeMetaDot(color: VybeColors.gray600),
        Text(club.area,
            style: VybeTypography.caption
                .copyWith(height: 14 / 12, color: VybeColors.gray300)),
        const VybeMetaDot(color: VybeColors.gray600),
        Text(club.genre,
            style: VybeTypography.caption
                .copyWith(height: 14 / 12, color: VybeColors.gray300)),
      ],
    );
  }

  Widget _curatorNote() {
    return Padding(
      padding: EdgeInsets.fromLTRB(18.w, 16.h, 18.w, 18.h),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.format_quote_rounded,
                  size: 18.r, color: VybeColors.mainPurple500),
              SizedBox(width: 10.w),
              Expanded(
                child: Text(club.reason,
                    style: VybeTypography.body4.copyWith(
                      fontSize: 15.sp,
                      height: 23 / 15,
                      color: VybeColors.gray200,
                    )),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          Row(
            children: [
              Expanded(
                child: Container(
                  height: 46.h,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: VybeColors.mainPurple500,
                    borderRadius: BorderRadius.circular(13.r),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('상세보기',
                          style: VybeTypography.button1.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                          )),
                      Icon(Icons.chevron_right_rounded,
                          size: 16.r,
                          color: Colors.white.withValues(alpha: 0.85)),
                    ],
                  ),
                ),
              ),
              SizedBox(width: 10.w),
              GestureDetector(
                onTap: onSave,
                behavior: HitTestBehavior.opaque,
                child: Container(
                  width: 46.r,
                  height: 46.r,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: saved
                        ? VybeColors.mainPurple500.withValues(alpha: 0.16)
                        : VybeColors.gray800,
                    borderRadius: BorderRadius.circular(13.r),
                    border: Border.all(
                      color: saved
                          ? VybeColors.mainPurple700
                          : VybeColors.gray800,
                    ),
                  ),
                  child: Icon(
                    saved ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                    size: 20.r,
                    color: saved ? VybeColors.mainPurple500 : Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _glassBadge({required Widget child}) {
    return Container(
      padding: EdgeInsets.fromLTRB(9.w, 7.h, 12.w, 7.h),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.45),
        borderRadius: BorderRadius.circular(999.r),
        border: Border.all(color: Colors.white.withValues(alpha: 0.16)),
      ),
      child: child,
    );
  }
}
