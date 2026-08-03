import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vybe/core/providers/auth_providers.dart';
import 'package:vybe/core/providers/location_providers.dart';
import 'package:vybe/core/utils/geohash_utils.dart';
import 'package:vybe/data/models/club_model.dart';
import 'package:vybe/design_system/colors.dart';
import 'package:vybe/presentation/clubs/club_detail_screen.dart';
import 'package:vybe/presentation/clubs/viewmodels/favorite_viewmodel.dart';
import 'package:vybe/presentation/clubs/widgets/club_glass.dart';
import 'package:vybe/presentation/common/widgets/vybe_skeleton.dart';
import 'package:vybe/presentation/main_scaffold/main_scaffold.dart';
import 'package:vybe/presentation/nearby/viewmodels/nearby_search_provider.dart';
import 'package:vybe/presentation/nearby/viewmodels/nearby_viewmodel.dart';
import 'package:vybe/presentation/nearby/widgets/club_nearby_list_item.dart';
import 'package:vybe/presentation/nearby/widgets/nearby_glass.dart';
import 'package:vybe/presentation/search/viewmodels/club_filter_viewmodel.dart';
import 'package:vybe/presentation/search/widgets/filter_chip_bar.dart';

/// 주변 페이지 리스트 시트 (리퀴드 글래스).
///
/// 디자인 nearby_glass.jsx `NGListSheet` — 핸들 · 제목+개수(라임) ·
/// 정렬/필터 칩 줄 · 클럽 카드 리스트. 지도 위로 떠 있어 배경이 비치는
/// 블러 시트([NearbySheetSurface])를 표면으로 쓴다.
class NearbyBottomSheet extends ConsumerWidget {
  final ScrollController scrollController;

  /// 지도에서 선택된 핀의 clubId. 해당 카드에 보라 wash로 표시.
  final String? selectedClubId;

  const NearbyBottomSheet({
    super.key,
    required this.scrollController,
    this.selectedClubId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 검색 모드면 검색결과를 소스로 사용 (geo 대신).
    final searchResult = ref.watch(nearbySearchResultProvider);
    final clubsAsync = searchResult != null
        ? AsyncValue.data(searchResult.clubs)
        : ref.watch(nearbyViewModelProvider);
    final activeFilters = ref.watch(clubFilterViewModelProvider);
    final sort = ref.watch(clubSortViewModelProvider);
    // 거리순 정렬·도보 거리 기준 = 내 위치(지도 내 위치 마커와 동일 좌표).
    final myLocation = ref.watch(userLocationProvider);
    // 지역 클러스터에서 선택한 area (null이면 전체).
    final selectedArea = ref.watch(selectedAreaProvider);
    final uid = ref.watch(currentUidProvider);
    final favoritedIds = ref.watch(mergedFavoriteIdsProvider);

    // 지역 선택 → 칩 필터(찜 포함) → 정렬 순으로 적용.
    final filteredAsync = clubsAsync.whenData((clubs) {
      // 검색 모드에선 지역(area) 필터 무시 (검색결과 그대로).
      var filtered = (selectedArea == null || searchResult != null)
          ? clubs
          : clubs.where((c) => c.area == selectedArea).toList();
      if (activeFilters.isNotEmpty) {
        filtered = filtered
            .where(
              (c) => clubMatchesFilters(
                c,
                activeFilters,
                favoritedIds: favoritedIds,
              ),
            )
            .toList();
      }
      return sortClubs(
        filtered,
        sort,
        refLat: myLocation.lat,
        refLng: myLocation.lng,
      );
    });

    // 마지막 카드가 하단 nav 바에 가리지 않도록.
    final padBottom = navBarTotalHeight(context) + 12.h;

    return NearbySheetSurface(
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
                SizedBox(height: 11.h),
                const NearbySheetHandle(),
                _SheetHeader(
                  count: filteredAsync.asData?.value.length ?? 0,
                  area: selectedArea,
                  searchKeyword: searchResult?.keyword,
                  loading: filteredAsync.isLoading,
                ),
                // 검색 결과 화면과 같은 칩 줄 (디자인·동작 공유).
                FilterChipBar(
                  showFavorite: true,
                  padding: EdgeInsets.fromLTRB(16.w, 4.h, 16.w, 0),
                ),
                SizedBox(height: 12.h),
              ],
            ),
          ),
          SliverPadding(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            sliver: filteredAsync.when(
              data: (clubs) => clubs.isEmpty
                  ? SliverToBoxAdapter(
                      child: _EmptyCard(
                        searching: searchResult != null,
                        filtered: activeFilters.isNotEmpty,
                      ),
                    )
                  : SliverList.builder(
                      itemCount: clubs.length,
                      itemBuilder: (_, i) => ClubNearbyListItem(
                        club: clubs[i],
                        isFavorited: favoritedIds.contains(clubs[i].clubId),
                        selected: clubs[i].clubId == selectedClubId,
                        distanceMeters: _distanceM(
                          clubs[i],
                          myLocation.lat,
                          myLocation.lng,
                        ),
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
              loading: () => SliverList.builder(
                itemCount: 3,
                itemBuilder: (_, __) => const NearbyListItemSkeleton(),
              ),
              error: (e, _) => SliverToBoxAdapter(
                child: _MessageCard(
                  icon: Icons.cloud_off_rounded,
                  title: '클럽 정보를 불러올 수 없어요',
                  message: '네트워크 상태를 확인하고\n잠시 후 다시 시도해주세요',
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(child: SizedBox(height: padBottom)),
        ],
      ),
    );
  }

  // 좌표가 없는 클럽(0,0)은 거리 표기를 생략한다.
  double? _distanceM(ClubModel club, double lat, double lng) {
    if (club.lat == 0 && club.lng == 0) return null;
    return GeohashUtils.haversineKm(lat, lng, club.lat, club.lng) * 1000;
  }
}

class _SheetHeader extends StatelessWidget {
  final int count;
  final String? area;
  final String? searchKeyword;
  final bool loading;

  const _SheetHeader({
    required this.count,
    this.area,
    this.searchKeyword,
    this.loading = false,
  });

  @override
  Widget build(BuildContext context) {
    final style = TextStyle(
      fontFamily: 'Pretendard',
      fontSize: 16.sp,
      height: 18 / 16,
      letterSpacing: 16 * -0.025,
      fontWeight: FontWeight.w700,
      color: Colors.white,
    );
    final label = searchKeyword != null
        ? "'$searchKeyword' 검색 결과"
        : area == null
        ? '내 주변 클럽'
        : '$area 클럽';

    return Padding(
      padding: EdgeInsets.fromLTRB(20.w, 13.h, 20.w, 12.h),
      child: Row(
        children: [
          Flexible(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: style,
            ),
          ),
          SizedBox(width: 7.w),
          // 로딩 중엔 카운트 자리에 shimmer.
          loading
              ? VybeSkel(width: 20.w, height: 15.h, radius: 4)
              : Text(
                  '$count',
                  style: style.copyWith(
                    color: VybeColors.mainLime500,
                    fontWeight: FontWeight.w800,
                  ),
                ),
        ],
      ),
    );
  }
}

/// 결과 0건 안내 카드 (디자인 NGListSheet 빈 상태).
class _EmptyCard extends StatelessWidget {
  final bool searching;
  final bool filtered;

  const _EmptyCard({required this.searching, required this.filtered});

  @override
  Widget build(BuildContext context) {
    if (searching) {
      return _MessageCard(
        icon: Icons.search_rounded,
        title: '검색 결과가 없어요',
        message: '다른 키워드로 검색하거나\n지도를 움직여 재검색해보세요',
      );
    }
    return _MessageCard(
      icon: Icons.search_rounded,
      title: filtered ? '조건에 맞는 클럽이 없어요' : '주변에 클럽이 없어요',
      message: filtered
          ? '필터를 줄이거나 지도를 움직여\n다른 지역에서 재검색해보세요'
          : '지도를 움직여\n다른 지역에서 재검색해보세요',
    );
  }
}

class _MessageCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String message;

  const _MessageCard({
    required this.icon,
    required this.title,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: 30,
      margin: EdgeInsets.only(top: 6.h),
      child: Column(
        children: [
          Container(
            width: 62.r,
            height: 62.r,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: VybeColors.mainPurple500.withValues(alpha: 0.16),
              shape: BoxShape.circle,
              border: Border.all(
                color: VybeColors.mainPurple500.withValues(alpha: 0.3),
              ),
            ),
            child: Icon(icon, size: 24.r, color: ClubGlass.t3),
          ),
          SizedBox(height: 12.h),
          Text(
            title,
            style: TextStyle(
              fontFamily: 'Pretendard',
              fontSize: 16.sp,
              height: 18 / 16,
              letterSpacing: 16 * -0.025,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 12.h),
          Text(
            message,
            textAlign: TextAlign.center,
            style: ClubGlass.body(color: ClubGlass.t3),
          ),
        ],
      ),
    );
  }
}
