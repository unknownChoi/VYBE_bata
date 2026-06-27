import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vybe/design_system/colors.dart';
import 'package:vybe/design_system/typography.dart';

// 핫플레이스 — 실시간 방문자/혼잡도 기반 클럽 랭킹.
// claude.ai/design hot_places.html 디자인을 하드코딩 프론트로 구현.
// TODO: 추후 Firebase 실연동 (현재는 더미 데이터).

// hot-place accent (flame orange)
const Color _hot = Color(0xFFFF6A2B);

// ── 혼잡도 ──
enum _Crowd { packed, busy, lively }

class _CrowdInfo {
  final String label;
  final Color color;
  final double pct;
  const _CrowdInfo(this.label, this.color, this.pct);
}

const Map<_Crowd, _CrowdInfo> _crowdMap = {
  _Crowd.packed: _CrowdInfo('매우 붐빔', Color(0xFFFF3B30), 95),
  _Crowd.busy: _CrowdInfo('붐빔', _hot, 78),
  _Crowd.lively: _CrowdInfo('활기참', VybeColors.mainLime500, 55),
};

// ── 클럽 더미 모델 ──
class _Club {
  final int id;
  final int rank;
  final String name;
  final String area;
  final String genre;
  final double dist; // km
  final String visitors;
  final double rating;
  final _Crowd crowd;
  final bool up;
  final List<Color> bg;
  const _Club({
    required this.id,
    required this.rank,
    required this.name,
    required this.area,
    required this.genre,
    required this.dist,
    required this.visitors,
    required this.rating,
    required this.crowd,
    this.up = false,
    required this.bg,
  });

  _Club copyRank(int r) => _Club(
        id: id,
        rank: r,
        name: name,
        area: area,
        genre: genre,
        dist: dist,
        visitors: visitors,
        rating: rating,
        crowd: crowd,
        up: up,
        bg: bg,
      );
}

const List<String> _areas = ['전체', '내 주변', '홍대', '강남', '이태원', '압구정', '건대'];

const List<_Club> _top = [
  _Club(id: 1, rank: 1, name: '어썸레드', area: '홍대', genre: '힙합', dist: 0.4, visitors: '2.4천', rating: 4.76, crowd: _Crowd.packed, bg: [Color(0xFF2B1655), Color(0xFF7731FE), Color(0xFFFF4D8D)]),
  _Club(id: 2, rank: 2, name: 'OCTAGON', area: '강남', genre: 'EDM', dist: 5.2, visitors: '2.1천', rating: 4.80, crowd: _Crowd.packed, bg: [Color(0xFF2B6BFF), Color(0xFF7731FE)]),
  _Club(id: 3, rank: 3, name: '버뮤다', area: '홍대', genre: '힙합', dist: 0.7, visitors: '1.8천', rating: 4.62, crowd: _Crowd.busy, bg: [Color(0xFF06FFA5), Color(0xFF3A86FF)]),
];

const List<_Club> _list = [
  _Club(id: 4, rank: 4, name: '인클', area: '홍대', genre: '힙합', dist: 0.5, visitors: '1.6천', rating: 4.70, crowd: _Crowd.busy, up: true, bg: [Color(0xFFFB5607), Color(0xFFFFBE0B)]),
  _Club(id: 5, rank: 5, name: '메이드', area: '이태원', genre: 'EDM', dist: 6.1, visitors: '1.5천', rating: 4.58, crowd: _Crowd.busy, up: true, bg: [Color(0xFFFF006E), Color(0xFF8338EC)]),
  _Club(id: 6, rank: 6, name: '소다', area: '강남', genre: '하우스', dist: 5.4, visitors: '1.3천', rating: 4.49, crowd: _Crowd.lively, bg: [Color(0xFF3A0CA3), Color(0xFF4361EE)]),
  _Club(id: 7, rank: 7, name: '케이크샵', area: '이태원', genre: '테크노', dist: 6.3, visitors: '1.2천', rating: 4.66, crowd: _Crowd.lively, up: true, bg: [Color(0xFF06FFA5), Color(0xFF1B9AAA)]),
  _Club(id: 8, rank: 8, name: '글로우', area: '압구정', genre: 'EDM', dist: 4.2, visitors: '1.1천', rating: 4.41, crowd: _Crowd.lively, bg: [Color(0xFFF72585), Color(0xFFB5179E)]),
  _Club(id: 9, rank: 9, name: '하이브', area: '건대', genre: '힙합', dist: 3.1, visitors: '980', rating: 4.38, crowd: _Crowd.lively, up: true, bg: [Color(0xFFFFBE0B), Color(0xFFFB5607)]),
  _Club(id: 10, rank: 10, name: '벨로주', area: '홍대', genre: '재즈', dist: 0.9, visitors: '870', rating: 4.51, crowd: _Crowd.lively, bg: [Color(0xFF2A2D34), Color(0xFF6C757D)]),
];

const double _nearRadius = 2; // km

class HotPlacesScreen extends StatefulWidget {
  const HotPlacesScreen({super.key});

  @override
  State<HotPlacesScreen> createState() => _HotPlacesScreenState();
}

class _HotPlacesScreenState extends State<HotPlacesScreen> {
  bool _loading = true;
  String _area = '전체';
  bool _scrolled = false;
  final Set<int> _saved = {1};
  final ScrollController _scroll = ScrollController();

  @override
  void initState() {
    super.initState();
    _scroll.addListener(() {
      final s = _scroll.offset > 8;
      if (s != _scrolled) setState(() => _scrolled = s);
    });
    Future.delayed(const Duration(milliseconds: 1300), () {
      if (mounted) setState(() => _loading = false);
    });
  }

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  void _toggleSave(int id) => setState(() {
        _saved.contains(id) ? _saved.remove(id) : _saved.add(id);
      });

  // 지역 필터 + 재랭킹.
  List<_Club> get _ranked {
    final all = [..._top, ..._list];
    if (_area == '전체') return all;
    if (_area == '내 주변') {
      final near = all.where((c) => c.dist <= _nearRadius).toList()
        ..sort((a, b) => a.dist.compareTo(b.dist));
      return [for (var i = 0; i < near.length; i++) near[i].copyRank(i + 1)];
    }
    final f = all.where((c) => c.area == _area).toList()
      ..sort((a, b) => a.rank.compareTo(b.rank));
    return [for (var i = 0; i < f.length; i++) f[i].copyRank(i + 1)];
  }

  @override
  Widget build(BuildContext context) {
    final near = _area == '내 주변';
    final ranked = _ranked;
    // 전체일 때만 TOP 3 포디움 + 나머지 순위.
    final list = _area == '전체' ? ranked.skip(3).toList() : ranked;
    final total = ranked.length;
    // 플로팅 바텀 nav(MainScaffold) 가림 방지용 하단 여백.
    final bottomPad = MediaQuery.of(context).padding.bottom + 90.h;

    return Scaffold(
      backgroundColor: VybeColors.background,
      body: Column(
        children: [
          _Header(scrolled: _scrolled),
          Expanded(
            child: _loading
                ? const _Skeleton()
                : Stack(
                    children: [
                      // intro→filter→podium 뒤 연속 그라데이션 백드롭.
                      Positioned(
                        top: 0,
                        left: 0,
                        right: 0,
                        height: 560.h,
                        child: const IgnorePointer(child: _Backdrop()),
                      ),
                      ListView(
                        controller: _scroll,
                        padding: EdgeInsets.only(bottom: bottomPad),
                        children: [
                          _Intro(area: _area),
                          _AreaFilter(
                            active: _area,
                            scrolled: _scrolled,
                            onChange: (a) => setState(() => _area = a),
                          ),
                          if (_area == '전체')
                            _Podium(
                              clubs: ranked.take(3).toList(),
                              saved: _saved,
                              onSave: _toggleSave,
                            ),
                          _SectionHeader(area: _area, near: near, total: total),
                          if (near && list.isEmpty)
                            Padding(
                              padding: EdgeInsets.symmetric(vertical: 60.h, horizontal: 24.w),
                              child: Text(
                                '반경 2km 안에 집계된 핫플이 아직 없어요',
                                textAlign: TextAlign.center,
                                style: VybeTypography.body4.copyWith(color: VybeColors.gray500),
                              ),
                            )
                          else
                            ...list.map((c) => _ListRow(
                                  club: c,
                                  near: near,
                                  saved: _saved.contains(c.id),
                                  onSave: _toggleSave,
                                )),
                          _Footer(),
                        ],
                      ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }
}

// ── 백드롭 그라데이션 ──
class _Backdrop extends StatelessWidget {
  const _Backdrop();
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: const Alignment(-1, -1),
                radius: 1.2,
                colors: [_hot.withValues(alpha: 0.30), Colors.transparent],
                stops: const [0, 0.72],
              ),
            ),
          ),
        ),
        Positioned.fill(
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: const Alignment(1, -0.85),
                radius: 1.3,
                colors: [const Color(0xFFFF3B30).withValues(alpha: 0.17), Colors.transparent],
                stops: const [0, 0.72],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ── 헤더 ──
class _Header extends StatelessWidget {
  final bool scrolled;
  const _Header({required this.scrolled});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 52.h + MediaQuery.of(context).padding.top,
      padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top, left: 8.w, right: 8.w),
      decoration: BoxDecoration(
        color: VybeColors.background.withValues(alpha: 0.9),
        border: Border(
          bottom: BorderSide(
            color: scrolled ? VybeColors.gray900 : Colors.transparent,
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _IconBtn(
            onTap: () => Navigator.of(context).maybePop(),
            child: Icon(Icons.arrow_back_ios_new, size: 22.r, color: Colors.white),
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const _Flame(size: 16),
              SizedBox(width: 6.w),
              Text(
                '핫플레이스',
                style: VybeTypography.button1.copyWith(fontWeight: FontWeight.w700, color: Colors.white),
              ),
            ],
          ),
          _IconBtn(
            onTap: () {},
            child: Icon(Icons.search, size: 22.r, color: Colors.white),
          ),
        ],
      ),
    );
  }
}

class _IconBtn extends StatelessWidget {
  final Widget child;
  final VoidCallback onTap;
  const _IconBtn({required this.child, required this.onTap});
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: SizedBox(width: 44.w, height: 44.h, child: Center(child: child)),
    );
  }
}

// ── 인트로 (헤딩 + 실시간 배지) ──
class _Intro extends StatelessWidget {
  final String area;
  const _Intro({required this.area});

  @override
  Widget build(BuildContext context) {
    final base = VybeTypography.heading2.copyWith(
      fontSize: 27.sp,
      height: 33 / 27,
      color: Colors.white,
    );
    final spans = area == '전체'
        ? <InlineSpan>[
            const TextSpan(text: '지금 가장 '),
            TextSpan(text: '뜨거운', style: TextStyle(color: _hot)),
            const TextSpan(text: '\n클럽을 모아봤어요'),
          ]
        : <InlineSpan>[
            TextSpan(text: '지금 $area에서 가장 '),
            TextSpan(text: '뜨거운', style: TextStyle(color: _hot)),
            const TextSpan(text: '\n클럽을 모아봤어요'),
          ];

    return Padding(
      padding: EdgeInsets.fromLTRB(24.w, 20.h, 24.w, 18.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 420),
            transitionBuilder: (child, anim) => FadeTransition(
              opacity: anim,
              child: SlideTransition(
                position: Tween(begin: const Offset(0, 0.3), end: Offset.zero).animate(anim),
                child: child,
              ),
            ),
            child: Text.rich(
              TextSpan(style: base, children: spans),
              key: ValueKey(area),
            ),
          ),
          SizedBox(height: 8.h),
          Row(
            children: [
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
                decoration: BoxDecoration(
                  color: const Color(0xFFFF3B30).withValues(alpha: 0.16),
                  borderRadius: BorderRadius.circular(999.r),
                  border: Border.all(color: const Color(0xFFFF3B30).withValues(alpha: 0.4)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const _PulseDot(),
                    SizedBox(width: 5.w),
                    Text(
                      '실시간',
                      style: VybeTypography.caption.copyWith(
                        height: 14 / 12,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(width: 7.w),
              Flexible(
                child: Text(
                  '오늘 23:40 기준 · 최근 2시간 방문자 순',
                  style: VybeTypography.caption.copyWith(height: 16 / 12, color: VybeColors.gray400),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _PulseDot extends StatefulWidget {
  const _PulseDot();
  @override
  State<_PulseDot> createState() => _PulseDotState();
}

class _PulseDotState extends State<_PulseDot> with SingleTickerProviderStateMixin {
  late final AnimationController _c =
      AnimationController(vsync: this, duration: const Duration(milliseconds: 1400))..repeat(reverse: true);

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: Tween(begin: 1.0, end: 1.18).animate(CurvedAnimation(parent: _c, curve: Curves.easeInOut)),
      child: FadeTransition(
        opacity: Tween(begin: 1.0, end: 0.7).animate(_c),
        child: Container(
          width: 7.r,
          height: 7.r,
          decoration: const BoxDecoration(color: Color(0xFFFF3B30), shape: BoxShape.circle),
        ),
      ),
    );
  }
}

// ── 지역 필터 ──
class _AreaFilter extends StatelessWidget {
  final String active;
  final bool scrolled;
  final ValueChanged<String> onChange;
  const _AreaFilter({required this.active, required this.scrolled, required this.onChange});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: scrolled ? VybeColors.background.withValues(alpha: 0.92) : Colors.transparent,
      padding: EdgeInsets.fromLTRB(16.w, 10.h, 16.w, 12.h),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            for (final a in _areas) ...[
              _Chip(label: a, selected: a == active, onTap: () => onChange(a)),
              if (a != _areas.last) SizedBox(width: 8.w),
            ],
          ],
        ),
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const _Chip({required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final isNear = label == '내 주변';
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: EdgeInsets.only(
          left: isNear ? 11.w : 16.w,
          right: 16.w,
          top: 8.h,
          bottom: 8.h,
        ),
        decoration: BoxDecoration(
          color: selected ? Colors.white : VybeColors.gray900,
          borderRadius: BorderRadius.circular(999.r),
          border: selected ? null : Border.all(color: VybeColors.gray800),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isNear) ...[
              Icon(Icons.place, size: 13.r, color: selected ? Colors.black : _hot),
              SizedBox(width: 4.w),
            ],
            Text(
              label,
              style: VybeTypography.button2.copyWith(
                fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                color: selected ? Colors.black : VybeColors.gray300,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── 포디움 (TOP 3) ──
class _Podium extends StatelessWidget {
  final List<_Club> clubs;
  final Set<int> saved;
  final ValueChanged<int> onSave;
  const _Podium({required this.clubs, required this.saved, required this.onSave});

  @override
  Widget build(BuildContext context) {
    if (clubs.isEmpty) return const SizedBox.shrink();
    final first = clubs.first;
    final rest = clubs.skip(1).toList();
    final solo = rest.isEmpty;

    return Padding(
      padding: EdgeInsets.fromLTRB(16.w, 6.h, 16.w, 8.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(2.w, 6.h, 2.w, 12.h),
            child: Text(
              '실시간 TOP ${clubs.length}',
              style: VybeTypography.button2.copyWith(fontWeight: FontWeight.w700, color: Colors.white),
            ),
          ),
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  flex: solo ? 1 : 6,
                  child: _PodiumCard(
                    club: first,
                    big: true,
                    saved: saved.contains(first.id),
                    onSave: onSave,
                  ),
                ),
                if (!solo) ...[
                  SizedBox(width: 10.w),
                  Expanded(
                    flex: 4,
                    child: Column(
                      children: [
                        for (var i = 0; i < rest.length; i++) ...[
                          _PodiumCard(
                            club: rest[i],
                            big: false,
                            saved: saved.contains(rest[i].id),
                            onSave: onSave,
                          ),
                          if (i != rest.length - 1) SizedBox(height: 10.h),
                        ],
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// 메달 색.
class _Medal {
  final List<Color> grad;
  final Color ink;
  const _Medal(this.grad, this.ink);
}

const Map<int, _Medal> _medals = {
  1: _Medal([Color(0xFFFFE7A0), Color(0xFFFBC02D), Color(0xFFC8860B)], Color(0xFF5A3A00)),
  2: _Medal([Color(0xFFF2F5FA), Color(0xFFC5CCD6), Color(0xFF9098A6)], Color(0xFF3D434D)),
  3: _Medal([Color(0xFFF2B98C), Color(0xFFD98A52), Color(0xFFA65B2A)], Color(0xFF502A0E)),
};

class _PodiumCard extends StatelessWidget {
  final _Club club;
  final bool big;
  final bool saved;
  final ValueChanged<int> onSave;
  const _PodiumCard({required this.club, required this.big, required this.saved, required this.onSave});

  @override
  Widget build(BuildContext context) {
    final cr = _crowdMap[club.crowd]!;
    final h = big ? 188.h : 89.h;
    final medal = _medals[club.rank] ?? _medals[3]!;

    return Container(
      height: h,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: club.bg),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: VybeColors.gray800),
      ),
      child: Stack(
        children: [
          // 하단 어둡게.
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [
                    VybeColors.background.withValues(alpha: 0.94),
                    VybeColors.background.withValues(alpha: 0.15),
                    Colors.transparent,
                  ],
                  stops: const [0.08, 0.55, 0.8],
                ),
              ),
            ),
          ),
          // 메달.
          Positioned(
            top: 10.h,
            left: 10.w,
            child: Container(
              width: big ? 32.r : 27.r,
              height: big ? 32.r : 27.r,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: medal.grad),
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white.withValues(alpha: 0.45), width: 1.5),
              ),
              child: Text(
                '${club.rank}',
                style: TextStyle(
                  fontFamily: 'Pretendard',
                  fontWeight: FontWeight.w800,
                  fontSize: (big ? 15 : 13).sp,
                  color: medal.ink,
                ),
              ),
            ),
          ),
          // 찜.
          Positioned(
            top: 8.h,
            right: 8.w,
            child: GestureDetector(
              onTap: () => onSave(club.id),
              behavior: HitTestBehavior.opaque,
              child: Container(
                width: 30.r,
                height: 30.r,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.4),
                  shape: BoxShape.circle,
                ),
                child: _Heart(active: saved, size: 16),
              ),
            ),
          ),
          // 혼잡 배지 (big만 상단 고정).
          if (big)
            Positioned(
              top: 48.h,
              left: 10.w,
              child: _CrowdBadge(cr: cr),
            ),
          // 정보.
          Positioned(
            left: 12.w,
            right: 12.w,
            bottom: 11.h,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  club.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: (big ? VybeTypography.heading4 : VybeTypography.body3)
                      .copyWith(fontWeight: FontWeight.w700, color: Colors.white),
                ),
                SizedBox(height: 5.h),
                Row(
                  children: [
                    _Star(size: 11),
                    SizedBox(width: 3.w),
                    Text(
                      club.rating.toStringAsFixed(2),
                      style: VybeTypography.caption.copyWith(
                        fontSize: 11.sp,
                        height: 13 / 11,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                    _dot(),
                    if (big) ...[
                      Icon(Icons.people, size: 11.r, color: VybeColors.gray300),
                      SizedBox(width: 3.w),
                      Text(
                        club.visitors,
                        style: VybeTypography.caption.copyWith(
                          fontSize: 11.sp,
                          height: 13 / 11,
                          fontWeight: FontWeight.w600,
                          color: VybeColors.gray300,
                        ),
                      ),
                      _dot(),
                      Text(
                        club.area,
                        style: VybeTypography.caption.copyWith(
                          fontSize: 11.sp,
                          height: 13 / 11,
                          color: VybeColors.gray300,
                        ),
                      ),
                    ] else ...[
                      _Flame(size: 10, color: cr.color),
                      SizedBox(width: 3.w),
                      Flexible(
                        child: Text(
                          cr.label,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: VybeTypography.caption.copyWith(
                            fontSize: 11.sp,
                            height: 13 / 11,
                            fontWeight: FontWeight.w700,
                            color: cr.color,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CrowdBadge extends StatelessWidget {
  final _CrowdInfo cr;
  const _CrowdBadge({required this.cr});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: cr.color.withValues(alpha: 0.19),
        borderRadius: BorderRadius.circular(99.r),
        border: Border.all(color: cr.color),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _Flame(size: 10, color: cr.color),
          SizedBox(width: 4.w),
          Text(
            cr.label,
            style: VybeTypography.caption.copyWith(
              fontSize: 10.sp,
              height: 12 / 10,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}

// ── 혼잡 바 ──
class _CrowdBar extends StatelessWidget {
  final _Crowd crowd;
  const _CrowdBar({required this.crowd});
  @override
  Widget build(BuildContext context) {
    final cr = _crowdMap[crowd]!;
    return Padding(
      padding: EdgeInsets.only(top: 7.h),
      child: Row(
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(99.r),
              child: Container(
                height: 5.h,
                color: VybeColors.gray800,
                alignment: Alignment.centerLeft,
                child: FractionallySizedBox(
                  widthFactor: cr.pct / 100,
                  child: Container(color: cr.color),
                ),
              ),
            ),
          ),
          SizedBox(width: 7.w),
          Text(
            cr.label,
            style: VybeTypography.caption.copyWith(
              fontSize: 11.sp,
              height: 12 / 11,
              fontWeight: FontWeight.w700,
              color: cr.color,
            ),
          ),
        ],
      ),
    );
  }
}

// ── 섹션 헤더 ──
class _SectionHeader extends StatelessWidget {
  final String area;
  final bool near;
  final int total;
  const _SectionHeader({required this.area, required this.near, required this.total});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 6.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          if (near)
            Row(
              children: [
                Icon(Icons.place, size: 14.r, color: _hot),
                SizedBox(width: 6.w),
                Text('내 주변 핫플',
                    style: VybeTypography.button2.copyWith(fontWeight: FontWeight.w700, color: Colors.white)),
              ],
            )
          else
            Text(
              area == '전체' ? '전체 순위' : '$area 순위',
              style: VybeTypography.button2.copyWith(fontWeight: FontWeight.w700, color: Colors.white),
            ),
          Text(
            near ? '반경 ${_nearRadius.toInt()}km · $total곳' : '$total곳',
            style: VybeTypography.caption.copyWith(height: 16 / 12, color: VybeColors.gray500),
          ),
        ],
      ),
    );
  }
}

// ── 리스트 로우 ──
class _ListRow extends StatelessWidget {
  final _Club club;
  final bool near;
  final bool saved;
  final ValueChanged<int> onSave;
  const _ListRow({required this.club, required this.near, required this.saved, required this.onSave});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 14.h),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: VybeColors.gray900)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            width: 20.w,
            child: Center(
              child: Text(
                '${club.rank}',
                style: TextStyle(
                  fontFamily: 'Pretendard',
                  fontWeight: FontWeight.w800,
                  fontSize: 17.sp,
                  color: VybeColors.gray600,
                  letterSpacing: 17 * -0.04,
                ),
              ),
            ),
          ),
          SizedBox(width: 13.w),
          Container(
            width: 72.r,
            height: 72.r,
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(
              gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: club.bg),
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(color: VybeColors.gray900),
            ),
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: const Alignment(-0.4, -0.4),
                  radius: 0.8,
                  colors: [Colors.white.withValues(alpha: 0.2), Colors.transparent],
                  stops: const [0, 0.6],
                ),
              ),
            ),
          ),
          SizedBox(width: 13.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        club.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: VybeTypography.body3.copyWith(color: Colors.white, fontWeight: FontWeight.w600),
                      ),
                    ),
                    if (club.up) ...[
                      SizedBox(width: 6.w),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 2.h),
                        decoration: BoxDecoration(
                          color: _hot.withValues(alpha: 0.16),
                          borderRadius: BorderRadius.circular(6.r),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.trending_up, size: 10.r, color: _hot),
                            SizedBox(width: 2.w),
                            Text(
                              '상승',
                              style: VybeTypography.caption.copyWith(
                                fontSize: 10.sp,
                                height: 12 / 10,
                                fontWeight: FontWeight.w700,
                                color: _hot,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                    const Spacer(),
                    GestureDetector(
                      onTap: () => onSave(club.id),
                      behavior: HitTestBehavior.opaque,
                      child: Padding(
                        padding: EdgeInsets.all(2.r),
                        child: _Heart(active: saved, size: 18),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 3.h),
                _metaRow(),
                _CrowdBar(crowd: club.crowd),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _metaRow() {
    final children = <Widget>[];
    void dot() => children.add(_dot());

    if (near) {
      children.addAll([
        Icon(Icons.place, size: 11.r, color: _hot),
        SizedBox(width: 3.w),
        Text('${club.dist.toStringAsFixed(1)}km',
            style: VybeTypography.caption.copyWith(height: 14 / 12, color: _hot, fontWeight: FontWeight.w700)),
      ]);
      dot();
    }
    children.addAll([
      _Star(size: 11),
      SizedBox(width: 3.w),
      Text(club.rating.toStringAsFixed(2),
          style: VybeTypography.caption.copyWith(height: 14 / 12, color: Colors.white, fontWeight: FontWeight.w700)),
    ]);
    dot();
    children.add(Text(club.area, style: VybeTypography.caption.copyWith(height: 14 / 12, color: VybeColors.gray500)));
    dot();
    children.add(Text(club.genre, style: VybeTypography.caption.copyWith(height: 14 / 12, color: VybeColors.gray500)));
    dot();
    children.addAll([
      Icon(Icons.people, size: 11.r, color: VybeColors.gray400),
      SizedBox(width: 3.w),
      Text(club.visitors,
          style: VybeTypography.caption.copyWith(height: 14 / 12, color: VybeColors.gray400, fontWeight: FontWeight.w600)),
    ]);

    return Row(children: children);
  }
}

// ── 푸터 안내 ──
class _Footer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(20.w, 18.h, 20.w, 8.h),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
        decoration: BoxDecoration(
          color: VybeColors.gray900,
          borderRadius: BorderRadius.circular(14.r),
          border: Border.all(color: VybeColors.gray800),
        ),
        child: Row(
          children: [
            const _Flame(size: 15),
            SizedBox(width: 10.w),
            Expanded(
              child: Text(
                '순위는 실시간 방문자 수와 혼잡도를 반영해 10분마다 갱신돼요.',
                style: VybeTypography.caption.copyWith(height: 17 / 12, color: VybeColors.gray400),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── 메타 구분점 ──
Widget _dot() => Padding(
      padding: EdgeInsets.symmetric(horizontal: 6.w),
      child: Container(
        width: 2.r,
        height: 2.r,
        decoration: const BoxDecoration(color: VybeColors.gray600, shape: BoxShape.circle),
      ),
    );

// ── 불꽃 아이콘 ──
class _Flame extends StatelessWidget {
  final double size;
  final Color color;
  const _Flame({required this.size, this.color = _hot});
  @override
  Widget build(BuildContext context) {
    return Icon(Icons.local_fire_department, size: size.r, color: color);
  }
}

// ── 별 아이콘 ──
class _Star extends StatelessWidget {
  final double size;
  const _Star({required this.size});
  @override
  Widget build(BuildContext context) {
    return Icon(Icons.star, size: size.r, color: VybeColors.mainLime500);
  }
}

// ── 하트 아이콘 ──
class _Heart extends StatelessWidget {
  final bool active;
  final double size;
  const _Heart({required this.active, required this.size});
  @override
  Widget build(BuildContext context) {
    return Icon(
      active ? Icons.favorite : Icons.favorite_border,
      size: size.r,
      color: active ? VybeColors.mainPurple500 : Colors.white,
    );
  }
}

// ── 스켈레톤 ──
class _Skeleton extends StatelessWidget {
  const _Skeleton();
  @override
  Widget build(BuildContext context) {
    return ListView(
      physics: const NeverScrollableScrollPhysics(),
      children: [
        Padding(
          padding: EdgeInsets.fromLTRB(24.w, 20.h, 24.w, 18.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _Shimmer(w: 0.75, h: 28, fraction: true),
              SizedBox(height: 12.h),
              _Shimmer(w: 150, h: 26, r: 999),
            ],
          ),
        ),
        Padding(
          padding: EdgeInsets.fromLTRB(16.w, 10.h, 16.w, 12.h),
          child: Row(
            children: [
              for (final w in [52.0, 60.0, 60.0, 70.0, 56.0]) ...[
                _Shimmer(w: w, h: 34, r: 999),
                SizedBox(width: 8.w),
              ],
            ],
          ),
        ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 6.h),
          child: IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(flex: 58, child: _Shimmer(h: 188, r: 16)),
                SizedBox(width: 10.w),
                Expanded(
                  flex: 42,
                  child: Column(
                    children: [
                      _Shimmer(h: 89, r: 16),
                      SizedBox(height: 10.h),
                      _Shimmer(h: 89, r: 16),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        for (var i = 0; i < 3; i++)
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 14.h),
            child: Row(
              children: [
                _Shimmer(w: 20, h: 20),
                SizedBox(width: 13.w),
                _Shimmer(w: 72, h: 72, r: 12),
                SizedBox(width: 13.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _Shimmer(w: 0.45, h: 14, fraction: true),
                      SizedBox(height: 9.h),
                      _Shimmer(w: 0.75, h: 11, fraction: true),
                      SizedBox(height: 9.h),
                      _Shimmer(w: 1, h: 5, r: 99, fraction: true),
                    ],
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

class _Shimmer extends StatefulWidget {
  final double w;
  final double h;
  final double r;
  final bool fraction; // w를 비율(0~1)로 해석.
  const _Shimmer({this.w = 0, required this.h, this.r = 6, this.fraction = false});
  @override
  State<_Shimmer> createState() => _ShimmerState();
}

class _ShimmerState extends State<_Shimmer> with SingleTickerProviderStateMixin {
  late final AnimationController _c =
      AnimationController(vsync: this, duration: const Duration(milliseconds: 1300))..repeat();

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final box = AnimatedBuilder(
      animation: _c,
      builder: (_, __) {
        return Container(
          height: widget.h.h,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(widget.r.r),
            gradient: LinearGradient(
              begin: Alignment(-1 + 2 * _c.value, 0),
              end: Alignment(1 + 2 * _c.value, 0),
              colors: const [VybeColors.gray900, VybeColors.gray800, VybeColors.gray900],
            ),
          ),
        );
      },
    );
    if (widget.fraction) {
      return FractionallySizedBox(
        alignment: Alignment.centerLeft,
        widthFactor: widget.w,
        child: box,
      );
    }
    return SizedBox(width: widget.w.w, child: box);
  }
}
