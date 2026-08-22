import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vybe/data/models/club_table_layout.dart';
import 'package:vybe/presentation/clubs/widgets/table_floor_map.dart';
import 'package:vybe/presentation/clubs/widgets/table_pricing_section.dart';

// 배치도 렌더 — 격자 셀 → 픽셀 변환, 선택, 층 전환.
//
// 좌표 계산이 새로 들어간 곳이라 오버플로·탭 타겟을 여기서 잡는다.
// 파싱 규칙은 club_table_layout_test.dart 쪽.

Map<String, dynamic> _table(
  String id,
  String tierKey,
  int col,
  int row, {
  int price = 500000,
  int span = 2,
}) => {
  'id': id,
  'tierKey': tierKey,
  'name': '테이블 $id',
  'desc': '설명 $id',
  'col': col,
  'row': row,
  'colSpan': span,
  'rowSpan': span,
  'shape': 'rect',
  'price': price,
  'minPeople': 6,
  'minBottles': 2,
  'minSpend': price,
};

ClubTableLayout _layout({bool twoFloors = false, int cols = 12}) =>
    ClubTableLayout.fromMap({
      'schemaVersion': 1,
      'clubId': 'club_1',
      'tiers': [
        {
          'key': 'vvip',
          'name': 'VVIP',
          'short': 'VVIP',
          'colorKey': 'purple',
          'order': 0,
        },
        {
          'key': 'std',
          'name': 'STANDARD',
          'short': 'STD',
          'colorKey': 'gray',
          'order': 1,
        },
      ],
      'floors': [
        {
          'floorId': 'f1',
          'name': '1F',
          'order': 0,
          'cols': cols,
          'rows': 16,
          'fixtures': [
            {
              'id': 'fx1',
              'type': 'stage',
              'label': 'DJ BOOTH · STAGE',
              'col': 1,
              'row': 0,
              'colSpan': cols - 2,
              'rowSpan': 2,
            },
          ],
          'tables': [
            _table('S1', 'vvip', 0, 3, price: 1000000),
            _table('T1', 'std', cols - 2, 3, price: 200000),
          ],
        },
        if (twoFloors)
          {
            'floorId': 'f2',
            'name': '2F 라운지',
            'order': 1,
            'cols': 12,
            'rows': 12,
            'fixtures': const [],
            'tables': [_table('L1', 'std', 0, 3, price: 250000)],
          },
      ],
      'notice': '가격은 변동될 수 있습니다.',
    }, 'club_1')!;

Widget _host(Widget child) => ScreenUtilInit(
  designSize: const Size(393, 852),
  builder: (_, __) => MaterialApp(
    home: Scaffold(
      backgroundColor: const Color(0xFF0E0D12),
      body: SingleChildScrollView(child: child),
    ),
  ),
);

Future<void> _pump(WidgetTester tester, Widget child) async {
  tester.view.physicalSize = const Size(393, 852);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(_host(child));
  await tester.pump(const Duration(milliseconds: 200));
}

void main() {
  testWidgets('배치도·범례·상세가 오버플로 없이 그려진다', (tester) async {
    await _pump(tester, TablePricingSection(layout: _layout()));

    expect(find.text('DJ BOOTH · STAGE'), findsOneWidget);
    expect(find.text('100만'), findsWidgets); // 도형 + 범례
    expect(find.text('STANDARD'), findsWidgets);
    // 첫 진입은 첫 테이블이 선택돼 있다.
    expect(find.text('테이블 S1'), findsOneWidget);
    expect(find.text('1,000,000원'), findsWidgets);
    expect(find.text('가격은 변동될 수 있습니다.'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('테이블을 누르면 상세가 그 자리로 바뀐다', (tester) async {
    await _pump(tester, TablePricingSection(layout: _layout()));

    expect(find.text('테이블 S1'), findsOneWidget);
    await tester.tap(find.text('20만'));
    await tester.pump(const Duration(milliseconds: 200));

    expect(find.text('테이블 T1'), findsOneWidget);
    expect(find.text('테이블 S1'), findsNothing);
  });

  testWidgets('층이 하나면 층 탭을 그리지 않는다', (tester) async {
    await _pump(tester, TablePricingSection(layout: _layout()));

    expect(find.byType(FloorTabs), findsNothing);
  });

  testWidgets('층이 둘이면 탭이 뜨고, 층을 바꾸면 선택도 그 층으로 옮긴다', (tester) async {
    await _pump(tester, TablePricingSection(layout: _layout(twoFloors: true)));

    expect(find.byType(FloorTabs), findsOneWidget);
    expect(find.text('테이블 S1'), findsOneWidget);

    await tester.tap(find.text('2F 라운지'));
    await tester.pump(const Duration(milliseconds: 200));

    // 배치도 하이라이트가 없는 채로 다른 층 상세만 남아 있으면 안 된다.
    expect(find.text('테이블 L1'), findsOneWidget);
    expect(find.text('테이블 S1'), findsNothing);
  });

  testWidgets('격자가 최대 열이어도 테이블 탭 타겟이 44px 이상이다', (tester) async {
    // kMaxGridCols · 테이블 최소 2칸이 44px 하한을 지키는지 — 이 불변식이 깨지면
    // 업주가 놓은 테이블을 손가락으로 못 누른다.
    // 캔버스 안쪽 여백(_pad)도 격자 폭을 깎으므로 계산에 같이 들어간다.
    await _pump(
      tester,
      TablePricingSection(layout: _layout(cols: kMaxGridCols)),
    );

    final spot = find.ancestor(
      of: find.text('100만'),
      matching: find.byType(GestureDetector),
    );
    final size = tester.getSize(spot.first);

    expect(size.width, greaterThanOrEqualTo(44));
    expect(size.height, greaterThanOrEqualTo(44));
  });

  testWidgets('셀은 정사각 — 캔버스 높이가 cols/rows 비율을 따른다', (tester) async {
    await _pump(tester, TablePricingSection(layout: _layout()));

    final map = tester.getSize(find.byType(ClubFloorMap));
    // 12열 × 16행 → 격자가 3:4(가로:세로). 캔버스 여백(_pad)까지 포함해도 세로가 길다.
    expect(map.height / map.width, greaterThan(1.2));
    expect(map.height / map.width, lessThan(1.5));
    expect(tester.takeException(), isNull);
  });
}
