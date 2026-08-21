import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vybe/core/providers/auth_providers.dart';
import 'package:vybe/data/models/club_model.dart';
import 'package:vybe/data/models/free_entry_policy.dart';
import 'package:vybe/data/models/operating_hours.dart';
import 'package:vybe/presentation/free_entry/free_entry_screen.dart';
import 'package:vybe/presentation/free_entry/viewmodels/free_entry_viewmodel.dart';

/// 입장비 무료 페이지 — 상시 무료 + 시간대 무료를 한 목록에 담은 뒤의 표기.
///
/// 화면이 `DateTime.now()` 로 판정하므로 **시각을 주입할 수 없다** →
/// 창을 지금 기준 상대 시각으로 만들어 실행 시각과 무관하게 같은 결과가 나오게 한다.

/// 24시간 영업 — '지금 무료'는 영업 중일 때만 뜨므로 영업시간이 판정을 가리지 않게.
const _open24 = OperatingHours(
  mon: DayHours(isOpen: true, open: '00:00', close: '24:00'),
  tue: DayHours(isOpen: true, open: '00:00', close: '24:00'),
  wed: DayHours(isOpen: true, open: '00:00', close: '24:00'),
  thu: DayHours(isOpen: true, open: '00:00', close: '24:00'),
  fri: DayHours(isOpen: true, open: '00:00', close: '24:00'),
  sat: DayHours(isOpen: true, open: '00:00', close: '24:00'),
  sun: DayHours(isOpen: true, open: '00:00', close: '24:00'),
);

String _hhmm(DateTime t) =>
    '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';

/// [from] ~ [to] 를 덮는 창 하나. 창은 **시작 요일**에 속한다.
FreeEntryWindow _window(DateTime from, DateTime to) => FreeEntryWindow(
  days: [dayKeyOf(from.weekday)],
  start: _hhmm(from),
  end: _hhmm(to),
);

ClubModel _club({
  required String id,
  required String name,
  required FreeEntryPolicy freeEntry,
  int entryFeeMin = 20000,
  OperatingHours hours = _open24,
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

class _FakeFreeEntryViewModel extends FreeEntryViewModel {
  _FakeFreeEntryViewModel(this._clubs);
  final List<ClubModel> _clubs;

  @override
  Future<List<ClubModel>> build() async => _clubs;
}

Widget _app(List<ClubModel> clubs) => ProviderScope(
  overrides: [
    freeEntryViewModelProvider.overrideWith(
      () => _FakeFreeEntryViewModel(clubs),
    ),
    // 비로그인 — mergedFavoriteIds 가 Firestore 스트림을 건드리지 않게 한다.
    currentUidProvider.overrideWithValue(null),
  ],
  child: ScreenUtilInit(
    designSize: const Size(393, 852),
    builder: (_, __) => const MaterialApp(home: FreeEntryScreen()),
  ),
);

/// 등장/스켈레톤 애니메이션이 반복이라 pumpAndSettle 대신 정해진 만큼만 돌린다.
Future<void> _settle(WidgetTester tester) async {
  for (var i = 0; i < 6; i++) {
    await tester.pump(const Duration(milliseconds: 300));
  }
}

void main() {
  testWidgets('상시·진행중·예정 무료가 각각 다른 문구로 그려진다', (tester) async {
    tester.view.physicalSize = const Size(393, 1400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    final now = DateTime.now();
    final clubs = [
      // 상시 무료 — entryFeeMin 이 0 이라 비교값은 entryFeeMax(30,000)를 쓴다.
      _club(
        id: 'always',
        name: '상시무료클럽',
        entryFeeMin: 0,
        freeEntry: const FreeEntryPolicy(
          type: FreeEntryType.always,
          condition: '상시 무료입장',
        ),
      ),
      // 지금 무료 — 한 시간 전에 시작해 한 시간 뒤에 끝나는 창.
      _club(
        id: 'now',
        name: '지금무료클럽',
        freeEntry: FreeEntryPolicy(
          type: FreeEntryType.timed,
          condition: '자정 이전 입장 무료',
          windows: [
            _window(
              now.subtract(const Duration(hours: 1)),
              now.add(const Duration(hours: 1)),
            ),
          ],
        ),
      ),
      // 아직 무료 아님 — 세 시간 뒤에 시작하는 창.
      _club(
        id: 'later',
        name: '예정무료클럽',
        freeEntry: FreeEntryPolicy(
          type: FreeEntryType.timed,
          condition: '오픈런 무료',
          windows: [
            _window(
              now.add(const Duration(hours: 3)),
              now.add(const Duration(hours: 5)),
            ),
          ],
        ),
      ),
    ];

    await tester.pumpWidget(_app(clubs));
    await _settle(tester);

    // 인트로 pill 은 '정책이 있는 곳'이 아니라 **지금 무료인 곳**을 센다
    // (상시 무료도 영업 중이면 지금 무료 → 2곳).
    expect(find.text('지금 무료 2곳'), findsOneWidget);

    // 진행 중 — 리본에 남은 시간이 붙는다.
    expect(find.textContaining('지금 무료 ·'), findsOneWidget);
    // 예정 — 언제부터 무료인지로 바꿔 말한다.
    expect(find.textContaining('부터 무료'), findsOneWidget);
    // 상시 — '지금 무료'로 쓰면 시간 제한이 있는 것처럼 읽혀 기존 문구를 유지한다.
    expect(find.text('입장비 무료'), findsOneWidget);

    expect(find.text('상시무료클럽'), findsOneWidget);
    expect(find.text('지금무료클럽'), findsOneWidget);
    expect(find.text('예정무료클럽'), findsOneWidget);

    // 조건 문구는 freeEntry.condition 에서 온다.
    expect(find.text('자정 이전 입장 무료'), findsOneWidget);
    expect(find.text('오픈런 무료'), findsOneWidget);
  });

  testWidgets('무료 시간이 아닌 클럽은 요금에 취소선을 긋지 않는다', (tester) async {
    tester.view.physicalSize = const Size(393, 1400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    final now = DateTime.now();
    await tester.pumpWidget(
      _app([
        _club(
          id: 'later',
          name: '예정무료클럽',
          freeEntry: FreeEntryPolicy(
            type: FreeEntryType.timed,
            windows: [
              _window(
                now.add(const Duration(hours: 3)),
                now.add(const Duration(hours: 5)),
              ),
            ],
          ),
        ),
      ]),
    );
    await _settle(tester);

    final fee = tester.widget<Text>(find.text('20,000원'));
    expect(fee.style?.decoration, isNot(TextDecoration.lineThrough));
    // 지금 무료가 아니므로 '무료'만 덜렁 쓰지 않는다.
    expect(find.text('무료'), findsNothing);
    expect(find.text('지금 무료 1곳'), findsNothing);
    expect(find.text('무료입장 정책'), findsOneWidget);
  });

  testWidgets('지금 무료인 곳이 목록 맨 위로 온다', (tester) async {
    tester.view.physicalSize = const Size(393, 1400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    final now = DateTime.now();
    await tester.pumpWidget(
      _app([
        _club(
          id: 'later',
          name: '예정무료클럽',
          freeEntry: FreeEntryPolicy(
            type: FreeEntryType.timed,
            windows: [
              _window(
                now.add(const Duration(hours: 3)),
                now.add(const Duration(hours: 5)),
              ),
            ],
          ),
        ),
        _club(
          id: 'now',
          name: '지금무료클럽',
          freeEntry: FreeEntryPolicy(
            type: FreeEntryType.timed,
            windows: [
              _window(
                now.subtract(const Duration(hours: 1)),
                now.add(const Duration(hours: 1)),
              ),
            ],
          ),
        ),
      ]),
    );
    await _settle(tester);

    final freeNowY = tester.getTopLeft(find.text('지금무료클럽')).dy;
    final laterY = tester.getTopLeft(find.text('예정무료클럽')).dy;
    expect(freeNowY, lessThan(laterY));
  });

  testWidgets('문 닫은 클럽은 무료 창 안이어도 지금 무료라고 하지 않는다', (tester) async {
    tester.view.physicalSize = const Size(393, 1400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    final now = DateTime.now();
    await tester.pumpWidget(
      _app([
        _club(
          id: 'closed',
          name: '휴무클럽',
          hours: const OperatingHours(), // 전 요일 휴무
          freeEntry: FreeEntryPolicy(
            type: FreeEntryType.timed,
            windows: [
              _window(
                now.subtract(const Duration(hours: 1)),
                now.add(const Duration(hours: 1)),
              ),
            ],
          ),
        ),
      ]),
    );
    await _settle(tester);

    expect(find.text('휴무클럽'), findsOneWidget);
    // '지금 무료순'(정렬 라벨)과 겹치지 않게 리본/pill 문구로만 확인한다.
    expect(find.textContaining('지금 무료 ·'), findsNothing);
    expect(find.text('지금 무료'), findsNothing);
    expect(find.text('무료입장 정책'), findsOneWidget);
  });
}
