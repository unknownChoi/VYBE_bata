import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vybe/design_system/colors.dart';
import 'package:vybe/design_system/typography.dart';
import 'package:vybe/presentation/common/widgets/vybe_meta_dot.dart';
import 'package:vybe/presentation/hot_places/hot_places_models.dart';
import 'package:vybe/presentation/hot_places/widgets/hot_places_podium.dart';

// 핫플레이스 순위 리스트 행.

// ── 섹션 헤더 ──
class HotPlacesSectionHeader extends StatelessWidget {
  final String area;
  final bool near;
  final int total;
  const HotPlacesSectionHeader({super.key, required this.area, required this.near, required this.total});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 6.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          if (near)
            Row(
              children: [
                Icon(Icons.place, size: 14.r, color: kHotAccent),
                SizedBox(width: 6.w),
                Text('내 주변 핫플',
                    style: VybeTypography.button2.copyWith(fontWeight: FontWeight.w700, color: Colors.white)),
              ],
            )
          else
            Text(
              area == '전체' ? '전체 순위' : '$area 순위',
              style: VybeTypography.button2.copyWith(fontWeight: FontWeight.w700, color: Colors.white),
            ),
          Text(
            near ? '반경 ${kHotNearRadiusKm.toInt()}km · $total곳' : '$total곳',
            style: VybeTypography.caption.copyWith(height: 16 / 12, color: VybeColors.gray500),
          ),
        ],
      ),
    );
  }
}

// ── 리스트 로우 ──
class HotPlacesListRow extends StatelessWidget {
  final HotClub club;
  final bool near;
  final bool saved;
  final ValueChanged<int> onSave;
  const HotPlacesListRow({super.key, required this.club, required this.near, required this.saved, required this.onSave});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 14.h),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: VybeColors.gray900)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            width: 20.w,
            child: Center(
              child: Text(
                '${club.rank}',
                style: TextStyle(
                  fontFamily: 'Pretendard',
                  fontWeight: FontWeight.w800,
                  fontSize: 17.sp,
                  color: VybeColors.gray600,
                  letterSpacing: 17 * -0.04,
                ),
              ),
            ),
          ),
          SizedBox(width: 13.w),
          Container(
            width: 72.r,
            height: 72.r,
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(
              gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: club.bg),
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(color: VybeColors.gray900),
            ),
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: const Alignment(-0.4, -0.4),
                  radius: 0.8,
                  colors: [Colors.white.withValues(alpha: 0.2), Colors.transparent],
                  stops: const [0, 0.6],
                ),
              ),
            ),
          ),
          SizedBox(width: 13.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        club.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: VybeTypography.body3.copyWith(color: Colors.white, fontWeight: FontWeight.w600),
                      ),
                    ),
                    if (club.up) ...[
                      SizedBox(width: 6.w),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 2.h),
                        decoration: BoxDecoration(
                          color: kHotAccent.withValues(alpha: 0.16),
                          borderRadius: BorderRadius.circular(6.r),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.trending_up, size: 10.r, color: kHotAccent),
                            SizedBox(width: 2.w),
                            Text(
                              '상승',
                              style: VybeTypography.caption.copyWith(
                                fontSize: 10.sp,
                                height: 12 / 10,
                                fontWeight: FontWeight.w700,
                                color: kHotAccent,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                    const Spacer(),
                    GestureDetector(
                      onTap: () => onSave(club.id),
                      behavior: HitTestBehavior.opaque,
                      child: Padding(
                        padding: EdgeInsets.all(2.r),
                        child: HotHeartIcon(active: saved, size: 18),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 3.h),
                _metaRow(),
                HotCrowdBar(crowd: club.crowd),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _metaRow() {
    final children = <Widget>[];
    void dot() =>
        children.add(const VybeMetaDot(color: VybeColors.gray600));

    if (near) {
      children.addAll([
        Icon(Icons.place, size: 11.r, color: kHotAccent),
        SizedBox(width: 3.w),
        Text('${club.dist.toStringAsFixed(1)}km',
            style: VybeTypography.caption.copyWith(height: 14 / 12, color: kHotAccent, fontWeight: FontWeight.w700)),
      ]);
      dot();
    }
    children.addAll([
      const HotStarIcon(size: 11),
      SizedBox(width: 3.w),
      Text(club.rating.toStringAsFixed(2),
          style: VybeTypography.caption.copyWith(height: 14 / 12, color: Colors.white, fontWeight: FontWeight.w700)),
    ]);
    dot();
    children.add(Text(club.area, style: VybeTypography.caption.copyWith(height: 14 / 12, color: VybeColors.gray500)));
    dot();
    children.add(Text(club.genre, style: VybeTypography.caption.copyWith(height: 14 / 12, color: VybeColors.gray500)));
    dot();
    children.addAll([
      Icon(Icons.people, size: 11.r, color: VybeColors.gray400),
      SizedBox(width: 3.w),
      Text(club.visitors,
          style: VybeTypography.caption.copyWith(height: 14 / 12, color: VybeColors.gray400, fontWeight: FontWeight.w600)),
    ]);

    return Row(children: children);
  }
}

// ── 불꽃 아이콘 ──
class HotFlameIcon extends StatelessWidget {
  final double size;
  final Color color;
  const HotFlameIcon({super.key, required this.size, this.color = kHotAccent});
  @override
  Widget build(BuildContext context) {
    return Icon(Icons.local_fire_department, size: size.r, color: color);
  }
}

// ── 별 아이콘 ──
class HotStarIcon extends StatelessWidget {
  final double size;
  const HotStarIcon({super.key, required this.size});
  @override
  Widget build(BuildContext context) {
    return Icon(Icons.star, size: size.r, color: VybeColors.mainLime500);
  }
}

// ── 하트 아이콘 ──
class HotHeartIcon extends StatelessWidget {
  final bool active;
  final double size;
  const HotHeartIcon({super.key, required this.active, required this.size});
  @override
  Widget build(BuildContext context) {
    return Icon(
      active ? Icons.favorite : Icons.favorite_border,
      size: size.r,
      color: active ? VybeColors.mainPurple500 : Colors.white,
    );
  }
}
