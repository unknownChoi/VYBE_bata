import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vybe/core/providers/auth_providers.dart';
import 'package:vybe/presentation/search/search_result_screen.dart';
import 'package:vybe/data/models/search_history_model.dart';
import 'package:vybe/design_system/colors.dart';
import 'package:vybe/design_system/typography.dart';
import 'package:vybe/presentation/search/viewmodels/search_viewmodel.dart';
import 'package:vybe/presentation/search/widgets/hashtag_chip.dart';
import 'package:vybe/presentation/search/widgets/keyword_chip.dart';
import 'package:vybe/presentation/search/widgets/search_bar.dart';
import 'package:vybe/presentation/search/widgets/search_suggestion_item.dart';
import 'package:vybe/presentation/search/widgets/trend_row.dart';

// ── 검색어 자동완성 더미 데이터 ──
const _suggestionKeywords = [
  '홍대',
  '홍대 클럽 레이저',
  '홍대 클럽',
  '힙합',
  '힙합클럽',
  '헌포',
  '건대',
  '강남',
  '강남 클럽',
  '무료입장',
  'EDM',
  '레이저',
  '레이저 클럽',
  '버뮤다',
  '인클',
  '동성로',
];

// ── 인기 해시태그 더미 데이터 ──
const _popularHashtags = ['힙합', '무료입장', 'EDM', '홍대'];

// ── 인기 검색어 더미 데이터 ──
const _trendItems = [
  TrendItem(rank: 1, keyword: '홍대', status: TrendStatus.up, change: 3),
  TrendItem(rank: 2, keyword: '건대', status: TrendStatus.newEntry),
  TrendItem(rank: 3, keyword: '강남', status: TrendStatus.down, change: 2),
  TrendItem(rank: 4, keyword: '힙합클럽', status: TrendStatus.newEntry),
  TrendItem(rank: 5, keyword: '무료입장', status: TrendStatus.newEntry),
  TrendItem(rank: 6, keyword: 'EDM', status: TrendStatus.up, change: 3),
  TrendItem(rank: 7, keyword: '동성로 핫플', status: TrendStatus.newEntry),
  TrendItem(rank: 8, keyword: '레드', status: TrendStatus.down, change: 2),
  TrendItem(rank: 9, keyword: '헌포', status: TrendStatus.same),
  TrendItem(rank: 10, keyword: '힙합', status: TrendStatus.same),
];

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  late final TextEditingController _controller;
  late final FocusNode _focusNode;
  String _query = '';

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
    _focusNode = FocusNode();
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  List<String> get _filteredSuggestions {
    if (_query.isEmpty) return [];
    final lower = _query.toLowerCase();
    return _suggestionKeywords
        .where((k) => k.toLowerCase().startsWith(lower))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final uid = ref.watch(currentUidProvider);
    final AsyncValue<List<SearchHistoryModel>>? historyAsync =
        uid != null ? ref.watch(searchHistoryProvider(uid)) : null;

    return Scaffold(
      backgroundColor: VybeColors.background,
      body: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SearchInputBar(
              controller: _controller,
              focusNode: _focusNode,
              onChanged: (value) => setState(() => _query = value),
              onSubmitted: _navigateToResult,
            ),
            Expanded(
              child: _query.isNotEmpty
                  ? _buildSuggestionList()
                  : _buildDefaultContent(historyAsync),
            ),
          ],
        ),
      ),
    );
  }

  void _navigateToResult(String query) {
    if (query.trim().isEmpty) return;
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => SearchResultScreen(query: query),
      ),
    );
  }

  Widget _buildSuggestionList() {
    final suggestions = _filteredSuggestions;
    if (suggestions.isEmpty) return const SizedBox.shrink();
    return ListView.builder(
      padding: EdgeInsets.zero,
      itemCount: suggestions.length,
      itemBuilder: (_, i) => SearchSuggestionItem(
        keyword: suggestions[i],
        query: _query,
        onTap: () => _navigateToResult(suggestions[i]),
      ),
    );
  }

  Widget _buildDefaultContent(AsyncValue<List<SearchHistoryModel>>? historyAsync) {
    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.fromLTRB(24.w, 24.h, 24.w, 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildRecentKeywords(historyAsync),
            SizedBox(height: 44.h),
            _buildPopularHashtags(),
            SizedBox(height: 44.h),
            _buildTrendingSearches(),
            SizedBox(height: 32.h),
          ],
        ),
      ),
    );
  }

  // ── 최근 검색어 ──

  Widget _buildRecentKeywords(AsyncValue<List<SearchHistoryModel>>? historyAsync) {
    final uid = ref.read(currentUidProvider);

    if (uid == null || historyAsync == null) return const SizedBox.shrink();

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
                  .map((item) => KeywordChip(
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
          children: _popularHashtags
              .map((tag) => HashtagChip(label: tag))
              .toList(),
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
              style: VybeTypography.caption
                  .copyWith(color: VybeColors.gray200),
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
                    padding: EdgeInsets.only(
                        bottom: i < left.length - 1 ? 16.h : 0),
                    child: TrendRow(item: left[i]),
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
                    child: TrendRow(item: right[i]),
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
