import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:vybe/design_system/colors.dart';
import 'package:vybe/design_system/typography.dart';

enum TrendStatus { up, down, newEntry, same }

class TrendItem {
  final int rank;
  final String keyword;
  final TrendStatus status;
  final int? change;

  const TrendItem({
    required this.rank,
    required this.keyword,
    required this.status,
    this.change,
  });
}

class TrendRow extends StatelessWidget {
  final TrendItem item;
  final VoidCallback? onTap;

  const TrendRow({super.key, required this.item, this.onTap});

  @override
  Widget build(BuildContext context) {
    final top = item.rank <= 3;
    final rankColor = top ? VybeColors.mainLime500 : VybeColors.gray500;

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 9.h, horizontal: 6.w),
        child: Row(
          children: [
            SizedBox(
              width: 20.w,
              child: Text(
                '${item.rank}',
                textAlign: TextAlign.center,
                maxLines: 1,
                softWrap: false,
                overflow: TextOverflow.visible,
                style: TextStyle(
                  fontFamily: 'Pretendard',
                  fontWeight: FontWeight.w800,
                  fontSize: 15.sp,
                  height: 18 / 15,
                  letterSpacing: 15 * -0.025,
                  color: rankColor,
                ),
              ),
            ),
            SizedBox(width: 10.w),
            Expanded(
              child: Text(
                item.keyword,
                style: VybeTypography.body3.copyWith(
                  color: VybeColors.gray100,
                  fontWeight: FontWeight.w500,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            SizedBox(width: 6.w),
            _buildStatus(),
          ],
        ),
      ),
    );
  }

  Widget _buildStatus() {
    final numStyle = TextStyle(
      fontFamily: 'Pretendard',
      fontWeight: FontWeight.w400,
      fontSize: 12.sp,
      height: 14 / 12,
      letterSpacing: 12 * -0.025,
      color: VybeColors.gray500,
    );

    switch (item.status) {
      case TrendStatus.up:
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SvgPicture.asset(
              'assets/icons/search_screen/search_rank_up.svg',
              width: 10.r,
              height: 10.r,
            ),
            SizedBox(width: 4.w),
            Text('${item.change}', style: numStyle),
          ],
        );
      case TrendStatus.down:
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SvgPicture.asset(
              'assets/icons/search_screen/search_rank_down.svg',
              width: 10.r,
              height: 10.r,
            ),
            SizedBox(width: 4.w),
            Text('${item.change}', style: numStyle),
          ],
        );
      case TrendStatus.newEntry:
        return Text(
          'N',
          style: numStyle.copyWith(color: VybeColors.accentRed500),
        );
      case TrendStatus.same:
        return Text('—', style: numStyle);
    }
  }
}
