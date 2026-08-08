import 'package:flutter/material.dart';
import 'package:vybe/core/navigation/swipe_back_page_route.dart';
import 'package:vybe/core/utils/gradient_palette.dart';
import 'package:vybe/design_system/colors.dart';
import 'package:vybe/presentation/clubs/club_detail_screen.dart';
import 'package:vybe/presentation/clubs/widgets/club_glass.dart';

// 찜 탭 공용 — 정렬 옵션 · 썸네일 폴백 그라데이션 · 캡션 스타일 · 상세 이동.

enum SavedSortOption { recent, rating, name, open }

const Map<SavedSortOption, String> kSavedSortLabels = {
  SavedSortOption.recent: '최근 찜한 순',
  SavedSortOption.rating: '평점 높은 순',
  SavedSortOption.name: '가나다 순',
  SavedSortOption.open: '영업중 먼저',
};

/// 그라데이션 fallback 색 — 썸네일 없을 때/로딩 중 placeholder.
const List<List<Color>> kSavedGradients = [
  [VybeColors.mainPurple500, Color(0xFFFF4D8D)],
  [Color(0xFFFF006E), Color(0xFF8338EC)],
  [Color(0xFF06FFA5), Color(0xFF3A86FF)],
  [Color(0xFFFB5607), Color(0xFFFFBE0B)],
  [Color(0xFF2A2D34), Color(0xFF6C757D)],
  [VybeColors.accentBlue500, VybeColors.mainPurple500],
];

List<Color> savedGradientFor(String key) => gradientForKey(kSavedGradients, key);

/// 탭 내부 Navigator로 클럽 상세 push.
void openSavedClubDetail(BuildContext context, String clubId) {
  Navigator.of(context).push(
    SwipeBackPageRoute(builder: (_) => ClubDetailScreen(clubId: clubId)),
  );
}

TextStyle savedCaption({
  Color color = ClubGlass.t3,
  double size = 12,
  double lineHeight = 14,
  FontWeight weight = FontWeight.w400,
}) => ClubGlass.caption(
  color: color,
  size: size,
  lineHeight: lineHeight,
  weight: weight,
);

// ============ 화면 ============
