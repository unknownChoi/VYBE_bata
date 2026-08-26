import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vybe/core/providers/auth_providers.dart';
import 'package:vybe/domain/repositories/vybe_recommendation_repository.dart';
import 'package:vybe/presentation/clubs/club_detail_route.dart';
import 'package:vybe/presentation/clubs/viewmodels/favorite_viewmodel.dart';
import 'package:vybe/presentation/common/widgets/vybe_aurora.dart';
import 'package:vybe/presentation/common/widgets/vybe_glass_header.dart';
import 'package:vybe/presentation/recommend/recommend_models.dart';
import 'package:vybe/presentation/recommend/viewmodels/vybe_recommend_viewmodel.dart';
import 'package:vybe/presentation/recommend/widgets/recommend_featured.dart';
import 'package:vybe/presentation/recommend/widgets/recommend_hero.dart';
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
      // ⚠ 튕김(오버스크롤) 금지 — 히어로가 상태바 뒤까지 올라가 있어서 위로 당기면
      // 이미지 위에 검은 배경이 드러난다. iOS 기본 BouncingScrollPhysics를 쓰면
      // 화면 맨 위가 들리면서 그 틈이 보인다.
      physics: const ClampingScrollPhysics(),
      children: [
        const RecommendHero(),
        // 라임 띠와 첫 카드 사이 숨돌릴 간격. 카드 자체가 8.h를 갖고 있어 합쳐 24.h.
        // ⚠ 스켈레톤(recommend_states.dart)에도 같은 값이 있어야 로딩이 끝날 때
        //   카드가 위아래로 튀지 않는다.
        SizedBox(height: 16.h),
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
        // 하단 안내문은 뺐다 — 인트로 라임 띠가 같은 말('매주 화요일 …
        // 업데이트돼요')을 이미 하고 있어 한 화면에 두 번 나왔다.
        // 자리는 여백으로 남긴다(마지막 행이 하단 탭바에 붙지 않게).
        SizedBox(height: 120.h),
      ],
    );
  }
}
