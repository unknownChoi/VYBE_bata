import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vybe/design_system/colors.dart';
import 'package:vybe/design_system/typography.dart';
import 'package:vybe/presentation/common/widgets/vybe_meta_dot.dart';
import 'package:vybe/presentation/hot_places/hot_places_models.dart';
import 'package:vybe/presentation/hot_places/widgets/hot_places_list_row.dart';

// 핫플레이스 TOP3 포디움 + 혼잡도 표시.

// ── 포디움 (TOP 3) ──
class HotPlacesPodium extends StatelessWidget {
  final List<HotClub> clubs;
  final Set<int> saved;
  final ValueChanged<int> onSave;
  const HotPlacesPodium({super.key, required this.clubs, required this.saved, required this.onSave});

  @override
  Widget build(BuildContext context) {
    if (clubs.isEmpty) return const SizedBox.shrink();
    final first = clubs.first;
    final rest = clubs.skip(1).toList();
    final solo = rest.isEmpty;

    return Padding(
      padding: EdgeInsets.fromLTRB(16.w, 6.h, 16.w, 8.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(2.w, 6.h, 2.w, 12.h),
            child: Text(
              '실시간 TOP ${clubs.length}',
              style: VybeTypography.button2.copyWith(fontWeight: FontWeight.w700, color: Colors.white),
            ),
          ),
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  flex: solo ? 1 : 6,
                  child: _HotPodiumCard(
                    club: first,
                    big: true,
                    saved: saved.contains(first.id),
                    onSave: onSave,
                  ),
                ),
                if (!solo) ...[
                  SizedBox(width: 10.w),
                  Expanded(
                    flex: 4,
                    child: Column(
                      children: [
                        for (var i = 0; i < rest.length; i++) ...[
                          _HotPodiumCard(
                            club: rest[i],
                            big: false,
                            saved: saved.contains(rest[i].id),
                            onSave: onSave,
                          ),
                          if (i != rest.length - 1) SizedBox(height: 10.h),
                        ],
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// 메달 색.
class _HotMedal {
  final List<Color> grad;
  final Color ink;
  const _HotMedal(this.grad, this.ink);
}

const Map<int, _HotMedal> _kHotMedals = {
  1: _HotMedal([Color(0xFFFFE7A0), Color(0xFFFBC02D), Color(0xFFC8860B)], Color(0xFF5A3A00)),
  2: _HotMedal([Color(0xFFF2F5FA), Color(0xFFC5CCD6), Color(0xFF9098A6)], Color(0xFF3D434D)),
  3: _HotMedal([Color(0xFFF2B98C), Color(0xFFD98A52), Color(0xFFA65B2A)], Color(0xFF502A0E)),
};

class _HotPodiumCard extends StatelessWidget {
  final HotClub club;
  final bool big;
  final bool saved;
  final ValueChanged<int> onSave;
  const _HotPodiumCard({required this.club, required this.big, required this.saved, required this.onSave});

  @override
  Widget build(BuildContext context) {
    final cr = kHotCrowdMap[club.crowd]!;
    final h = big ? 188.h : 89.h;
    final medal = _kHotMedals[club.rank] ?? _kHotMedals[3]!;

    return Container(
      height: h,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: club.bg),
        borderRadius: BorderRadius.circular(16.r),
      ),
      // 테두리는 자식 위에 — decoration 에 두면 코너 호에서 선이 덮인다.
      foregroundDecoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: VybeColors.gray800),
      ),
      child: Stack(
        children: [
          // 하단 어둡게.
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [
                    VybeColors.background.withValues(alpha: 0.94),
                    VybeColors.background.withValues(alpha: 0.15),
                    Colors.transparent,
                  ],
                  stops: const [0.08, 0.55, 0.8],
                ),
              ),
            ),
          ),
          // 메달.
          Positioned(
            top: 10.h,
            left: 10.w,
            child: Container(
              width: big ? 32.r : 27.r,
              height: big ? 32.r : 27.r,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: medal.grad),
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white.withValues(alpha: 0.45), width: 1.5),
              ),
              child: Text(
                '${club.rank}',
                style: TextStyle(
                  fontFamily: 'Pretendard',
                  fontWeight: FontWeight.w800,
                  fontSize: (big ? 15 : 13).sp,
                  color: medal.ink,
                ),
              ),
            ),
          ),
          // 찜.
          Positioned(
            top: 8.h,
            right: 8.w,
            child: GestureDetector(
              onTap: () => onSave(club.id),
              behavior: HitTestBehavior.opaque,
              child: Container(
                width: 30.r,
                height: 30.r,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.4),
                  shape: BoxShape.circle,
                ),
                child: HotHeartIcon(active: saved, size: 16),
              ),
            ),
          ),
          // 혼잡 배지 (big만 상단 고정).
          if (big)
            Positioned(
              top: 48.h,
              left: 10.w,
              child: HotCrowdBadge(cr: cr),
            ),
          // 정보.
          Positioned(
            left: 12.w,
            right: 12.w,
            bottom: 11.h,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  club.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: (big ? VybeTypography.heading4 : VybeTypography.body3)
                      .copyWith(fontWeight: FontWeight.w700, color: Colors.white),
                ),
                SizedBox(height: 5.h),
                Row(
                  children: [
                    const HotStarIcon(size: 11),
                    SizedBox(width: 3.w),
                    Text(
                      club.rating.toStringAsFixed(2),
                      style: VybeTypography.caption.copyWith(
                        fontSize: 11.sp,
                        height: 13 / 11,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                    const VybeMetaDot(color: VybeColors.gray600),
                    if (big) ...[
                      Icon(Icons.people, size: 11.r, color: VybeColors.gray300),
                      SizedBox(width: 3.w),
                      Text(
                        club.visitors,
                        style: VybeTypography.caption.copyWith(
                          fontSize: 11.sp,
                          height: 13 / 11,
                          fontWeight: FontWeight.w600,
                          color: VybeColors.gray300,
                        ),
                      ),
                      const VybeMetaDot(color: VybeColors.gray600),
                      Text(
                        club.area,
                        style: VybeTypography.caption.copyWith(
                          fontSize: 11.sp,
                          height: 13 / 11,
                          color: VybeColors.gray300,
                        ),
                      ),
                    ] else ...[
                      HotFlameIcon(size: 10, color: cr.color),
                      SizedBox(width: 3.w),
                      Flexible(
                        child: Text(
                          cr.label,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: VybeTypography.caption.copyWith(
                            fontSize: 11.sp,
                            height: 13 / 11,
                            fontWeight: FontWeight.w700,
                            color: cr.color,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class HotCrowdBadge extends StatelessWidget {
  final HotCrowdInfo cr;
  const HotCrowdBadge({super.key, required this.cr});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: cr.color.withValues(alpha: 0.19),
        borderRadius: BorderRadius.circular(99.r),
        border: Border.all(color: cr.color),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          HotFlameIcon(size: 10, color: cr.color),
          SizedBox(width: 4.w),
          Text(
            cr.label,
            style: VybeTypography.caption.copyWith(
              fontSize: 10.sp,
              height: 12 / 10,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}

// ── 혼잡 바 ──
class HotCrowdBar extends StatelessWidget {
  final HotCrowd crowd;
  const HotCrowdBar({super.key, required this.crowd});
  @override
  Widget build(BuildContext context) {
    final cr = kHotCrowdMap[crowd]!;
    return Padding(
      padding: EdgeInsets.only(top: 7.h),
      child: Row(
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(99.r),
              child: Container(
                height: 5.h,
                color: VybeColors.gray800,
                alignment: Alignment.centerLeft,
                child: FractionallySizedBox(
                  widthFactor: cr.pct / 100,
                  child: Container(color: cr.color),
                ),
              ),
            ),
          ),
          SizedBox(width: 7.w),
          Text(
            cr.label,
            style: VybeTypography.caption.copyWith(
              fontSize: 11.sp,
              height: 12 / 11,
              fontWeight: FontWeight.w700,
              color: cr.color,
            ),
          ),
        ],
      ),
    );
  }
}
