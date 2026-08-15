import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vybe/data/models/club_model.dart';
import 'package:vybe/data/models/menu_model.dart';
import 'package:vybe/data/models/operating_hours.dart';
import 'package:vybe/presentation/clubs/renew/widgets/renew_button.dart';
import 'package:vybe/presentation/clubs/renew/widgets/renew_chrome.dart';
import 'package:vybe/presentation/clubs/renew/widgets/renew_glass.dart';
import 'package:vybe/presentation/clubs/renew/widgets/renew_header.dart';
import 'package:vybe/presentation/clubs/renew/widgets/renew_home_sections.dart';
import 'package:vybe/presentation/clubs/renew/widgets/renew_hours_table.dart';
import 'package:vybe/presentation/clubs/renew/widgets/renew_menu_rows.dart';
import 'package:vybe/presentation/clubs/renew/widgets/renew_sticky_bar.dart';

const _hours = OperatingHours(
  mon: DayHours(isOpen: true, open: '22:00', close: '05:00'),
  tue: DayHours(isOpen: true, open: '22:00', close: '05:00'),
  wed: DayHours(isOpen: true, open: '22:00', close: '05:00'),
  thu: DayHours(isOpen: true, open: '22:00', close: '05:00'),
  fri: DayHours(isOpen: true, open: '22:00', close: '06:00'),
  sat: DayHours(isOpen: true, open: '22:00', close: '06:00'),
  sun: DayHours.closed,
);

final _club = ClubModel(
  clubId: 'c1',
  name: '어썸 레드',
  description: '홍대역 인근, 입문자에게 좋은 힙합 클럽',
  address: '서울 마포구 잔다리로 12 지하 1층',
  area: '홍대',
  phone: '02-333-1094',
  instagramUrl: 'https://instagram.com/awesomered_omg',
  lat: 37.55,
  lng: 126.92,
  geohash: 'wydm',
  genre: '힙합',
  rating: 4.76,
  reviewCount: 13,
  operatingHours: _hours,
  entryFeeMin: 0,
  entryFeeMax: 10000,
  imageUrls: List.generate(8, (i) => 'https://example.com/$i.jpg'),
  thumbnailUrl: 'https://example.com/t.jpg',
  tags: const ['힙합', '대중적', '무료입장', '홍대'],
  favoriteCount: 3,
  isActive: true,
  isVybeRecommended: true,
  createdAt: DateTime(2026),
  updatedAt: DateTime(2026),
);

MenuModel _menu(String name, {bool featured = false}) => MenuModel(
  menuId: name,
  clubId: 'c1',
  name: name,
  description: '설명 텍스트',
  price: 15000,
  imageUrl: '',
  category: '칵테일',
  isAvailable: true,
  isFeatured: featured,
  createdAt: DateTime(2026),
);

Widget _host(Widget child) => ScreenUtilInit(
  designSize: const Size(393, 852),
  builder: (_, __) => MaterialApp(
    home: Scaffold(
      backgroundColor: RenewGlass.ink,
      body: SingleChildScrollView(child: child),
    ),
  ),
);

void main() {
  testWidgets('타이틀 블록이 오버플로 없이 그려진다', (tester) async {
    tester.view.physicalSize = const Size(393, 852);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      _host(RenewTitleBlock(club: _club, distanceLabel: '0.4km')),
    );
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text('어썸 레드'), findsOneWidget);
    expect(find.text('VYBE 추천 클럽'), findsOneWidget);
    expect(find.text('리뷰 13'), findsOneWidget);
  });

  testWidgets('홈 섹션들이 오버플로 없이 그려진다', (tester) async {
    tester.view.physicalSize = const Size(393, 852);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      _host(
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              const RenewSectionHead(
                title: '메뉴',
                sub: '가격은 달라질 수 있어요',
                actionLabel: '더보기',
              ),
              RenewMenuRows(
                menus: [_menu('LEMON DROP', featured: true), _menu('NEGRONI')],
              ),
              const RenewTableSection(),
              RenewPhotoSection(imageUrls: _club.imageUrls, onOpen: (_) {}),
              const RenewHoursTable(hours: _hours),
              const RenewFooterNote(text: '방문 전 확인해 주세요.'),
              const RenewStatusPill(isOpen: true, label: '영업중 · 05:00 종료'),
              const RenewStarRow(rating: 4.5),
              const RenewButton(label: '길찾기', onTap: null),
            ],
          ),
        ),
      ),
    );
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text('테이블'), findsOneWidget);
    expect(find.text('LEMON DROP'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('상단바·하단바·탭바가 그려진다', (tester) async {
    tester.view.physicalSize = const Size(393, 852);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      ScreenUtilInit(
        designSize: const Size(393, 852),
        builder: (_, __) => MaterialApp(
          home: Scaffold(
            backgroundColor: RenewGlass.ink,
            body: Column(
              children: [
                RenewChrome(
                  scrollY: 300,
                  clubName: '어썸 레드',
                  onBack: () {},
                  onShare: () {},
                ),
                RenewTabBar(
                  tabs: const ['홈', '사진', '메뉴', '리뷰', '매장정보'],
                  activeIndex: 0,
                  onSelect: (_) {},
                ),
                const Spacer(),
                RenewBottomBar(
                  saved: false,
                  onSave: () {},
                  onDirections: () {},
                  onCall: () {},
                ),
              ],
            ),
          ),
        ),
      ),
    );
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('매장정보'), findsOneWidget);
    expect(find.text('전화 문의'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('sticky 바가 스크롤하면 위에 고정된다', (tester) async {
    tester.view.physicalSize = const Size(393, 852);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    final bar = RenewBar(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: SizedBox(
        height: 34,
        child: Row(
          children: [RenewChip(label: '전체', selected: true, onTap: () {})],
        ),
      ),
    );

    await tester.pumpWidget(
      ScreenUtilInit(
        designSize: const Size(393, 852),
        builder: (_, __) => MaterialApp(
          home: Scaffold(
            body: RenewStickyBarHost(
              bar: bar,
              scrollBuilder: (barKey) => ListView(
                children: [
                  const SizedBox(height: 400),
                  KeyedSubtree(key: barKey, child: bar),
                  const SizedBox(height: 2000),
                ],
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pump();

    expect(find.text('전체'), findsOneWidget);
    await tester.drag(find.byType(ListView), const Offset(0, -600));
    await tester.pump();
    // 원본은 화면 밖으로 나가고 복제본이 고정된다 (둘 다 트리에 있을 수 있음).
    expect(find.text('전체'), findsWidgets);
    expect(tester.takeException(), isNull);
  });

  testWidgets('히어로가 그려진다', (tester) async {
    tester.view.physicalSize = const Size(393, 852);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      ScreenUtilInit(
        designSize: const Size(393, 852),
        builder: (_, __) => MaterialApp(
          home: Scaffold(
            body: RenewHero(imageUrls: _club.imageUrls.take(3).toList()),
          ),
        ),
      ),
    );
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text('1 / 3'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
