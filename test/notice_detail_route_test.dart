import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vybe/data/models/notice_model.dart';
import 'package:vybe/presentation/my_page/notice_detail_route.dart';
import 'package:vybe/presentation/my_page/viewmodels/notice_viewmodel.dart';

// 배너 → 공지 상세 진입 (noticeId만 들고 들어오는 경로).

const _id = 'notice_ad_free_entry';

final _notice = NoticeModel(
  noticeId: _id,
  title: '목요일은 프리 엔트리',
  content: '매주 목요일 제휴 클럽 42곳에서 진행합니다.',
  imageUrls: const ['https://example.com/banner.jpg'],
  category: 'event',
  publishedAt: DateTime(2026, 8, 24),
  createdAt: DateTime(2026, 8, 24),
  updatedAt: DateTime(2026, 8, 24),
);

/// [found] 이 null 이면 '없는 공지' 경로.
Future<void> _boot(WidgetTester tester, NoticeModel? found) async {
  tester.view.physicalSize = const Size(393, 852);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        noticeProvider(_id).overrideWith((ref) async => found),
        // 이전/다음 글 줄이 보는 목록.
        noticesProvider.overrideWith(
          (ref) async => found == null ? const <NoticeModel>[] : [found],
        ),
      ],
      child: ScreenUtilInit(
        designSize: const Size(393, 852),
        builder: (_, __) =>
            const MaterialApp(home: NoticeDetailById(noticeId: _id)),
      ),
    ),
  );
  await tester.pump(const Duration(milliseconds: 200));
}

void main() {
  testWidgets('noticeId로 조회한 공지가 상세로 그려진다', (tester) async {
    await _boot(tester, _notice);

    expect(find.text('목요일은 프리 엔트리'), findsOneWidget);
    expect(find.text('이벤트'), findsOneWidget);
  });

  testWidgets('없는 공지(게시 종료·중단 포함)는 안내 문구를 보여준다', (tester) async {
    await _boot(tester, null);

    expect(find.text('종료되었거나 찾을 수 없는 공지예요'), findsOneWidget);
  });
}
