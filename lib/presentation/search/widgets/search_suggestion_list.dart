import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vybe/presentation/search/viewmodels/search_viewmodel.dart';
import 'package:vybe/presentation/search/widgets/search_suggestion_item.dart';

/// 검색어 입력 중 뜨는 연관 클럽 목록.
///
/// 로딩 중이거나(첫 입력) 결과가 없으면 빈 화면 — 자리만 차지하는 스켈레톤 대신
/// 아무것도 안 그린다.
class SearchSuggestionList extends ConsumerWidget {
  /// 지금 입력된 검색어 (일치 구간 강조에 쓴다).
  final String query;

  /// 항목 탭 → 클럽 상세로 직행.
  final ValueChanged<String> onSelectClub;

  const SearchSuggestionList({
    super.key,
    required this.query,
    required this.onSelectClub,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final clubs = ref.watch(searchSuggestionViewModelProvider).clubs;
    if (clubs.isEmpty) return const SizedBox.shrink();

    return ListView.builder(
      padding: EdgeInsets.zero,
      itemCount: clubs.length,
      itemBuilder: (_, i) => SearchSuggestionItem(
        keyword: clubs[i].name,
        query: query,
        onTap: () => onSelectClub(clubs[i].clubId),
      ),
    );
  }
}
