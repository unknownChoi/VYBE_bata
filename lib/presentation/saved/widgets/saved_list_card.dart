import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vybe/design_system/colors.dart';
import 'package:vybe/presentation/clubs/widgets/club_glass.dart';
import 'package:vybe/presentation/common/widgets/vybe_recommend_badge.dart';
import 'package:vybe/presentation/saved/saved_common.dart';
import 'package:vybe/presentation/saved/viewmodels/saved_viewmodel.dart';
import 'package:vybe/presentation/saved/widgets/saved_thumb.dart';

// 찜 리스트 뷰 카드.

class SavedListCard extends StatelessWidget {
  final SavedEntry entry;
  final ValueChanged<String> onUnsave;

  const SavedListCard({super.key, required this.entry, required this.onUnsave});

  @override
  Widget build(BuildContext context) {
    final club = entry.club;

    return GestureDetector(
      onTap: () => openSavedClubDetail(context, club.clubId),
      behavior: HitTestBehavior.opaque,
      child: GlassCard(
        padding: 12,
        radius: 18,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SavedThumb(entry: entry, size: 92, radius: 14),
            SizedBox(width: 13.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Padding(
                          padding: EdgeInsets.only(top: 2.h),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Flexible(
                                child: Text(
                                  club.name,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontFamily: 'Pretendard',
                                    fontSize: 16.sp,
                                    height: 18 / 16,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: 16 * -0.025,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                              // VYBE 추천 뱃지 — 클럽 이름 옆.
                              if (club.isVybeRecommended) ...[
                                SizedBox(width: 6.w),
                                const VybeRecommendBadge(size: 10),
                              ],
                            ],
                          ),
                        ),
                      ),
                      SizedBox(width: 8.w),
                      _SavedUnsaveButton(onTap: () => onUnsave(club.clubId)),
                    ],
                  ),
                  SizedBox(height: 6.h),
                  Row(
                    children: [
                      Icon(Icons.star_rounded,
                          size: 12.r, color: VybeColors.mainLime500),
                      SizedBox(width: 5.w),
                      Text(
                        club.rating.toStringAsFixed(2),
                        style: savedCaption(
                          color: Colors.white,
                          weight: FontWeight.w700,
                        ),
                      ),
                      Container(
                        width: 1,
                        height: 9.h,
                        margin: EdgeInsets.symmetric(horizontal: 6.w),
                        color: const Color(0x33FFFFFF),
                      ),
                      Flexible(
                        child: Text(
                          club.area,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: savedCaption(),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 6.w),
                        child: const GlassDot(),
                      ),
                      Flexible(
                        child: Text(
                          club.genre,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: savedCaption(),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 6.h),
                  _SavedOpenHoursPill(isOpen: entry.isOpen, hours: entry.hoursLabel),
                  SizedBox(height: 6.h),
                  Text(
                    entry.savedAtLabel,
                    style: savedCaption(color: ClubGlass.t4),
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

/// 찜 해제 버튼 (리스트 카드용 글래스 타일 원형).
class _SavedUnsaveButton extends StatelessWidget {
  final VoidCallback onTap;

  const _SavedUnsaveButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        width: 30.r,
        height: 30.r,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: ClubGlass.tileFill,
          shape: BoxShape.circle,
          border: Border.all(color: ClubGlass.tileBorder),
        ),
        child: Icon(
          Icons.favorite_rounded,
          size: 15.r,
          color: ClubGlass.saved,
        ),
      ),
    );
  }
}

/// 영업 상태 + 마감/오픈 시각을 한 pill 안에 담는다 (찜 리스트 전용).
class _SavedOpenHoursPill extends StatelessWidget {
  final bool isOpen;
  final String hours;

  const _SavedOpenHoursPill({required this.isOpen, required this.hours});

  @override
  Widget build(BuildContext context) {
    final accent = isOpen ? VybeColors.mainLime500 : ClubGlass.t4;
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 9.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: isOpen
            ? VybeColors.mainLime500.withValues(alpha: 0.13)
            : const Color(0x0FFFFFFF),
        borderRadius: BorderRadius.circular(999.r),
        border: Border.all(
          color: isOpen
              ? VybeColors.mainLime500.withValues(alpha: 0.28)
              : const Color(0x1AFFFFFF),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 5.r,
            height: 5.r,
            decoration: BoxDecoration(
              color: isOpen ? VybeColors.mainLime500 : const Color(0x59FFFFFF),
              shape: BoxShape.circle,
            ),
          ),
          SizedBox(width: 5.w),
          Text(
            isOpen ? '영업중' : '영업종료',
            style: savedCaption(
              color: accent,
              lineHeight: 13,
              weight: FontWeight.w700,
            ),
          ),
          SizedBox(width: 5.w),
          Flexible(
            child: Text(
              hours,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: savedCaption(lineHeight: 13),
            ),
          ),
        ],
      ),
    );
  }
}

// ============ 그리드 카드 ============
