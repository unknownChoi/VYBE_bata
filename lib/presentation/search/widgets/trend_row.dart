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

  const TrendRow({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    final rankColor =
        item.rank <= 2 ? VybeColors.mainLime700 : VybeColors.gray200;

    return Row(
      children: [
        SizedBox(
          width: 18.w,
          child: Text(
            '${item.rank}',
            style: TextStyle(
              fontFamily: 'Pretendard',
              fontWeight: FontWeight.w600,
              fontSize: 16.sp,
              height: 20 / 16,
              letterSpacing: 16 * -0.025,
              color: rankColor,
            ),
          ),
        ),
        SizedBox(width: 8.w),
        Expanded(
          child: Text(
            item.keyword,
            style: VybeTypography.body3.copyWith(color: VybeColors.gray200),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        _buildStatus(),
      ],
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
