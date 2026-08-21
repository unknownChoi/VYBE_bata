import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vybe/core/providers/auth_providers.dart';
import 'package:vybe/data/models/search_hashtag_model.dart';
import 'package:vybe/data/models/search_history_model.dart';
import 'package:vybe/data/models/search_trend_model.dart';
import 'package:vybe/design_system/colors.dart';
import 'package:vybe/presentation/clubs/club_detail_route.dart';
import 'package:vybe/presentation/common/widgets/vybe_aurora.dart';
import 'package:vybe/presentation/common/widgets/vybe_toast.dart';
import 'package:vybe/presentation/search/search_navigation.dart';
import 'package:vybe/presentation/search/search_result_screen.dart';
import 'package:vybe/presentation/search/viewmodels/search_trend_viewmodel.dart';
import 'package:vybe/presentation/search/viewmodels/search_viewmodel.dart';
import 'package:vybe/presentation/search/widgets/popular_hashtags_section.dart';
import 'package:vybe/presentation/search/widgets/recent_keywords_section.dart';
import 'package:vybe/presentation/search/widgets/search_bar.dart';
import 'package:vybe/presentation/search/widgets/search_suggestion_item.dart';
import 'package:vybe/presentation/search/widgets/trending_searches_section.dart';

/// 해시태그 노출 개수. 문서는 이보다 많이 두고 상위 N개만 보여준다.
const int _kHashtagCount = 8;

/// 연관 검색어: 입력당 서버 폭증 방지 (디바운스 + 최소 글자수).
const Duration _kDebounce = Duration(milliseconds: 300);
const int _kMinChars = 2;

/// 섹션 사이 간격. 숨은 섹션의 간격까지 같이 빠져야 해서 사이에만 넣는다.
const double _kSectionGap = 30;

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

  /// 최근 검색어 전체 삭제 진행 중 — 연타로 중복 요청되지 않게 막는다.
  bool _clearingHistory = false;

  bool get _isMapMode => widget.onMapResult != null;
  bool get _hasQuery => _query.trim().length >= _kMinChars;

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
    _debounce = Timer(
      _kDebounce,
      () => ref.read(searchSuggestionViewModelProvider.notifier).fetch(q),
    );
  }

  // ------------------------------------------------------------------ 이동

  void _navigateToResult(
    String query, {
    SearchSource source = SearchSource.input,
  }) {
    final q = query.trim();
    if (q.isEmpty) return;
    // 지도 모드: 결과를 핀으로 띄우기 위해 콜백 호출 후 pop.
    // SearchResultScreen을 거치지 않으므로 검색 로그는 여기서 직접 남긴다.
    if (_isMapMode) {
      _logSearch(q, source);
      _focusNode.unfocus();
      widget.onMapResult!(q);
      Navigator.of(context).pop();
      return;
    }
    Navigator.of(context)
        .push(searchFadeRoute(SearchResultScreen(query: q, source: source)))
        .then((_) => _restoreQuery(q));
  }

  /// 클럽 제안 탭 → 해당 클럽 상세로. 돌아오면 입력 상태 그대로 복원.
  void _openClub(String clubId) {
    // 지도 모드: 클럽 제안 탭 → 그 클럽명으로 검색해 핀 표시.
    if (_isMapMode) {
      final clubs =
          ref.read(searchSuggestionViewModelProvider).value ?? const [];
      final matches = clubs.where((c) => c.clubId == clubId);
      _navigateToResult(
        matches.isEmpty ? _query.trim() : matches.first.name,
        source: SearchSource.suggestion,
      );
      return;
    }
    final q = _query.trim();
    // 직접 입력한 검색어로 클럽을 골랐다 = 가장 신뢰도 높은 검색 신호.
    // 결과 화면을 거치지 않으므로 여기서 로그를 남긴다.
    _logSearch(q, SearchSource.suggestion);
    // 상세는 다른 진입점과 같은 스와이프백 전환으로 통일한다(fade 아님) —
    // 하단 nav를 내려야 해서 openClubDetail 한 곳을 거친다.
    openClubDetail(context, clubId).then((_) => _restoreQuery(q));
  }

  /// 해시태그 탭 → 검색어 또는 전용 화면.
  void _openHashtag(SearchHashtagModel tag) {
    if (tag.linkType == HashtagLinkType.keyword) {
      _navigateToResult(tag.linkValue, source: SearchSource.hashtag);
      return;
    }
    final page = hashtagPageFor(tag);
    // 알 수 없는 page 키 → 라벨로 검색해서라도 빈 손으로 돌려보내지 않는다.
    if (page == null) {
      _navigateToResult(tag.label, source: SearchSource.hashtag);
      return;
    }
    _logSearch(tag.label, SearchSource.hashtag);
    Navigator.of(context).push(searchFadeRoute(page));
  }

  /// 결과/상세에서 돌아오면 검색어를 그대로 유지한 채 입력 상태로 복원
  /// (지우지 않음) → 검색창 탭 시 끊김 없이 연관 검색어 + 키보드 노출.
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

  // ------------------------------------------------------------------ 기록

  void _logSearch(String keyword, SearchSource source) {
    final uid = ref.read(currentUidProvider);
    if (uid == null) return;
    ref
        .read(searchViewModelProvider.notifier)
        .logSearch(userId: uid, keyword: keyword, source: source);
  }

  /// 최근 검색어 전체 삭제 (users/{uid}/searchHistory batch delete) → 하단 토스트.
  Future<void> _clearAllHistory(String uid) async {
    if (_clearingHistory) return;
    _clearingHistory = true;
    final ok = await ref
        .read(searchViewModelProvider.notifier)
        .clearHistory(uid);
    _clearingHistory = false;
    if (!mounted) return;
    VybeToast.show(
      context,
      message: ok ? '최근 검색어가 모두 삭제되었습니다' : '삭제에 실패했어요. 잠시 후 다시 시도해주세요',
      isError: !ok,
    );
  }

  // ------------------------------------------------------------------ 빌드

  @override
  Widget build(BuildContext context) {
    // 기본 화면 데이터는 검색어를 입력 중이어도 계속 구독한다 —
    // 입력할 때마다 구독을 끊었다 다시 걸면 Firestore 리스너가 껐다 켜진다.
    final sections = _visibleSections();

    return Scaffold(
      backgroundColor: VybeColors.background,
      body: Stack(
        children: [
          // 앰비언트 클럽 조명 백드롭
          const Positioned.fill(child: IgnorePointer(child: VybeAurora())),
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
                    child: _hasQuery
                        ? _buildSuggestionList()
                        : _buildDefaultContent(sections),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSuggestionList() {
    final clubs =
        ref.watch(searchSuggestionViewModelProvider).value ?? const [];
    // 로딩 중이거나(첫 입력) 결과 없음 → 빈 화면.
    if (clubs.isEmpty) return const SizedBox.shrink();

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

  /// 검색어 입력 전 기본 화면 — 최근 검색어 / 인기 해시태그 / 실시간 인기 검색어.
  ///
  /// 데이터가 없는 섹션은 통째로 숨는다 → 사이 여백도 같이 빠지도록
  /// **보이는 섹션만** 모은 뒤 그 사이에만 간격을 넣는다.
  Widget _buildDefaultContent(List<Widget> sections) {
    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.fromLTRB(24.w, 8.h, 24.w, 28.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (var i = 0; i < sections.length; i++) ...[
              if (i > 0) SizedBox(height: _kSectionGap.h),
              sections[i],
            ],
          ],
        ),
      ),
    );
  }

  List<Widget> _visibleSections() {
    final uid = ref.watch(currentUidProvider);
    final AsyncValue<List<SearchHistoryModel>>? historyAsync = uid == null
        ? null
        : ref.watch(searchHistoryProvider(uid));

    // 로딩·실패·빈 목록이면 섹션 자체를 숨긴다 (자리만 차지하는 스켈레톤 대신).
    final tags = ref.watch(popularHashtagsProvider).value ?? const [];
    final trends =
        ref.watch(searchTrendsProvider).value ?? SearchTrendSnapshot.empty;

    return [
      if (uid != null && historyAsync != null)
        RecentKeywordsSection(
          historyAsync: historyAsync,
          onKeyword: (k) =>
              _navigateToResult(k, source: SearchSource.history),
          onDelete: (historyId) => ref
              .read(searchViewModelProvider.notifier)
              .deleteHistory(uid, historyId),
          onClearAll: () => _clearAllHistory(uid),
        ),
      if (tags.isNotEmpty)
        PopularHashtagsSection(
          // 문서는 8개보다 많이 두고 상위 8개만 노출 —
          // 검색량에 따라 실제로 순서가 바뀐다.
          tags: tags.take(_kHashtagCount).toList(),
          onTap: _openHashtag,
        ),
      if (trends.items.isNotEmpty)
        TrendingSearchesSection(
          snapshot: trends,
          onKeyword: (k) => _navigateToResult(k, source: SearchSource.trend),
        ),
    ];
  }
}
