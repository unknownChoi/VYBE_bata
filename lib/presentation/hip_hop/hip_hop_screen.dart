
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vybe/core/navigation/swipe_back_page_route.dart';
import 'package:vybe/core/providers/location_providers.dart';
import 'package:vybe/data/models/club_model.dart';
import 'package:vybe/data/models/performance_model.dart';
import 'package:vybe/design_system/colors.dart';
import 'package:vybe/design_system/typography.dart';
import 'package:vybe/presentation/clubs/club_detail_route.dart';
import 'package:vybe/presentation/common/widgets/vybe_club_poster_card.dart';
import 'package:vybe/presentation/common/widgets/vybe_glass_button.dart';
import 'package:vybe/presentation/common/widgets/vybe_skeleton.dart';
import 'package:vybe/presentation/hip_hop/hip_hop_gradients.dart';
import 'package:vybe/presentation/hip_hop/hip_hop_style.dart';
import 'package:vybe/presentation/hip_hop/hip_hop_view_models.dart';
import 'package:vybe/presentation/hip_hop/today_lineup_screen.dart';
import 'package:vybe/presentation/hip_hop/viewmodels/hip_hop_viewmodel.dart';
import 'package:vybe/presentation/hip_hop/widgets/hip_hop_chrome.dart';
import 'package:vybe/presentation/hip_hop/widgets/hip_hop_dj_rail.dart';
import 'package:vybe/presentation/hip_hop/widgets/hip_hop_intro_hero.dart';
import 'package:vybe/presentation/main_scaffold/nav_bar_visibility_provider.dart';
import 'package:vybe/presentation/nearby/viewmodels/nearby_search_provider.dart';

// 힙합 — 오늘 밤 헤드라인 공연 + DJ 라인업 + 지역별 인기 클럽.
// claude.ai/design hip_hop.html 디자인 기반. UI는 디자인(393 기준) 값 그대로 매핑.
// 데이터: hero/rail은 performances(오늘 공연), 그리드는 clubs + 오늘 라인업 머지.

class HipHopScreen extends ConsumerStatefulWidget {
  const HipHopScreen({super.key});

  @override
  ConsumerState<HipHopScreen> createState() => _HipHopScreenState();
}

class _HipHopScreenState extends ConsumerState<HipHopScreen> {
  String _area = '인기순';
  final Set<Object> _saved = {};

  void _toggleSave(Object id) => setState(() {
    _saved.contains(id) ? _saved.remove(id) : _saved.add(id);
  });

  // '지도에서 보기' → TOP 10 클럽을 주변 탭 지도 핀으로 표시 + 탭 전환.
  void _showOnMap(List<HipHopClub> grid, Map<String, ClubModel> clubById) {
    final clubs = grid
        .map((g) => clubById[g.id])
        .whereType<ClubModel>()
        .toList();
    if (clubs.isEmpty) return;
    final keyword = _area == '인기순' ? '힙합 인기 TOP 10' : '$_area 힙합 인기 TOP 10';
    ref
        .read(nearbySearchResultProvider.notifier)
        .showClubs(keyword: keyword, clubs: clubs);
    // 주변 탭(index 1)으로 전환 — MainScaffold가 listen해 점프.
    ref.read(tabSwitchRequestProvider.notifier).request(1);
  }

  // 지역 필터 → 평점 desc → 리뷰수 desc → 상위 10개.
  List<HipHopClub> _grid(List<HipHopClub> source) {
    final base = _area == '인기순'
        ? source
        : source.where((c) => c.area == _area).toList();
    final sorted = base.toList()
      ..sort((a, b) {
        final r = b.rating.compareTo(a.rating);
        return r != 0 ? r : b.reviews.compareTo(a.reviews);
      });
    return sorted.take(10).toList();
  }

  @override
  Widget build(BuildContext context) {
    final bottomPad = MediaQuery.paddingOf(context).bottom + 90.h;
    final async = ref.watch(hipHopViewModelProvider);
    final data = async.asData?.value;
    final loading = async.isLoading && data == null;

    final clubs = data?.clubs ?? const <ClubModel>[];
    final perfs = data?.performances ?? const <PerformanceModel>[];
    final clubById = {for (final c in clubs) c.clubId: c};
    final headliner = data?.headlinerByClub ?? const {};

    // 카드 거리 표시는 내 위치 기준.
    final me = ref.watch(userLocationProvider);
    final origin = (lat: me.lat, lng: me.lng);

    // 아티스트 = 오늘 공연 전체(시작시각순).
    final djs = [
      for (var i = 0; i < perfs.length; i++) hipHopDjFrom(perfs[i], i),
    ];

    // 그리드(포스터) = 클럽 + 오늘 라인업 머지(live/lineup).
    final source = clubs
        .map((c) => hipHopClubFrom(c, headliner[c.clubId], origin: origin))
        .toList();
    final grid = _grid(source);

    return Scaffold(
      backgroundColor: kHipBg,
      body: SizedBox.expand(
        child: Stack(
          children: [
            // 골드/보라 백드롭 — 화면 전체를 채운다(우하단 글로우까지).
            const Positioned.fill(child: IgnorePointer(child: HipBackdrop())),
            Positioned.fill(
              child: ListView(
                padding: EdgeInsets.only(bottom: bottomPad),
                // ⚠ 튕김(오버스크롤) 금지 — 히어로가 상태바 뒤까지 올라가 있어서
                // 위로 당기면 이미지 위에 배경이 드러난다.
                physics: const ClampingScrollPhysics(),
                children: [
                  // 상단은 오늘 공연 캐러셀 대신 인트로 히어로 이미지.
                  // 로딩 분기가 없다 — 로컬 asset이라 데이터와 무관하게 바로 그려진다.
                  const HipHopIntroHero(),
                  // 오늘의 공연 아티스트 (항상 노출)
                  Padding(
                    padding: EdgeInsets.only(top: 24.h),
                    child: HipHopSectionHead(
                      title: '오늘의 공연 아티스트',
                      sub: '내 주변 힙합 클럽 · 공연 시간순',
                      onAllTap: () => Navigator.of(context).push(
                        SwipeBackPageRoute(
                          builder: (_) => const TodayLineupScreen(),
                        ),
                      ),
                    ),
                  ),
                  if (loading)
                    const HipHopDjRailSkeleton()
                  else if (djs.isNotEmpty)
                    HipHopDjRail(djs: djs)
                  else
                    const HipHopRailEmpty(),
                  // 안내 카드
                  Container(
                    margin: EdgeInsets.fromLTRB(16.w, 22.h, 16.w, 8.h),
                    padding: EdgeInsets.symmetric(
                      horizontal: 16.w,
                      vertical: 14.h,
                    ),
                    decoration: BoxDecoration(
                      color: VybeColors.gray900,
                      borderRadius: BorderRadius.circular(14.r),
                      border: Border.all(color: VybeColors.gray800),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.album_outlined, size: 15.r, color: kHipAccent),
                        SizedBox(width: 10.w),
                        Expanded(
                          child: Text(
                            '공연 라인업은 당일 사정에 따라 변경될 수 있어요. 방문 전 확인해 주세요.',
                            style: VybeTypography.caption.copyWith(
                              height: 17 / 12,
                              color: VybeColors.gray400,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  // 지역 필터 + 포스터 그리드
                  Padding(
                    padding: EdgeInsets.only(top: 26.h),
                    child: Padding(
                      padding: EdgeInsets.only(bottom: 14.h),
                      child: HipHopAreaFilter(
                        active: _area,
                        onChange: (a) => setState(() => _area = a),
                      ),
                    ),
                  ),
                  HipHopSectionHead(
                    title: _area == '인기순'
                        ? '인기 클럽 TOP 10'
                        : '$_area 인기 클럽 TOP 10',
                    sub: _area == '인기순'
                        ? '지금 가장 인기있는 클럽 TOP 10'
                        : '$_area에서 가장 인기있는 클럽 TOP 10',
                    mapAction: true,
                    onMapTap: () => _showOnMap(grid, clubById),
                    bottomGap: 14.h,
                  ),
                  if (loading)
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16.w),
                      child: GridView.count(
                        crossAxisCount: 2,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        // padding 미지정 시 safe-area(상태바)가 top padding으로 주입돼 공백 생김.
                        padding: EdgeInsets.zero,
                        mainAxisSpacing: 12.h,
                        crossAxisSpacing: 12.w,
                        childAspectRatio: 3 / 4,
                        children: List.generate(
                          4,
                          (_) => const VybeSkel(height: double.infinity, radius: 16),
                        ),
                      ),
                    )
                  else if (grid.isEmpty)
                    Padding(
                      padding: EdgeInsets.symmetric(
                        vertical: 50.h,
                        horizontal: 24.w,
                      ),
                      child: Text(
                        '$_area 지역에는 클럽이 아직 없어요',
                        textAlign: TextAlign.center,
                        style: VybeTypography.body4.copyWith(
                          color: VybeColors.gray500,
                        ),
                      ),
                    )
                  else
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16.w),
                      child: GridView.count(
                        crossAxisCount: 2,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        // padding 미지정 시 safe-area(상태바)가 top padding으로 주입돼 공백 생김.
                        padding: EdgeInsets.zero,
                        mainAxisSpacing: 12.h,
                        crossAxisSpacing: 12.w,
                        childAspectRatio: 3 / 4,
                        children: grid
                            .map(
                              (c) => VybeClubPosterCard(
                                club: c,
                                saved: _saved.contains(c.id),
                                onSave: () => _toggleSave(c.id),
                                // 카드 탭 → 클럽 상세.
                                onTap: () => openClubDetail(context, c.id),
                              ),
                            )
                            .toList(),
                      ),
                    ),
                  SizedBox(height: 24.h),
                ],
              ),
            ),
            // 돌아가기 버튼 오버레이 (추천 페이지와 동일한 글래스 버튼).
            Positioned(
              top: MediaQuery.paddingOf(context).top,
              left: 16.w,
              child: VybeGlassButton(
                onTap: () => Navigator.of(context).maybePop(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
