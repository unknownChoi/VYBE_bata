// 클럽 테이블 배치도 — `clubs/{clubId}/tableLayout/{clubId}` 문서 1건.
//
// 위치는 **정수 그리드 셀**이다. 층마다 `cols × rows` 격자를 두고 테이블·구조물은
// 자기가 점유하는 셀 사각형(`col`,`row`,`colSpan`,`rowSpan`)만 저장한다.
//
// 소수 좌표(0~1) 대신 격자를 쓰는 이유:
// - 웹(업주 편집기)과 앱이 `col * width / cols` 로 **반올림 여지 없이 같은 그림**을 그린다.
// - 캔버스 비율이 `cols / rows` 로 자동 도출된다(셀 정사각) — 양쪽이 따로 지켜야 할
//   `aspectRatio` 필드가 없다.
// - 겹침 판정이 셀 비교 한 줄이라 편집기가 원천 차단할 수 있다.
// - 회전 개념이 사라진다(축 정렬만).
//
// 문서 하나에 층·테이블·구조물을 전부 담는다. 배치도는 통째로 편집되고 통째로 읽히므로
// 문서를 쪼개면 앱은 read N회, 웹은 저장이 원자적이지 않아 **저장 도중 반쯤 옮겨진
// 배치도**가 앱에 보인다.

/// 앱이 읽을 수 있는 스키마 판. 문서가 이보다 높으면 렌더를 포기한다.
const int kTableLayoutSchemaVersion = 1;

/// 테이블 최소 점유 칸.
///
/// [kMaxGridCols](14)와 짝을 이뤄 **탭 타겟 44px 하한**을 격자 규칙만으로 보장한다.
/// 가장 좁은 흔한 기기(iPhone SE 375)에서 계산:
/// 섹션 좌우 20.w + 캔버스 안쪽 8.w 를 뺀 격자 폭 ≈ 321px ÷ 14열 ≈ 23px/셀, × 2칸 ≈ 46px.
/// 기준 폭 393 에서는 24px/셀 × 2 = 48px.
/// **열 수를 더 늘리면 이 보장이 깨져** 손가락으로 못 누르는 테이블이 생긴다.
const int kMinTableSpan = 2;

/// 격자 크기 허용 범위. 밖의 값은 clamp 한다.
const int kMinGridCols = 4;
const int kMaxGridCols = 14;
const int kMinGridRows = 4;
const int kMaxGridRows = 32;

// ============================================================================
// 격자 사각형
// ============================================================================

/// 격자 위에서 요소가 점유하는 셀 사각형.
class GridRect {
  /// 좌상단 셀 열 (0부터).
  final int col;

  /// 좌상단 셀 행 (0부터).
  final int row;

  /// 점유 열 수 (1 이상).
  final int colSpan;

  /// 점유 행 수 (1 이상).
  final int rowSpan;

  const GridRect({
    required this.col,
    required this.row,
    required this.colSpan,
    required this.rowSpan,
  });

  /// 격자 안으로 접어 넣으며 파싱한다.
  ///
  /// 업주 편집기가 격자 밖 배치를 막지만, 격자를 나중에 줄였거나 잘못된 문서가
  /// 들어와도 앱이 화면 밖에 그리지 않도록 여기서 한 번 더 가둔다.
  /// [minSpan] 은 테이블 2 / 구조물 1 (구조물은 탭 대상이 아니라 얇아도 된다).
  static GridRect parse(
    Map<String, dynamic> map, {
    required int cols,
    required int rows,
    required int minSpan,
  }) {
    var cw = _int(map['colSpan'], 1);
    var ch = _int(map['rowSpan'], 1);
    cw = cw.clamp(minSpan, cols);
    ch = ch.clamp(minSpan, rows);
    final c = _int(map['col'], 0).clamp(0, cols - cw);
    final r = _int(map['row'], 0).clamp(0, rows - ch);
    return GridRect(col: c, row: r, colSpan: cw, rowSpan: ch);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GridRect &&
          col == other.col &&
          row == other.row &&
          colSpan == other.colSpan &&
          rowSpan == other.rowSpan;

  @override
  int get hashCode => Object.hash(col, row, colSpan, rowSpan);

  @override
  String toString() => 'GridRect($col,$row,$colSpan×$rowSpan)';
}

// ============================================================================
// 구조물
// ============================================================================

/// 배치도에 놓이는 구조물 종류. Firestore 에는 **영문 키만** 저장하고
/// 라벨·색은 앱이 정한다(`ClubFacility` 와 같은 규칙).
///
/// 모르는 키는 [fromKey] 가 null 을 돌려주고 파서가 **버린다** —
/// 영문 키가 그대로 화면에 뜨는 것보다 안 그리는 편이 낫다.
enum FixtureType {
  stage('stage', 'STAGE'),
  dancefloor('dancefloor', 'DANCE FLOOR'),
  bar('bar', 'BAR'),
  dj('dj', 'DJ BOOTH'),
  entrance('entrance', 'ENTRANCE'),
  restroom('restroom', 'RESTROOM'),
  stairs('stairs', 'STAIRS'),
  wall('wall', ''),
  etc('etc', '');

  /// Firestore 에 저장되는 값.
  final String key;

  /// `label` 이 비었을 때 대신 쓰는 기본 문구.
  final String defaultLabel;

  const FixtureType(this.key, this.defaultLabel);

  static FixtureType? fromKey(String? key) {
    for (final t in FixtureType.values) {
      if (t.key == key) return t;
    }
    return null;
  }
}

/// 무대·바·댄스플로어 같은 배치도 구조물. 탭 대상이 아니다.
class FloorFixture {
  final String id;
  final FixtureType type;

  /// 표시 문구. 비면 [FixtureType.defaultLabel].
  final String label;

  final GridRect rect;

  const FloorFixture({
    required this.id,
    required this.type,
    required this.label,
    required this.rect,
  });

  /// 화면에 그릴 문구 (빈 문자열이면 문구 없이 도형만).
  String get displayLabel => label.isNotEmpty ? label : type.defaultLabel;

  /// 모르는 타입이면 null — 호출부가 목록에서 뺀다.
  static FloorFixture? fromMap(
    Map<String, dynamic> map, {
    required int cols,
    required int rows,
  }) {
    final type = FixtureType.fromKey(map['type'] as String?);
    if (type == null) return null;
    return FloorFixture(
      id: map['id'] as String? ?? '',
      type: type,
      label: map['label'] as String? ?? '',
      rect: GridRect.parse(map, cols: cols, rows: rows, minSpan: 1),
    );
  }
}

// ============================================================================
// 테이블
// ============================================================================

/// 격자 칸 안에서 그리는 모양. 모르는 값은 [rect] 로 폴백한다.
enum TableShape {
  rect('rect'),
  circle('circle');

  final String key;
  const TableShape(this.key);

  static TableShape fromKey(String? key) {
    for (final s in TableShape.values) {
      if (s.key == key) return s;
    }
    return TableShape.rect;
  }
}

/// 테이블 한 자리 — 위치 + 가격 + 예약 조건.
class ClubTable {
  /// 층 안에서 유일한 키 (예 'S1'). 업주가 부여한다.
  final String id;

  /// [TableTierDef.key] 참조.
  final String tierKey;

  /// 표시 이름 (예 '스테이지 프론트 A').
  final String name;

  /// 한 줄 설명 (예 '무대 바로 앞 · 최고의 시야').
  final String desc;

  final GridRect rect;
  final TableShape shape;

  /// 테이블 가격(원). 0이면 '문의'.
  final int price;

  /// 최소 인원(명).
  final int minPeople;

  /// 최소 주문 보틀(병).
  final int minBottles;

  /// 최소 주문 금액(원).
  final int minSpend;

  /// 자유 문구 (선택).
  final String note;

  const ClubTable({
    required this.id,
    required this.tierKey,
    required this.name,
    required this.desc,
    required this.rect,
    required this.shape,
    required this.price,
    required this.minPeople,
    required this.minBottles,
    required this.minSpend,
    required this.note,
  });

  /// `isActive:false` 면 null — 호출부가 목록에서 뺀다(공사중·시즌 운영).
  static ClubTable? fromMap(
    Map<String, dynamic> map, {
    required int cols,
    required int rows,
  }) {
    if (map['isActive'] == false) return null;
    return ClubTable(
      id: map['id'] as String? ?? '',
      tierKey: map['tierKey'] as String? ?? '',
      name: map['name'] as String? ?? '',
      desc: map['desc'] as String? ?? '',
      rect: GridRect.parse(map, cols: cols, rows: rows, minSpan: kMinTableSpan),
      shape: TableShape.fromKey(map['shape'] as String?),
      price: _int(map['price'], 0),
      minPeople: _int(map['minPeople'], 0),
      minBottles: _int(map['minBottles'], 0),
      minSpend: _int(map['minSpend'], 0),
      note: map['note'] as String? ?? '',
    );
  }
}

// ============================================================================
// 등급
// ============================================================================

/// 테이블 등급 정의. 등급 구성은 클럽마다 달라 전역 상수로 두지 않는다.
class TableTierDef {
  /// [ClubTable.tierKey] 가 가리키는 키 (예 'vvip').
  final String key;

  /// 상세 배지 라벨 (예 'VVIP').
  final String name;

  /// 배치도 도형 안 짧은 라벨 (예 'VVIP'). 비면 [name].
  final String short;

  /// 색 팔레트 키. 실제 색값은 앱이 소유한다
  /// (업주가 hex 를 자유 입력하면 다크 배경에서 안 보이는 색이 나온다).
  final String colorKey;

  final int order;

  const TableTierDef({
    required this.key,
    required this.name,
    required this.short,
    required this.colorKey,
    required this.order,
  });

  /// 정의가 없는 `tierKey` 를 가진 테이블용 폴백.
  static const unknown = TableTierDef(
    key: '',
    name: 'TABLE',
    short: 'TBL',
    colorKey: 'gray',
    order: 999,
  );

  factory TableTierDef.fromMap(Map<String, dynamic> map, int index) {
    final name = map['name'] as String? ?? '';
    final short = map['short'] as String? ?? '';
    return TableTierDef(
      key: map['key'] as String? ?? '',
      name: name.isNotEmpty ? name : 'TABLE',
      short: short.isNotEmpty ? short : (name.isNotEmpty ? name : 'TBL'),
      colorKey: map['colorKey'] as String? ?? 'gray',
      order: _int(map['order'], index),
    );
  }
}

// ============================================================================
// 층
// ============================================================================

/// 배치도 한 층.
class TableFloor {
  /// 층 삭제·재정렬에도 안 바뀌는 키.
  final String floorId;

  /// 표시 이름 (예 '1F', '루프탑').
  final String name;

  final int order;

  /// 격자 열 수.
  final int cols;

  /// 격자 행 수.
  final int rows;

  /// 방 모양 마스크 — 길이 `cols * rows`, 행 우선. `'1'` = 방 안, `'0'` = 방 밖.
  ///
  /// 클럽 홀이 직사각형이 아니라서(ㄱ자·계단 옆이 파인 형태 등) 격자 안에서
  /// 실제 바닥만 남길 수 있게 둔다. 길이가 안 맞거나 비면 **전부 방 안**으로 본다 —
  /// 마스크는 표현일 뿐이라, 깨졌다고 배치도를 통째로 버리면 손해가 더 크다.
  final String cells;

  final List<FloorFixture> fixtures;
  final List<ClubTable> tables;

  const TableFloor({
    required this.floorId,
    required this.name,
    required this.order,
    required this.cols,
    required this.rows,
    required this.cells,
    required this.fixtures,
    required this.tables,
  });

  /// 캔버스 가로/세로 비. 셀이 정사각이므로 격자 모양이 곧 캔버스 모양이다.
  double get aspectRatio => cols / rows;

  /// 마스크가 없거나(빈 문자열) 전부 방 안이면 true — 예전처럼 둥근 사각 판으로 그린다.
  bool get isFullRect => cells.isEmpty;

  /// 이 셀이 방 안인가. 격자 밖은 항상 false.
  bool isInside(int col, int row) {
    if (col < 0 || row < 0 || col >= cols || row >= rows) return false;
    if (cells.isEmpty) return true;
    return cells.codeUnitAt(row * cols + col) != _kCellOut;
  }

  /// 사각 영역이 전부 방 안인가 (테이블 배치 검사용).
  bool containsRect(GridRect r) {
    for (var y = r.row; y < r.row + r.rowSpan; y++) {
      for (var x = r.col; x < r.col + r.colSpan; x++) {
        if (!isInside(x, y)) return false;
      }
    }
    return true;
  }

  factory TableFloor.fromMap(Map<String, dynamic> map, int index) {
    final cols = _int(map['cols'], 12).clamp(kMinGridCols, kMaxGridCols);
    final rows = _int(map['rows'], 16).clamp(kMinGridRows, kMaxGridRows);

    final fixtures = <FloorFixture>[];
    for (final e in _mapList(map['fixtures'])) {
      final f = FloorFixture.fromMap(e, cols: cols, rows: rows);
      if (f != null) fixtures.add(f);
    }

    final tables = <ClubTable>[];
    for (final e in _mapList(map['tables'])) {
      final t = ClubTable.fromMap(e, cols: cols, rows: rows);
      if (t != null) tables.add(t);
    }

    final name = map['name'] as String? ?? '';
    return TableFloor(
      floorId: map['floorId'] as String? ?? 'f${index + 1}',
      name: name.isNotEmpty ? name : '${index + 1}F',
      order: _int(map['order'], index),
      cols: cols,
      rows: rows,
      cells: _cellMask(map['cells'], cols, rows),
      fixtures: fixtures,
      tables: tables,
    );
  }
}

// ============================================================================
// 배치도 전체
// ============================================================================

class ClubTableLayout {
  final String clubId;

  /// 등급 정의. `order` 오름차순으로 정렬돼 있다.
  final List<TableTierDef> tiers;

  /// 층 목록. `order` 오름차순. 테이블이 하나도 없는 층은 빠져 있다.
  final List<TableFloor> floors;

  /// 하단 안내 문구.
  final String notice;

  const ClubTableLayout({
    required this.clubId,
    required this.tiers,
    required this.floors,
    required this.notice,
  });

  /// 전 층 테이블 수.
  int get tableCount => floors.fold(0, (sum, f) => sum + f.tables.length);

  /// 층 전환 탭이 필요한지.
  bool get isMultiFloor => floors.length >= 2;

  /// 정의가 없는 키는 [TableTierDef.unknown] — 테이블을 통째로 버리지 않는다
  /// (등급 정의를 지운 실수 때문에 배치도가 사라지면 더 나쁘다).
  TableTierDef tierOf(String key) {
    for (final t in tiers) {
      if (t.key == key) return t;
    }
    return TableTierDef.unknown;
  }

  /// 실제로 쓰이고 있는 등급만 (범례·요약용).
  List<TableTierDef> usedTiers() {
    final keys = <String>{
      for (final f in floors)
        for (final t in f.tables) t.tierKey,
    };
    return tiers.where((t) => keys.contains(t.key)).toList();
  }

  /// 해당 등급의 테이블 (전 층 합산).
  List<ClubTable> tablesOfTier(String tierKey) => [
    for (final f in floors)
      for (final t in f.tables)
        if (t.tierKey == tierKey) t,
  ];

  /// 문서 → 모델. **그릴 게 없으면 null** — 호출부는 섹션 자체를 뺀다.
  ///
  /// null 을 돌려주는 경우:
  /// - 문서 없음 / 빈 문서
  /// - `schemaVersion` 이 앱이 아는 판보다 높음 (모르는 필드를 억지로 그리면 깨진다)
  /// - 테이블이 한 자리도 없음 (빈 배치도는 '테이블 없음'과 구분이 안 된다)
  static ClubTableLayout? fromMap(Map<String, dynamic>? data, String clubId) {
    if (data == null || data.isEmpty) return null;

    final version = _int(data['schemaVersion'], kTableLayoutSchemaVersion);
    if (version > kTableLayoutSchemaVersion) return null;

    final tiers = <TableTierDef>[];
    final tierMaps = _mapList(data['tiers']);
    for (var i = 0; i < tierMaps.length; i++) {
      tiers.add(TableTierDef.fromMap(tierMaps[i], i));
    }
    tiers.sort((a, b) => a.order.compareTo(b.order));

    final floors = <TableFloor>[];
    final floorMaps = _mapList(data['floors']);
    for (var i = 0; i < floorMaps.length; i++) {
      final f = TableFloor.fromMap(floorMaps[i], i);
      // 테이블 없는 층은 뺀다 — 층 탭을 눌렀는데 빈 격자만 나오면 고장으로 보인다.
      if (f.tables.isEmpty) continue;
      floors.add(f);
    }
    floors.sort((a, b) => a.order.compareTo(b.order));
    if (floors.isEmpty) return null;

    return ClubTableLayout(
      clubId: data['clubId'] as String? ?? clubId,
      tiers: tiers,
      floors: floors,
      notice: data['notice'] as String? ?? '',
    );
  }
}

// ============================================================================
// 파싱 헬퍼
// ============================================================================

/// 방 밖을 뜻하는 문자 `'0'`.
const int _kCellOut = 0x30;

/// 방 모양 마스크 정규화. **빈 문자열 = 전부 방 안**.
///
/// 길이가 `cols * rows` 와 다르면(격자를 바꾼 뒤 마스크를 안 고친 문서) 버린다 —
/// 어긋난 마스크로 그리면 엉뚱한 칸이 뚫려 배치도가 거짓말을 한다.
/// 전부 `'0'` 인 마스크도 버린다(바닥이 없는 층은 그릴 게 없다).
String _cellMask(Object? v, int cols, int rows) {
  if (v is! String || v.length != cols * rows) return '';
  if (!v.contains('1')) return '';
  if (!v.contains('0')) return ''; // 전부 방 안 = 마스크 없는 것과 같다
  return v;
}

/// Firestore 숫자는 int/double 어느 쪽으로도 올 수 있다.
int _int(Object? v, int fallback) {
  if (v is int) return v;
  if (v is double) return v.round();
  if (v is num) return v.toInt();
  return fallback;
}

List<Map<String, dynamic>> _mapList(Object? v) {
  if (v is! List) return const [];
  return [
    for (final e in v)
      if (e is Map) Map<String, dynamic>.from(e),
  ];
}
