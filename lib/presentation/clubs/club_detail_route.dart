import 'package:flutter/material.dart';
import 'package:vybe/presentation/clubs/renew/club_detail_renew_screen.dart';
import 'package:vybe/presentation/main_scaffold/nav_bar_hide_route.dart';

/// 클럽 상세 진입점 — 앱의 모든 화면이 이 함수 하나만 쓴다.
///
/// 상세 화면 자체를 바꿀 때(구 [ClubDetailScreen] → [ClubDetailRenewScreen])
/// 호출 지점 10여 곳을 전부 고치지 않도록 한 곳으로 모았다.
///
/// 리뉴얼 상세는 **하단 고정 액션 바**(찜·길찾기·전화)가 MainScaffold의 floating
/// 바텀 nav와 겹치므로 항상 nav를 내리고 전체화면으로 띄운다.
/// 이미 내려가 있으면 [pushHidingNavBar]가 알아서 평범한 push로 넘어간다.
///
/// [rootNavigator] — 상세가 바텀시트(주변 페이지)로 떠 있는 상태에서 열 때,
/// 시트 안이 아니라 전체 화면으로 밀어 올리기 위해 사용.
Future<void> openClubDetail(
  BuildContext context,
  String clubId, {
  bool rootNavigator = false,
}) {
  return pushHidingNavBar<void>(
    context,
    ClubDetailRenewScreen(clubId: clubId),
    rootNavigator: rootNavigator,
  );
}
