import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vybe/core/providers/auth_providers.dart';
import 'package:vybe/presentation/clubs/club_detail_screen.dart';
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
  /// 외부(MainScaffold)에서 탭 재진입 시 포커스를 주기 위해 주입.
  /// null이면 내부에서 생성.
  final FocusNode? focusNode;

  const SearchScreen({super.key, this.focusNode});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  late final TextEditingController _controller;
  late final FocusNode _focusNode;
  String _query = '';
  Timer? _debounce;

  // 연관 검색어: 입력당 서버 폭증 방지 (디바운스 + 최소 글자수).
  static const _kDebounce = Duration(milliseconds: 300);
  static const _kMinChars = 2;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
    _focusNode = widget.focusNode ?? FocusNode();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _controller.dispose();
    // 외부 주입 FocusNode는 소유자(MainScaffold)가 dispose.
    if (widget.focusNode == null) _focusNode.dispose();
    super.dispose();
  }

  void _onQueryChanged(String value) {
    setState(() => _query = value);
    _debounce?.cancel();
    final q = value.trim();
    if (q.length < _kMinChars) {
      ref.read(searchSuggestionViewModelProvider.notifier).clear();
      return;
    }
    _debounce = Timer(_kDebounce, () {
      ref.read(searchSuggestionViewModelProvider.notifier).fetch(q);
    });
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
              autofocus: true,
              onChanged: _onQueryChanged,
              onSubmitted: _navigateToResult,
            ),
            Expanded(
              child: _query.trim().length >= _kMinChars
                  ? _buildSuggestionList()
                  : _buildDefaultContent(historyAsync),
            ),
          ],
        ),
      ),
    );
  }

  void _navigateToResult(String query) {
    final q = query.trim();
    if (q.isEmpty) return;
    Navigator.of(context)
        .push(_fadeRoute(SearchResultScreen(query: q)))
        .then((_) => _restoreQuery(q));
  }

  // 클럽 제안 탭 → 해당 클럽 상세로. 돌아오면 입력 상태 그대로 복원.
  void _openClub(String clubId) {
    final q = _query.trim();
    Navigator.of(context)
        .push(_fadeRoute(ClubDetailScreen(clubId: clubId)))
        .then((_) => _restoreQuery(q));
  }

  // 결과/상세에서 돌아오면 검색어를 그대로 유지한 채 입력 상태로 복원
  // (지우지 않음) → 검색창 탭 시 끊김 없이 연관 검색어 + 키보드 노출.
  void _restoreQuery(String q) {
    if (!mounted) return;
    if (q.isEmpty) {
      _controller.clear();
      ref.read(searchSuggestionViewModelProvider.notifier).clear();
      setState(() => _query = '');
    } else {
      _controller.text = q;
      _controller.selection = TextSelection.collapsed(offset: q.length);
      setState(() => _query = q);
      ref.read(searchSuggestionViewModelProvider.notifier).fetch(q);
    }
    _focusNode.requestFocus();
  }

  // 페이드 전환 — 기본 슬라이드보다 검색 흐름에 자연스럽다.
  PageRoute<T> _fadeRoute<T>(Widget page) {
    return PageRouteBuilder<T>(
      transitionDuration: const Duration(milliseconds: 200),
      reverseTransitionDuration: const Duration(milliseconds: 200),
      pageBuilder: (_, __, ___) => page,
      transitionsBuilder: (_, anim, __, child) =>
          FadeTransition(opacity: anim, child: child),
    );
  }

  Widget _buildSuggestionList() {
    final async = ref.watch(searchSuggestionViewModelProvider);
    final clubs = async.value ?? const [];
    if (clubs.isEmpty) {
      // 로딩 중이거나(첫 입력) 결과 없음 → 빈 화면.
      return const SizedBox.shrink();
    }
    return ListView.builder(
      padding: EdgeInsets.zero,
      itemCount: clubs.length,
      itemBuilder: (_, i) => SearchSuggestionItem(
        keyword: clubs[i].name,
        query: _query.trim(),
        onTap: () => _openClub(clubs[i].clubId),
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
                        onTap: () => _navigateToResult(item.keyword),
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
