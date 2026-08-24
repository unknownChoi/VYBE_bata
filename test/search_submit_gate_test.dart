import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vybe/core/providers/auth_providers.dart';
import 'package:vybe/data/models/search_hashtag_model.dart';
import 'package:vybe/data/models/search_trend_model.dart';
import 'package:vybe/data/repositories/club_repository_impl.dart';
import 'package:vybe/domain/repositories/club_repository.dart';
import 'package:vybe/presentation/search/search_result_screen.dart';
import 'package:vybe/presentation/search/search_screen.dart';
import 'package:vybe/presentation/search/viewmodels/search_trend_viewmodel.dart';

/// 검색어를 치자마자(엔진 결과가 나오기 전에) 엔터를 누르면 결과가 비던 회귀.
/// 원인은 연관 검색어 조회와 결과 화면 조회가 **동시에** 나가는 것 —
/// 엔터는 엔진 결과가 확정된 뒤에만 결과 화면으로 가야 한다.
class _FakeClubRepository implements ClubRepository {
  /// 검색 응답을 붙잡아 두는 게이트 — '엔진이 아직 안 돌아온' 상태를 만든다.
  final gate = Completer<void>();

  /// searchClubsPage 호출 횟수 — 게이트가 열리기 전엔 1회(연관 검색어)뿐이어야 한다.
  int calls = 0;

  @override
  Future<ClubSearchPage> searchClubsPage(
    String keyword, {
    Object? cursor,
    int pageSize = 10,
  }) async {
    calls++;
    await gate.future;
    return const ClubSearchPage(
      clubs: [],
      cursor: 1,
      hasMore: false,
      totalCount: 0,
    );
  }

  // 이 테스트가 쓰지 않는 나머지 메서드는 호출되면 그대로 실패시킨다.
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

Widget _app(_FakeClubRepository repo) => ProviderScope(
  overrides: [
    clubRepositoryProvider.overrideWithValue(repo),
    // 비로그인 — 최근 검색어·찜이 Firestore를 건드리지 않게 한다.
    currentUidProvider.overrideWithValue(null),
    searchTrendsProvider.overrideWith((ref) async => SearchTrendSnapshot.empty),
    popularHashtagsProvider.overrideWith(
      (ref) async => const <SearchHashtagModel>[],
    ),
  ],
  child: ScreenUtilInit(
    designSize: const Size(393, 852),
    builder: (_, __) => const MaterialApp(home: SearchScreen()),
  ),
);

/// 오로라 배경 등 반복 애니메이션이 있어 pumpAndSettle 대신 정해진 만큼만 돌린다.
Future<void> _settle(WidgetTester tester) async {
  for (var i = 0; i < 6; i++) {
    await tester.pump(const Duration(milliseconds: 300));
  }
}

void main() {
  testWidgets('엔진 결과 전 엔터는 이동하지 않고, 결과가 나온 뒤 이동한다', (tester) async {
    tester.view.physicalSize = const Size(393, 852);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    final repo = _FakeClubRepository();
    await tester.pumpWidget(_app(repo));
    await tester.pump();

    // 검색어 입력 직후(디바운스도 안 끝난 시점)에 엔터.
    await tester.enterText(find.byType(TextField), '홍대');
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pump();

    // 엔진이 아직 안 돌아왔다 → 결과 화면으로 가지 않는다.
    // 조회도 연관 검색어 1건뿐 — 결과 화면 조회가 같이 나가면 안 된다.
    expect(find.byType(SearchResultScreen), findsNothing);
    expect(repo.calls, 1);

    // 엔진 결과 확정 → 대기 중이던 엔터가 이어서 결과 화면으로 보낸다.
    repo.gate.complete();
    await _settle(tester);

    expect(find.byType(SearchResultScreen), findsOneWidget);
    expect(repo.calls, 2);
  });

  testWidgets('엔터 대기 중 검색어를 바꾸면 예전 검색어로 이동하지 않는다', (tester) async {
    tester.view.physicalSize = const Size(393, 852);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    final repo = _FakeClubRepository();
    await tester.pumpWidget(_app(repo));
    await tester.pump();

    await tester.enterText(find.byType(TextField), '홍대');
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pump();

    // 대기 중에 입력을 바꿨다 → 대기 중이던 엔터는 무효.
    await tester.enterText(find.byType(TextField), '강남');
    repo.gate.complete();
    await _settle(tester);

    expect(find.byType(SearchResultScreen), findsNothing);
  });
}
