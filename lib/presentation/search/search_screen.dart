import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vybe/core/providers/auth_providers.dart';
import 'package:vybe/data/models/search_hashtag_model.dart';
import 'package:vybe/data/models/search_history_model.dart';
import 'package:vybe/data/models/search_trend_model.dart';
import 'package:vybe/design_system/colors.dart';
import 'package:vybe/design_system/typography.dart';
import 'package:vybe/presentation/clubs/club_detail_route.dart';
import 'package:vybe/presentation/common/widgets/ambient_backdrop.dart';
import 'package:vybe/presentation/common/widgets/vybe_toast.dart';
import 'package:vybe/presentation/free_entry/free_entry_screen.dart';
import 'package:vybe/presentation/hip_hop/hip_hop_screen.dart';
import 'package:vybe/presentation/hot_places/hot_places_screen.dart';
import 'package:vybe/presentation/recommend/vybe_recommend_screen.dart';
import 'package:vybe/presentation/search/search_result_screen.dart';
import 'package:vybe/presentation/search/viewmodels/search_trend_viewmodel.dart';
import 'package:vybe/presentation/search/viewmodels/search_viewmodel.dart';
import 'package:vybe/presentation/search/widgets/hashtag_chip.dart';
import 'package:vybe/presentation/search/widgets/keyword_chip.dart';
import 'package:vybe/presentation/search/widgets/search_bar.dart';
import 'package:vybe/presentation/search/widgets/search_suggestion_item.dart';
import 'package:vybe/presentation/search/widgets/trend_row.dart';
import 'package:vybe/presentation/service_drinks/service_drinks_screen.dart';

// 해시태그 노출 개수. 문서는 이보다 많이 두고 상위 N개만 보여준다.
const _kHashtagCount = 8;

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
            child: IgnorePointer(
              child: AmbientBackdrop(gradientStops: [0.0, 0.30, 1.0]),
            ),
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

  void _navigateToResult(
    String query, {
    SearchSource source = SearchSource.input,
  }) {
    final q = query.trim();
    if (q.isEmpty) return;
    // 지도 모드: 결과를 핀으로 띄우기 위해 콜백 호출 후 pop.
    // SearchResultScreen을 거치지 않으므로 검색 로그는 여기서 직접 남긴다.
    if (widget.onMapResult != null) {
      _logSearch(q, source);
      _focusNode.unfocus();
      widget.onMapResult!(q);
      Navigator.of(context).pop();
      return;
    }
    Navigator.of(context)
        .push(_fadeRoute(SearchResultScreen(query: q, source: source)))
        .then((_) => _restoreQuery(q));
  }

  // 클럽 제안 탭 → 해당 클럽 상세로. 돌아오면 입력 상태 그대로 복원.
  void _openClub(String clubId) {
    // 지도 모드: 클럽 제안 탭 → 그 클럽명으로 검색해 핀 표시.
    if (widget.onMapResult != null) {
      final clubs = ref.read(searchSuggestionViewModelProvider).value ?? const [];
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

  void _logSearch(String keyword, SearchSource source) {
    final uid = ref.read(currentUidProvider);
    if (uid == null) return;
    ref
        .read(searchViewModelProvider.notifier)
        .logSearch(userId: uid, keyword: keyword, source: source);
  }

  // 해시태그 탭 → 검색어 또는 전용 화면.
  void _openHashtag(SearchHashtagModel tag) {
    if (tag.linkType == HashtagLinkType.keyword) {
      _navigateToResult(tag.linkValue, source: SearchSource.hashtag);
      return;
    }

    final Widget? page = switch (tag.linkValue) {
      'freeEntry' => const FreeEntryScreen(),
      'serviceDrinks' => const ServiceDrinksScreen(),
      'hipHop' => const HipHopScreen(),
      'hotPlaces' => const HotPlacesScreen(),
      'vybeRecommend' => const VybeRecommendScreen(),
      _ => null,
    };
    // 알 수 없는 page 키 → 라벨로 검색해서라도 빈 손으로 돌려보내지 않는다.
    if (page == null) {
      _navigateToResult(tag.label, source: SearchSource.hashtag);
      return;
    }
    _logSearch(tag.label, SearchSource.hashtag);
    Navigator.of(context).push(_fadeRoute(page));
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
    // 데이터가 없는 섹션은 통째로 숨는다 → 사이 여백도 같이 빠져야 하므로
    // 보이는 섹션만 모아서 간격을 넣는다.
    final sections = <Widget>[
      _buildRecentKeywords(historyAsync),
      _buildPopularHashtags(),
      _buildTrendingSearches(),
    ].where((w) => w is! SizedBox).toList();

    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.fromLTRB(24.w, 8.h, 24.w, 28.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (var i = 0; i < sections.length; i++) ...[
              if (i > 0) SizedBox(height: 30.h),
              sections[i],
            ],
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

  /// 최근 검색어 전체 삭제 (users/{uid}/searchHistory batch delete) → 하단 토스트.
  /// 연타로 중복 요청되지 않게 진행 중엔 무시한다.
  bool _clearingHistory = false;

  Future<void> _clearAllHistory(String uid) async {
    if (_clearingHistory) return;
    _clearingHistory = true;
    final ok =
        await ref.read(searchViewModelProvider.notifier).clearHistory(uid);
    _clearingHistory = false;
    if (!mounted) return;
    VybeToast.show(
      context,
      message: ok ? '최근 검색어가 모두 삭제되었습니다' : '삭제에 실패했어요. 잠시 후 다시 시도해주세요',
      isError: !ok,
    );
  }

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
                    onTap: () => _clearAllHistory(uid),
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
          loading: () => Center(
            child: SizedBox(
              width: 20.r,
              height: 20.r,
              child: const CircularProgressIndicator(
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
                        onTap: () => _navigateToResult(item.keyword,
                            source: SearchSource.history),
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
    final tags = ref.watch(popularHashtagsProvider).value ?? const [];
    // 로딩·실패·빈 목록이면 섹션 자체를 숨긴다 (자리만 차지하는 스켈레톤 대신).
    if (tags.isEmpty) return const SizedBox.shrink();

    // 문서는 8개보다 많이 두고 상위 8개만 노출 — 검색량에 따라 실제로 순서가 바뀐다.
    final visible = tags.take(_kHashtagCount).toList();

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
          children: visible
              .map((tag) => HashtagChip(
                    label: tag.label,
                    onTap: () => _openHashtag(tag),
                  ))
              .toList(),
        ),
      ],
    );
  }

  // ── 실시간 인기 검색어 ──

  Widget _buildTrendingSearches() {
    final snapshot =
        ref.watch(searchTrendsProvider).value ?? SearchTrendSnapshot.empty;
    final items = snapshot.items;
    if (items.isEmpty) return const SizedBox.shrink();

    // 좌우 2열. 홀수여도 왼쪽이 한 칸 더 많게 나눈다.
    final split = (items.length / 2).ceil();
    final left = items.sublist(0, split);
    final right = items.sublist(split);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionHead(
          icon: Icon(Icons.local_fire_department_rounded,
              size: 16.r, color: VybeColors.mainLime500),
          // 실검색 데이터가 하나도 없으면 '실시간'이라고 하지 않는다.
          title: snapshot.isLive ? '실시간 인기 검색어' : '인기 검색어',
          right: snapshot.updatedAt == null
              ? null
              : Text(
                  '${_formatUpdatedAt(snapshot.updatedAt!)} 기준',
                  style: VybeTypography.caption
                      .copyWith(color: VybeColors.gray600),
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
              Expanded(child: _trendColumn(left)),
              Container(
                width: 1,
                margin: EdgeInsets.symmetric(vertical: 6.h),
                color: VybeColors.gray800,
              ),
              Expanded(child: _trendColumn(right)),
            ],
          ),
        ),
      ],
    );
  }

  // 'MM.dd HH:mm' — 서버 갱신 시각을 그대로 보여준다.
  String _formatUpdatedAt(DateTime dt) {
    final local = dt.toLocal();
    String two(int n) => n.toString().padLeft(2, '0');
    return '${two(local.month)}.${two(local.day)} '
        '${two(local.hour)}:${two(local.minute)}';
  }

  Widget _trendColumn(List<SearchTrendItem> items) {
    return Column(
      children: items
          .map((it) => TrendRow(
                item: it,
                onTap: () =>
                    _navigateToResult(it.keyword, source: SearchSource.trend),
              ))
          .toList(),
    );
  }
}
