import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vybe/design_system/colors.dart';
import 'package:vybe/design_system/typography.dart';
import 'package:vybe/presentation/common/widgets/vybe_meta_dot.dart';
import 'package:vybe/presentation/common/widgets/vybe_recommend_badge.dart';
import 'package:vybe/presentation/recommend/recommend_models.dart';

// VYBE 추천 2위 이하 순위 리스트.

// ── 순위 섹션 ──
class RecommendRankedSection extends StatelessWidget {
  final List<RecommendClub> clubs;
  final Set<String> savedIds;
  final ValueChanged<String> onSave;
  final ValueChanged<String> onOpen;
  const RecommendRankedSection(
      {super.key, required this.clubs,
      required this.savedIds,
      required this.onSave,
      required this.onOpen});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.fromLTRB(20.w, 28.h, 20.w, 6.h),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text('추천 순위',
                  style: VybeTypography.heading4
                      .copyWith(color: Colors.white, fontWeight: FontWeight.w700)),
              SizedBox(width: 8.w),
              Padding(
                padding: EdgeInsets.only(bottom: 2.h),
                child: Text('2위 — ${clubs.length + 1}위',
                    style: VybeTypography.caption
                        .copyWith(height: 16 / 12, color: VybeColors.gray500)),
              ),
            ],
          ),
        ),
        for (final c in clubs)
          _RecommendRankRow(
            club: c,
            saved: savedIds.contains(c.id),
            onSave: () => onSave(c.id),
            onOpen: () => onOpen(c.id),
          ),
      ],
    );
  }
}

// ── 순위 행 ──
class _RecommendRankRow extends StatelessWidget {
  final RecommendClub club;
  final bool saved;
  final VoidCallback onSave;
  final VoidCallback onOpen;
  const _RecommendRankRow(
      {required this.club,
      required this.saved,
      required this.onSave,
      required this.onOpen});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onOpen,
      behavior: HitTestBehavior.opaque,
      child: Container(
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: VybeColors.gray900)),
      ),
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 순위 숫자.
          SizedBox(
            width: 22.w,
            child: Padding(
              padding: EdgeInsets.only(top: 2.h),
              child: Text('${club.rank}',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'Pretendard',
                    fontWeight: FontWeight.w800,
                    fontSize: 22.sp,
                    height: 24 / 22,
                    color: VybeColors.gray700,
                    letterSpacing: 22 * -0.04,
                  )),
            ),
          ),
          SizedBox(width: 14.w),
          _thumb(),
          SizedBox(width: 14.w),
          Expanded(child: _content()),
        ],
      ),
      ),
    );
  }

  Widget _thumb() {
    return SizedBox(
      width: 84.r,
      height: 84.r,
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12.r),
            child: SizedBox(
              width: 84.r,
              height: 84.r,
              child: recommendImageOrGradient(club.imageUrl, club.bg),
            ),
          ),
          // 보더 오버레이.
          Container(
            width: 84.r,
            height: 84.r,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(color: VybeColors.gray900),
            ),
          ),
          Positioned(
            left: 5.w,
            bottom: 5.h,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.6),
                borderRadius: BorderRadius.circular(99.r),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.star_rounded,
                      size: 9.r, color: VybeColors.mainLime500),
                  SizedBox(width: 3.w),
                  Text(club.rating.toStringAsFixed(2),
                      style: TextStyle(
                        fontFamily: 'Pretendard',
                        fontSize: 11.sp,
                        height: 12 / 11,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      )),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _content() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Row(
                children: [
                  Flexible(
                    child: Text(club.name,
                        overflow: TextOverflow.ellipsis,
                        style: VybeTypography.body3.copyWith(
                            color: Colors.white, fontWeight: FontWeight.w600)),
                  ),
                  if (club.vybeRecommended) ...[
                    SizedBox(width: 6.w),
                    const VybeRecommendBadge(),
                  ],
                ],
              ),
            ),
            GestureDetector(
              onTap: onSave,
              behavior: HitTestBehavior.opaque,
              child: Padding(
                padding: EdgeInsets.all(2.r),
                child: Icon(
                  saved ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                  size: 19.r,
                  color: saved ? VybeColors.mainPurple500 : Colors.white,
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 5.h),
        Row(
          children: [
            Text('매치 ${club.match}%',
                style: VybeTypography.caption.copyWith(
                  height: 14 / 12,
                  fontWeight: FontWeight.w700,
                  color: VybeColors.mainPurple500,
                )),
            const VybeMetaDot(color: VybeColors.gray600),
            Text(club.area,
                style: VybeTypography.caption
                    .copyWith(height: 14 / 12, color: VybeColors.gray500)),
            const VybeMetaDot(color: VybeColors.gray600),
            Text(club.genre,
                style: VybeTypography.caption
                    .copyWith(height: 14 / 12, color: VybeColors.gray500)),
            const VybeMetaDot(color: VybeColors.gray600),
            Text(club.open ? '영업중' : '영업종료',
                style: VybeTypography.caption.copyWith(
                  height: 14 / 12,
                  fontWeight: FontWeight.w600,
                  color: club.open ? VybeColors.mainLime500 : VybeColors.gray600,
                )),
          ],
        ),
        SizedBox(height: 5.h),
        Text(club.reason,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: VybeTypography.caption
                .copyWith(height: 18 / 12, color: VybeColors.gray400)),
      ],
    );
  }
}
