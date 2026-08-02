import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart' show ScrollDirection;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vybe/data/models/club_model.dart';
import 'package:vybe/data/models/performance_model.dart';
import 'package:vybe/design_system/colors.dart';
import 'package:vybe/design_system/typography.dart';
import 'package:vybe/presentation/clubs/club_detail_screen.dart';
import 'package:vybe/presentation/common/widgets/vybe_glass_button.dart';
import 'package:vybe/presentation/common/widgets/vybe_recommend_badge.dart';
import 'package:vybe/presentation/common/widgets/vybe_skeleton.dart';
import 'package:vybe/presentation/hip_hop/hip_hop_gradients.dart';
import 'package:vybe/presentation/hip_hop/today_lineup_screen.dart';
import 'package:vybe/presentation/hip_hop/viewmodels/hip_hop_viewmodel.dart';
import 'package:vybe/presentation/main_scaffold/nav_bar_visibility_provider.dart';
import 'package:vybe/presentation/nearby/viewmodels/nearby_search_provider.dart';

// 힙합 — 오늘 밤 헤드라인 공연 + DJ 라인업 + 지역별 인기 클럽.
// claude.ai/design hip_hop.html 디자인 기반. UI는 디자인(393 기준) 값 그대로 매핑.
// 데이터: hero/rail은 performances(오늘 공연), 그리드는 clubs + 오늘 라인업 머지.

// hip-hop accent (gold)
const Color _hip = Color(0xFFF5B82E);
const Color _onHip = Color(0xFF2A1E04);
// 디자인 App 배경(#0d0a0c) — VybeColors.background와 미세하게 달라 값 그대로 사용.
const Color _bg = Color(0xFF0D0A0C);

// ── 더미 모델 ──
class _Hero {
  final String name;
  final String area;
  final double dist;
  final double rating;
  final String lineup;
  final String genre;
  final String time;
  final String tag;
  final List<Color> bg;
  const _Hero({
    required this.name,
    required this.area,
    required this.dist,
    required this.rating,
    required this.lineup,
    required this.genre,
    required this.time,
    required this.tag,
    required this.bg,
  });
}

class _Dj {
  final int id;
  final String clubId; // 탭 → 클럽 상세 이동용
  final String dj;
  final String club;
  final String time;
  final bool isDj; // true=DJ(disc), false=rapper(mic)
  final List<Color> bg;
  const _Dj({
    required this.id,
    required this.clubId,
    required this.dj,
    required this.club,
    required this.time,
    required this.isDj,
    required this.bg,
  });
}

class _HipClub {
  final String id;
  final String name;
  final String area;
  final double dist;
  final double rating;
  final int reviews;
  final List<String> styles;
  final String lineup;
  final bool live;
  final bool open;
  final String thumbnailUrl;
  final List<Color> bg;
  final bool vybe; // isVybeRecommended — VYBE 추천 뱃지 노출
  const _HipClub({
    required this.id,
    required this.name,
    required this.area,
    required this.dist,
    required this.rating,
    required this.reviews,
    required this.styles,
    required this.lineup,
    required this.live,
    required this.open,
    required this.thumbnailUrl,
    required this.bg,
    required this.vybe,
  });
}

// 홍대 기준 좌표 — 거리 표시용(홈·주변 페이지와 동일).
const _kHongdaeLat = 37.5572;
const _kHongdaeLng = 126.9239;

// 두 좌표 간 거리(km) — Haversine.
double _distanceKm(double lat, double lng) {
  const r = 6371.0;
  final dLat = (lat - _kHongdaeLat) * math.pi / 180;
  final dLng = (lng - _kHongdaeLng) * math.pi / 180;
  final a =
      math.sin(dLat / 2) * math.sin(dLat / 2) +
      math.cos(_kHongdaeLat * math.pi / 180) *
          math.cos(lat * math.pi / 180) *
          math.sin(dLng / 2) *
          math.sin(dLng / 2);
  return r * 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
}

// ClubModel(+오늘 헤드라이너 공연) → 포스터 카드 뷰모델.
_HipClub _fromClub(ClubModel c, PerformanceModel? headliner) {
  return _HipClub(
    id: c.clubId,
    name: c.name,
    area: c.area,
    dist: _distanceKm(c.lat, c.lng),
    rating: c.rating,
    reviews: c.reviewCount,
    // 세부 장르 스타일 칩(genreStyles), 없으면 태그/장르 fallback.
    styles: c.genreStyles.isNotEmpty
        ? c.genreStyles.take(2).toList()
        : (c.tags.isNotEmpty ? c.tags.take(2).toList() : [c.genre]),
    lineup: headliner?.artistName ?? '',
    live: headliner != null,
    open: c.operatingHours.today.isCurrentlyOpen,
    thumbnailUrl: c.thumbnailUrl,
    bg: hipGradFor(c.clubId),
    vybe: c.isVybeRecommended,
  );
}

// 오늘 공연(performance) + 클럽 → hero(배너) 슬라이드 뷰모델. (텍스트=실데이터, 배경=그라데이션)
_Hero _heroFromPerf(PerformanceModel p, ClubModel? club) {
  return _Hero(
    name: p.clubName,
    area: p.clubArea,
    dist: club != null ? _distanceKm(club.lat, club.lng) : 0,
    rating: club?.rating ?? 0,
    lineup: p.artistName,
    genre: club?.genre ?? p.genre,
    time: '오늘 ${p.hhmm} 공연',
    tag: '오늘밤 주목할 공연',
    bg: hipGradFor(p.clubId),
  );
}

// 오늘 공연 → DJ rail(아티스트) 뷰모델.
_Dj _djFromPerf(PerformanceModel p, int idx) => _Dj(
  id: idx,
  clubId: p.clubId,
  dj: p.artistName,
  club: p.clubName,
  time: p.hhmm,
  isDj: p.isDj,
  bg: hipGradFor(p.clubId),
);

const _areas = ['인기순', '홍대', '강남', '압구정', '이태원', '건대'];

// 150deg 그라데이션 근사 (디자인 색/순서 유지, 각도만 근사).
LinearGradient _slideGrad(List<Color> colors) => LinearGradient(
  begin: const Alignment(-0.5, -0.87),
  end: const Alignment(0.5, 0.87),
  colors: colors,
);

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
  void _showOnMap(List<_HipClub> grid, Map<String, ClubModel> clubById) {
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
  List<_HipClub> _grid(List<_HipClub> source) {
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
    final bottomPad = MediaQuery.of(context).padding.bottom + 90.h;
    final async = ref.watch(hipHopViewModelProvider);
    final data = async.asData?.value;
    final loading = async.isLoading && data == null;

    final clubs = data?.clubs ?? const <ClubModel>[];
    final perfs = data?.performances ?? const <PerformanceModel>[];
    final clubById = {for (final c in clubs) c.clubId: c};
    final headliner = data?.headlinerByClub ?? const {};

    // 배너 = 오늘 공연하는 클럽(클럽별 1개, featured 먼저 → 시작시각순).
    final heroSrc =
        (data?.headlinerByClub.values.toList() ?? <PerformanceModel>[])
          ..sort((a, b) {
            final f = (b.isFeatured ? 1 : 0) - (a.isFeatured ? 1 : 0);
            return f != 0 ? f : a.startAt.compareTo(b.startAt);
          });
    final heroes = heroSrc
        .map((p) => _heroFromPerf(p, clubById[p.clubId]))
        .toList();
    // 아티스트 = 오늘 공연 전체(시작시각순).
    final djs = [
      for (var i = 0; i < perfs.length; i++) _djFromPerf(perfs[i], i),
    ];

    // 그리드(포스터) = 클럽 + 오늘 라인업 머지(live/lineup).
    final source = clubs.map((c) => _fromClub(c, headliner[c.clubId])).toList();
    final grid = _grid(source);

    return Scaffold(
      backgroundColor: _bg,
      body: SizedBox.expand(
        child: Stack(
          children: [
            // 상단 골드/보라 백드롭 그라데이션
            const Positioned(
              top: 0,
              left: 0,
              right: 0,
              height: 560,
              child: IgnorePointer(child: HipBackdrop()),
            ),
            Positioned.fill(
              child: ListView(
                padding: EdgeInsets.only(bottom: bottomPad),
                children: [
                  if (loading)
                    VybeSkel(height: 440.h, radius: 0)
                  else if (heroes.isNotEmpty)
                    _HeroCarousel(
                      heroes: heroes,
                      saved: _saved,
                      onSave: _toggleSave,
                    )
                  else
                    const _HeroEmpty(),
                  // 오늘의 공연 아티스트 (항상 노출)
                  Padding(
                    padding: EdgeInsets.only(top: 24.h),
                    child: _SectionHead(
                      title: '오늘의 공연 아티스트',
                      sub: '내 주변 힙합 클럽 · 공연 시간순',
                      onAllTap: () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const TodayLineupScreen(),
                        ),
                      ),
                    ),
                  ),
                  if (loading)
                    _DjRailSkeleton()
                  else if (djs.isNotEmpty)
                    _DjRail(djs: djs)
                  else
                    const _RailEmpty(),
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
                        Icon(Icons.album_outlined, size: 15.r, color: _hip),
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
                      child: _AreaFilter(
                        active: _area,
                        onChange: (a) => setState(() => _area = a),
                      ),
                    ),
                  ),
                  _SectionHead(
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
                          (_) => VybeSkel(height: double.infinity, radius: 16),
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
                              (c) => _PosterCard(
                                club: c,
                                saved: _saved.contains(c.id),
                                onSave: () => _toggleSave(c.id),
                                // 카드 탭 → 클럽 상세.
                                onTap: () => Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) =>
                                        ClubDetailScreen(clubId: c.id),
                                  ),
                                ),
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
              top: MediaQuery.of(context).padding.top,
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

// ── 배너 빈 상태 (오늘 공연 없음) ──
class _HeroEmpty extends StatelessWidget {
  const _HeroEmpty();

  @override
  Widget build(BuildContext context) {
    final top = MediaQuery.of(context).padding.top;
    return Container(
      height: 320.h,
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF1A1216), Color(0xFF0D0A0C)],
        ),
      ),
      alignment: Alignment.center,
      padding: EdgeInsets.only(top: top + 52.h, left: 24.w, right: 24.w),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 56.r,
            height: 56.r,
            decoration: BoxDecoration(
              color: _hip.withValues(alpha: 0.12),
              shape: BoxShape.circle,
              border: Border.all(color: _hip.withValues(alpha: 0.3)),
            ),
            child: Icon(
              Icons.mic_external_off_rounded,
              size: 26.r,
              color: _hip,
            ),
          ),
          SizedBox(height: 16.h),
          Text(
            '오늘 예정된 공연이 없어요',
            style: TextStyle(
              fontFamily: 'Pretendard',
              fontSize: 18.sp,
              height: 22 / 18,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            '새로운 공연 일정이 등록되면 여기에 표시돼요.',
            textAlign: TextAlign.center,
            style: VybeTypography.body4.copyWith(
              height: 18 / 13,
              color: VybeColors.gray500,
            ),
          ),
        ],
      ),
    );
  }
}

// ── 아티스트 레일 빈 상태 (오늘 공연 없음) ──
class _RailEmpty extends StatelessWidget {
  const _RailEmpty();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w),
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 22.h),
      decoration: BoxDecoration(
        color: VybeColors.gray900,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: VybeColors.gray800),
      ),
      alignment: Alignment.center,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.album_outlined, size: 16.r, color: VybeColors.gray500),
          SizedBox(width: 8.w),
          Text(
            '오늘 공연 예정인 아티스트가 없어요',
            style: VybeTypography.body4.copyWith(color: VybeColors.gray400),
          ),
        ],
      ),
    );
  }
}

// ── 히어로 캐러셀 (배너 광고 — 좌우 스크롤 + 자동 넘김) ──
class _HeroCarousel extends StatefulWidget {
  final List<_Hero> heroes;
  final Set<Object> saved;
  final ValueChanged<Object> onSave;
  const _HeroCarousel({
    required this.heroes,
    required this.saved,
    required this.onSave,
  });

  @override
  State<_HeroCarousel> createState() => _HeroCarouselState();
}

class _HeroCarouselState extends State<_HeroCarousel> {
  final PageController _page = PageController();
  int _active = 0;
  Timer? _auto;

  // 배너 자동 넘김 주기.
  static const _kRotate = Duration(seconds: 4);

  @override
  void initState() {
    super.initState();
    _startAuto();
  }

  void _startAuto() {
    _auto?.cancel();
    if (widget.heroes.length <= 1) return;
    _auto = Timer.periodic(_kRotate, (_) {
      if (!mounted || !_page.hasClients) return;
      final next = (_active + 1) % widget.heroes.length;
      _page.animateToPage(
        next,
        duration: const Duration(milliseconds: 450),
        curve: Curves.easeInOut,
      );
    });
  }

  @override
  void didUpdateWidget(covariant _HeroCarousel old) {
    super.didUpdateWidget(old);
    if (old.heroes.length != widget.heroes.length) {
      if (_active >= widget.heroes.length) _active = 0;
      _startAuto();
    }
  }

  @override
  void dispose() {
    _auto?.cancel();
    _page.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final heroes = widget.heroes;
    return SizedBox(
      height: 440.h,
      child: Stack(
        children: [
          // 사용자가 직접 스와이프하면 자동 넘김 타이머 리셋(바로 안 넘어가게).
          NotificationListener<UserScrollNotification>(
            onNotification: (n) {
              if (n.direction != ScrollDirection.idle) _startAuto();
              return false;
            },
            child: PageView.builder(
              controller: _page,
              onPageChanged: (i) => setState(() => _active = i),
              itemCount: heroes.length,
              itemBuilder: (_, i) => _HeroSlide(
                h: heroes[i],
                saved: widget.saved.contains('hero-${heroes[i].name}'),
                onSave: () => widget.onSave('hero-${heroes[i].name}'),
              ),
            ),
          ),
          // 페이지 인디케이터.
          Positioned(
            bottom: 16.h,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                for (var i = 0; i < heroes.length; i++)
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    margin: EdgeInsets.symmetric(horizontal: 3.w),
                    height: 6.h,
                    width: i == _active ? 20.w : 6.w,
                    decoration: BoxDecoration(
                      color: i == _active
                          ? _hip
                          : Colors.white.withValues(alpha: 0.4),
                      borderRadius: BorderRadius.circular(99.r),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _HeroSlide extends StatelessWidget {
  final _Hero h;
  final bool saved;
  final VoidCallback onSave;
  const _HeroSlide({
    required this.h,
    required this.saved,
    required this.onSave,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        DecoratedBox(decoration: BoxDecoration(gradient: _slideGrad(h.bg))),
        // 우상단 화이트 하이라이트.
        const Positioned.fill(
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: Alignment(0.5, -0.76),
                radius: 0.9,
                colors: [Color(0x38FFFFFF), Color(0x00FFFFFF)],
                stops: [0.0, 0.55],
              ),
            ),
          ),
        ),
        // 하단 어둡게.
        const Positioned.fill(
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
                colors: [
                  Color(0xFF0D0A0C),
                  Color(0x8C0D0A0C),
                  Color(0x260D0A0C),
                  Color(0x660D0A0C),
                ],
                stops: [0.06, 0.42, 0.70, 1.0],
              ),
            ),
          ),
        ),
        // 찜.
        Positioned(
          top: 60.h,
          right: 16.w,
          child: GestureDetector(
            onTap: onSave,
            behavior: HitTestBehavior.opaque,
            child: Container(
              width: 38.r,
              height: 38.r,
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.4),
                shape: BoxShape.circle,
              ),
              child: Icon(
                saved ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                size: 20.r,
                color: saved ? VybeColors.mainPurple500 : Colors.white,
              ),
            ),
          ),
        ),
        // 본문.
        Positioned(
          left: 20.w,
          right: 20.w,
          bottom: 42.h,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // eyebrow.
              Container(
                margin: EdgeInsets.only(bottom: 13.h),
                padding: EdgeInsets.symmetric(horizontal: 11.w, vertical: 6.h),
                decoration: BoxDecoration(
                  color: _hip,
                  borderRadius: BorderRadius.circular(999.r),
                  boxShadow: [
                    BoxShadow(
                      color: _hip.withValues(alpha: 0.4),
                      blurRadius: 20,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.mic_none_rounded, size: 13.r, color: _onHip),
                    SizedBox(width: 6.w),
                    Text(
                      h.tag,
                      style: TextStyle(
                        fontFamily: 'Pretendard',
                        fontSize: 11.sp,
                        height: 12 / 11,
                        fontWeight: FontWeight.w800,
                        color: _onHip,
                        letterSpacing: 11 * 0.02,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                h.name,
                style: TextStyle(
                  fontFamily: 'Pretendard',
                  fontSize: 40.sp,
                  height: 42 / 40,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                  shadows: const [
                    Shadow(
                      color: Color(0x800D0A0C),
                      blurRadius: 24,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 12.h),
              // 라인업 · 장르.
              Row(
                children: [
                  Icon(Icons.mic_none_rounded, size: 14.r, color: _hip),
                  SizedBox(width: 4.w),
                  Text(
                    '${h.lineup} LIVE',
                    style: VybeTypography.body4.copyWith(
                      fontWeight: FontWeight.w700,
                      color: _hip,
                    ),
                  ),
                  SizedBox(width: 8.w),
                  _dot(),
                  SizedBox(width: 8.w),
                  Text(
                    h.genre,
                    style: VybeTypography.body4.copyWith(
                      fontWeight: FontWeight.w600,
                      color: VybeColors.gray200,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16.h),
              // CTA.
              Container(
                height: 50.h,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: _hip,
                  borderRadius: BorderRadius.circular(14.r),
                  boxShadow: [
                    BoxShadow(
                      color: _hip.withValues(alpha: 0.3),
                      blurRadius: 24,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.play_arrow_rounded, size: 16.r, color: _onHip),
                    SizedBox(width: 7.w),
                    Text(
                      '지금 입장 정보 보기',
                      style: VybeTypography.button1.copyWith(
                        fontWeight: FontWeight.w800,
                        color: _onHip,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 13.h),
              // 평점 · 위치 · 시간.
              Row(
                children: [
                  Icon(
                    Icons.star_rounded,
                    size: 13.r,
                    color: VybeColors.mainLime500,
                  ),
                  SizedBox(width: 4.w),
                  Text(
                    h.rating.toStringAsFixed(2),
                    style: VybeTypography.body4.copyWith(
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(width: 7.w),
                  _dot(),
                  SizedBox(width: 7.w),
                  Icon(
                    Icons.place_rounded,
                    size: 12.r,
                    color: VybeColors.gray300,
                  ),
                  SizedBox(width: 4.w),
                  Flexible(
                    child: Text(
                      '${h.area} · ${h.dist}km',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: VybeTypography.body4.copyWith(
                        color: VybeColors.gray300,
                      ),
                    ),
                  ),
                  SizedBox(width: 7.w),
                  _dot(),
                  SizedBox(width: 7.w),
                  Text(
                    h.time,
                    style: VybeTypography.body4.copyWith(
                      color: VybeColors.gray400,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _dot() => Container(
    width: 3.r,
    height: 3.r,
    decoration: const BoxDecoration(
      color: VybeColors.gray500,
      shape: BoxShape.circle,
    ),
  );
}

// ── 섹션 헤더 ──
class _SectionHead extends StatelessWidget {
  final String title;
  final String sub;
  final bool mapAction;
  final VoidCallback? onMapTap;
  final VoidCallback? onAllTap;
  final double bottomGap;
  const _SectionHead({
    required this.title,
    required this.sub,
    this.mapAction = false,
    this.onMapTap,
    this.onAllTap,
    this.bottomGap = 13,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(left: 16.w, right: 16.w, bottom: bottomGap.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontFamily: 'Pretendard',
                    fontSize: 19.sp,
                    height: 22 / 19,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 5.h),
                Text(
                  sub,
                  style: VybeTypography.caption.copyWith(
                    height: 16 / 12,
                    color: VybeColors.gray500,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: 8.w),
          if (mapAction)
            GestureDetector(
              onTap: onMapTap,
              behavior: HitTestBehavior.opaque,
              child: Container(
                height: 30.h,
                padding: EdgeInsets.symmetric(horizontal: 11.w),
                decoration: BoxDecoration(
                  color: VybeColors.gray900,
                  borderRadius: BorderRadius.circular(99.r),
                  border: Border.all(color: VybeColors.gray800),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.place_rounded, size: 13.r, color: _hip),
                    SizedBox(width: 4.w),
                    Text(
                      '지도에서 보기',
                      style: VybeTypography.caption.copyWith(
                        height: 14 / 12,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            GestureDetector(
              onTap: onAllTap,
              behavior: HitTestBehavior.opaque,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '전체',
                    style: VybeTypography.caption.copyWith(
                      height: 14 / 12,
                      fontWeight: FontWeight.w600,
                      color: VybeColors.gray500,
                    ),
                  ),
                  Icon(
                    Icons.chevron_right_rounded,
                    size: 14.r,
                    color: VybeColors.gray500,
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

// ── 오늘의 공연 아티스트 레일 ──
class _DjRail extends StatelessWidget {
  final List<_Dj> djs;
  const _DjRail({required this.djs});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: EdgeInsets.only(left: 16.w, right: 16.w, bottom: 4.h),
      child: Row(
        children: [
          for (var i = 0; i < djs.length; i++) ...[
            if (i > 0) SizedBox(width: 14.w),
            _DjCircle(d: djs[i]),
          ],
        ],
      ),
    );
  }
}

// 아티스트 레일 로딩 스켈레톤.
class _DjRailSkeleton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const NeverScrollableScrollPhysics(),
      padding: EdgeInsets.only(left: 16.w, right: 16.w, bottom: 4.h),
      child: Row(
        children: [
          for (var i = 0; i < 5; i++) ...[
            if (i > 0) SizedBox(width: 14.w),
            SizedBox(
              width: 76.w,
              child: Column(
                children: [
                  VybeSkel(width: 72.r, height: 72.r, radius: 99),
                  SizedBox(height: 8.h),
                  VybeSkel(width: 56.w, height: 12.h, radius: 6),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _DjCircle extends StatelessWidget {
  final _Dj d;
  const _DjCircle({required this.d});

  @override
  Widget build(BuildContext context) {
    final grad = LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: d.bg,
    );
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      // 아티스트 탭 → 해당 클럽 상세.
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => ClubDetailScreen(clubId: d.clubId)),
      ),
      child: SizedBox(
        width: 76.w,
        child: Column(
          children: [
            SizedBox(
              width: 72.r,
              height: 72.r,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  // 외곽 골드 링 + 내부 원.
                  Container(
                    width: 72.r,
                    height: 72.r,
                    padding: EdgeInsets.all(2.r),
                    decoration: BoxDecoration(
                      gradient: grad,
                      shape: BoxShape.circle,
                      border: Border.all(color: _hip, width: 2),
                    ),
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: grad,
                        shape: BoxShape.circle,
                      ),
                      alignment: Alignment.center,
                      child: Icon(
                        d.isDj ? Icons.album_outlined : Icons.mic_none_rounded,
                        size: 24.r,
                        color: Colors.white.withValues(alpha: 0.85),
                      ),
                    ),
                  ),
                  // 시간 배지.
                  Positioned(
                    bottom: -3.h,
                    left: 0,
                    right: 0,
                    child: Center(
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 7.w,
                          vertical: 2.h,
                        ),
                        decoration: BoxDecoration(
                          color: _onHip,
                          borderRadius: BorderRadius.circular(99.r),
                          border: Border.all(color: _hip),
                        ),
                        child: Text(
                          d.time,
                          style: TextStyle(
                            fontFamily: 'Pretendard',
                            fontSize: 10.sp,
                            height: 12 / 10,
                            fontWeight: FontWeight.w800,
                            color: _hip,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              d.dj,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: VybeTypography.caption.copyWith(
                height: 14 / 12,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
            SizedBox(height: 2.h),
            Text(
              '${d.isDj ? 'DJ · ' : ''}${d.club}',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontFamily: 'Pretendard',
                fontSize: 11.sp,
                height: 13 / 11,
                color: VybeColors.gray500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── 지역 필터 ──
class _AreaFilter extends StatelessWidget {
  final String active;
  final ValueChanged<String> onChange;
  const _AreaFilter({required this.active, required this.onChange});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 34.h,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.only(left: 16.w, right: 16.w),
        itemCount: _areas.length,
        separatorBuilder: (_, __) => SizedBox(width: 8.w),
        itemBuilder: (_, i) {
          final s = _areas[i];
          final sel = s == active;
          final fg = sel ? _onHip : VybeColors.gray300;
          return GestureDetector(
            onTap: () => onChange(s),
            child: Container(
              height: 34.h,
              padding: EdgeInsets.symmetric(horizontal: 15.w),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: sel ? _hip : VybeColors.gray900,
                borderRadius: BorderRadius.circular(999.r),
                border: sel ? null : Border.all(color: VybeColors.gray800),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (s != '인기순') ...[
                    Icon(
                      Icons.place_rounded,
                      size: 12.r,
                      color: sel ? _onHip : VybeColors.gray400,
                    ),
                    SizedBox(width: 5.w),
                  ],
                  Text(
                    s,
                    style: VybeTypography.button2.copyWith(
                      fontWeight: sel ? FontWeight.w700 : FontWeight.w500,
                      color: fg,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

// ── 포스터 카드 ──
class _PosterCard extends StatelessWidget {
  final _HipClub club;
  final bool saved;
  final VoidCallback onSave;
  final VoidCallback onTap;
  const _PosterCard({
    required this.club,
    required this.saved,
    required this.onSave,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16.r),
        child: Container(
          decoration: BoxDecoration(
            gradient: _slideGrad(club.bg),
            border: Border.all(color: VybeColors.gray800),
          ),
          child: Stack(
            fit: StackFit.expand,
            children: [
              // 클럽 썸네일(없으면 그라데이션만).
              if (club.thumbnailUrl.isNotEmpty)
                Positioned.fill(
                  child: SkeletonImage(
                    url: club.thumbnailUrl,
                    fit: BoxFit.cover,
                    minSkeleton: const Duration(seconds: 1),
                  ),
                ),
              const Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: RadialGradient(
                      center: Alignment(0.4, -0.76),
                      radius: 0.9,
                      colors: [Color(0x33FFFFFF), Color(0x00FFFFFF)],
                      stops: [0.0, 0.55],
                    ),
                  ),
                ),
              ),
              const Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                      colors: [
                        Color(0xF20A090B),
                        Color(0x330A090B),
                        Color(0x000A090B),
                      ],
                      stops: [0.16, 0.56, 0.80],
                    ),
                  ),
                ),
              ),
              // 영업 상태.
              Positioned(
                top: 11.h,
                left: 11.w,
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.42),
                    borderRadius: BorderRadius.circular(99.r),
                    border: Border.all(
                      color: club.open
                          ? VybeColors.mainLime500.withValues(alpha: 0.5)
                          : VybeColors.gray700,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 5.r,
                        height: 5.r,
                        decoration: BoxDecoration(
                          color: club.open
                              ? VybeColors.mainLime500
                              : VybeColors.gray500,
                          shape: BoxShape.circle,
                        ),
                      ),
                      SizedBox(width: 5.w),
                      Text(
                        club.open ? '영업중' : '영업종료',
                        style: VybeTypography.caption.copyWith(
                          fontSize: 10.sp,
                          height: 11 / 10,
                          fontWeight: FontWeight.w700,
                          color: club.open
                              ? VybeColors.mainLime500
                              : VybeColors.gray400,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              // 찜.
              Positioned(
                top: 8.h,
                right: 8.w,
                child: GestureDetector(
                  onTap: onSave,
                  behavior: HitTestBehavior.opaque,
                  child: Container(
                    width: 30.r,
                    height: 30.r,
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.42),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      saved
                          ? Icons.favorite_rounded
                          : Icons.favorite_border_rounded,
                      size: 15.r,
                      color: saved ? VybeColors.mainPurple500 : Colors.white,
                    ),
                  ),
                ),
              ),
              // 본문.
              Positioned(
                left: 12.w,
                right: 12.w,
                bottom: 12.h,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (club.live) ...[
                      Container(
                        margin: EdgeInsets.only(bottom: 8.h),
                        padding: EdgeInsets.symmetric(
                          horizontal: 8.w,
                          vertical: 3.h,
                        ),
                        decoration: BoxDecoration(
                          color: _hip.withValues(alpha: 0.18),
                          borderRadius: BorderRadius.circular(7.r),
                          border: Border.all(
                            color: _hip.withValues(alpha: 0.36),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.mic_none_rounded,
                              size: 11.r,
                              color: _hip,
                            ),
                            SizedBox(width: 4.w),
                            Text(
                              '${club.lineup} LIVE',
                              style: VybeTypography.caption.copyWith(
                                fontSize: 10.sp,
                                height: 11 / 10,
                                fontWeight: FontWeight.w700,
                                color: _hip,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        Flexible(
                          child: Text(
                            club.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontFamily: 'Pretendard',
                              fontSize: 18.sp,
                              height: 20 / 18,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        // VYBE 추천 뱃지 — 클럽 이름 옆.
                        if (club.vybe) ...[
                          SizedBox(width: 6.w),
                          const VybeRecommendBadge(size: 10),
                        ],
                        SizedBox(width: 6.w),
                        Icon(
                          Icons.star_rounded,
                          size: 11.r,
                          color: VybeColors.mainLime500,
                        ),
                        SizedBox(width: 2.w),
                        Text(
                          club.rating.toStringAsFixed(2),
                          style: VybeTypography.caption.copyWith(
                            fontSize: 11.sp,
                            height: 12 / 11,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 5.h),
                    Row(
                      children: [
                        Icon(
                          Icons.place_rounded,
                          size: 10.r,
                          color: VybeColors.gray400,
                        ),
                        SizedBox(width: 4.w),
                        Text(
                          '${club.area} · ${club.dist.toStringAsFixed(1)}km',
                          style: VybeTypography.caption.copyWith(
                            fontSize: 11.sp,
                            height: 12 / 11,
                            fontWeight: FontWeight.w600,
                            color: VybeColors.gray400,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 8.h),
                    Wrap(
                      spacing: 5.w,
                      runSpacing: 5.h,
                      children: club.styles
                          .map(
                            (t) => Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 7.w,
                                vertical: 1.h,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.09),
                                borderRadius: BorderRadius.circular(6.r),
                              ),
                              child: Text(
                                '#$t',
                                style: VybeTypography.caption.copyWith(
                                  fontSize: 10.sp,
                                  height: 13 / 10,
                                  fontWeight: FontWeight.w600,
                                  color: VybeColors.gray300,
                                ),
                              ),
                            ),
                          )
                          .toList(),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
