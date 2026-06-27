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
const _popularHashtags = ['힙합', '무료입장', 'EDM', '홍대', '이태원', '테크노', '서비스음료', 'K-POP'];

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

  /// true이면 검색창 왼쪽에 뒤로가기 화살표 노출 (push로 띄운 경우, 예: 주변 페이지).
  final bool showBackButton;

  /// 지도 모드: 값이 있으면 검색 제출 시 결과 화면으로 push하지 않고
  /// 이 콜백(검색어)을 호출한 뒤 pop한다 (주변 지도에 핀으로 표시).
  final ValueChanged<String>? onMapResult;

  const SearchScreen({
    super.key,
    this.focusNode,
    this.showBackButton = false,
    this.onMapResult,
  });

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
      body: Stack(
        children: [
          // 앰비언트 클럽 조명 백드롭
          const Positioned.fill(
            child: IgnorePointer(child: _AmbientBackdrop()),
          ),
          GestureDetector(
            // 검색창 밖 탭 시 키보드 닫기
            onTap: () => FocusScope.of(context).unfocus(),
            behavior: HitTestBehavior.translucent,
            child: SafeArea(
              bottom: false,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SearchInputBar(
                    controller: _controller,
                    focusNode: _focusNode,
                    autofocus: false,
                    onChanged: _onQueryChanged,
                    onSubmitted: _navigateToResult,
                    onBack: widget.showBackButton
                        ? () => Navigator.of(context).pop()
                        : null,
                  ),
                  Expanded(
                    child: _query.trim().length >= _kMinChars
                        ? _buildSuggestionList()
                        : _buildDefaultContent(historyAsync),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _navigateToResult(String query) {
    final q = query.trim();
    if (q.isEmpty) return;
    // 지도 모드: 결과를 핀으로 띄우기 위해 콜백 호출 후 pop.
    if (widget.onMapResult != null) {
      _focusNode.unfocus();
      widget.onMapResult!(q);
      Navigator.of(context).pop();
      return;
    }
    Navigator.of(context)
        .push(_fadeRoute(SearchResultScreen(query: q)))
        .then((_) => _restoreQuery(q));
  }

  // 클럽 제안 탭 → 해당 클럽 상세로. 돌아오면 입력 상태 그대로 복원.
  void _openClub(String clubId) {
    // 지도 모드: 클럽 제안 탭 → 그 클럽명으로 검색해 핀 표시.
    if (widget.onMapResult != null) {
      final clubs = ref.read(searchSuggestionViewModelProvider).value ?? const [];
      final matches = clubs.where((c) => c.clubId == clubId);
      _navigateToResult(matches.isEmpty ? _query.trim() : matches.first.name);
      return;
    }
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
        padding: EdgeInsets.fromLTRB(24.w, 8.h, 24.w, 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildRecentKeywords(historyAsync),
            SizedBox(height: 30.h),
            _buildPopularHashtags(),
            SizedBox(height: 30.h),
            _buildTrendingSearches(),
            SizedBox(height: 28.h),
          ],
        ),
      ),
    );
  }

  // ── 섹션 헤더 (아이콘 + 타이틀 + 우측) ──
  Widget _sectionHead({
    required Widget icon,
    required String title,
    Widget? right,
  }) {
    return Padding(
      padding: EdgeInsets.only(bottom: 16.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              icon,
              SizedBox(width: 7.w),
              Text(
                title,
                style: TextStyle(
                  fontFamily: 'Pretendard',
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                  letterSpacing: 18 * -0.025,
                ),
              ),
            ],
          ),
          if (right != null) right,
        ],
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
        _sectionHead(
          icon: Icon(Icons.access_time_rounded,
              size: 15.r, color: VybeColors.gray300),
          title: '최근 검색어',
          right: historyAsync.maybeWhen(
            data: (list) => list.isEmpty
                ? null
                : GestureDetector(
                    onTap: () => ref
                        .read(searchViewModelProvider.notifier)
                        .clearHistory(uid),
                    child: Text(
                      '전체 삭제',
                      style: VybeTypography.caption
                          .copyWith(color: VybeColors.gray500),
                    ),
                  ),
            orElse: () => null,
          ),
        ),
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
              return Padding(
                padding: EdgeInsets.symmetric(vertical: 20.h),
                child: Center(
                  child: Text(
                    '최근 검색 기록이 없어요',
                    style: VybeTypography.body4
                        .copyWith(color: VybeColors.gray600),
                  ),
                ),
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

  // ── 인기 해시태그 ──

  Widget _buildPopularHashtags() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionHead(
          icon: Text(
            '#',
            style: TextStyle(
              fontFamily: 'Pretendard',
              fontSize: 17.sp,
              fontWeight: FontWeight.w800,
              color: VybeColors.mainLime700,
            ),
          ),
          title: '인기 해시태그',
        ),
        Wrap(
          spacing: 8.w,
          runSpacing: 8.h,
          children: _popularHashtags
              .map((tag) => HashtagChip(
                    label: tag,
                    onTap: () => _navigateToResult(tag),
                  ))
              .toList(),
        ),
      ],
    );
  }

  // ── 실시간 인기 검색어 ──

  Widget _buildTrendingSearches() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionHead(
          icon: Icon(Icons.local_fire_department_rounded,
              size: 16.r, color: VybeColors.mainLime500),
          title: '실시간 인기 검색어',
          right: Text(
            '06.27 22:00 기준',
            style: VybeTypography.caption.copyWith(color: VybeColors.gray600),
          ),
        ),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 6.h),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.white.withValues(alpha: 0.05),
                Colors.white.withValues(alpha: 0.015),
              ],
            ),
            border: Border.all(color: VybeColors.gray800),
            borderRadius: BorderRadius.circular(18.r),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: _trendColumn(_trendItems.sublist(0, 5))),
              Container(
                width: 1,
                margin: EdgeInsets.symmetric(vertical: 6.h),
                color: VybeColors.gray800,
              ),
              Expanded(child: _trendColumn(_trendItems.sublist(5, 10))),
            ],
          ),
        ),
      ],
    );
  }

  Widget _trendColumn(List<TrendItem> items) {
    return Column(
      children: items
          .map((it) => TrendRow(
                item: it,
                onTap: () => _navigateToResult(it.keyword),
              ))
          .toList(),
    );
  }
}

class _AmbientBackdrop extends StatelessWidget {
  const _AmbientBackdrop();

  @override
  Widget build(BuildContext context) {
    return const DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF120F1A), Color(0xFF101013), Color(0xFF0E0D12)],
          stops: [0.0, 0.30, 1.0],
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: 420,
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment(-0.9, -1),
                  radius: 1.4,
                  colors: [Color(0x8A7731FE), Color(0x00000000)],
                  stops: [0.0, 0.78],
                ),
              ),
            ),
          ),
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: 420,
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment(1, -0.9),
                  radius: 1.4,
                  colors: [Color(0x4DB5FF60), Color(0x00000000)],
                  stops: [0.0, 0.8],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
