/// 밤 영업 시간대(22:00 ~ 새벽) 시각 계산 — 화면들이 같은 규칙을 쓰게 하는 단일 소스.
///
/// 06시 미만은 **다음 날 새벽**으로 보고 +24h 해 이어 붙인다. 그냥 비교하면
/// `01:00`이 `23:30`보다 이른 것으로 나와 타임테이블 순서가 뒤집힌다.
///
/// 힙합 '오늘의 라인업'과 EDM 'DJ 타임테이블'이 같은 공연을 다르게 말하면 안 되므로
/// 두 화면 모두 여기를 지난다.
library;

/// "HH:mm" → 분. 06시 미만은 +24h.
int nightMinutes(String hhmm) {
  final parts = hhmm.split(':');
  var h = int.parse(parts[0]);
  final m = int.parse(parts[1]);
  if (h < 6) h += 24;
  return h * 60 + m;
}

/// 현재 시각 → 분(같은 규칙).
int nightNowMinutes() {
  final now = DateTime.now();
  var h = now.hour;
  if (h < 6) h += 24;
  return h * 60 + now.minute;
}

/// 공연 한 건의 진행 상태.
enum NightSlotStatus { past, live, upcoming }

/// 시작 시각 기준 판정. 종료 시각 필드가 없어(performances 스키마)
/// **시작 후 [liveMinutes]분 동안 진행 중**으로 본다 — 없는 종료 시각을 지어내지 않는다.
NightSlotStatus nightSlotStatus(
  String hhmm,
  int nowMin, {
  int liveMinutes = 60,
}) {
  final m = nightMinutes(hhmm);
  if (m <= nowMin - liveMinutes) return NightSlotStatus.past;
  if (m <= nowMin) return NightSlotStatus.live;
  return NightSlotStatus.upcoming;
}
