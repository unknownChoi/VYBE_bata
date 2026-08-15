import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vybe/data/models/banner_model.dart';
import 'package:vybe/presentation/main_scaffold/nav_bar_hide_route.dart';
import 'package:vybe/presentation/promotion/promotion_detail_screen.dart';

/// 홈 배너 탭 → 목적지 이동.
///
/// 배너 doc의 `linkType`/`linkValue`만 보고 분기한다 — 화면 쪽엔 분기 로직이 없다.
/// 현재는 `promotion`(DB 콘텐츠를 범용 상세 화면으로 렌더)만 연결돼 있고,
/// club·page·url(코드에 이미 있는 화면으로 보내는 링크)은 아직 미연결이라
/// 조용히 무시한다 — 잘못된 곳으로 보내는 것보다 낫다.
///
/// 광고 페이지는 전체화면으로 보여준다 → [pushHidingNavBar]로 열어 하단 nav 바를
/// 화면 밖으로 내리고, 돌아오면 다시 올린다.
void openBannerLink(BuildContext context, WidgetRef ref, BannerModel banner) {
  if (!banner.isTappable) return;

  switch (banner.linkType) {
    case BannerLinkType.promotion:
      pushHidingNavBar<void>(
        context,
        PromotionDetailScreen(promotionId: banner.linkValue),
      );
    case BannerLinkType.club:
    case BannerLinkType.page:
    case BannerLinkType.url:
    case BannerLinkType.none:
      break;
  }
}
