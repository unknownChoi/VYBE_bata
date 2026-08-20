import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vybe/data/models/club_model.dart';
import 'package:vybe/data/models/free_entry_policy.dart';
import 'package:vybe/data/models/notice_model.dart';
import 'package:vybe/data/models/operating_hours.dart';
import 'package:vybe/presentation/home/home_models.dart';
import 'package:vybe/presentation/home/viewmodels/home_free_time_viewmodel.dart';
import 'package:vybe/presentation/home/viewmodels/home_notices_viewmodel.dart';
import 'package:vybe/presentation/home/widgets/home_free_time_clubs.dart';
import 'package:vybe/presentation/home/widgets/home_notices.dart';

/// 홈 '타임 무료입장' · '공지사항' 섹션.
/// 카드 문구가 데이터에서 조립되는 부분(무료 시각·남은 시간·요금)까지 같이 본다.
///
/// 기준 날짜: 2026-08-21은 금요일.

const _hongdae = (lat: 37.5563, lng: 126.9236);

ClubModel _club({
  required String id,
  required String name,
  required FreeEntryPolicy freeEntry,
  int entryFeeMin = 20000,
  OperatingHours hours = _openEveryDay,
}) => ClubModel(
  clubId: id,
  name: name,
  description: '',
  address: '',
  area: '홍대',
  phone: '',
  instagramUrl: '',
  lat: _hongdae.lat,
  lng: _hongdae.lng,
  geohash: 'wydm',
  genre: '힙합',
  rating: 4.5,
  operatingHours: hours,
  entryFeeMin: entryFeeMin,
  entryFeeMax: 30000,
  imageUrls: const [],
  thumbnailUrl: '',
  tags: const [],
  favoriteCount: 0,
  isActive: true,
  isVybeRecommended: false,
  freeEntry: freeEntry,
  isFreeEntry: freeEntry.hasFreeEntry,
  createdAt: DateTime(2026),
  updatedAt: DateTime(2026),
);

const _openEveryDay = OperatingHours(
  mon: DayHours(isOpen: true, open: '22:00', close: '06:00'),
  tue: DayHours(isOpen: true, open: '22:00', close: '06:00'),
  wed: DayHours(isOpen: true, open: '22:00', close: '06:00'),
  thu: DayHours(isOpen: true, open: '22:00', close: '06:00'),
  fri: DayHours(isOpen: true, open: '22:00', close: '06:00'),
  sat: DayHours(isOpen: true, open: '22:00', close: '06:00'),
  sun: DayHours(isOpen: true, open: '22:00', close: '06:00'),
);

const _closedEveryDay = OperatingHours();

void main() {
  group('toHomeFreeTimeClub', () {
    const policy = FreeEntryPolicy(
      type: FreeEntryType.timed,
      condition: '자정 이전 입장 무료',
      windows: [
        FreeEntryWindow(days: ['fri'], start: '22:00', end: '23:30'),
      ],
    );

    test('창 안 + 영업 중 → 지금 무료', () {
      final card = toHomeFreeTimeClub(
        _club(id: 'c1', name: '어썸레드', freeEntry: policy),
        now: DateTime(2026, 8, 21, 22, 52),
        myLat: _hongdae.lat,
        myLng: _hongdae.lng,
      )!;
      expect(card.freeNow, isTrue);
      expect(card.windowLabel, '22:00 – 23:30');
      expect(card.remainingLabel, '38분 남음');
      expect(card.startsLabel, isNull);
      expect(card.normalFeeLabel, '₩20,000');
    });

    test('창 안이어도 휴무면 지금 무료가 아니다', () {
      // 문 닫은 클럽에 '지금 무료'는 거짓 정보 — 무료 창만 보고 그리면 안 된다.
      final card = toHomeFreeTimeClub(
        _club(
          id: 'c1',
          name: '어썸레드',
          freeEntry: policy,
          hours: _closedEveryDay,
        ),
        now: DateTime(2026, 8, 21, 22, 52),
        myLat: _hongdae.lat,
        myLng: _hongdae.lng,
      )!;
      expect(card.freeNow, isFalse);
    });

    test('창 밖이면 시작 시각을 안내한다', () {
      final card = toHomeFreeTimeClub(
        _club(id: 'c1', name: '어썸레드', freeEntry: policy),
        now: DateTime(2026, 8, 21, 20),
        myLat: _hongdae.lat,
        myLng: _hongdae.lng,
      )!;
      expect(card.freeNow, isFalse);
      expect(card.startsLabel, '22:00부터');
      expect(card.remainingLabel, isNull);
    });

    test('오늘이 아니면 요일을 붙인다', () {
      final card = toHomeFreeTimeClub(
        _club(id: 'c1', name: '어썸레드', freeEntry: policy),
        now: DateTime(2026, 8, 19, 20), // 수요일
        myLat: _hongdae.lat,
        myLng: _hongdae.lng,
      )!;
      expect(card.startsLabel, '금 22:00부터');
    });

    test('평상시 요금이 0이면 취소선 표기를 비운다', () {
      final card = toHomeFreeTimeClub(
        _club(id: 'c1', name: '어썸레드', freeEntry: policy, entryFeeMin: 0),
        now: DateTime(2026, 8, 21, 22, 52),
        myLat: _hongdae.lat,
        myLng: _hongdae.lng,
      )!;
      expect(card.normalFeeLabel, '');
    });

    test('무료 창이 하나도 없으면 카드로 만들지 않는다', () {
      final card = toHomeFreeTimeClub(
        _club(
          id: 'c1',
          name: '어썸레드',
          freeEntry: const FreeEntryPolicy(type: FreeEntryType.timed),
        ),
        now: DateTime(2026, 8, 21, 22),
        myLat: _hongdae.lat,
        myLng: _hongdae.lng,
      );
      expect(card, isNull);
    });
  });

  group('compareHomeFreeTime', () {
    HomeFreeTimeClub card({
      required String name,
      required bool freeNow,
      required DateTime at,
      double dist = 1,
    }) => HomeFreeTimeClub(
      clubId: name,
      name: name,
      area: '홍대',
      genre: '힙합',
      thumbnailUrl: '',
      gradient: const [Colors.black, Colors.black],
      distanceKm: dist,
      normalFee: 20000,
      freeNow: freeNow,
      windowLabel: '22:00 – 23:30',
      sortAt: at,
    );

    test('지금 무료 → 곧 시작 → 가까운 순', () {
      final list = [
        card(name: '나중시작', freeNow: false, at: DateTime(2026, 8, 21, 23)),
        card(name: '곧시작', freeNow: false, at: DateTime(2026, 8, 21, 22)),
        card(name: '무료중', freeNow: true, at: DateTime(2026, 8, 21, 23, 30)),
      ]..sort(compareHomeFreeTime);
      expect(list.map((e) => e.name), ['무료중', '곧시작', '나중시작']);
    });

    test('같은 시각이면 가까운 곳이 앞', () {
      final at = DateTime(2026, 8, 21, 22);
      final list = [
        card(name: '먼곳', freeNow: false, at: at, dist: 5),
        card(name: '가까운곳', freeNow: false, at: at, dist: 0.4),
      ]..sort(compareHomeFreeTime);
      expect(list.first.name, '가까운곳');
    });
  });

  group('위젯', () {
    final freeTimeCards = [
      HomeFreeTimeClub(
        clubId: 'c1',
        name: '어썸레드',
        area: '홍대',
        genre: '힙합',
        thumbnailUrl: '',
        gradient: const [Color(0xFF2B1655), Color(0xFF7731FE)],
        distanceKm: 0.4,
        normalFee: 20000,
        freeNow: true,
        windowLabel: '22:00 – 23:30',
        remainingLabel: '38분 남음',
        sortAt: DateTime(2026, 8, 21, 23, 30),
      ),
      HomeFreeTimeClub(
        clubId: 'c2',
        name: '케이크샵',
        area: '이태원',
        genre: '테크노',
        thumbnailUrl: '',
        gradient: const [Color(0xFF06FFA5), Color(0xFF1B9AAA)],
        distanceKm: 6.3,
        normalFee: 30000,
        freeNow: false,
        windowLabel: '23:30 – 01:00',
        startsLabel: '23:30부터',
        sortAt: DateTime(2026, 8, 21, 23, 30),
      ),
    ];

    final notices = [
      NoticeModel(
        noticeId: 'n1',
        title: '입장 확정 절차 변경 안내',
        content: '',
        category: 'notice',
        publishedAt: DateTime.now().subtract(const Duration(days: 1)),
        createdAt: DateTime(2026),
        updatedAt: DateTime(2026),
      ),
      NoticeModel(
        noticeId: 'n2',
        title: 'v2.4 업데이트 — 주변 지도 개편',
        content: '',
        category: 'update',
        publishedAt: DateTime(2026, 7, 28),
        createdAt: DateTime(2026),
        updatedAt: DateTime(2026),
      ),
    ];

    Widget app({
      List<HomeFreeTimeClub>? cards,
      List<NoticeModel>? noticeList,
    }) => ProviderScope(
      overrides: [
        homeFreeTimeClubsProvider.overrideWith((ref) async => cards ?? []),
        homeNoticesProvider.overrideWith((ref) async => noticeList ?? []),
      ],
      child: ScreenUtilInit(
        designSize: const Size(393, 852),
        builder: (_, __) => const MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: Column(
                children: [HomeFreeTimeClubs(), HomeNotices()],
              ),
            ),
          ),
        ),
      ),
    );

    /// 등장 애니메이션(45ms 스태거)이 끝날 만큼만 돌린다.
    /// (shimmer 스켈레톤이 반복 애니메이션이라 pumpAndSettle은 못 쓴다)
    Future<void> settle(WidgetTester tester) async {
      for (var i = 0; i < 5; i++) {
        await tester.pump(const Duration(milliseconds: 200));
      }
    }

    testWidgets('타임 무료입장 카드가 시간·요금·상태까지 그려진다', (tester) async {
      tester.view.physicalSize = const Size(393, 852);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(app(cards: freeTimeCards, noticeList: notices));
      await settle(tester);

      expect(find.text('타임 무료입장'), findsOneWidget);
      expect(find.text('이 시간대에만 입장료 0원'), findsOneWidget);
      // 진행 중 카드
      expect(find.text('지금 무료'), findsOneWidget);
      expect(find.text('38분 남음'), findsOneWidget);
      expect(find.text('22:00 – 23:30'), findsOneWidget);
      expect(find.text('₩20,000'), findsOneWidget);
      expect(find.text('어썸레드'), findsOneWidget);
      expect(find.text('0.4km'), findsOneWidget);
      // 예정 카드는 시작 시각을 대신 보여준다
      expect(find.text('23:30부터'), findsOneWidget);
      expect(find.text('케이크샵'), findsOneWidget);
    });

    testWidgets('공지 카드가 배지 · NEW · 날짜와 함께 그려진다', (tester) async {
      tester.view.physicalSize = const Size(393, 852);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(app(cards: freeTimeCards, noticeList: notices));
      await settle(tester);

      expect(find.text('공지사항'), findsOneWidget);
      expect(find.text('입장 확정 절차 변경 안내'), findsOneWidget);
      expect(find.text('v2.4 업데이트 — 주변 지도 개편'), findsOneWidget);
      expect(find.text('공지'), findsOneWidget);
      expect(find.text('업데이트'), findsOneWidget);
      // 7일 이내 게시분에만 NEW
      expect(find.text('NEW'), findsOneWidget);
      expect(find.text('2026.07.28'), findsOneWidget);
    });

    testWidgets('데이터가 비면 각 섹션이 빈 안내를 보여준다', (tester) async {
      tester.view.physicalSize = const Size(393, 852);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(app());
      await settle(tester);

      expect(find.text('지금 예정된 무료입장 시간이 없어요'), findsOneWidget);
      expect(find.text('등록된 공지가 없어요'), findsOneWidget);
    });
  });
}
