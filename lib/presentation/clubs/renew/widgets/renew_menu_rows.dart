import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vybe/core/utils/number_format.dart';
import 'package:vybe/data/models/menu_model.dart';
import 'package:vybe/design_system/colors.dart';
import 'package:vybe/design_system/typography.dart';
import 'package:vybe/presentation/clubs/renew/widgets/renew_glass.dart';
import 'package:vybe/presentation/common/widgets/vybe_skeleton.dart';

/// 메뉴 목록 (디자인 VRMenuRows) — 홈 탭 미리보기와 메뉴 탭 섹션이 공유.
///
/// 카드 없이 hairline으로만 구분되는 줄 목록. 이미지가 있으면 우측 78 정사각.
class RenewMenuRows extends StatelessWidget {
  final List<MenuModel> menus;

  const RenewMenuRows({super.key, required this.menus});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (var i = 0; i < menus.length; i++)
          _RenewMenuRow(menu: menus[i], first: i == 0),
      ],
    );
  }
}

class _RenewMenuRow extends StatelessWidget {
  final MenuModel menu;
  final bool first;

  const _RenewMenuRow({required this.menu, required this.first});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 16.h),
      decoration: BoxDecoration(
        border: first
            ? null
            : const Border(top: BorderSide(color: RenewGlass.hair)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    if (menu.isFeatured) ...[
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 7.w,
                          vertical: 2.h,
                        ),
                        decoration: BoxDecoration(
                          color: VybeColors.mainPurple500,
                          borderRadius: BorderRadius.circular(6.r),
                        ),
                        child: Text(
                          '대표',
                          style: RenewGlass.caption(
                            color: Colors.white,
                            size: 10,
                            lineHeight: 13,
                            weight: FontWeight.w600,
                          ),
                        ),
                      ),
                      SizedBox(width: 6.w),
                    ],
                    Flexible(
                      child: Text(
                        menu.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: RenewGlass.body(
                          color: RenewGlass.t1,
                          weight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                if (menu.description.isNotEmpty) ...[
                  SizedBox(height: 4.h),
                  Text(
                    menu.description,
                    style: RenewGlass.caption(lineHeight: 17),
                  ),
                ],
                SizedBox(height: 6.h),
                Text(
                  '${formatThousands(menu.price)}원',
                  style: VybeTypography.body3.copyWith(
                    fontWeight: FontWeight.w600,
                    color: RenewGlass.t1,
                  ),
                ),
              ],
            ),
          ),
          if (menu.imageUrl.isNotEmpty) ...[
            SizedBox(width: 12.w),
            Container(
              width: 78.r,
              height: 78.r,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14.r),
                border: Border.all(color: RenewGlass.tileBorder),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(13.r),
                child: SkeletonImage(url: menu.imageUrl, fit: BoxFit.cover),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
