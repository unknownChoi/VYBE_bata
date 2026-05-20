import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vybe/design_system/colors.dart';
import 'package:vybe/design_system/typography.dart';
import 'package:vybe/presentation/nearby/viewmodels/nearby_viewmodel.dart';
import 'package:vybe/presentation/nearby/widgets/club_nearby_list_item.dart';

class NearbyBottomSheet extends ConsumerWidget {
  final ScrollController scrollController;

  const NearbyBottomSheet({super.key, required this.scrollController});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final clubsAsync = ref.watch(nearbyViewModelProvider);

    return Container(
      decoration: BoxDecoration(
        color: VybeColors.gray900,
        borderRadius: BorderRadius.vertical(top: Radius.circular(16.r)),
      ),
      child: Column(
        children: [
          _Handle(),
          Expanded(
            child: clubsAsync.when(
              data: (clubs) => clubs.isEmpty
                  ? Center(
                      child: Text(
                        '주변에 클럽이 없어요',
                        style: VybeTypography.body2
                            .copyWith(color: VybeColors.gray500),
                      ),
                    )
                  : ListView.builder(
                      controller: scrollController,
                      padding: EdgeInsets.zero,
                      itemCount: clubs.length,
                      itemBuilder: (_, i) => ClubNearbyListItem(club: clubs[i]),
                    ),
              loading: () => const Center(
                child: CircularProgressIndicator(
                  color: VybeColors.mainPurple500,
                ),
              ),
              error: (e, _) => Center(
                child: Text(
                  '클럽 정보를 불러올 수 없어요',
                  style: VybeTypography.body2
                      .copyWith(color: VybeColors.gray500),
                ),
              ),
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
