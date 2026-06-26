import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:vybe/core/providers/auth_providers.dart';
import 'package:vybe/design_system/colors.dart';
import 'package:vybe/design_system/typography.dart';
import 'package:vybe/presentation/clubs/viewmodels/favorite_viewmodel.dart';
import 'package:vybe/presentation/search/viewmodels/club_filter_viewmodel.dart';
import 'package:vybe/presentation/search/viewmodels/search_viewmodel.dart';
import 'package:vybe/presentation/search/widgets/club_list_item.dart';
import 'package:vybe/presentation/search/widgets/filter_chip_bar.dart';
import 'package:vybe/presentation/search/widgets/result_gnb.dart';

class SearchResultScreen extends ConsumerStatefulWidget {
  final String query;

  const SearchResultScreen({super.key, required this.query});

  @override
  ConsumerState<SearchResultScreen> createState() => _SearchResultScreenState();
}

class _SearchResultScreenState extends ConsumerState<SearchResultScreen> {
  @override
  void initState() {
    super.initState();
    // 진입 즉시 첫 페이지 검색 (+ 검색 기록 저장).
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final uid = ref.read(currentUidProvider);
      ref
          .read(searchViewModelProvider.notifier)
          .search(widget.query, userId: uid);
    });
  }

  // 바닥 근처 스크롤 시 다음 페이지(10개) 서버에서 추가 로드.
  bool _onScroll(ScrollNotification n) {
    if (n.metrics.pixels >= n.metrics.maxScrollExtent - 200) {
      ref.read(searchViewModelProvider.notifier).loadMore();
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    final resultsAsync = ref.watch(searchViewModelProvider);
    final filters = ref.watch(clubFilterViewModelProvider);
    final sort = ref.watch(clubSortViewModelProvider);

    // 찜 상태(스트림 + 낙관적 오버라이드 머지).
    final uid = ref.watch(currentUidProvider);
    final streamFavIds = uid != null
        ? ref.watch(favoritedClubIdsProvider(uid)).asData?.value ?? <String>{}
        : <String>{};
    final optimistic = ref.watch(favoriteViewModelProvider);
    final favoritedIds = Set<String>.from(streamFavIds)
      ..addAll(optimistic.entries.where((e) => e.value).map((e) => e.key))
      ..removeAll(optimistic.entries.where((e) => !e.value).map((e) => e.key));

    return Scaffold(
      backgroundColor: VybeColors.background,
      body: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ResultGnb(query: widget.query),
            _buildLocationRow(),
            const FilterChipBar(),
            Expanded(
              child: resultsAsync.when(
                loading: () => const Center(
                  child: CircularProgressIndicator(
                    color: VybeColors.mainPurple500,
                  ),
                ),
                error: (e, _) => _buildMessage('검색 중 오류가 발생했어요\n\n$e'),
                data: (results) {
                  // 로드된 결과에 필터 + 정렬 적용 (클라).
                  var clubs = results.clubs
                      .where((c) =>
                          clubMatchesFilters(c, filters, favoritedIds: favoritedIds))
                      .toList();
                  clubs = sortClubs(clubs, sort);

                  // 필터로 다 걸러졌는데 서버에 더 있으면 자동으로 다음 페이지 로드
                  // (사용자가 스크롤할 콘텐츠가 없어 멈추는 것 방지).
                  if (clubs.isEmpty &&
                      results.hasMore &&
                      !results.loadingMore) {
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      ref.read(searchViewModelProvider.notifier).loadMore();
                    });
                  }

                  if (clubs.isEmpty) {
                    if (results.hasMore || results.loadingMore) {
                      return const Center(
                        child: CircularProgressIndicator(
                          color: VybeColors.mainPurple500,
                        ),
                      );
                    }
                    return _buildMessage(
                      filters.isEmpty
                          ? "'${widget.query}' 검색 결과가 없어요"
                          : '조건에 맞는 클럽이 없어요',
                    );
                  }

                  final showSpinner = results.hasMore || results.loadingMore;
                  return NotificationListener<ScrollNotification>(
                    onNotification: _onScroll,
                    child: ListView.builder(
                      padding: EdgeInsets.zero,
                      itemCount: clubs.length + (showSpinner ? 1 : 0),
                      itemBuilder: (_, i) {
                        if (i >= clubs.length) {
                          return Padding(
                            padding: EdgeInsets.symmetric(vertical: 20.h),
                            child: const Center(
                              child: CircularProgressIndicator(
                                color: VybeColors.mainPurple500,
                              ),
                            ),
                          );
                        }
                        final club = clubs[i];
                        return ClubListItem(
                          club: club,
                          isFavorited: favoritedIds.contains(club.clubId),
                          onFavoriteTap: uid == null
                              ? null
                              : () => ref
                                  .read(favoriteViewModelProvider.notifier)
                                  .toggleFavorite(
                                    uid,
                                    club.clubId,
                                    favoritedIds.contains(club.clubId),
                                  ),
                        );
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMessage(String text) {
    return Center(
      child: Padding(
        padding: EdgeInsets.only(bottom: 80.h),
        child: Text(
          text,
          textAlign: TextAlign.center,
          style: VybeTypography.body3.copyWith(color: VybeColors.gray500),
        ),
      ),
    );
  }

  Widget _buildLocationRow() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 8.h),
      child: Row(
        children: [
          SvgPicture.asset(
            'assets/icons/common/club_card/location_pin_sm.svg',
            width: 16.r,
            height: 16.r,
          ),
          SizedBox(width: 4.w),
          Text(
            '내 주변 검색',
            style: VybeTypography.body3.copyWith(color: VybeColors.gray200),
          ),
        ],
      ),
    );
  }
}
