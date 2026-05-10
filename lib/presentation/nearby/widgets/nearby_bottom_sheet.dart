import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vybe/design_system/colors.dart';
import 'package:vybe/presentation/nearby/widgets/club_nearby_list_item.dart';
import 'package:vybe/presentation/search/data/dummy_clubs.dart';

class NearbyBottomSheet extends StatelessWidget {
  final ScrollController scrollController;

  const NearbyBottomSheet({super.key, required this.scrollController});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: VybeColors.gray900,
        borderRadius: BorderRadius.vertical(top: Radius.circular(16.r)),
      ),
      child: Column(
        children: [
          _Handle(),
          Expanded(
            child: ListView.builder(
              controller: scrollController,
              padding: EdgeInsets.zero,
              itemCount: dummyClubs.length,
              itemBuilder: (_, i) => ClubNearbyListItem(club: dummyClubs[i]),
            ),
          ),
        ],
      ),
    );
  }
}

class _Handle extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 12.h),
      child: Container(
        width: 36.w,
        height: 4.h,
        decoration: BoxDecoration(
          color: VybeColors.gray700,
          borderRadius: BorderRadius.circular(2.r),
        ),
      ),
    );
  }
}
