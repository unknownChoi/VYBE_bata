import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vybe/design_system/colors.dart';
import 'package:vybe/presentation/common/widgets/vybe_club_poster_card.dart';
import 'package:vybe/presentation/common/widgets/vybe_recommend_badge.dart';

/// 포스터 카드 — 큰 build 하나를 조각 위젯으로 나눈 뒤에도 같은 것이 보이는지.

VybeClubPoster _club({
  bool live = true,
  bool open = true,
  bool vybe = true,
  List<String> styles = const ['트랩', '붐뱁'],
}) => VybeClubPoster(
  id: 'c1',
  name: '어썸 레드',
  area: '홍대',
  dist: 1.234,
  rating: 4.56,
  reviews: 12,
  styles: styles,
  lineup: '3팀',
  live: live,
  open: open,
  thumbnailUrl: '',
  bg: const [VybeColors.mainPurple500, VybeColors.accentBlue500],
  vybe: vybe,
);

/// 실제 그리드 칸은 393 화면에서 약 175 x 233 이지만, 테스트 폰트(Ahem)는
/// 글자 하나가 폰트 크기만큼의 정사각형이라 Pretendard보다 훨씬 넓다.
/// 그 폭으로 실제 칸 크기를 쓰면 실기기에 없는 오버플로가 잡히므로
/// 글자 폭 차이만큼 넉넉한 칸을 준다 (검증 대상은 폭이 아니라 구성 요소다).
Widget _host(VybeClubPoster club, {bool saved = false}) => ScreenUtilInit(
  designSize: const Size(393, 852),
  builder: (_, __) => MaterialApp(
    home: Scaffold(
      backgroundColor: VybeColors.background,
      body: Center(
        child: SizedBox(
          width: 260,
          height: 360,
          child: VybeClubPosterCard(
            club: club,
            saved: saved,
            onSave: () {},
            onTap: () {},
          ),
        ),
      ),
    ),
  ),
);

void main() {
  testWidgets('이름·평점·지역·거리·스타일 태그가 그려진다', (tester) async {
    tester.view.physicalSize = const Size(393, 852);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(_host(_club()));
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text('어썸 레드'), findsOneWidget);
    expect(find.text('4.56'), findsOneWidget);
    expect(find.text('홍대 · 1.2km'), findsOneWidget);
    expect(find.text('#트랩'), findsOneWidget);
    expect(find.text('#붐뱁'), findsOneWidget);
    expect(find.byType(VybeRecommendBadge), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('영업 상태와 LIVE 뱃지가 값에 따라 바뀐다', (tester) async {
    tester.view.physicalSize = const Size(393, 852);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(_host(_club()));
    await tester.pump(const Duration(milliseconds: 100));
    expect(find.text('영업중'), findsOneWidget);
    expect(find.text('3팀 LIVE'), findsOneWidget);

    // 공연이 없고 문도 닫은 클럽 — LIVE 뱃지는 아예 빠진다.
    await tester.pumpWidget(_host(_club(live: false, open: false)));
    await tester.pump(const Duration(milliseconds: 100));
    expect(find.text('영업종료'), findsOneWidget);
    expect(find.text('3팀 LIVE'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('찜 상태에 따라 하트가 채워진다', (tester) async {
    tester.view.physicalSize = const Size(393, 852);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(_host(_club(), saved: false));
    await tester.pump(const Duration(milliseconds: 100));
    expect(find.byIcon(Icons.favorite_border_rounded), findsOneWidget);

    await tester.pumpWidget(_host(_club(), saved: true));
    await tester.pump(const Duration(milliseconds: 100));
    expect(find.byIcon(Icons.favorite_rounded), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('추천이 아니면 뱃지를, 태그가 없으면 태그 줄을 뺀다', (tester) async {
    tester.view.physicalSize = const Size(393, 852);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(_host(_club(vybe: false, styles: const [])));
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.byType(VybeRecommendBadge), findsNothing);
    expect(find.textContaining('#'), findsNothing);
    expect(tester.takeException(), isNull);
  });
}
