import 'package:flutter/material.dart';
import 'package:vybe/core/utils/gradient_palette.dart';
import 'package:vybe/data/models/club_model.dart';
import 'package:vybe/presentation/common/club_list_sorting.dart';
import 'package:vybe/presentation/common/free_entry_labels.dart';
import 'package:vybe/presentation/free_entry/free_entry_style.dart';

/// 입장비 무료 카드 1장에 필요한 값만 담은 **표시 전용** 모델.
///
/// `ClubModel`을 그대로 카드에 넘기지 않는 이유 — 카드가 쓰는 건 열 몇 개인데
/// 거리(`dist`)는 화면의 위치 선택에 따라 매번 다시 계산된다. 또 '지금 무료인가'는
/// 목록 전체가 **같은 시각**으로 판정해야 해서(카드마다 `DateTime.now()`를 다시
/// 읽으면 정렬과 표기가 따로 논다) 매핑 시점에 한 번 굳혀 둔다.
class FreeEntryClub implements ClubSortable {
  final String id;
  final String name;
  @override
  final String area;
  final String genre;

  /// 클럽 좌표 — 내 위치와의 haversine 실거리 계산에 쓴다(0이면 좌표 없음).
  @override
  final double lat;
  @override
  final double lng;

  @override
  final double dist;
  @override
  final double rating;

  /// 무료가 아닐 때 내는 값. 0이면 표시 안 함.
  /// 시간대 무료는 `entryFeeMin`, 상시 무료는 min이 0이라 `entryFeeMax`.
  final int cover;

  /// 무료입장 조건 (`freeEntry.condition`, 없으면 레거시 `freeEntryCondition`).
  final String cond;
  @override
  final bool open;
  final String thumbnailUrl;
  final List<Color> gradient;

  /// isVybeRecommended — VYBE 추천 뱃지 노출.
  final bool isVybeRecommended;

  /// 시간대 무료(`freeEntry.type == 'timed'`)인지. false면 상시 무료.
  final bool timed;

  /// 지금 무료인지 — **영업 중일 때만** true.
  /// 문 닫은 클럽의 '지금 무료'는 거짓 정보다(홈 카드와 같은 규칙).
  final bool freeNow;

  /// `22:00 – 01:00`. 지금 무료면 진행 중인 창, 아니면 다음 창. 상시 무료면 빈 값.
  final String windowLabel;

  /// 지금 무료일 때 `38분 남음`. 아니면 null.
  final String? remainingLabel;

  /// 지금 무료가 아닐 때 `22:00부터` / `금 22:00부터`. 다음 창이 없으면 null.
  final String? startsLabel;

  /// '지금 무료순' 정렬 키 — 지금 무료면 끝나는 시각, 아니면 시작 시각.
  final DateTime? sortAt;

  const FreeEntryClub({
    required this.id,
    required this.name,
    required this.area,
    required this.genre,
    required this.lat,
    required this.lng,
    required this.dist,
    required this.rating,
    required this.cover,
    required this.cond,
    required this.open,
    required this.thumbnailUrl,
    required this.gradient,
    required this.isVybeRecommended,
    required this.timed,
    required this.freeNow,
    required this.windowLabel,
    this.remainingLabel,
    this.startsLabel,
    this.sortAt,
  });

  FreeEntryClub copyWithDist(double d) => FreeEntryClub(
    id: id,
    name: name,
    area: area,
    genre: genre,
    lat: lat,
    lng: lng,
    dist: d,
    rating: rating,
    cover: cover,
    cond: cond,
    open: open,
    thumbnailUrl: thumbnailUrl,
    gradient: gradient,
    isVybeRecommended: isVybeRecommended,
    timed: timed,
    freeNow: freeNow,
    windowLabel: windowLabel,
    remainingLabel: remainingLabel,
    startsLabel: startsLabel,
    sortAt: sortAt,
  );

  /// `ClubModel` → 카드 모델. [dist]는 0으로 두고 화면이 위치 기준으로 채운다.
  ///
  /// [now] 는 목록 전체가 같은 값을 넘긴다 — 카드마다 `DateTime.now()`를 다시 읽으면
  /// 같은 목록 안에서 기준 시각이 어긋나 정렬과 표기가 따로 논다.
  factory FreeEntryClub.fromClub(ClubModel c, DateTime now) {
    final status = c.freeEntry.statusAt(now);
    final timed = c.freeEntry.isTimed;

    // 무료 창 판정과 **같은 now** 로 영업 여부를 묻는다. today.isCurrentlyOpen 은
    // 벽시계를 다시 읽어, 주입한 시각과 섞이면 '무료 창인데 영업 종료' 같은
    // 어긋난 답이 나온다.
    final openNow = c.operatingHours.dayAt(now).isOpenAt(now);
    final window = status.active ?? status.next;

    return FreeEntryClub(
      id: c.clubId,
      name: c.name,
      area: c.area,
      genre: c.genre,
      lat: c.lat,
      lng: c.lng,
      dist: 0,
      rating: c.rating,
      // 시간대 무료는 무료가 끝나면 평상시 최소 요금을 받는다. 상시 무료는 min이
      // 0이라 비교값이 없어 entryFeeMax(상한)를 대신 쓴다 — 기존 표기 그대로.
      cover: c.entryFeeMin > 0 ? c.entryFeeMin : c.entryFeeMax,
      cond: _conditionLabel(c),
      open: openNow,
      thumbnailUrl: c.thumbnailUrl,
      gradient: gradientForKey(kEntryFallbackGradients, c.clubId),
      isVybeRecommended: c.isVybeRecommended,
      timed: timed,
      freeNow: status.isFreeNow && openNow,
      windowLabel: timed ? (window?.rangeLabel ?? '') : '',
      remainingLabel: status.isFreeNow && openNow
          ? freeEntryRemainingLabel(status.remainingFrom(now))
          : null,
      startsLabel: status.isFreeNow
          ? null
          : freeEntryStartsLabel(status.nextStartsAt, now),
      sortAt: status.isFreeNow ? status.activeEndsAt : status.nextStartsAt,
    );
  }
}

/// 무료입장 조건 문구 — 신규 필드 우선, 없으면 레거시, 둘 다 없으면 기본 문구.
String _conditionLabel(ClubModel c) {
  if (c.freeEntry.condition.isNotEmpty) return c.freeEntry.condition;
  if (c.freeEntryCondition.isNotEmpty) return c.freeEntryCondition;
  return '입장비 무료';
}

/// '지금 무료순' — ① 지금 무료 먼저 ② 시각(끝나는/시작하는) 이른 순 ③ 가까운 순.
///
/// 지금 무료인 카드끼리는 **곧 끝나는 것**을 앞에 둔다(놓치면 안 되는 순서).
/// 상시 무료는 [FreeEntryClub.sortAt] 이 null이라 같은 freeNow 그룹 안에서 거리순이 된다.
int compareFreeNow(FreeEntryClub a, FreeEntryClub b) {
  if (a.freeNow != b.freeNow) return a.freeNow ? -1 : 1;
  final at = a.sortAt;
  final bt = b.sortAt;
  if (at != null && bt != null && at != bt) return at.compareTo(bt);
  if ((at == null) != (bt == null)) return at == null ? -1 : 1;
  return a.dist.compareTo(b.dist);
}
