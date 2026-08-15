import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vybe/data/models/review_model.dart';
import 'package:vybe/presentation/common/renew/renew_glass.dart';
import 'package:vybe/presentation/common/renew/renew_icons.dart';
import 'package:vybe/presentation/my_page/viewmodels/my_page_viewmodel.dart';
import 'package:vybe/presentation/my_page/widgets/my_page_common.dart';
import 'package:vybe/presentation/my_page/widgets/my_review_card.dart';

/// 마이페이지 리뉴얼 조각(my_renew.html) 레이아웃 스모크.
///
/// 화면 전체는 Firebase 프로바이더에 묶여 있어 여기선 프로바이더가 필요 없는
/// 표시 위젯만 393×852에서 오버플로 없이 그려지는지 확인한다.

final _entry = MyReviewEntry(
  review: ReviewModel(
    reviewId: 'r1',
    clubId: 'c1',
    userId: 'u1',
    rating: 4.5,
    content: '빅룸 사운드가 진짜 미쳤어요. 다음 주말에 또 방문 예정!',
    imageUrls: const [],
    createdAt: DateTime(2026, 7, 12),
    updatedAt: DateTime(2026, 7, 12),
  ),
  club: null,
);

Widget _host(Widget child) => ScreenUtilInit(
  designSize: const Size(393, 852),
  builder: (_, __) => MaterialApp(
    home: Scaffold(
      backgroundColor: RenewGlass.ink,
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: kMyPagePad),
        child: child,
      ),
    ),
  ),
);

void main() {
  testWidgets('메뉴 행 · 토글 · 입력 필드가 오버플로 없이 그려진다', (tester) async {
    tester.view.physicalSize = const Size(393, 852);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      _host(
        Column(
          children: [
            const RenewSectionHead(title: '내 활동'),
            MyMenuRow(
              icon: RenewIcons.review,
              label: '내 리뷰 관리',
              value: '12',
              onTap: () {},
            ),
            MyMenuRow(
              icon: RenewIcons.logout,
              label: '로그아웃',
              danger: true,
              last: true,
              onTap: () {},
            ),
            MyToggle(on: true, onTap: () {}),
            const MyField(label: '닉네임', child: Text('김바이브')),
            const MyGlassTile(icon: RenewIcons.user),
          ],
        ),
      ),
    );
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text('내 리뷰 관리'), findsOneWidget);
    expect(find.text('12'), findsOneWidget);
    expect(find.text('로그아웃'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('로그아웃 행에는 이동 꺾쇠를 그리지 않는다', (tester) async {
    tester.view.physicalSize = const Size(393, 852);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      _host(
        Column(
          children: [
            MyMenuRow(icon: RenewIcons.gear, label: '설정', onTap: () {}),
            MyMenuRow(
              icon: RenewIcons.logout,
              label: '로그아웃',
              danger: true,
              last: true,
              onTap: () {},
            ),
          ],
        ),
      ),
    );
    await tester.pump(const Duration(milliseconds: 100));

    // '설정' 행 하나만 꺾쇠를 가진다 — danger 행은 이동이 아니라 실행이다.
    expect(find.byType(RenewChevron), findsOneWidget);
  });

  testWidgets('리뷰 카드가 클럽·별점·작성일을 보여준다', (tester) async {
    tester.view.physicalSize = const Size(393, 852);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      _host(MyReviewCard(entry: _entry, onEdit: () {}, onDelete: () {})),
    );
    await tester.pump(const Duration(milliseconds: 100));

    // club이 null이면 '알 수 없는 클럽'으로 떨어진다 (조인 실패해도 카드는 살린다).
    expect(find.text('알 수 없는 클럽'), findsOneWidget);
    expect(find.text('4.5'), findsOneWidget);
    expect(find.text('2026.07.12'), findsOneWidget);
    expect(find.text('수정'), findsOneWidget);
    expect(find.text('삭제'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('MyFadeUp은 지연 후 완전히 나타난다', (tester) async {
    tester.view.physicalSize = const Size(393, 852);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      _host(const MyFadeUp(index: 2, child: Text('내 활동'))),
    );
    await tester.pump();

    expect(
      tester.widget<AnimatedOpacity>(find.byType(AnimatedOpacity)).opacity,
      0,
    );

    // 40ms + index(2) × 45ms = 130ms 뒤 시작, 280ms 동안 진행.
    await tester.pump(const Duration(milliseconds: 200));
    await tester.pump(const Duration(milliseconds: 400));

    expect(
      tester.widget<AnimatedOpacity>(find.byType(AnimatedOpacity)).opacity,
      1,
    );
  });
}
