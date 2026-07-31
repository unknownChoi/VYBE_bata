import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vybe/data/models/search_history_model.dart';
import 'package:vybe/data/repositories/search_history_repository_impl.dart';
import 'package:vybe/domain/repositories/search_history_repository.dart';
import 'package:vybe/presentation/search/viewmodels/search_viewmodel.dart';

/// 검색 화면은 SearchViewModel을 watch하지 않고 read로만 호출한다(= 리스너 없음).
/// autoDispose가 await 사이에 VM을 버리면 삭제 후 searchHistoryProvider invalidate가
/// 실행되지 않아 Firestore에선 지워졌는데 화면 칩은 남는다. 그 회귀를 막는 테스트.
class _FakeSearchHistoryRepository implements SearchHistoryRepository {
  List<SearchHistoryModel> items;

  /// 삭제를 붙잡아 두는 게이트 — 통신 지연(프레임 경과)을 흉내낸다.
  Future<void>? gate;

  _FakeSearchHistoryRepository(this.items);

  @override
  Future<List<SearchHistoryModel>> getSearchHistory(String userId) async =>
      items;

  @override
  Future<void> addSearchHistory(String userId, String keyword) async {}

  @override
  Future<void> deleteSearchHistory(String userId, String historyId) async {
    items = items.where((e) => e.historyId != historyId).toList();
  }

  @override
  Future<void> clearAllSearchHistory(String userId) async {
    if (gate != null) await gate;
    items = [];
  }
}

SearchHistoryModel _item(String id, String keyword) => SearchHistoryModel(
      historyId: id,
      userId: 'u1',
      keyword: keyword,
      createdAt: DateTime(2026, 7, 31),
    );

void main() {
  late _FakeSearchHistoryRepository repo;
  late ProviderContainer container;

  setUp(() {
    repo = _FakeSearchHistoryRepository([_item('h1', '홍대'), _item('h2', '강남')]);
    container = ProviderContainer(
      overrides: [searchHistoryRepositoryProvider.overrideWith((ref) => repo)],
    );
    addTearDown(container.dispose);
  });

  test('전체 삭제 후 최근 검색어 목록이 즉시 비워진다', () async {
    // 화면이 목록을 watch 중인 상황.
    container.listen(searchHistoryProvider('u1'), (_, __) {});
    expect(await container.read(searchHistoryProvider('u1').future), hasLength(2));

    // VM은 read로만 호출 (화면과 동일).
    final ok =
        await container.read(searchViewModelProvider.notifier).clearHistory('u1');

    expect(ok, isTrue);
    expect(await container.read(searchHistoryProvider('u1').future), isEmpty);
  });

  test('삭제가 프레임을 넘겨 VM이 autoDispose돼도 목록이 갱신된다', () async {
    container.listen(searchHistoryProvider('u1'), (_, __) {});
    expect(await container.read(searchHistoryProvider('u1').future), hasLength(2));

    // 삭제를 붙잡아 둔 사이 스케줄러를 돌린다 = 리스너 없는 VM이 폐기되는 시점.
    final gate = Completer<void>();
    repo.gate = gate.future;
    final pending =
        container.read(searchViewModelProvider.notifier).clearHistory('u1');
    await container.pump();
    gate.complete();

    expect(await pending, isTrue);
    expect(await container.read(searchHistoryProvider('u1').future), isEmpty);
  });

  test('개별 삭제 후 해당 검색어만 목록에서 사라진다', () async {
    container.listen(searchHistoryProvider('u1'), (_, __) {});
    expect(await container.read(searchHistoryProvider('u1').future), hasLength(2));

    await container
        .read(searchViewModelProvider.notifier)
        .deleteHistory('u1', 'h1');

    final after = await container.read(searchHistoryProvider('u1').future);
    expect(after.map((e) => e.keyword), ['강남']);
  });
}
