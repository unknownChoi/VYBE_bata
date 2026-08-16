import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vybe/core/providers/auth_providers.dart';
import 'package:vybe/data/models/search_trend_model.dart';
import 'package:vybe/design_system/colors.dart';
import 'package:vybe/design_system/typography.dart';
import 'package:vybe/presentation/clubs/viewmodels/favorite_viewmodel.dart';
import 'package:vybe/presentation/common/widgets/vybe_aurora.dart';
import 'package:vybe/presentation/search/viewmodels/club_filter_viewmodel.dart';
import 'package:vybe/presentation/search/viewmodels/search_viewmodel.dart';
import 'package:vybe/presentation/search/widgets/club_list_item.dart';
import 'package:vybe/presentation/search/widgets/filter_chip_bar.dart';
import 'package:vybe/presentation/search/widgets/result_gnb.dart';
import 'package:vybe/presentation/search/widgets/search_result_item_skeleton.dart';

class SearchResultScreen extends ConsumerStatefulWidget {
  final String query;

  /// 이 검색이 어디서 왔는지 — 인기 검색어 집계에서 되먹임을 걸러내는 데 쓰인다.
  final SearchSource source;

  const SearchResultScreen({
    super.key,
    required this.query,
    this.source = SearchSource.input,
  });

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
          .search(widget.query, userId: uid, source: widget.source);
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
    final favoritedIds = ref.watch(mergedFavoriteIdsProvider);

    // 메타 행 결과 수. 로딩 중엔 null.
    // - 필터 없음: 검색어 전체 매칭 수(totalCount) — 10개씩 로드해도 숫자 안 변함.
    // - 필터 있음: 서버는 필터를 모르므로 지금까지 로드된 것 중 통과 개수.
    final int? count = resultsAsync.maybeWhen(
      data: (results) {
        if (filters.isEmpty) return results.totalCount;
        return results.clubs
            .where((c) =>
                clubMatchesFilters(c, filters, favoritedIds: favoritedIds))
            .length;
      },
      orElse: () => null,
    );

    return Scaffold(
      backgroundColor: kVybeInk,
      body: Stack(
        children: [
          const Positioned.fill(
            child: IgnorePointer(child: _ResultBackdrop()),
          ),
          SafeArea(
            bottom: false,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ResultGnb(query: widget.query),
            _buildMetaRow(count),
            const FilterChipBar(),
            Expanded(
              child: resultsAsync.when(
                loading: _buildSkeletonList,
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
                    // 필터로 다 걸러진 채 다음 페이지를 받아오는 중 —
                    // 스피너 대신 카드 골격 스켈레톤으로 채운다.
                    if (results.hasMore || results.loadingMore) {
                      return _buildSkeletonList();
                    }
                    return _buildMessage(
                      filters.isEmpty
                          ? "'${widget.query}' 검색 결과가 없어요"
                          : '조건에 맞는 클럽이 없어요',
                    );
                  }

                  final showSkeleton = results.hasMore || results.loadingMore;
                  return NotificationListener<ScrollNotification>(
                    onNotification: _onScroll,
                    child: ListView.builder(
                      padding: EdgeInsets.only(top: 4.h),
                      itemCount: clubs.length + (showSkeleton ? 1 : 0),
                      itemBuilder: (_, i) {
                        // 다음 페이지 로드 자리 — 스피너 대신 카드 골격 스켈레톤.
                        if (i >= clubs.length) {
                          return Padding(
                            padding: EdgeInsets.only(top: 6.h),
                            child: const Column(
                              children: [
                                SearchResultItemSkeleton(),
                                SearchResultItemSkeleton(),
                              ],
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
        ],
      ),
    );
  }

  // 결과 카드 자리를 채우는 스켈레톤 리스트 (최초 검색·필터 대기 중 표시).
  // 화면 높이에 상관없이 아래가 잘리도록 넉넉히 4장.
  Widget _buildSkeletonList() {
    return ListView.builder(
      padding: EdgeInsets.only(top: 4.h),
      physics: const NeverScrollableScrollPhysics(),
      itemCount: 4,
      itemBuilder: (_, __) => const SearchResultItemSkeleton(),
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

  // 검색결과 수 + '내 주변 검색' 라임 pill (search_results_v2 MetaRow).
  Widget _buildMetaRow(int? count) {
    return Padding(
      padding: EdgeInsets.fromLTRB(24.w, 4.h, 24.w, 12.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.baseline,
        textBaseline: TextBaseline.alphabetic,
        children: [
          Text(
            '검색결과',
            style: VybeTypography.body3
                .copyWith(color: Colors.white, fontWeight: FontWeight.w700),
          ),
          SizedBox(width: 6.w),
          Text(
            count?.toString() ?? '–',
            style: VybeTypography.body3.copyWith(
                color: VybeColors.mainLime500, fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }
}

// 검색결과 배경 — 공용 리뉴얼 오로라([VybeAurora]).
class _ResultBackdrop extends StatelessWidget {
  const _ResultBackdrop();

  @override
  Widget build(BuildContext context) => const VybeAurora();
}
