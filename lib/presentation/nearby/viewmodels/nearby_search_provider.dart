import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:vybe/data/models/club_model.dart';
import 'package:vybe/data/repositories/club_repository_impl.dart';
import 'package:vybe/data/repositories/search_history_repository_impl.dart';
import 'package:vybe/presentation/search/viewmodels/search_viewmodel.dart';

part 'nearby_search_provider.g.dart';

/// 주변 지도에 띄울 검색 결과. null이면 일반 주변 클럽(geo) 모드.
/// 값이 있으면 지도는 geo 핀 대신 검색결과 핀을 표시한다.
class NearbySearchResult {
  final String keyword;
  final List<ClubModel> clubs;

  const NearbySearchResult({required this.keyword, required this.clubs});
}

@riverpod
class NearbySearchResultNotifier extends _$NearbySearchResultNotifier {
  // 지도 핀용은 페이지네이션 없이 한 번에 넉넉히 가져온다.
  static const int _pageSize = 50;

  @override
  NearbySearchResult? build() => null;

  /// 검색어로 클럽 조회 → 지도 핀 표시 + 검색기록 저장.
  Future<void> search(String keyword, {String? userId}) async {
    final q = keyword.trim();
    if (q.isEmpty) return;

    final page = await ref
        .read(clubRepositoryProvider)
        .searchClubsPage(q, pageSize: _pageSize);
    state = NearbySearchResult(keyword: q, clubs: page.clubs);

    // 검색 기록 저장은 부가기능 — 실패해도 무시.
    if (userId != null) {
      try {
        await ref
            .read(searchHistoryRepositoryProvider)
            .addSearchHistory(userId, q);
        if (ref.mounted) ref.invalidate(searchHistoryProvider(userId));
      } catch (_) {
        // ignore
      }
    }
  }

  /// 검색 모드 해제 → geo 핀으로 복귀.
  void clear() => state = null;
}
