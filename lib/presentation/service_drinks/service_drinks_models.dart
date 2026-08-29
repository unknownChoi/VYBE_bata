import 'package:flutter/material.dart';
import 'package:vybe/core/utils/gradient_palette.dart';
import 'package:vybe/data/models/club_model.dart';
import 'package:vybe/presentation/common/club_list_sorting.dart';
import 'package:vybe/presentation/service_drinks/service_drinks_style.dart';

/// 서비스 음료 카드 1장에 필요한 값만 담은 **표시 전용** 모델.
///
/// `ClubModel`을 그대로 카드에 넘기지 않는 이유 — 카드가 쓰는 건 열 몇 개인데
/// 거리(`dist`)는 화면의 위치 선택에 따라 매번 다시 계산된다. 원본을 복사하며
/// 거리만 갈아 끼우면 필터·정렬 코드가 클럽 스키마 전체를 알 필요가 없다.
class ServiceDrinkClub implements ClubSortable {
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

  /// 제공 코멘트 (예: '1인 음료 무제한') — 카드 좌상단 리본.
  final String perk;

  /// 음료 종류 — 종류 필터가 이 목록으로 걸린다.
  final List<String> drinks;

  @override
  final bool open;

  /// '오늘 22:00 - 06:00' / '오늘 휴무'.
  final String hours;

  final String thumbnailUrl;
  final bool isVybeRecommended;

  /// 썸네일이 없을 때 카드 배경으로 쓰는 그라데이션.
  final List<Color> gradient;

  const ServiceDrinkClub({
    required this.id,
    required this.name,
    required this.area,
    required this.genre,
    required this.lat,
    required this.lng,
    required this.dist,
    required this.rating,
    required this.perk,
    required this.drinks,
    required this.open,
    required this.hours,
    required this.thumbnailUrl,
    required this.isVybeRecommended,
    required this.gradient,
  });

  ServiceDrinkClub copyWithDist(double d) => ServiceDrinkClub(
    id: id,
    name: name,
    area: area,
    genre: genre,
    lat: lat,
    lng: lng,
    dist: d,
    rating: rating,
    perk: perk,
    drinks: drinks,
    open: open,
    hours: hours,
    thumbnailUrl: thumbnailUrl,
    isVybeRecommended: isVybeRecommended,
    gradient: gradient,
  );

  /// `ClubModel` → 카드 모델. [dist]는 0으로 두고 화면이 위치 기준으로 채운다.
  factory ServiceDrinkClub.fromClub(ClubModel c) => ServiceDrinkClub(
    id: c.clubId,
    name: c.name,
    area: c.area,
    genre: c.genre,
    lat: c.lat,
    lng: c.lng,
    dist: 0,
    rating: c.rating,
    perk: c.serviceDrink.comment,
    drinks: c.serviceDrink.drinks,
    open: c.operatingHours.today.isCurrentlyOpen,
    hours: _hoursLabel(c),
    thumbnailUrl: c.thumbnailUrl,
    isVybeRecommended: c.isVybeRecommended,
    gradient: gradientForKey(kDrinkFallbackGradients, c.clubId),
  );
}

/// 오늘 영업시간 라벨 ('오늘 22:00 - 06:00' / '오늘 휴무').
String _hoursLabel(ClubModel c) {
  final d = c.operatingHours.today;
  if (d.isOpen && d.open != null && d.close != null) {
    return '오늘 ${d.open} - ${d.close}';
  }
  return '오늘 휴무';
}
