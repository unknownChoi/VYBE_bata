import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vybe/design_system/colors.dart';
import 'package:vybe/design_system/typography.dart';
import 'package:vybe/presentation/common/widgets/vybe_glass_button.dart';

// 입장비 무료 클럽 모음 — mock UI.
// ClubModel에 입장료/무료입장 조건 필드가 없어 현재는 더미 데이터. 추후 스키마 확장 시 연동.
const _entry = Color(0xFFFF4D8D); // 무료입장 액센트 (hot pink)
const _entryInk = Color(0xFF2A0712); // pink 위 어두운 텍스트

const _regions = ['전체', '홍대', '강남', '이태원', '압구정', '건대'];
const _locations = ['홍대입구역', '강남역', '이태원', '압구정로데오'];
const _sorts = ['거리순', '평점순', '추천순'];

const _areaDist = <String, Map<String, double>>{
  '홍대입구역': {'홍대': 0.4, '강남': 11.2, '이태원': 7.1, '압구정': 9.3, '건대': 12.8},
  '강남역': {'홍대': 11.0, '강남': 0.5, '이태원': 4.8, '압구정': 2.9, '건대': 7.9},
  '이태원': {'홍대': 7.0, '강남': 4.9, '이태원': 0.4, '압구정': 3.6, '건대': 8.8},
  '압구정로데오': {'홍대': 9.1, '강남': 3.0, '이태원': 3.7, '압구정': 0.5, '건대': 6.2},
};

double _distFor(_EntryClub c, String loc, int idx) {
  final base = _areaDist[loc]?[c.area] ?? c.dist;
  return ((base + (idx % 5) * 0.16) * 10).round() / 10;
}

// 원화 천단위 콤마.
String _won(int n) {
  final s = n.toString();
  final b = StringBuffer();
  for (var i = 0; i < s.length; i++) {
    if (i > 0 && (s.length - i) % 3 == 0) b.write(',');
    b.write(s[i]);
  }
  return '$b원';
}

class _EntryClub {
  final String name;
  final String area;
  final String genre;
  final double dist;
  final double rating;
  final int cover; // 평소 입장료
  final String cond; // 무료입장 조건
  final bool open;
  final String hours;
  final List<Color> gradient;

  const _EntryClub({
    required this.name,
    required this.area,
    required this.genre,
    required this.dist,
    required this.rating,
    required this.cover,
    required this.cond,
    required this.open,
    required this.hours,
    required this.gradient,
  });

  _EntryClub copyWithDist(double d) => _EntryClub(
        name: name,
        area: area,
        genre: genre,
        dist: d,
        rating: rating,
        cover: cover,
        cond: cond,
        open: open,
        hours: hours,
        gradient: gradient,
      );
}

const _clubs = <_EntryClub>[
  _EntryClub(name: '어썸레드', area: '홍대', genre: '힙합', dist: 0.4, rating: 4.58, cover: 20000, cond: '새벽 2시까지 무료', open: true, hours: '오늘 21:00 - 06:00', gradient: [Color(0xFF2B1655), Color(0xFFFF4D8D)]),
  _EntryClub(name: '버뮤다', area: '홍대', genre: '힙합', dist: 0.7, rating: 4.49, cover: 15000, cond: '남녀 전원 무료', open: true, hours: '오늘 21:00 - 05:00', gradient: [Color(0xFF06FFA5), Color(0xFF3A86FF)]),
  _EntryClub(name: 'OCTAGON', area: '강남', genre: 'EDM', dist: 5.2, rating: 4.82, cover: 40000, cond: '오픈~23시 무료입장', open: true, hours: '오늘 21:00 - 06:00', gradient: [Color(0xFF2B6BFF), Color(0xFF7731FE)]),
  _EntryClub(name: '소다', area: '강남', genre: '하우스', dist: 5.4, rating: 4.55, cover: 25000, cond: '여성 무료입장', open: true, hours: '오늘 22:00 - 06:00', gradient: [Color(0xFF3A0CA3), Color(0xFF4361EE)]),
  _EntryClub(name: '메이드', area: '이태원', genre: 'EDM', dist: 6.1, rating: 4.74, cover: 30000, cond: '자정 이전 무료', open: true, hours: '오늘 22:00 - 05:00', gradient: [Color(0xFFFF006E), Color(0xFF8338EC)]),
  _EntryClub(name: '케이크샵', area: '이태원', genre: '테크노', dist: 6.3, rating: 4.40, cover: 25000, cond: '오픈 시간 무료', open: true, hours: '오늘 23:00 - 07:00', gradient: [Color(0xFF06FFA5), Color(0xFF1B9AAA)]),
  _EntryClub(name: '글로우', area: '압구정', genre: 'EDM', dist: 4.2, rating: 4.61, cover: 30000, cond: '남녀 무료입장', open: true, hours: '오늘 21:00 - 05:00', gradient: [Color(0xFFF72585), Color(0xFFB5179E)]),
  _EntryClub(name: '벨로주', area: '홍대', genre: '재즈', dist: 0.9, rating: 4.36, cover: 10000, cond: '상시 무료입장', open: true, hours: '오늘 20:00 - 02:00', gradient: [Color(0xFF6D4C91), Color(0xFF2A2D34)]),
  _EntryClub(name: '인클', area: '홍대', genre: '힙합', dist: 0.5, rating: 4.44, cover: 15000, cond: '게스트리스트 무료', open: false, hours: '내일 21:00 오픈', gradient: [Color(0xFFFB5607), Color(0xFFFFBE0B)]),
  _EntryClub(name: '하이브', area: '건대', genre: '힙합', dist: 3.1, rating: 4.31, cover: 15000, cond: '전원 무료입장', open: false, hours: '내일 21:00 오픈', gradient: [Color(0xFFFFBE0B), Color(0xFFFB5607)]),
];

class FreeEntryScreen extends StatefulWidget {
  const FreeEntryScreen({super.key});

  @override
  State<FreeEntryScreen> createState() => _FreeEntryScreenState();
}

class _FreeEntryScreenState extends State<FreeEntryScreen> {
  String _region = '전체';
  String _loc = '홍대입구역';
  String _sort = '거리순';
  final Set<String> _saved = {'어썸레드'};

  List<_EntryClub> get _filtered {
    final mapped = <_EntryClub>[];
    for (var i = 0; i < _clubs.length; i++) {
      mapped.add(_clubs[i].copyWithDist(_distFor(_clubs[i], _loc, i)));
    }
    final list = mapped
        .where((c) => _region == '전체' || c.area == _region)
        .toList();
    list.sort((a, b) {
      if (_sort == '평점순') return b.rating.compareTo(a.rating);
      if (_sort == '추천순') {
        final o = (b.open ? 1 : 0) - (a.open ? 1 : 0);
        return o != 0 ? o : b.rating.compareTo(a.rating);
      }
      return a.dist.compareTo(b.dist);
    });
    return list;
  }

  void _toggleSave(String name) => setState(() {
        _saved.contains(name) ? _saved.remove(name) : _saved.add(name);
      });

  @override
  Widget build(BuildContext context) {
    final top = MediaQuery.of(context).padding.top;
    final bottomPad = MediaQuery.of(context).padding.bottom + 100.h;
    final list = _filtered;
    final openCount = list.where((c) => c.open).length;

    return Scaffold(
      backgroundColor: VybeColors.background,
      body: SizedBox.expand(
        child: Stack(
          children: [
            const Positioned(
              top: 0,
              left: 0,
              right: 0,
              height: 560,
              child: IgnorePointer(child: _Backdrop()),
            ),
            ListView(
              padding: EdgeInsets.only(top: top + 52.h, bottom: bottomPad),
              children: [
                _Intro(count: openCount, loc: _loc),
                _LocationBar(
                  loc: _loc,
                  sort: _sort,
                  onLoc: (l) => setState(() => _loc = l),
                  onSort: (s) => setState(() => _sort = s),
                ),
                _RegionFilter(
                  active: _region,
                  onChange: (r) => setState(() => _region = r),
                ),
                SizedBox(height: 4.h),
                ...list.map((c) => Padding(
                      padding: EdgeInsets.fromLTRB(24.w, 0, 24.w, 14.h),
                      child: _EntryCard(
                        club: c,
                        saved: _saved.contains(c.name),
                        onSave: () => _toggleSave(c.name),
                      ),
                    )),
                if (list.isEmpty)
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 60.h, horizontal: 24.w),
                    child: Text(
                      _region == '전체'
                          ? '입장비 무료 클럽이 아직 없어요'
                          : '$_region 지역에 입장비 무료 클럽이 없어요',
                      textAlign: TextAlign.center,
                      style: VybeTypography.body4.copyWith(color: VybeColors.gray500),
                    ),
                  ),
                _FooterNote(),
              ],
            ),
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: _Header(),
            ),
          ],
        ),
      ),
    );
  }
}

// ── 헤더 ──
class _Header extends StatelessWidget {
  const _Header();

  @override
  Widget build(BuildContext context) {
    final top = MediaQuery.of(context).padding.top;
    return Container(
      height: top + 52.h,
      padding: EdgeInsets.only(top: top, left: 16.w, right: 16.w),
      color: Colors.transparent,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          VybeGlassButton(onTap: () => Navigator.of(context).maybePop()),
          VybeGlassButton(icon: Icons.share_outlined, onTap: () {}),
        ],
      ),
    );
  }
}

// ── 백드롭 ──
class _Backdrop extends StatelessWidget {
  const _Backdrop();
  @override
  Widget build(BuildContext context) {
    return const DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF17090F), Color(0xFF101013), Color(0xFF0D0A0C)],
          stops: [0.0, 0.38, 1.0],
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: 420,
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment(-0.85, -1),
                  radius: 1.3,
                  colors: [Color(0x6BFF4D8D), Color(0x00000000)],
                  stops: [0.0, 0.62],
                ),
              ),
            ),
          ),
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: 420,
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment(1, -0.9),
                  radius: 1.2,
                  colors: [Color(0x4D7731FE), Color(0x00000000)],
                  stops: [0.0, 0.62],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── 인트로 ──
class _Intro extends StatelessWidget {
  final int count;
  final String loc;
  const _Intro({required this.count, required this.loc});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(24.w, 20.h, 24.w, 14.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text.rich(
            TextSpan(
              style: TextStyle(
                fontFamily: 'Pretendard',
                fontSize: 27.sp,
                height: 33 / 27,
                fontWeight: FontWeight.w700,
                color: Colors.white,
                letterSpacing: 27 * -0.025,
              ),
              children: const [
                TextSpan(text: '내 주변 '),
                TextSpan(text: '입장비 무료', style: TextStyle(color: _entry)),
                TextSpan(text: '\n클럽 모아보기'),
              ],
            ),
          ),
          SizedBox(height: 9.h),
          Row(
            children: [
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                decoration: BoxDecoration(
                  color: _entry.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(999.r),
                  border: Border.all(color: _entry.withValues(alpha: 0.4)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 7.r,
                      height: 7.r,
                      decoration: const BoxDecoration(
                          color: _entry, shape: BoxShape.circle),
                    ),
                    SizedBox(width: 5.w),
                    Text(
                      '지금 무료입장',
                      style: VybeTypography.caption.copyWith(
                          height: 14 / 12,
                          fontWeight: FontWeight.w700,
                          color: Colors.white),
                    ),
                  ],
                ),
              ),
              SizedBox(width: 7.w),
              Text.rich(
                TextSpan(
                  style: VybeTypography.caption
                      .copyWith(color: VybeColors.gray400),
                  children: [
                    TextSpan(
                        text: loc,
                        style: const TextStyle(
                            color: Colors.white, fontWeight: FontWeight.w700)),
                    const TextSpan(text: ' 근처 '),
                    TextSpan(
                        text: '$count곳',
                        style: const TextStyle(
                            color: Colors.white, fontWeight: FontWeight.w700)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ── 내 위치 + 정렬 바 ──
class _LocationBar extends StatelessWidget {
  final String loc;
  final String sort;
  final ValueChanged<String> onLoc;
  final ValueChanged<String> onSort;
  const _LocationBar({
    required this.loc,
    required this.sort,
    required this.onLoc,
    required this.onSort,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(24.w, 4.h, 24.w, 10.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // 내 위치 (지도 핀 아이콘 + pink 틴트).
          _Dropdown<String>(
            value: loc,
            items: _locations,
            onSelected: onLoc,
            child: Container(
              padding: EdgeInsets.fromLTRB(10.w, 6.h, 12.w, 6.h),
              decoration: BoxDecoration(
                color: _entry.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(999.r),
                border: Border.all(color: _entry.withValues(alpha: 0.34)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.place_rounded, size: 13.r, color: _entry),
                  SizedBox(width: 5.w),
                  Text(
                    loc,
                    style: VybeTypography.caption.copyWith(
                        height: 14 / 12,
                        fontWeight: FontWeight.w700,
                        color: Colors.white),
                  ),
                  SizedBox(width: 3.w),
                  Icon(Icons.keyboard_arrow_down_rounded,
                      size: 14.r, color: _entry),
                ],
              ),
            ),
          ),
          // 정렬.
          _Dropdown<String>(
            value: sort,
            items: _sorts,
            onSelected: onSort,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
              decoration: BoxDecoration(
                color: VybeColors.gray900,
                borderRadius: BorderRadius.circular(999.r),
                border: Border.all(color: VybeColors.gray800),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    sort,
                    style: VybeTypography.caption.copyWith(
                        height: 14 / 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.white),
                  ),
                  SizedBox(width: 4.w),
                  Icon(Icons.keyboard_arrow_down_rounded,
                      size: 14.r, color: Colors.white),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// 공통 드롭다운 — 선택값 체크 표시.
class _Dropdown<T> extends StatelessWidget {
  final T value;
  final List<T> items;
  final ValueChanged<T> onSelected;
  final Widget child;
  const _Dropdown({
    required this.value,
    required this.items,
    required this.onSelected,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<T>(
      onSelected: onSelected,
      color: VybeColors.gray800,
      elevation: 12,
      position: PopupMenuPosition.under,
      offset: Offset(0, 6.h),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.r),
        side: const BorderSide(color: VybeColors.gray700),
      ),
      itemBuilder: (_) => items.map((it) {
        final on = it == value;
        return PopupMenuItem<T>(
          value: it,
          height: 40.h,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '$it',
                style: VybeTypography.caption.copyWith(
                  fontWeight: on ? FontWeight.w700 : FontWeight.w500,
                  color: on ? _entry : Colors.white,
                ),
              ),
              if (on) ...[
                SizedBox(width: 12.w),
                Icon(Icons.check_rounded, size: 14.r, color: _entry),
              ],
            ],
          ),
        );
      }).toList(),
      child: child,
    );
  }
}

// ── 지역 필터 ──
class _RegionFilter extends StatelessWidget {
  final String active;
  final ValueChanged<String> onChange;
  const _RegionFilter({required this.active, required this.onChange});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 50.h,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 8.h),
        itemCount: _regions.length,
        separatorBuilder: (_, __) => SizedBox(width: 8.w),
        itemBuilder: (_, i) {
          final r = _regions[i];
          final sel = r == active;
          return GestureDetector(
            onTap: () => onChange(r),
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: sel ? _entry : VybeColors.gray900,
                borderRadius: BorderRadius.circular(999.r),
                border: sel ? null : Border.all(color: VybeColors.gray800),
              ),
              child: Text(
                r,
                style: VybeTypography.button2.copyWith(
                  fontWeight: sel ? FontWeight.w700 : FontWeight.w500,
                  color: sel ? _entryInk : VybeColors.gray300,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

// ── 클럽 카드 ──
class _EntryCard extends StatelessWidget {
  final _EntryClub club;
  final bool saved;
  final VoidCallback onSave;
  const _EntryCard({required this.club, required this.saved, required this.onSave});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(18.r),
      child: Container(
        height: 208.h,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: club.gradient,
          ),
          border: Border.all(color: VybeColors.gray800),
          borderRadius: BorderRadius.circular(18.r),
        ),
        child: Stack(
          fit: StackFit.expand,
          children: [
            const DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [Color(0xF50C0C0F), Color(0x400C0C0F), Colors.transparent],
                  stops: [0.14, 0.56, 0.78],
                ),
              ),
            ),
            // 무료입장 리본.
            Positioned(
              top: 14.h,
              left: 14.w,
              child: Container(
                padding: EdgeInsets.fromLTRB(11.w, 8.h, 13.w, 8.h),
                decoration: BoxDecoration(
                  color: _entry,
                  borderRadius: BorderRadius.circular(12.r),
                  boxShadow: [
                    BoxShadow(
                      color: _entry.withValues(alpha: 0.34),
                      blurRadius: 18,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.confirmation_number_rounded,
                        size: 15.r, color: _entryInk),
                    SizedBox(width: 6.w),
                    Text(
                      '입장비 무료',
                      style: VybeTypography.button2.copyWith(
                          fontWeight: FontWeight.w800, color: _entryInk),
                    ),
                  ],
                ),
              ),
            ),
            // 영업 상태 pill.
            Positioned(
              top: 16.h,
              right: 52.w,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 9.w, vertical: 5.h),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.45),
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
                      width: 6.r,
                      height: 6.r,
                      decoration: BoxDecoration(
                        color: club.open
                            ? VybeColors.mainLime500
                            : VybeColors.gray500,
                        shape: BoxShape.circle,
                      ),
                    ),
                    SizedBox(width: 5.w),
                    Text(
                      club.open ? '영업 중' : '영업 종료',
                      style: VybeTypography.caption.copyWith(
                        fontSize: 11.sp,
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
              top: 12.h,
              right: 12.w,
              child: GestureDetector(
                onTap: onSave,
                behavior: HitTestBehavior.opaque,
                child: Container(
                  width: 32.r,
                  height: 32.r,
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.42),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    saved ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                    size: 17.r,
                    color: saved ? VybeColors.mainPurple500 : Colors.white,
                  ),
                ),
              ),
            ),
            // 하단 정보.
            Positioned(
              left: 16.w,
              right: 16.w,
              bottom: 14.h,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Text(
                        club.name,
                        style: VybeTypography.heading4
                            .copyWith(color: Colors.white),
                      ),
                      SizedBox(width: 8.w),
                      Icon(Icons.star_rounded,
                          size: 12.r, color: VybeColors.mainLime500),
                      SizedBox(width: 3.w),
                      Text(
                        club.rating.toStringAsFixed(2),
                        style: VybeTypography.caption.copyWith(
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w700,
                            color: Colors.white),
                      ),
                    ],
                  ),
                  SizedBox(height: 7.h),
                  Row(
                    children: [
                      Icon(Icons.place_rounded,
                          size: 11.r, color: VybeColors.gray300),
                      SizedBox(width: 3.w),
                      Text(
                        '${club.area} · ${club.dist.toStringAsFixed(1)}km',
                        style: VybeTypography.caption.copyWith(
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w600,
                            color: VybeColors.gray300),
                      ),
                      _dot(),
                      Text(
                        club.genre,
                        style: VybeTypography.caption.copyWith(
                            fontSize: 12.sp, color: VybeColors.gray400),
                      ),
                    ],
                  ),
                  SizedBox(height: 9.h),
                  // 입장 정보 칩.
                  Row(
                    children: [
                      Flexible(
                        child: Container(
                          padding: EdgeInsets.symmetric(
                              horizontal: 9.w, vertical: 4.h),
                          decoration: BoxDecoration(
                            color: _entry.withValues(alpha: 0.16),
                            borderRadius: BorderRadius.circular(8.r),
                            border: Border.all(
                                color: _entry.withValues(alpha: 0.34)),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.confirmation_number_outlined,
                                  size: 11.r, color: _entry),
                              SizedBox(width: 5.w),
                              Flexible(
                                child: Text(
                                  club.cond,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: VybeTypography.caption.copyWith(
                                    fontSize: 11.sp,
                                    fontWeight: FontWeight.w600,
                                    color: _entry,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(width: 8.w),
                      Text(
                        _won(club.cover),
                        style: VybeTypography.caption.copyWith(
                          fontSize: 11.sp,
                          color: VybeColors.gray500,
                          decoration: TextDecoration.lineThrough,
                        ),
                      ),
                      SizedBox(width: 5.w),
                      Text(
                        '무료',
                        style: VybeTypography.caption.copyWith(
                          fontSize: 11.sp,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _dot() => Padding(
        padding: EdgeInsets.symmetric(horizontal: 6.w),
        child: Container(
          width: 2.r,
          height: 2.r,
          decoration: const BoxDecoration(
              color: VybeColors.gray500, shape: BoxShape.circle),
        ),
      );
}

// ── 하단 안내 ──
class _FooterNote extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.fromLTRB(24.w, 18.h, 24.w, 8.h),
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
      decoration: BoxDecoration(
        color: VybeColors.gray900,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: VybeColors.gray800),
      ),
      child: Row(
        children: [
          Icon(Icons.confirmation_number_rounded, size: 15.r, color: _entry),
          SizedBox(width: 10.w),
          Expanded(
            child: Text(
              '입장 정책은 요일·시간대에 따라 달라질 수 있어요. 방문 전 확인해 주세요.',
              style: VybeTypography.caption.copyWith(
                  color: VybeColors.gray400, height: 17 / 12),
            ),
          ),
        ],
      ),
    );
  }
}
