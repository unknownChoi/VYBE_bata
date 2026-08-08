import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vybe/presentation/common/widgets/vybe_recommend_badge.dart';
import 'package:vybe/presentation/saved/saved_common.dart';
import 'package:vybe/presentation/saved/viewmodels/saved_viewmodel.dart';
import 'package:vybe/presentation/saved/widgets/saved_thumb.dart';

// 찜 그리드 뷰 카드.

class SavedGridCard extends StatelessWidget {
  final SavedEntry entry;
  final ValueChanged<String> onUnsave;

  const SavedGridCard({super.key, required this.entry, required this.onUnsave});

  @override
  Widget build(BuildContext context) {
    final club = entry.club;

    return GestureDetector(
      onTap: () => openSavedClubDetail(context, club.clubId),
      behavior: HitTestBehavior.opaque,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AspectRatio(
            aspectRatio: 1,
            child: SavedThumb(
              entry: entry,
              radius: 18,
              isGrid: true,
              onUnsave: () => onUnsave(club.clubId),
            ),
          ),
          SizedBox(height: 9.h),
          Row(
            children: [
              Flexible(
                child: Text(
                  club.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontFamily: 'Pretendard',
                    fontSize: 14.sp,
                    height: 16 / 14,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 14 * -0.025,
                    color: Colors.white,
                  ),
                ),
              ),
              // VYBE 추천 뱃지 — 클럽 이름 옆.
              if (club.isVybeRecommended) ...[
                SizedBox(width: 5.w),
                const VybeRecommendBadge(size: 9),
              ],
            ],
          ),
          SizedBox(height: 3.h),
          Text(
            '${club.area} · ${club.genre}',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: savedCaption(),
          ),
        ],
      ),
    );
  }
}

// ============ 썸네일 ============
