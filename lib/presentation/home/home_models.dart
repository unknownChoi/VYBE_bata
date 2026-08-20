import 'package:flutter/material.dart';
import 'package:vybe/core/utils/geohash_utils.dart';
import 'package:vybe/core/utils/gradient_palette.dart';
import 'package:vybe/core/utils/number_format.dart';
import 'package:vybe/data/models/club_model.dart';
import 'package:vybe/data/models/free_entry_policy.dart';
import 'package:vybe/design_system/colors.dart';

/// 홈 '이 시간에만 무료입장' 카드 표시 모델.
///
/// 시각 판정([FreeEntryPolicy.statusAt])·거리·문구 조립을 전부 여기서 끝내고
/// 위젯은 값만 그린다. 카드마다 `DateTime.now()`를 다시 읽으면 같은 목록 안에서
/// 기준 시각이 어긋나 정렬과 표기가 따로 놀 수 있다 — now는 한 번만 넘겨받는다.
class HomeFreeTimeClub {
  final String clubId;
  final String name;
  final String area;
  final String genre;
  final String thumbnailUrl;
  final List<Color> gradient;

  /// 내 위치에서의 거리(km).
  final double distanceKm;

  /// 평상시 입장료(최소). 0이면 표기하지 않는다.
  final int normalFee;

  /// 지금 무료인지 — **영업 중일 때만** true (문 닫은 클럽의 '지금 무료'는 거짓).
  final bool freeNow;

  /// `22:00 – 23:30`. 지금 무료면 진행 중인 창, 아니면 다음 창.
  final String windowLabel;

  /// 지금 무료일 때 `38분 남음`. 아니면 null.
  final String? remainingLabel;

  /// 지금 무료가 아닐 때 `22:00부터` / `금 22:00부터`. 다음 창이 없으면 null.
  final String? startsLabel;

  /// 정렬 키 — 지금 무료면 끝나는 시각, 아니면 시작 시각.
  final DateTime? sortAt;

  const HomeFreeTimeClub({
    required this.clubId,
    required this.name,
    required this.area,
    required this.genre,
    required this.thumbnailUrl,
    required this.gradient,
    required this.distanceKm,
    required this.normalFee,
    required this.freeNow,
    required this.windowLabel,
    this.remainingLabel,
    this.startsLabel,
    this.sortAt,
  });

  /// `₩20,000` — 무료 시간이 끝나면 받는 값. 0이면 빈 문자열.
  String get normalFeeLabel =>
      normalFee > 0 ? '₩${formatThousands(normalFee)}' : '';

  String get distanceLabel => '${distanceKm.toStringAsFixed(1)}km';
}

/// 썸네일이 없을 때 clubId 해시로 고르는 폴백 그라데이션 (디자인 카드 배경 색상표).
const _kFallbackGradients = <List<Color>>[
  [Color(0xFF2B1655), VybeColors.mainPurple500, Color(0xFFFF4D8D)],
  [Color(0xFF3A0CA3), Color(0xFF4361EE), Color(0xFF4361EE)],
  [Color(0xFF06FFA5), Color(0xFF1B9AAA), Color(0xFF1B9AAA)],
  [Color(0xFF06FFA5), Color(0xFF3A86FF), Color(0xFF3A86FF)],
  [Color(0xFF6D4C91), Color(0xFF2A2D34), Color(0xFF2A2D34)],
];

/// [ClubModel] → 카드 모델. 무료 시간이 전혀 없는 클럽이면 null.
///
/// [now] 는 목록 전체가 같은 값을 쓴다(정렬·표기 기준 통일).
HomeFreeTimeClub? toHomeFreeTimeClub(
  ClubModel club, {
  required DateTime now,
  required double myLat,
  required double myLng,
}) {
  final status = club.freeEntry.statusAt(now);

  // 진행 중인 창도 예정된 창도 없으면 카드로 만들 게 없다 (창이 비었거나 데이터 오류).
  final window = status.active ?? status.next;
  if (window == null) return null;

  // '지금 무료'는 영업 중일 때만. 무료 창이 영업시간 밖으로 잘못 잡혀 있어도
  // 문 닫은 클럽을 무료라고 띄우지 않는다.
  final openNow = club.operatingHours.today.isCurrentlyOpen;
  final freeNow = status.isFreeNow && openNow;

  return HomeFreeTimeClub(
    clubId: club.clubId,
    name: club.name,
    area: club.area,
    genre: club.genre,
    thumbnailUrl: club.thumbnailUrl,
    gradient: gradientForKey(_kFallbackGradients, club.clubId),
    distanceKm: GeohashUtils.haversineKm(myLat, myLng, club.lat, club.lng),
    // 무료가 끝나면 받는 값 = 평상시 최소 입장료. (entryFeeMax는 테이블·부스가
    // 섞인 상한이라 '원래 이만큼 낸다'는 비교값으로는 과장된다)
    normalFee: club.entryFeeMin,
    freeNow: freeNow,
    windowLabel: window.rangeLabel,
    remainingLabel: freeNow ? _remainingLabel(status.remainingFrom(now)) : null,
    startsLabel: freeNow ? null : _startsLabel(status.nextStartsAt, now),
    sortAt: freeNow ? status.activeEndsAt : status.nextStartsAt,
  );
}

/// 카드 정렬 — ① 지금 무료 먼저 ② 시각(끝나는/시작하는) 이른 순 ③ 가까운 순.
///
/// 지금 무료인 카드끼리는 **곧 끝나는 것**을 앞에 둔다 (놓치면 안 되는 순서).
int compareHomeFreeTime(HomeFreeTimeClub a, HomeFreeTimeClub b) {
  if (a.freeNow != b.freeNow) return a.freeNow ? -1 : 1;
  final at = a.sortAt;
  final bt = b.sortAt;
  if (at != null && bt != null && at != bt) return at.compareTo(bt);
  return a.distanceKm.compareTo(b.distanceKm);
}

String? _remainingLabel(Duration? left) {
  if (left == null) return null;
  final minutes = left.inMinutes;
  if (minutes < 1) return '곧 종료';
  if (minutes < 60) return '$minutes분 남음';
  final h = minutes ~/ 60;
  final m = minutes % 60;
  return m == 0 ? '$h시간 남음' : '$h시간 $m분 남음';
}

/// `22:00부터` — 오늘이 아니면 요일을 앞에 붙인다(`금 22:00부터`).
///
/// 디자인 원본은 `22:00 오픈`이지만 '오픈'은 **영업 시작**으로 읽혀
/// 무료 시작 시각과 혼동된다 → `…부터`로 바꿨다.
String? _startsLabel(DateTime? startsAt, DateTime now) {
  if (startsAt == null) return null;
  final hhmm =
      '${startsAt.hour.toString().padLeft(2, '0')}:'
      '${startsAt.minute.toString().padLeft(2, '0')}';
  final today = DateTime(now.year, now.month, now.day);
  final day = DateTime(startsAt.year, startsAt.month, startsAt.day);
  if (day == today) return '$hhmm부터';
  return '${_weekdayLabel(startsAt.weekday)} $hhmm부터';
}

const _kWeekdayLabels = ['월', '화', '수', '목', '금', '토', '일'];

String _weekdayLabel(int weekday) => _kWeekdayLabels[(weekday - 1) % 7];
