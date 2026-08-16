import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vybe/core/providers/auth_providers.dart';
import 'package:vybe/design_system/colors.dart';
import 'package:vybe/domain/repositories/vybe_recommendation_repository.dart';
import 'package:vybe/presentation/clubs/club_detail_route.dart';
import 'package:vybe/presentation/clubs/viewmodels/favorite_viewmodel.dart';
import 'package:vybe/presentation/common/widgets/vybe_aurora.dart';
import 'package:vybe/presentation/common/widgets/vybe_footer_note.dart';
import 'package:vybe/presentation/common/widgets/vybe_glass_header.dart';
import 'package:vybe/presentation/recommend/recommend_models.dart';
import 'package:vybe/presentation/recommend/viewmodels/vybe_recommend_viewmodel.dart';
import 'package:vybe/presentation/recommend/widgets/recommend_featured.dart';
import 'package:vybe/presentation/recommend/widgets/recommend_intro.dart';
import 'package:vybe/presentation/recommend/widgets/recommend_rank.dart';
import 'package:vybe/presentation/recommend/widgets/recommend_states.dart';

class VybeRecommendScreen extends ConsumerStatefulWidget {
  const VybeRecommendScreen({super.key});

  @override
  ConsumerState<VybeRecommendScreen> createState() =>
      _VybeRecommendScreenState();
}

class _VybeRecommendScreenState extends ConsumerState<VybeRecommendScreen> {
  // 찜 토글 — favorites 실연동(스트림 + 낙관적 오버라이드, 다른 화면과 동일 패턴).
  void _toggleFavorite(String clubId, bool currentIsFav) {
    final uid = ref.read(currentUidProvider);
    if (uid == null) return; // 비로그인 — 추후 로그인 유도 처리
    ref
        .read(favoriteViewModelProvider.notifier)
        .toggleFavorite(uid, clubId, currentIsFav);
  }

  // 클럽 상세 페이지 이동 (다른 화면과 동일 패턴).
  void _openDetail(String clubId) {
    openClubDetail(context, clubId);
  }

  @override
  Widget build(BuildContext context) {
    final asyncRecs = ref.watch(vybeRecommendViewModelProvider);

    // 찜 상태(스트림 + 낙관적 오버라이드 머지) — search_result_screen과 동일.
    final favoritedIds = ref.watch(mergedFavoriteIdsProvider);
    return Scaffold(
      backgroundColor: kVybeInk,
      // SizedBox.expand로 Stack을 화면 전체로 강제 → Positioned.fill 본문이
      // 꽉 차도록. (Stack은 non-positioned 자식 크기만 따라가므로 명시 필요)
      body: SizedBox.expand(
        child: Stack(
          children: [
            // 배경 — 공용 리뉴얼 오로라. 화면 전체를 채우는 전제라
            // 부분 높이로 자르지 않는다(우하단 글로우가 중간에 맺힘).
            const Positioned.fill(
              child: IgnorePointer(child: VybeAurora()),
            ),
            Positioned.fill(
              child: asyncRecs.when(
                loading: () => const RecommendSkeleton(),
                error: (_, __) => const RecommendErrorView(),
                data: (recs) => _body(recs, favoritedIds),
              ),
            ),
            const Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: VybeGlassHeader(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _body(List<VybeRecommendedClub> recs, Set<String> favoritedIds) {
    if (recs.isEmpty) return const RecommendEmptyView();

    final featured = RecommendClub.from(recs.first, featured: true);
    final ranked =
        recs.skip(1).map((r) => RecommendClub.from(r, featured: false)).toList();

    return ListView(
      padding: EdgeInsets.zero,
      children: [
        const RecommendIntro(),
        RecommendFeatured(
          club: featured,
          saved: favoritedIds.contains(featured.id),
          onSave: () => _toggleFavorite(
            featured.id,
            favoritedIds.contains(featured.id),
          ),
          onOpen: () => _openDetail(featured.id),
        ),
        if (ranked.isNotEmpty)
          RecommendRankedSection(
            clubs: ranked,
            savedIds: favoritedIds,
            onSave: (id) => _toggleFavorite(id, favoritedIds.contains(id)),
            onOpen: _openDetail,
          ),
        VybeFooterNote(
          icon: Icons.auto_awesome,
          iconColor: VybeColors.mainLime500,
          text: '추천 리스트는 매주 화요일, 최근 방문 데이터를 반영해 새롭게 업데이트돼요.',
          iconSize: 16,
          margin: EdgeInsets.fromLTRB(20.w, 20.h, 20.w, 8.h),
          padding: EdgeInsets.all(16.r),
        ),
        SizedBox(height: 28.h),
      ],
    );
  }
}
