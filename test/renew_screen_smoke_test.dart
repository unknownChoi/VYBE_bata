import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vybe/core/providers/location_providers.dart';
import 'package:vybe/data/models/club_info_model.dart';
import 'package:vybe/data/models/club_model.dart';
import 'package:vybe/data/models/club_table_layout.dart';
import 'package:vybe/data/models/menu_model.dart';
import 'package:vybe/data/models/operating_hours.dart';
import 'package:vybe/data/models/photo_model.dart';
import 'package:vybe/presentation/auth/viewmodels/auth_viewmodel.dart';
import 'package:vybe/presentation/clubs/renew/club_detail_renew_screen.dart';
import 'package:vybe/presentation/clubs/viewmodels/club_detail_viewmodel.dart';
import 'package:vybe/presentation/clubs/viewmodels/club_schedule_viewmodel.dart';
import 'package:vybe/presentation/clubs/viewmodels/review_viewmodel.dart';
import 'package:vybe/presentation/clubs/widgets/schedule_shared.dart';
import 'package:vybe/presentation/common/renew/renew_icons.dart';

const _clubId = 'c1';

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
  clubId: _clubId,
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
  imageUrls: List.generate(8, (i) => 'https://example.com/g$i.jpg'),
  heroImageUrls: List.generate(4, (i) => 'https://example.com/h$i.jpg'),
  thumbnailUrl: 'https://example.com/t.jpg',
  menuBoardUrls: const ['https://example.com/b0.jpg'],
  tags: const ['힙합', '대중적', '무료입장', '홍대'],
  favoriteCount: 3,
  isActive: true,
  isVybeRecommended: true,
  createdAt: DateTime(2026),
  updatedAt: DateTime(2026),
);

final _menus = [
  MenuModel(
    menuId: 'm1',
    clubId: _clubId,
    name: 'LEMON DROP',
    description: '레몬 보드카 베이스',
    price: 15000,
    imageUrl: '',
    category: '칵테일',
    isAvailable: true,
    isFeatured: true,
    createdAt: DateTime(2026),
  ),
  MenuModel(
    menuId: 'm2',
    clubId: _clubId,
    name: 'HEINEKEN',
    description: '330ml',
    price: 12000,
    imageUrl: '',
    category: '맥주',
    isAvailable: true,
    createdAt: DateTime(2026),
  ),
];

final _photos = List.generate(
  20,
  (i) => PhotoModel(
    photoId: 'p$i',
    clubId: _clubId,
    userId: 'seed',
    url: 'https://example.com/p$i.jpg',
    category: PhotoCategory.values[i % PhotoCategory.values.length],
    createdAt: DateTime(2026),
  ),
);

const _schedule = [
  ScheduleDay(
    year: 2026,
    month: 8,
    day: 14,
    dow: '목',
    dday: 0,
    acts: [
      ScheduleAct(
        time: '22:00',
        name: 'YANO',
        type: 'rapper',
        headline: true,
        gradient: [Color(0xFF7731FE), Color(0xFFFF4D8D)],
      ),
      ScheduleAct(
        time: '23:30',
        name: 'GRIM',
        type: 'dj',
        gradient: [Color(0xFFFB5607), Color(0xFFFFBE0B)],
      ),
    ],
  ),
];

/// 테이블 섹션용 최소 배치도 — VIP 2자리 · 1층.
final _tableLayout = ClubTableLayout.fromMap({
  'schemaVersion': 1,
  'clubId': _clubId,
  'tiers': [
    {'key': 'vip', 'name': 'VIP', 'short': 'VIP', 'colorKey': 'blue', 'order': 0},
  ],
  'floors': [
    {
      'floorId': 'f1',
      'name': '1F',
      'order': 0,
      'cols': 12,
      'rows': 16,
      'fixtures': [
        {'id': 'fx1', 'type': 'stage', 'col': 1, 'row': 0, 'colSpan': 10, 'rowSpan': 2},
      ],
      'tables': [
        {
          'id': 'V1', 'tierKey': 'vip', 'name': '센터 1', 'desc': '플로어 옆',
          'col': 0, 'row': 3, 'colSpan': 2, 'rowSpan': 2,
          'price': 500000, 'minPeople': 6, 'minBottles': 2, 'minSpend': 500000,
        },
        {
          'id': 'V2', 'tierKey': 'vip', 'name': '센터 2', 'desc': '플로어 옆',
          'col': 10, 'row': 3, 'colSpan': 2, 'rowSpan': 2,
          'price': 700000, 'minPeople': 8, 'minBottles': 3, 'minSpend': 700000,
        },
      ],
    },
  ],
}, _clubId)!;

Widget _app() => ProviderScope(
  overrides: [
    authStateProvider.overrideWith((ref) => Stream.value(null)),
    // 거리 표기(301m)는 내 위치 기준이라 좌표를 고정한다 —
    // 앱 폴백 좌표나 실제 GPS가 바뀌어도 이 테스트는 흔들리지 않아야 한다.
    userLocationProvider.overrideWithValue(
      const UserLocation(lat: 37.55069527696864, lng: 126.92330205669276),
    ),
    clubDetailProvider(_clubId).overrideWith((ref) async => _club),
    clubInfoProvider(_clubId).overrideWith(
      (ref) async => ClubInfoModel(
        nearbySubways: const [
          {
            'stationName': '상수역',
            'distanceM': 422,
            'lines': ['9호선'],
          },
        ],
        cautions: const ['만 19세 이상 입장 가능 (신분증 필수)'],
        updatedAt: DateTime(2026),
      ),
    ),
    clubTableLayoutProvider(_clubId).overrideWith((ref) async => _tableLayout),
    clubMenusProvider(_clubId).overrideWith((ref) async => _menus),
    clubPhotosProvider(_clubId).overrideWith((ref) async => _photos),
    nearbyClubsProvider(_clubId).overrideWith((ref) async => [_club]),
    clubScheduleProvider(_clubId).overrideWith((ref) async => _schedule),
    reviewListProvider(_clubId).overrideWith((ref) => Stream.value(const [])),
  ],
  child: ScreenUtilInit(
    designSize: const Size(393, 852),
    builder: (_, __) =>
        const MaterialApp(home: ClubDetailRenewScreen(clubId: _clubId)),
  ),
);

/// 애니메이션·비동기 provider가 정착할 만큼만 프레임을 돌린다.
/// (히어로 자동 넘김 타이머 · shimmer 반복 때문에 pumpAndSettle은 못 쓴다.)
Future<void> _settle(WidgetTester tester) async {
  for (var i = 0; i < 5; i++) {
    await tester.pump(const Duration(milliseconds: 200));
  }
}

/// 히어로·타이틀이 다 올라갈 만큼 끌어올려 탭 바를 상단에 붙인다.
Future<void> collapseHeader(WidgetTester tester) async {
  await tester.drag(find.byType(TabBarView), const Offset(0, -700));
  await _settle(tester);
}

void main() {
  Future<void> boot(WidgetTester tester) async {
    tester.view.physicalSize = const Size(393, 852);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(_app());
    await _settle(tester);
  }

  testWidgets('상세 화면이 헤더 · 탭 · 하단바까지 그려진다', (tester) async {
    await boot(tester);

    // 타이틀 블록
    expect(find.text('어썸 레드'), findsWidgets);
    expect(find.text('VYBE 추천 클럽'), findsOneWidget);
    expect(find.text('301m'), findsOneWidget);
    // 탭 5개
    for (final t in ['홈', '사진', '메뉴', '리뷰', '매장정보']) {
      expect(find.text(t), findsWidgets);
    }
    // 홈 탭 첫 섹션
    expect(find.text('매장 정보'), findsOneWidget);
    // 하단 액션 바
    expect(find.text('전화 문의'), findsOneWidget);
    expect(find.text('길찾기'), findsOneWidget);
  });

  testWidgets('스크롤하면 헤더가 접히고 탭 바가 위에 붙는다', (tester) async {
    await boot(tester);

    final tabBefore = tester.getTopLeft(find.text('매장정보')).dy;
    await collapseHeader(tester);
    final tabAfter = tester.getTopLeft(find.text('매장정보')).dy;

    // 탭 바가 상단바 바로 아래(테스트 뷰는 상태바 0이므로 46 + 바 패딩 9)에 멈춘다.
    expect(tabBefore, greaterThan(400));
    expect(tabAfter, lessThan(80));
    // 헤더가 접히면 아래쪽 섹션이 드러난다.
    expect(find.text('오늘의 라인업'), findsOneWidget);
    expect(find.text('테이블'), findsOneWidget);
    // 상단바 제목은 계속 남는다.
    expect(find.text('어썸 레드'), findsWidgets);
  });

  testWidgets('사진 · 메뉴 · 리뷰 탭으로 전환된다', (tester) async {
    await boot(tester);

    await tester.tap(find.text('사진').first);
    await _settle(tester);
    expect(find.textContaining('전체 20'), findsWidgets);
    expect(find.textContaining('업체 7'), findsWidgets);

    await tester.tap(find.text('메뉴').first);
    await _settle(tester);
    expect(find.text('메뉴 이미지'), findsOneWidget);
    await collapseHeader(tester);
    expect(find.text('LEMON DROP'), findsWidgets);
    expect(find.text('15,000원'), findsWidgets);

    await tester.tap(find.text('리뷰').first);
    await _settle(tester);
    await collapseHeader(tester);
    expect(find.text('리뷰 작성하기'), findsOneWidget);
    expect(find.text('첫 리뷰를 남겨주세요'), findsOneWidget);
  });

  testWidgets('사진 탭 카테고리 칩이 스크롤해도 위에 남는다', (tester) async {
    await boot(tester);

    await tester.tap(find.text('사진').first);
    await _settle(tester);
    await collapseHeader(tester);

    // 칩 줄이 위로 지나가도록 더 끌어올린다.
    await tester.drag(find.byType(TabBarView), const Offset(0, -600));
    await _settle(tester);

    // 고정된 복제본이 탭 바 바로 아래(= 46 + 52 언저리)에 있다.
    final chip = tester.getTopLeft(find.text('전체 20').last).dy;
    expect(chip, lessThan(160));
  });

  testWidgets('매장 정보 카드 영업시간을 펼치면 요일 표가 나온다', (tester) async {
    await boot(tester);
    // 카드가 탭 바 아래로 완전히 들어가지 않을 만큼만 올린다.
    await tester.drag(find.byType(TabBarView), const Offset(0, -450));
    await _settle(tester);

    expect(find.text('정기휴무'), findsNothing);
    // 영업 상태 문구는 현재 시각에 따라 달라져 펼침 화살표로 행을 찍는다.
    // (주소 · 영업시간 두 개 중 아래쪽이 영업시간)
    await tester.tap(find.byType(RenewChevron).last);
    await _settle(tester);

    // 일요일 휴무 + '오늘' 뱃지가 드러난다.
    expect(find.text('정기휴무'), findsOneWidget);
    expect(find.text('오늘'), findsOneWidget);
  });
}
