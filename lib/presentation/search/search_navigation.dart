import 'package:flutter/material.dart';
import 'package:vybe/data/models/search_hashtag_model.dart';
import 'package:vybe/presentation/free_entry/free_entry_screen.dart';
import 'package:vybe/presentation/hip_hop/hip_hop_screen.dart';
import 'package:vybe/presentation/hot_places/hot_places_screen.dart';
import 'package:vybe/presentation/recommend/vybe_recommend_screen.dart';
import 'package:vybe/presentation/service_drinks/service_drinks_screen.dart';

/// 검색 화면에서 쓰는 전환·목적지 매핑.

/// 페이드 전환 — 기본 슬라이드보다 검색 흐름에 자연스럽다.
PageRoute<T> searchFadeRoute<T>(Widget page) {
  return PageRouteBuilder<T>(
    transitionDuration: const Duration(milliseconds: 200),
    reverseTransitionDuration: const Duration(milliseconds: 200),
    pageBuilder: (_, __, ___) => page,
    transitionsBuilder: (_, anim, __, child) =>
        FadeTransition(opacity: anim, child: child),
  );
}

/// 해시태그의 `linkType: page` 값 → 전용 화면.
///
/// `searchHashtags.linkValue`에 저장된 문자열이라 앱이 모르는 키가 올 수 있다.
/// 그때는 null을 돌려 호출측이 라벨 검색으로 폴백하게 한다 —
/// 빈 손으로 돌려보내는 것보다 낫다.
Widget? hashtagPageFor(SearchHashtagModel tag) {
  if (tag.linkType != HashtagLinkType.page) return null;
  return switch (tag.linkValue) {
    'freeEntry' => const FreeEntryScreen(),
    'serviceDrinks' => const ServiceDrinksScreen(),
    'hipHop' => const HipHopScreen(),
    'hotPlaces' => const HotPlacesScreen(),
    'vybeRecommend' => const VybeRecommendScreen(),
    _ => null,
  };
}
