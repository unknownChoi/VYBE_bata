import 'package:flutter_test/flutter_test.dart';
import 'package:vybe/data/models/club_table_layout.dart';
import 'package:vybe/presentation/common/table_price_format.dart';

// 테이블 배치도 파서 — 업주 웹이 쓴 문서를 앱이 그릴 수 있는 모양으로 접어 넣는다.
//
// 여기서 막는 것들은 전부 "웹이 막아야 하지만 막혔다고 믿으면 안 되는" 값들이다 —
// 격자를 나중에 줄였거나, 앱보다 새 판으로 저장됐거나, 스키마 밖 값이 들어온 경우.

Map<String, dynamic> _table({
  String id = 'T1',
  String tierKey = 'vip',
  int col = 0,
  int row = 0,
  int colSpan = 2,
  int rowSpan = 2,
  int price = 500000,
  bool? isActive,
}) => {
  'id': id,
  'tierKey': tierKey,
  'name': '테이블 $id',
  'desc': '설명',
  'col': col,
  'row': row,
  'colSpan': colSpan,
  'rowSpan': rowSpan,
  'shape': 'rect',
  'price': price,
  'minPeople': 6,
  'minBottles': 2,
  'minSpend': price,
  if (isActive != null) 'isActive': isActive,
};

Map<String, dynamic> _doc({
  int schemaVersion = 1,
  int cols = 12,
  int rows = 16,
  List<Map<String, dynamic>>? tables,
  List<Map<String, dynamic>>? fixtures,
  List<Map<String, dynamic>>? floors,
  List<Map<String, dynamic>>? tiers,
}) => {
  'schemaVersion': schemaVersion,
  'clubId': 'club_1',
  'tiers':
      tiers ??
      [
        {
          'key': 'vip',
          'name': 'VIP',
          'short': 'VIP',
          'colorKey': 'blue',
          'order': 0,
        },
      ],
  'floors':
      floors ??
      [
        {
          'floorId': 'f1',
          'name': '1F',
          'order': 0,
          'cols': cols,
          'rows': rows,
          'fixtures': fixtures ?? const [],
          'tables': tables ?? [_table()],
        },
      ],
  'notice': '가격은 변동될 수 있습니다.',
};

ClubTableLayout _parse(Map<String, dynamic> doc) =>
    ClubTableLayout.fromMap(doc, 'club_1')!;

void main() {
  group('정상 파싱', () {
    test('층·등급·테이블·안내문구를 그대로 읽는다', () {
      final layout = _parse(_doc());

      expect(layout.clubId, 'club_1');
      expect(layout.floors, hasLength(1));
      expect(layout.floors.first.cols, 12);
      expect(layout.floors.first.rows, 16);
      expect(layout.tableCount, 1);
      expect(layout.isMultiFloor, isFalse);
      expect(layout.notice, '가격은 변동될 수 있습니다.');

      final t = layout.floors.first.tables.first;
      expect(t.id, 'T1');
      expect(t.price, 500000);
      expect(t.minPeople, 6);
      expect(t.minBottles, 2);
      expect(t.minSpend, 500000);
      expect(t.rect, const GridRect(col: 0, row: 0, colSpan: 2, rowSpan: 2));
    });

    test('캔버스 비율은 cols/rows 에서 도출된다 (셀 정사각)', () {
      final layout = _parse(_doc(cols: 12, rows: 16));
      expect(layout.floors.first.aspectRatio, 12 / 16);
    });

    test('층은 order 오름차순으로 정렬된다', () {
      final layout = _parse(
        _doc(
          floors: [
            {
              'floorId': 'f2',
              'name': '2F',
              'order': 1,
              'cols': 12,
              'rows': 16,
              'tables': [_table(id: 'A')],
            },
            {
              'floorId': 'f1',
              'name': '1F',
              'order': 0,
              'cols': 12,
              'rows': 16,
              'tables': [_table(id: 'B')],
            },
          ],
        ),
      );

      expect(layout.floors.map((f) => f.name), ['1F', '2F']);
      expect(layout.isMultiFloor, isTrue);
      expect(layout.tableCount, 2);
    });
  });

  group('격자 밖 값은 접어 넣는다', () {
    test('격자를 넘는 위치는 안쪽으로 밀어 넣는다', () {
      // 격자를 12열로 줄였는데 예전 문서가 20열 위치를 들고 있는 상황.
      final layout = _parse(
        _doc(cols: 12, rows: 16, tables: [_table(col: 20, row: 30)]),
      );
      final r = layout.floors.first.tables.first.rect;

      expect(r.col + r.colSpan, lessThanOrEqualTo(12));
      expect(r.row + r.rowSpan, lessThanOrEqualTo(16));
    });

    test('격자보다 큰 span 은 격자 크기로 자른다', () {
      final layout = _parse(
        _doc(cols: 12, rows: 16, tables: [_table(colSpan: 40, rowSpan: 40)]),
      );
      final r = layout.floors.first.tables.first.rect;

      expect(r.colSpan, 12);
      expect(r.rowSpan, 16);
      expect(r.col, 0);
      expect(r.row, 0);
    });

    test('1칸 테이블은 2칸으로 키운다 — 탭 타겟 44px 하한', () {
      final layout = _parse(_doc(tables: [_table(colSpan: 1, rowSpan: 1)]));
      final r = layout.floors.first.tables.first.rect;

      expect(r.colSpan, kMinTableSpan);
      expect(r.rowSpan, kMinTableSpan);
    });

    test('구조물은 1칸을 허용한다 — 벽·바는 얇아도 되고 탭 대상이 아니다', () {
      final layout = _parse(
        _doc(
          fixtures: [
            {
              'id': 'w1',
              'type': 'wall',
              'col': 0,
              'row': 0,
              'colSpan': 1,
              'rowSpan': 8,
            },
          ],
        ),
      );

      expect(layout.floors.first.fixtures.first.rect.colSpan, 1);
    });

    test('격자 크기 자체가 범위 밖이면 clamp 한다', () {
      final layout = _parse(_doc(cols: 99, rows: 99));

      expect(layout.floors.first.cols, kMaxGridCols);
      expect(layout.floors.first.rows, kMaxGridRows);
    });
  });

  group('방 모양 마스크 (cells)', () {
    // 4×4 격자에서 오른쪽 아래 2×2 를 도려낸 ㄱ자 방.
    const lShape =
        '1111'
        '1111'
        '1100'
        '1100';

    ClubTableLayout parseWithCells(
      String? cells, {
      int cols = 4,
      int rows = 4,
    }) => ClubTableLayout.fromMap({
      'schemaVersion': 1,
      'clubId': 'club_1',
      'tiers': [
        {'key': 'vip', 'name': 'VIP', 'colorKey': 'blue', 'order': 0},
      ],
      'floors': [
        {
          'floorId': 'f1',
          'name': '1F',
          'order': 0,
          'cols': cols,
          'rows': rows,
          if (cells != null) 'cells': cells,
          'tables': [_table(id: 'A', col: 0, row: 0)],
        },
      ],
    }, 'club_1')!;

    test('마스크가 없으면 전부 방 안', () {
      final f = parseWithCells(null).floors.first;

      expect(f.isFullRect, isTrue);
      expect(f.isInside(3, 3), isTrue);
    });

    test('도려낸 칸은 방 밖', () {
      final f = parseWithCells(lShape).floors.first;

      expect(f.isFullRect, isFalse);
      expect(f.isInside(0, 0), isTrue);
      expect(f.isInside(1, 3), isTrue);
      expect(f.isInside(2, 2), isFalse);
      expect(f.isInside(3, 3), isFalse);
    });

    test('격자 밖은 항상 방 밖 — 외곽선을 그릴 때 경계가 된다', () {
      final f = parseWithCells(lShape).floors.first;

      expect(f.isInside(-1, 0), isFalse);
      expect(f.isInside(0, -1), isFalse);
      expect(f.isInside(4, 0), isFalse);
      expect(f.isInside(0, 4), isFalse);
    });

    test('containsRect — 테이블이 방 안에 온전히 들어가는지', () {
      final f = parseWithCells(lShape).floors.first;

      expect(
        f.containsRect(const GridRect(col: 0, row: 0, colSpan: 2, rowSpan: 2)),
        isTrue,
      );
      // 오른쪽 아래로 걸치면 도려낸 칸을 밟는다.
      expect(
        f.containsRect(const GridRect(col: 2, row: 2, colSpan: 2, rowSpan: 2)),
        isFalse,
      );
    });

    test('길이가 격자와 안 맞으면 버린다 — 어긋난 마스크는 엉뚱한 칸을 뚫는다', () {
      final f = parseWithCells('1111').floors.first; // 4칸뿐인데 격자는 16칸

      expect(f.isFullRect, isTrue);
      expect(f.isInside(3, 3), isTrue);
    });

    test('전부 방 밖이면 버린다 — 바닥 없는 층은 그릴 게 없다', () {
      final f = parseWithCells('0' * 16).floors.first;

      expect(f.isFullRect, isTrue);
    });

    test('전부 방 안인 마스크는 없는 것과 같게 다룬다 (둥근 카드로 그린다)', () {
      final f = parseWithCells('1' * 16).floors.first;

      expect(f.isFullRect, isTrue);
    });
  });

  group('모르는 값 처리', () {
    test('모르는 구조물 타입은 버린다 — 영문 키가 화면에 뜨면 안 된다', () {
      final layout = _parse(
        _doc(
          fixtures: [
            {
              'id': 'x',
              'type': 'hologram_deck',
              'col': 0,
              'row': 0,
              'colSpan': 2,
              'rowSpan': 2,
            },
            {
              'id': 'b',
              'type': 'bar',
              'col': 0,
              'row': 14,
              'colSpan': 12,
              'rowSpan': 2,
            },
          ],
        ),
      );

      expect(layout.floors.first.fixtures, hasLength(1));
      expect(layout.floors.first.fixtures.first.type, FixtureType.bar);
    });

    test('모르는 shape 은 rect 로 떨어진다', () {
      final t = _table();
      t['shape'] = 'hexagon';
      final layout = _parse(_doc(tables: [t]));

      expect(layout.floors.first.tables.first.shape, TableShape.rect);
    });

    test('정의 없는 tierKey 는 테이블을 버리지 않고 폴백 등급을 준다', () {
      final layout = _parse(_doc(tables: [_table(tierKey: 'ghost')]));

      expect(layout.tableCount, 1);
      expect(layout.tierOf('ghost'), same(TableTierDef.unknown));
    });

    test('구조물 라벨이 비면 타입 기본 문구를 쓴다', () {
      final layout = _parse(
        _doc(
          fixtures: [
            {
              'id': 's',
              'type': 'stage',
              'col': 0,
              'row': 0,
              'colSpan': 12,
              'rowSpan': 2,
            },
          ],
        ),
      );

      expect(layout.floors.first.fixtures.first.displayLabel, 'STAGE');
    });

    test('숫자가 double 로 와도 int 로 읽는다 (Firestore 수 타입)', () {
      final t = _table();
      t['col'] = 3.0;
      t['price'] = 500000.0;
      final layout = _parse(_doc(tables: [t]));

      expect(layout.floors.first.tables.first.rect.col, 3);
      expect(layout.floors.first.tables.first.price, 500000);
    });
  });

  group('그릴 게 없으면 null — 호출부가 섹션을 통째로 뺀다', () {
    test('문서 없음 / 빈 문서', () {
      expect(ClubTableLayout.fromMap(null, 'club_1'), isNull);
      expect(ClubTableLayout.fromMap({}, 'club_1'), isNull);
    });

    test('앱이 모르는 schemaVersion 이면 렌더를 포기한다', () {
      expect(
        ClubTableLayout.fromMap(
          _doc(schemaVersion: kTableLayoutSchemaVersion + 1),
          'club_1',
        ),
        isNull,
      );
    });

    test('테이블이 한 자리도 없으면 null', () {
      expect(ClubTableLayout.fromMap(_doc(tables: []), 'club_1'), isNull);
    });

    test('isActive:false 테이블은 빠지고, 그것뿐이면 null', () {
      expect(
        ClubTableLayout.fromMap(
          _doc(tables: [_table(isActive: false)]),
          'club_1',
        ),
        isNull,
      );

      final layout = _parse(
        _doc(
          tables: [
            _table(id: 'A'),
            _table(id: 'B', isActive: false),
          ],
        ),
      );
      expect(layout.tableCount, 1);
      expect(layout.floors.first.tables.first.id, 'A');
    });

    test('테이블 없는 층은 목록에서 빠진다 — 빈 격자만 나오는 층 탭 방지', () {
      final layout = _parse(
        _doc(
          floors: [
            {
              'floorId': 'f1',
              'name': '1F',
              'order': 0,
              'cols': 12,
              'rows': 16,
              'tables': [_table()],
            },
            {
              'floorId': 'f2',
              'name': '2F',
              'order': 1,
              'cols': 12,
              'rows': 16,
              'tables': const [],
            },
          ],
        ),
      );

      expect(layout.floors, hasLength(1));
      expect(layout.isMultiFloor, isFalse);
    });
  });

  group('등급 조회', () {
    test('usedTiers 는 실제로 쓰인 등급만 돌려준다', () {
      final layout = _parse(
        _doc(
          tiers: [
            {'key': 'vvip', 'name': 'VVIP', 'colorKey': 'purple', 'order': 0},
            {'key': 'vip', 'name': 'VIP', 'colorKey': 'blue', 'order': 1},
          ],
          tables: [_table(tierKey: 'vip')],
        ),
      );

      expect(layout.usedTiers().map((t) => t.key), ['vip']);
    });

    test('short 가 비면 name 으로 채운다', () {
      final layout = _parse(
        _doc(
          tiers: [
            {'key': 'vip', 'name': 'VIP', 'colorKey': 'blue', 'order': 0},
          ],
        ),
      );

      expect(layout.tierOf('vip').short, 'VIP');
    });

    test('tablesOfTier 는 전 층을 합산한다', () {
      final layout = _parse(
        _doc(
          floors: [
            {
              'floorId': 'f1',
              'name': '1F',
              'order': 0,
              'cols': 12,
              'rows': 16,
              'tables': [_table(id: 'A')],
            },
            {
              'floorId': 'f2',
              'name': '2F',
              'order': 1,
              'cols': 12,
              'rows': 16,
              'tables': [_table(id: 'B')],
            },
          ],
        ),
      );

      expect(layout.tablesOfTier('vip'), hasLength(2));
    });
  });

  group('금액 표기', () {
    test('배치도 도형용 짧은 표기', () {
      expect(formatTablePriceShort(1000000), '100만');
      expect(formatTablePriceShort(500000), '50만');
      expect(formatTablePriceShort(1250000), '125만');
      expect(formatTablePriceShort(1234000), '123.4만');
      expect(formatTablePriceShort(9000), '9,000');
    });

    test('상세 카드용 정식 표기', () {
      expect(formatWon(1000000), '1,000,000원');
      expect(formatWon(500000), '500,000원');
    });

    test('0원은 무료가 아니라 문의 — 테이블은 공짜로 주는 상품이 아니다', () {
      expect(formatTablePriceShort(0), '문의');
      expect(formatWon(0), '문의');
    });
  });
}
