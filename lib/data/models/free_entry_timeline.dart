/// 무료입장 **타임라인** — 영업 회차 하나를 "시간대별 입장비" 구간으로 쪼갠 것.
///
/// [FreeEntryPolicy.statusAt] 이 "지금 무료냐"를 답한다면, 여기는 "오늘 밤
/// 몇 시부터 몇 시까지 얼마냐"를 답한다. 클럽 상세의 시간대별 입장비 도형이
/// 이 결과를 그대로 그린다.
///
/// ⚠ Firestore 에 **시간대별 요금표는 없다.** 있는 건 세 가지뿐 —
/// `operatingHours`(회차 = 오픈~마감) · `freeEntry.windows`(무료 구간) ·
/// `entryFeeMin/Max`(평상시 요금). 도형은 이 셋의 조합으로 만든다:
/// 회차를 무료 창으로 잘라 무료 칸(0원)과 평상시 칸(entryFeeMin)을 번갈아 놓는다.
/// 없는 요금 구간을 지어내지 않는다.
///
/// Firebase 의존이 없는 순수 Dart — 테스트는 `test/free_entry_timeline_test.dart`.
library;

import 'package:vybe/data/models/free_entry_policy.dart';
import 'package:vybe/data/models/operating_hours.dart';

/// 타임라인 한 칸 — 같은 입장비가 유지되는 구간. [start] 포함 · [end] 미포함.
class FeeSlot {
  final DateTime start;
  final DateTime end;

  /// 이 구간 입장비(원). 0 이면 무료.
  final int fee;

  /// 무료 칸에 붙은 창 라벨(`'오픈런'`). 없으면 빈 문자열.
  final String label;

  const FeeSlot({
    required this.start,
    required this.end,
    required this.fee,
    this.label = '',
  });

  bool get isFree => fee == 0;

  int get minutes => end.difference(start).inMinutes;

  bool contains(DateTime t) => !t.isBefore(start) && t.isBefore(end);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FeeSlot &&
          start == other.start &&
          end == other.end &&
          fee == other.fee &&
          label == other.label;

  @override
  int get hashCode => Object.hash(start, end, fee, label);

  @override
  String toString() => 'FeeSlot($start~$end, $fee원)';
}

/// 영업 회차 하나(오픈 → 마감)를 입장비 구간으로 쪼갠 결과.
///
/// 회차는 자정을 넘길 수 있다 — `22:00 오픈 / 06:00 마감`이면 [start] 는 오늘
/// 22:00, [end] 는 내일 06:00 이다. 그래서 "시:분"이 아니라 [DateTime] 으로 든다.
class FreeEntryTimeline {
  /// 회차 시작(오픈).
  final DateTime start;

  /// 회차 끝(마감).
  final DateTime end;

  /// 시간순 구간 목록. 빈틈 없이 [start]~[end] 를 덮는다.
  final List<FeeSlot> slots;

  const FreeEntryTimeline({
    required this.start,
    required this.end,
    required this.slots,
  });

  int get minutes => end.difference(start).inMinutes;

  List<FeeSlot> get freeSlots => slots.where((s) => s.isFree).toList();

  bool contains(DateTime t) => !t.isBefore(start) && t.isBefore(end);

  /// [t] 가 회차 안이면 0~1 진행도, 밖이면 null.
  double? progressAt(DateTime t) {
    if (minutes <= 0 || !contains(t)) return null;
    return t.difference(start).inSeconds / (minutes * 60);
  }

  /// [t] 가 걸린 칸. 회차 밖이면 null.
  FeeSlot? slotAt(DateTime t) {
    for (final s in slots) {
      if (s.contains(t)) return s;
    }
    return null;
  }
}

/// [at] 이 들어 있는 영업 회차. 없으면 [at] 이후 **가장 이른** 회차.
///
/// 어제 시작해 자정을 넘긴 회차가 [at] 을 품고 있을 수 있어 -1일부터 훑는다.
/// 7일 안에 여는 날이 없으면(전 요일 휴무) null.
(DateTime, DateTime)? _sessionAt(OperatingHours hours, DateTime at) {
  final base = DateTime(at.year, at.month, at.day);
  (DateTime, DateTime)? upcoming;

  for (var offset = -1; offset <= 7; offset++) {
    final day = base.add(Duration(days: offset));
    final d = hours.dayOf(day.weekday);
    if (!d.isOpen || d.open == null || d.close == null) continue;

    final open = hhmmToMinutes(d.open!);
    final close = hhmmToMinutes(d.close!);
    // 깨진 시각·길이 0 회차는 버린다 (도형이 0폭이 되거나 종일로 늘어난다).
    if (open < 0 || close < 0 || open == close) continue;

    final from = day.add(Duration(minutes: open));
    final to = from.add(
      Duration(minutes: close < open ? 1440 - open + close : close - open),
    );

    if (!at.isBefore(from) && at.isBefore(to)) return (from, to);
    if (from.isAfter(at) && (upcoming == null || from.isBefore(upcoming.$1))) {
      upcoming = (from, to);
    }
  }
  return upcoming;
}

/// 회차 `[sStart, sEnd)` 와 겹치는 무료 창들 — 회차 밖은 잘라내고 겹치면 합친다.
///
/// 창은 **시작 요일**에 속하므로 회차 시작일 기준 -1 ~ +1 일을 본다
/// (금 23:00~02:00 창은 토요일 01:00 도 무료).
List<FeeSlot> _freeRangesIn(
  FreeEntryPolicy policy,
  DateTime sStart,
  DateTime sEnd,
) {
  final base = DateTime(sStart.year, sStart.month, sStart.day);
  final ranges = <FeeSlot>[];

  for (var offset = -1; offset <= 1; offset++) {
    final day = base.add(Duration(days: offset));
    for (final w in policy.windows) {
      if (!w.startsOnWeekday(day.weekday)) continue;
      final occurrence = w.occurrenceOn(day);
      if (occurrence == null) continue;

      final (wStart, wEnd) = occurrence;
      final from = wStart.isBefore(sStart) ? sStart : wStart;
      final to = wEnd.isAfter(sEnd) ? sEnd : wEnd;
      if (!from.isBefore(to)) continue; // 회차와 안 겹침

      ranges.add(FeeSlot(start: from, end: to, fee: 0, label: w.label));
    }
  }

  ranges.sort((a, b) => a.start.compareTo(b.start));

  // 붙어 있거나 겹치는 창은 한 칸으로 — 이어진 무료 시간이 두 칸으로 쪼개지면
  // 도형에 없는 경계선이 생겨 "중간에 요금이 바뀐다"로 읽힌다.
  final merged = <FeeSlot>[];
  for (final r in ranges) {
    if (merged.isNotEmpty && !r.start.isAfter(merged.last.end)) {
      final last = merged.removeLast();
      merged.add(
        FeeSlot(
          start: last.start,
          end: r.end.isAfter(last.end) ? r.end : last.end,
          fee: 0,
          label: last.label.isNotEmpty ? last.label : r.label,
        ),
      );
    } else {
      merged.add(r);
    }
  }
  return merged;
}

/// [at] 시점에 보여 줄 회차의 시간대별 입장비.
///
/// - [at] 이 영업 중이면 **그 회차**, 아니면 [at] 이후 첫 회차.
///   그래서 "다음 무료가 금요일"이면 [at] 에 그 시작 시각을 넣어 금요일 회차를 얻는다.
/// - [normalFee] 는 무료가 아닌 칸의 요금(= `clubs.entryFeeMin`).
///
/// null 을 주는 경우 — 무료 정책이 없거나 / 7일 안에 영업일이 없거나 /
/// 그 회차에 무료 구간이 하나도 없을 때. 어느 쪽이든 그릴 도형이 없다.
FreeEntryTimeline? buildFreeEntryTimeline({
  required OperatingHours hours,
  required FreeEntryPolicy policy,
  required int normalFee,
  required DateTime at,
}) {
  if (!policy.hasFreeEntry) return null;

  final session = _sessionAt(hours, at);
  if (session == null) return null;
  final (sStart, sEnd) = session;

  // 상시 무료는 회차 전체가 한 칸. windows 를 안 쓴다(있어도 무시 — type 이 우선).
  // ⚠ 클럽 상세 섹션은 timed 만 그리므로 이 갈래로 안 온다. 남겨 둔 건 이 함수가
  //   화면이 아니라 정책 전체를 다루는 모델이기 때문 — 입장비 무료 페이지처럼
  //   상시 무료까지 한 줄로 세우는 화면이 붙으면 그대로 쓴다.
  final free = policy.isAlways
      ? [FeeSlot(start: sStart, end: sEnd, fee: 0)]
      : _freeRangesIn(policy, sStart, sEnd);
  if (free.isEmpty) return null;

  final slots = <FeeSlot>[];
  var cursor = sStart;
  for (final f in free) {
    if (f.start.isAfter(cursor)) {
      slots.add(FeeSlot(start: cursor, end: f.start, fee: normalFee));
    }
    slots.add(f);
    cursor = f.end;
  }
  if (cursor.isBefore(sEnd)) {
    slots.add(FeeSlot(start: cursor, end: sEnd, fee: normalFee));
  }

  return FreeEntryTimeline(start: sStart, end: sEnd, slots: slots);
}
