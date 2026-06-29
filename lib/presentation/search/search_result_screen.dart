import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
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

    // 메타 행에 표시할 (필터/정렬 적용 후) 결과 수. 로딩 중엔 null.
    final int? count = resultsAsync.maybeWhen(
      data: (results) {
        final clubs = results.clubs
            .where((c) =>
                clubMatchesFilters(c, filters, favoritedIds: favoritedIds))
            .toList();
        return sortClubs(clubs, sort).length;
      },
      orElse: () => null,
    );

    return Scaffold(
      backgroundColor: VybeColors.background,
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
                      padding: EdgeInsets.only(top: 4.h),
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
        ],
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

// 검색결과 배경 — 보라/녹색 radial glow + 다크 베이스 (search_results_v2 backdrop).
class _ResultBackdrop extends StatelessWidget {
  const _ResultBackdrop();

  static const _purple = Color(0xFF7731FE); // 119,49,254
  static const _lime = Color(0xFFB5FF60); // 181,255,96

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      // linear-gradient(180deg, #14101f → #101013 → #0d0a0c).
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF14101F), Color(0xFF101013), Color(0xFF0D0A0C)],
          stops: [0.0, 0.4, 1.0],
        ),
      ),
      child: Stack(
        children: [
          // 좌상단 보라 glow.
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: 240.h,
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: const Alignment(-0.85, -1),
                  radius: 1.1,
                  colors: [_purple.withValues(alpha: 0.24), Colors.transparent],
                  stops: const [0.0, 0.6],
                ),
              ),
            ),
          ),
          // 우상단 라임 glow.
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: 260.h,
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: const Alignment(1, -0.92),
                  radius: 1.0,
                  colors: [_lime.withValues(alpha: 0.12), Colors.transparent],
                  stops: const [0.0, 0.62],
                ),
              ),
            ),
          ),
          // 우하단 보라 glow.
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            height: 360.h,
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: const Alignment(0.85, 1),
                  radius: 1.1,
                  colors: [_purple.withValues(alpha: 0.12), Colors.transparent],
                  stops: const [0.0, 0.66],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
