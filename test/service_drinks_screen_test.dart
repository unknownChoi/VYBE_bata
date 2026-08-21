import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vybe/core/providers/auth_providers.dart';
import 'package:vybe/data/models/club_model.dart';
import 'package:vybe/data/models/operating_hours.dart';
import 'package:vybe/data/models/service_drink.dart';
import 'package:vybe/presentation/service_drinks/service_drinks_screen.dart';
import 'package:vybe/presentation/service_drinks/viewmodels/service_drinks_viewmodel.dart';
import 'package:vybe/presentation/service_drinks/widgets/service_drinks_card.dart';

/// 서비스 음료 화면 — 인트로 개수 · 종류 필터 · 카드 렌더.
///
/// 화면을 조립부(screen) / 표시 모델 / 위젯으로 나눈 뒤에도 같은 것이 보이는지
/// 확인하는 스모크 테스트. Firestore를 타지 않도록 뷰모델을 가짜로 갈아 끼운다.

const _open24 = OperatingHours(
  mon: DayHours(isOpen: true, open: '00:00', close: '24:00'),
  tue: DayHours(isOpen: true, open: '00:00', close: '24:00'),
  wed: DayHours(isOpen: true, open: '00:00', close: '24:00'),
  thu: DayHours(isOpen: true, open: '00:00', close: '24:00'),
  fri: DayHours(isOpen: true, open: '00:00', close: '24:00'),
  sat: DayHours(isOpen: true, open: '00:00', close: '24:00'),
  sun: DayHours(isOpen: true, open: '00:00', close: '24:00'),
);

ClubModel _club({
  required String id,
  required String name,
  required String comment,
  required List<String> drinks,
}) => ClubModel(
  clubId: id,
  name: name,
  description: '',
  address: '',
  area: '홍대',
  phone: '',
  instagramUrl: '',
  lat: 37.5563,
  lng: 126.9236,
  geohash: 'wydm',
  genre: '힙합',
  rating: 4.5,
  operatingHours: _open24,
  entryFeeMin: 20000,
  entryFeeMax: 30000,
  imageUrls: const [],
  thumbnailUrl: '',
  tags: const [],
  favoriteCount: 0,
  isActive: true,
  isVybeRecommended: false,
  serviceDrink: ServiceDrink(
    isOffered: true,
    comment: comment,
    drinks: drinks,
  ),
  createdAt: DateTime(2026),
  updatedAt: DateTime(2026),
);

class _FakeViewModel extends ServiceDrinksViewModel {
  _FakeViewModel(this._clubs);
  final List<ClubModel> _clubs;

  @override
  Future<List<ClubModel>> build() async => _clubs;
}

Widget _app(List<ClubModel> clubs) => ProviderScope(
  overrides: [
    serviceDrinksViewModelProvider.overrideWith(() => _FakeViewModel(clubs)),
    // 비로그인 — mergedFavoriteIds 가 Firestore 스트림을 건드리지 않게 한다.
    currentUidProvider.overrideWithValue(null),
  ],
  child: ScreenUtilInit(
    designSize: const Size(393, 852),
    builder: (_, __) => const MaterialApp(home: ServiceDrinksScreen()),
  ),
);

/// 인트로 개수는 `Text.rich` 안의 TextSpan이라 `find.text`로는 안 잡힌다 —
/// RichText 의 평문을 펼쳐서 찾는다.
Finder _richTextContaining(String needle) => find.byWidgetPredicate(
  (w) => w is RichText && w.text.toPlainText().contains(needle),
);

/// 등장/스켈레톤 애니메이션이 반복이라 pumpAndSettle 대신 정해진 만큼만 돌린다.
Future<void> _settle(WidgetTester tester) async {
  for (var i = 0; i < 6; i++) {
    await tester.pump(const Duration(milliseconds: 300));
  }
}

final _clubs = [
  _club(id: 'a', name: '위스키클럽', comment: '양주 1병 서비스', drinks: const ['양주']),
  _club(id: 'b', name: '맥주클럽', comment: '테이블당 맥주 6병', drinks: const ['맥주']),
  _club(id: 'c', name: '샴페인클럽', comment: '샴페인 1병', drinks: const ['샴페인']),
];

void main() {
  testWidgets('클럽 카드와 제공 코멘트가 그려진다', (tester) async {
    tester.view.physicalSize = const Size(393, 1400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(_app(_clubs));
    await _settle(tester);

    expect(find.byType(ServiceDrinksCard), findsNWidgets(3));
    expect(find.text('양주 1병 서비스'), findsOneWidget);
    expect(find.text('테이블당 맥주 6병'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('인트로는 필터를 거친 개수를 센다', (tester) async {
    tester.view.physicalSize = const Size(393, 1400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(_app(_clubs));
    await _settle(tester);
    expect(_richTextContaining('홍대 근처 3곳'), findsOneWidget);

    // 종류 칩 '양주' 탭 → 양주 클럽만 남는다.
    // (칩 줄은 가로 스크롤이라 화면 밖 칩은 탭할 수 없다 — 앞쪽 칩으로 검증)
    await tester.tap(find.text('양주'));
    await _settle(tester);

    expect(_richTextContaining('홍대 근처 1곳'), findsOneWidget);
    expect(find.byType(ServiceDrinksCard), findsOneWidget);
    expect(find.text('양주 1병 서비스'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('제공 클럽이 없으면 안내 문구를 보여준다', (tester) async {
    tester.view.physicalSize = const Size(393, 1400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(_app(const []));
    await _settle(tester);

    expect(find.text('해당 음료를 제공하는 클럽이 아직 없어요'), findsOneWidget);
    expect(find.byType(ServiceDrinksCard), findsNothing);
    expect(tester.takeException(), isNull);
  });
}
