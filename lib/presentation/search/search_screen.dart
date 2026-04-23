import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:vybe/data/models/search_history_model.dart';
import 'package:vybe/design_system/colors.dart';
import 'package:vybe/design_system/typography.dart';
import 'package:vybe/presentation/search/viewmodels/search_viewmodel.dart';

// ── 인기 해시태그 더미 데이터 ──
const _popularHashtags = ['힙합', '무료입장', 'EDM', '홍대'];

// ── 인기 검색어 더미 데이터 ──
enum _TrendStatus { up, down, newEntry, same }

class _TrendItem {
  final int rank;
  final String keyword;
  final _TrendStatus status;
  final int? change;
  const _TrendItem({
    required this.rank,
    required this.keyword,
    required this.status,
    this.change,
  });
}

const _trendItems = [
  _TrendItem(rank: 1, keyword: '홍대', status: _TrendStatus.up, change: 3),
  _TrendItem(rank: 2, keyword: '건대', status: _TrendStatus.newEntry),
  _TrendItem(rank: 3, keyword: '강남', status: _TrendStatus.down, change: 2),
  _TrendItem(rank: 4, keyword: '힙합클럽', status: _TrendStatus.newEntry),
  _TrendItem(rank: 5, keyword: '무료입장', status: _TrendStatus.newEntry),
  _TrendItem(rank: 6, keyword: 'EDM', status: _TrendStatus.up, change: 3),
  _TrendItem(rank: 7, keyword: '동성로 핫플', status: _TrendStatus.newEntry),
  _TrendItem(rank: 8, keyword: '레드', status: _TrendStatus.down, change: 2),
  _TrendItem(rank: 9, keyword: '헌포', status: _TrendStatus.same),
  _TrendItem(rank: 10, keyword: '힙합', status: _TrendStatus.same),
];

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  String? get _uid => FirebaseAuth.instance.currentUser?.uid;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: VybeColors.background,
      body: SafeArea(
        bottom: false,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSearchBar(),
              Padding(
                padding: EdgeInsets.fromLTRB(24.w, 24.h, 24.w, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildRecentKeywords(),
                    SizedBox(height: 44.h),
                    _buildPopularHashtags(),
                    SizedBox(height: 44.h),
                    _buildTrendingSearches(),
                    SizedBox(height: 32.h),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── 검색바 ──

  Widget _buildSearchBar() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 10.h),
      child: Container(
        height: 44.h,
        decoration: BoxDecoration(
          color: VybeColors.gray800,
          borderRadius: BorderRadius.circular(999.r),
        ),
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                style: VybeTypography.body4.copyWith(color: VybeColors.gray200),
                decoration: InputDecoration(
                  hintText: '클럽, 지역, 장르 검색',
                  hintStyle: VybeTypography.body4
                      .copyWith(color: VybeColors.gray600),
                  border: InputBorder.none,
                  isDense: true,
                  contentPadding: EdgeInsets.zero,
                ),
              ),
            ),
            SvgPicture.asset(
              'assets/icons/search_screen/search.svg',
              width: 18.r,
              height: 18.r,
            ),
          ],
        ),
      ),
    );
  }

  // ── 최근 검색어 ──

  Widget _buildRecentKeywords() {
    final uid = _uid;

    // 로그인 안 된 경우 섹션 숨김
    if (uid == null) return const SizedBox.shrink();

    final historyAsync = ref.watch(searchHistoryProvider(uid));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '최근 검색어',
              style: VybeTypography.heading4
                  .copyWith(color: VybeColors.gray200),
            ),
            historyAsync.maybeWhen(
              data: (list) => list.isEmpty
                  ? const SizedBox.shrink()
                  : GestureDetector(
                      onTap: () => ref
                          .read(searchViewModelProvider.notifier)
                          .clearHistory(uid),
                      child: Text(
                        '전체 삭제',
                        style: VybeTypography.caption
                            .copyWith(color: VybeColors.gray200),
                      ),
                    ),
              orElse: () => const SizedBox.shrink(),
            ),
          ],
        ),
        SizedBox(height: 24.h),
        historyAsync.when(
          loading: () => const Center(
            child: SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: VybeColors.mainLime500,
              ),
            ),
          ),
          error: (_, __) => const SizedBox.shrink(),
          data: (list) {
            if (list.isEmpty) {
              return Text(
                '최근 검색어가 없습니다',
                style: VybeTypography.body4
                    .copyWith(color: VybeColors.gray600),
              );
            }
            return Wrap(
              spacing: 8.w,
              runSpacing: 8.h,
              children: list
                  .map((item) => _KeywordChip(
                        item: item,
                        onDelete: () => ref
                            .read(searchViewModelProvider.notifier)
                            .deleteHistory(uid, item.historyId),
                      ))
                  .toList(),
            );
          },
        ),
      ],
    );
  }

  // ── 인기 해시태그 추천 ──

  Widget _buildPopularHashtags() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '인기 해시태그 추천',
          style: VybeTypography.heading4.copyWith(color: VybeColors.gray200),
        ),
        SizedBox(height: 24.h),
        Wrap(
          spacing: 8.w,
          runSpacing: 8.h,
          children:
              _popularHashtags.map((tag) => _HashtagChip(label: tag)).toList(),
        ),
      ],
    );
  }

  // ── 인기 검색어 ──

  Widget _buildTrendingSearches() {
    final left = _trendItems.sublist(0, 5);
    final right = _trendItems.sublist(5, 10);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '인기 검색어',
              style: VybeTypography.heading4
                  .copyWith(color: VybeColors.gray200),
            ),
            Text(
              '05.18 20:00 기준',
              style:
                  VybeTypography.caption.copyWith(color: VybeColors.gray200),
            ),
          ],
        ),
        SizedBox(height: 24.h),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                children: List.generate(
                  left.length,
                  (i) => Padding(
                    padding:
                        EdgeInsets.only(bottom: i < left.length - 1 ? 16.h : 0),
                    child: _TrendRow(item: left[i]),
                  ),
                ),
              ),
            ),
            SizedBox(width: 24.w),
            Expanded(
              child: Column(
                children: List.generate(
                  right.length,
                  (i) => Padding(
                    padding: EdgeInsets.only(
                        bottom: i < right.length - 1 ? 16.h : 0),
                    child: _TrendRow(item: right[i]),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

// ── 최근 검색어 칩 ──

class _KeywordChip extends StatelessWidget {
  final SearchHistoryModel item;
  final VoidCallback onDelete;
  const _KeywordChip({required this.item, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 24.h,
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: VybeColors.gray900,
        borderRadius: BorderRadius.circular(999.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            item.keyword,
            style: VybeTypography.body4.copyWith(color: VybeColors.gray400),
          ),
          SizedBox(width: 8.w),
          GestureDetector(
            onTap: onDelete,
            child: SvgPicture.asset(
              'assets/icons/search_screen/delete_search_history.svg',
              width: 9.r,
              height: 9.r,
            ),
          ),
        ],
      ),
    );
  }
}

// ── 해시태그 칩 ──

class _HashtagChip extends StatelessWidget {
  final String label;
  const _HashtagChip({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 24.h,
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: VybeColors.gray900,
        borderRadius: BorderRadius.circular(999.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '# ',
            style:
                VybeTypography.body4.copyWith(color: VybeColors.mainLime500),
          ),
          Text(
            label,
            style: VybeTypography.body4.copyWith(color: VybeColors.gray400),
          ),
        ],
      ),
    );
  }
}

// ── 인기 검색어 행 ──

class _TrendRow extends StatelessWidget {
  final _TrendItem item;
  const _TrendRow({required this.item});

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
      case _TrendStatus.up:
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
      case _TrendStatus.down:
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
      case _TrendStatus.newEntry:
        return Text(
          'N',
          style: numStyle.copyWith(color: VybeColors.accentRed500),
        );
      case _TrendStatus.same:
        return Text('—', style: numStyle);
    }
  }
}
