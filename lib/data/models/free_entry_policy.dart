/// 클럽 무료입장 정책 (`clubs.freeEntry`) + "지금 무료인가" 판정.
///
/// Firestore 는 "요일 × 시:분 × 자정 넘김"을 쿼리할 수 없어 서버 쿼리는
/// `isFreeEntry` / `freeEntry.type` 까지만 좁히고, **지금 시각 판정은 여기서**
/// 끝낸다. 판정 로직을 여러 화면에 흩뿌리면 카드·상세·필터가 서로 다른 답을
/// 내놓으므로 [FreeEntryPolicy.statusAt] 하나만 쓴다.
///
/// Firebase 의존이 없는 순수 Dart — 테스트는 `test/free_entry_policy_test.dart`.
library;

/// 무료입장 종류.
enum FreeEntryType {
  /// 무료입장 없음.
  none,

  /// 상시 무료 (`entryFeeMin == 0`).
  always,

  /// 특정 시간대만 무료. 그 밖 시간엔 `entryFeeMin~entryFeeMax` 일반 입장비.
  timed;

  static FreeEntryType parse(String? raw) => switch (raw) {
    'always' => FreeEntryType.always,
    'timed' => FreeEntryType.timed,
    // 모르는 값은 '무료 아님'으로 — 유료 클럽이 무료로 노출되는 쪽이 더 나쁘다.
    _ => FreeEntryType.none,
  };

  String get key => name;
}

/// 요일 키 (`operatingHours` 와 같은 문자열을 쓴다 — 두 벌을 만들지 않는다).
const _kDayKeys = ['mon', 'tue', 'wed', 'thu', 'fri', 'sat', 'sun'];

/// `DateTime.weekday`(1=월) → 요일 키.
String dayKeyOf(int weekday) => _kDayKeys[(weekday - 1) % 7];

/// 무료 시간창 하나.
///
/// - [days] 가 비면 **매일**.
/// - [start] 포함, [end] 미포함.
/// - `end < start` 면 **자정을 넘긴 창**이고, 창은 언제나 **시작 요일**에 속한다.
///   (금 `23:00~02:00` 은 토요일 01:00 도 무료 — 그래서 판정이 어제 창까지 본다)
class FreeEntryWindow {
  /// `['fri','sat']` 형태. 빈 배열이면 매일.
  final List<String> days;

  /// `"22:00"` — 포함.
  final String start;

  /// `"01:00"` — 미포함.
  final String end;

  /// 창별 부가 문구 (`'오픈런'`). 없으면 빈 문자열.
  final String label;

  const FreeEntryWindow({
    this.days = const [],
    required this.start,
    required this.end,
    this.label = '',
  });

  /// 쓸 수 있는 창인지 — 두 시각이 다 유효하고 서로 달라야 한다.
  ///
  /// ⚠ `start == end` 를 '24시간'으로 읽지 않는다. 깨진 데이터 한 줄이
  /// 유료 클럽을 **종일 무료**로 만들어 버리기 때문. 상시 무료는 `type: 'always'`.
  bool get isValid =>
      _startMin >= 0 && _endMin >= 0 && _startMin < 1440 && _startMin != _endMin;

  /// 자정 이후로 이어지는 창인지 (`end < start`).
  bool get crossesMidnight => isValid && _endMin < _startMin;

  /// 창 길이(분). 자정을 넘기면 다음 날 몫까지 더한다. 잘못된 창은 0(무시된다).
  int get durationMinutes {
    if (!isValid) return 0;
    return crossesMidnight ? 1440 - _startMin + _endMin : _endMin - _startMin;
  }

  int get _startMin => _toMinutes(start);
  int get _endMin => _toMinutes(end);

  /// 시작 시각이 [day] 인 실제 구간. 길이가 0 이하인 창은 null(잘못된 데이터).
  ///
  /// [day] 의 시:분은 무시하고 날짜만 쓴다.
  (DateTime start, DateTime end)? occurrenceOn(DateTime day) {
    final minutes = durationMinutes;
    if (minutes <= 0) return null;
    final from = DateTime(
      day.year,
      day.month,
      day.day,
    ).add(Duration(minutes: _startMin));
    return (from, from.add(Duration(minutes: minutes)));
  }

  /// 이 창이 [weekday] 에 시작하는지.
  bool startsOnWeekday(int weekday) =>
      days.isEmpty || days.contains(dayKeyOf(weekday));

  /// 표시용 시간 범위 — `22:00 – 23:30`.
  String get rangeLabel => '$start – $end';

  factory FreeEntryWindow.fromMap(Map<String, dynamic> map) {
    return FreeEntryWindow(
      days:
          (map['days'] as List?)
              ?.map((e) => e.toString())
              .where(_kDayKeys.contains)
              .toList() ??
          const [],
      start: map['start'] as String? ?? '',
      end: map['end'] as String? ?? '',
      label: map['label'] as String? ?? '',
    );
  }

  Map<String, dynamic> toMap() => {
    'days': days,
    'start': start,
    'end': end,
    'label': label,
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FreeEntryWindow &&
          start == other.start &&
          end == other.end &&
          label == other.label &&
          _sameDays(days, other.days);

  @override
  int get hashCode => Object.hash(start, end, label, Object.hashAll(days));
}

/// `"22:00"` → 1320. 형식이 깨졌거나 범위를 벗어나면 **-1**.
///
/// 범위 검사를 빠뜨리면 `"22:99"`·`"25:00"` 같은 값이 그럴듯한 분 수로 통과해
/// 창이 엉뚱하게 길어진다 — 무료 시간이 늘어나는 쪽으로 틀리므로 반드시 막는다.
/// `"24:00"`(= 자정)만 예외로 허용한다.
int _toMinutes(String hhmm) {
  final parts = hhmm.split(':');
  if (parts.length != 2) return -1;
  final h = int.tryParse(parts[0]);
  final m = int.tryParse(parts[1]);
  if (h == null || m == null) return -1;
  if (h < 0 || h > 24 || m < 0 || m > 59) return -1;
  if (h == 24 && m != 0) return -1;
  return h * 60 + m;
}

bool _sameDays(List<String> a, List<String> b) {
  if (a.length != b.length) return false;
  for (var i = 0; i < a.length; i++) {
    if (a[i] != b[i]) return false;
  }
  return true;
}

/// 클럽 하나의 무료입장 정책.
class FreeEntryPolicy {
  final FreeEntryType type;

  /// 조건 코멘트 (`'자정 이전 입장 무료'`).
  final String condition;

  /// [FreeEntryType.timed] 일 때만 의미가 있다. 비어 있으면 무료 시간이 없다.
  final List<FreeEntryWindow> windows;

  const FreeEntryPolicy({
    this.type = FreeEntryType.none,
    this.condition = '',
    this.windows = const [],
  });

  /// 필드가 없는 문서(백필 전)의 기본값.
  static const none = FreeEntryPolicy();

  bool get isTimed => type == FreeEntryType.timed;
  bool get isAlways => type == FreeEntryType.always;

  /// 무료 정책을 가지고 있는지 (= `clubs.isFreeEntry` 와 같은 값).
  bool get hasFreeEntry => type != FreeEntryType.none;

  /// [now] 기준 무료 상태.
  ///
  /// - [FreeEntryType.always] → 항상 무료 (창 없음).
  /// - [FreeEntryType.timed] → 오늘·어제 창을 훑어 지금 걸린 창을 찾고,
  ///   없으면 앞으로 7일 안의 가장 이른 창을 [FreeEntryStatus.nextStartsAt] 로 준다.
  FreeEntryStatus statusAt(DateTime now) {
    if (type == FreeEntryType.none) return FreeEntryStatus.none;
    if (type == FreeEntryType.always) return FreeEntryStatus.always;
    if (windows.isEmpty) return FreeEntryStatus.none;

    final today = DateTime(now.year, now.month, now.day);

    // 어제 시작해 자정을 넘긴 창이 지금 살아 있을 수 있어 -1일부터 본다.
    FreeEntryWindow? nextWindow;
    DateTime? nextStart;

    for (var offset = -1; offset <= 7; offset++) {
      final day = today.add(Duration(days: offset));
      for (final w in windows) {
        if (!w.startsOnWeekday(day.weekday)) continue;
        final range = w.occurrenceOn(day);
        if (range == null) continue;
        final (from, to) = range;

        // start 포함 · end 미포함.
        if (!now.isBefore(from) && now.isBefore(to)) {
          return FreeEntryStatus(
            isFreeNow: true,
            active: w,
            activeEndsAt: to,
          );
        }
        if (from.isAfter(now) && (nextStart == null || from.isBefore(nextStart))) {
          nextStart = from;
          nextWindow = w;
        }
      }
      // 다음 창을 이미 찾았고 그날이 지났으면 더 볼 필요 없다.
      if (nextStart != null && day.isAfter(nextStart)) break;
    }

    return FreeEntryStatus(next: nextWindow, nextStartsAt: nextStart);
  }

  factory FreeEntryPolicy.fromMap(Map<String, dynamic>? map) {
    if (map == null) return none;
    return FreeEntryPolicy(
      type: FreeEntryType.parse(map['type'] as String?),
      condition: map['condition'] as String? ?? '',
      windows:
          (map['windows'] as List?)
              ?.whereType<Map>()
              .map((e) => FreeEntryWindow.fromMap(Map<String, dynamic>.from(e)))
              .toList() ??
          const [],
    );
  }

  Map<String, dynamic> toMap() => {
    'type': type.key,
    'condition': condition,
    'windows': windows.map((w) => w.toMap()).toList(),
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FreeEntryPolicy &&
          type == other.type &&
          condition == other.condition &&
          _sameWindows(windows, other.windows);

  @override
  int get hashCode => Object.hash(type, condition, Object.hashAll(windows));
}

bool _sameWindows(List<FreeEntryWindow> a, List<FreeEntryWindow> b) {
  if (a.length != b.length) return false;
  for (var i = 0; i < a.length; i++) {
    if (a[i] != b[i]) return false;
  }
  return true;
}

/// [FreeEntryPolicy.statusAt] 결과.
class FreeEntryStatus {
  /// 지금 무료인지. **화면에 '지금 무료'를 띄울 땐 영업 중인지도 같이 봐야 한다**
  /// — 문 닫은 클럽의 '지금 무료'는 거짓 정보다.
  final bool isFreeNow;

  /// 지금 걸려 있는 창 (상시 무료면 null).
  final FreeEntryWindow? active;

  /// 지금 창이 끝나는 시각.
  final DateTime? activeEndsAt;

  /// 다음 무료 창 (지금 무료면 null).
  final FreeEntryWindow? next;

  /// 다음 무료가 시작되는 시각.
  final DateTime? nextStartsAt;

  const FreeEntryStatus({
    this.isFreeNow = false,
    this.active,
    this.activeEndsAt,
    this.next,
    this.nextStartsAt,
  });

  static const none = FreeEntryStatus();
  static const always = FreeEntryStatus(isFreeNow: true);

  /// 무료가 끝나기까지 남은 시간. 지금 무료가 아니거나 상시 무료면 null.
  Duration? remainingFrom(DateTime now) {
    final end = activeEndsAt;
    if (!isFreeNow || end == null) return null;
    final left = end.difference(now);
    return left.isNegative ? Duration.zero : left;
  }

  /// 다음 무료까지 남은 시간. 없으면 null.
  Duration? untilNextFrom(DateTime now) {
    final start = nextStartsAt;
    if (start == null) return null;
    final left = start.difference(now);
    return left.isNegative ? Duration.zero : left;
  }
}
