import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vybe/core/providers/auth_providers.dart';
import 'package:vybe/design_system/colors.dart';
import 'package:vybe/design_system/typography.dart';
import 'package:vybe/presentation/clubs/club_detail_screen.dart';
import 'package:vybe/presentation/clubs/viewmodels/favorite_viewmodel.dart';
import 'package:vybe/presentation/nearby/viewmodels/nearby_viewmodel.dart';
import 'package:vybe/presentation/nearby/widgets/club_nearby_list_item.dart';
import 'package:vybe/presentation/search/widgets/filter_chip_bar.dart';

class NearbyBottomSheet extends ConsumerWidget {
  final ScrollController scrollController;

  const NearbyBottomSheet({super.key, required this.scrollController});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final clubsAsync = ref.watch(nearbyViewModelProvider);
    final uid = ref.watch(currentUidProvider);

    // 찜 목록 스트림 1번만 구독 → Set<clubId>
    final streamFavIds = uid != null
        ? ref.watch(favoritedClubIdsProvider(uid)).asData?.value ?? {}
        : <String>{};

    // 낙관적 오버라이드 머지 (스트림 업데이트 전 즉시 반영)
    final optimistic = ref.watch(favoriteViewModelProvider);
    final favoritedIds = Set<String>.from(streamFavIds)
      ..addAll(optimistic.entries.where((e) => e.value).map((e) => e.key))
      ..removeAll(optimistic.entries.where((e) => !e.value).map((e) => e.key));

    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: VybeColors.gray900,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28.r)),
      ),
      // 헤더(핸들·카운트·필터칩)까지 하나의 스크롤뷰로 묶어, 시트 어느 곳을
      // 잡고 드래그해도 DraggableScrollableSheet가 반응하도록 한다.
      child: CustomScrollView(
        controller: scrollController,
        // 내용이 짧아도 드래그가 시트로 전달되도록 항상 스크롤 가능.
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          SliverToBoxAdapter(
            child: Column(
              children: [
                _Handle(),
                _SheetHeader(count: clubsAsync.asData?.value.length ?? 0),
                const FilterChipBar(hasBackground: true),
                SizedBox(height: 8.h),
              ],
            ),
          ),
          clubsAsync.when(
            data: (clubs) => clubs.isEmpty
                ? _centerSliver(
                    Text(
                      '주변에 클럽이 없어요',
                      style: VybeTypography.body2
                          .copyWith(color: VybeColors.gray500),
                    ),
                  )
                : SliverList.builder(
                    itemCount: clubs.length,
                    itemBuilder: (_, i) => ClubNearbyListItem(
                      club: clubs[i],
                      isFavorited: favoritedIds.contains(clubs[i].clubId),
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) =>
                              ClubDetailScreen(clubId: clubs[i].clubId),
                        ),
                      ),
                      onFavoriteTap: uid == null
                          ? null
                          : () => ref
                              .read(favoriteViewModelProvider.notifier)
                              .toggleFavorite(
                                uid,
                                clubs[i].clubId,
                                favoritedIds.contains(clubs[i].clubId),
                              ),
                    ),
                  ),
            loading: () => const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 40),
                child: Center(
                  child: CircularProgressIndicator(
                    color: VybeColors.mainPurple500,
                  ),
                ),
              ),
            ),
            error: (e, _) => _centerSliver(
              Text(
                '클럽 정보를 불러올 수 없어요',
                style:
                    VybeTypography.body2.copyWith(color: VybeColors.gray500),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 빈/에러 상태 메시지를 sliver로 가운데 표시.
  Widget _centerSliver(Widget child) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 60),
        child: Center(child: child),
      ),
    );
  }
}

class _SheetHeader extends StatelessWidget {
  final int count;

  const _SheetHeader({required this.count});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(24.w, 4.h, 24.w, 12.h),
      child: Row(
        children: [
          Text.rich(
            TextSpan(
              style: VybeTypography.body3.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
              children: [
                const TextSpan(text: '내 주변 클럽 '),
                TextSpan(
                  text: '$count',
                  style: const TextStyle(color: VybeColors.mainLime500),
                ),
              ],
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
