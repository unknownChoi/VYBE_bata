import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:vybe/core/providers/auth_providers.dart';
import 'package:vybe/data/models/club_model.dart';
import 'package:vybe/design_system/colors.dart';
import 'package:vybe/design_system/typography.dart';
import 'package:vybe/presentation/clubs/club_detail_screen.dart';
import 'package:vybe/presentation/clubs/viewmodels/favorite_viewmodel.dart';
import 'package:vybe/presentation/common/widgets/vybe_genre_backdrop.dart';
import 'package:vybe/presentation/common/widgets/vybe_glass_button.dart';
import 'package:vybe/presentation/common/widgets/vybe_recommend_badge.dart';
import 'package:vybe/presentation/common/widgets/vybe_skeleton.dart';
import 'package:vybe/presentation/free_entry/viewmodels/free_entry_viewmodel.dart';

// 입장비 무료(entryFeeMin=0) 클럽 모음 — clubs Firestore 실데이터.
// 무료입장 조건 코멘트는 clubs.freeEntryCondition 필드(seed_free_entry.js로 배정).
const _entry = Color(0xFFFF4D8D); // 무료입장 액센트 (hot pink)
const _entryInk = Color(0xFF2A0712); // pink 위 어두운 텍스트

const _regions = ['전체', '홍대', '강남', '이태원', '압구정', '건대'];
const _sorts = ['거리순', '평점순', '추천순'];

// 홍대 기본 좌표 — 홈(home_location_greeting)·주변 페이지 최초 로딩 좌표와 동일.
const _kHongdaeLat = 37.5572;
const _kHongdaeLng = 126.9239;

// 위치 칩 애니메이션 시간 — 서비스 음료(service_drinks)와 동일 패턴.
const _kShrinkDuration = Duration(milliseconds: 320); // 칩 원형 축소
const _kSearchDuration = Duration(milliseconds: 1600); // 핀 플립 노출 구간

const _areaDist = <String, Map<String, double>>{
  '홍대': {'홍대': 0.4, '강남': 11.2, '이태원': 7.1, '압구정': 9.3, '건대': 12.8},
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
  final String id;
  final String name;
  final String area;
  final String genre;
  final double dist;
  final double rating;
  final int cover; // 평소 입장료 (entryFeeMax, 0이면 표시 안 함)
  final String cond; // 무료입장 조건 (freeEntryCondition)
  final bool open;
  final String thumbnailUrl;
  final List<Color> gradient;
  final bool vybe; // isVybeRecommended — VYBE 추천 뱃지 노출

  const _EntryClub({
    required this.id,
    required this.name,
    required this.area,
    required this.genre,
    required this.dist,
    required this.rating,
    required this.cover,
    required this.cond,
    required this.open,
    required this.thumbnailUrl,
    required this.gradient,
    required this.vybe,
  });

  _EntryClub copyWithDist(double d) => _EntryClub(
        id: id,
        name: name,
        area: area,
        genre: genre,
        dist: d,
        rating: rating,
        cover: cover,
        cond: cond,
        open: open,
        thumbnailUrl: thumbnailUrl,
        gradient: gradient,
        vybe: vybe,
      );
}

// 썸네일 없을 때 clubId 해시 기반 일관 그라데이션 fallback.
const _fallbackGradients = <List<Color>>[
  [Color(0xFF2B1655), Color(0xFFFF4D8D)],
  [Color(0xFF06FFA5), Color(0xFF3A86FF)],
  [Color(0xFF2B6BFF), Color(0xFF7731FE)],
  [Color(0xFF3A0CA3), Color(0xFF4361EE)],
  [Color(0xFFFF006E), Color(0xFF8338EC)],
  [Color(0xFFF72585), Color(0xFFB5179E)],
  [Color(0xFF06FFA5), Color(0xFF1B9AAA)],
  [Color(0xFF6D4C91), Color(0xFF2A2D34)],
];

// ClubModel → 카드 뷰모델. dist는 화면에서 _loc 기준으로 재계산.
_EntryClub _fromClub(ClubModel c) {
  final grad =
      _fallbackGradients[c.clubId.hashCode.abs() % _fallbackGradients.length];
  return _EntryClub(
    id: c.clubId,
    name: c.name,
    area: c.area,
    genre: c.genre,
    dist: 0,
    rating: c.rating,
    cover: c.entryFeeMax,
    cond: c.freeEntryCondition.isNotEmpty ? c.freeEntryCondition : '입장비 무료',
    open: c.operatingHours.today.isCurrentlyOpen,
    thumbnailUrl: c.thumbnailUrl,
    gradient: grad,
    vybe: c.isVybeRecommended,
  );
}

class FreeEntryScreen extends ConsumerStatefulWidget {
  const FreeEntryScreen({super.key});

  @override
  ConsumerState<FreeEntryScreen> createState() => _FreeEntryScreenState();
}

class _FreeEntryScreenState extends ConsumerState<FreeEntryScreen>
    with SingleTickerProviderStateMixin {
  String _region = '전체';
  String _loc = '홍대';
  String _sort = '거리순';
  bool _locLoading = false;

  // 지도 핀 3D 플립 컨트롤러 (Y축 회전 반복) — 서비스 음료와 동일.
  late final AnimationController _flip;

  @override
  void initState() {
    super.initState();
    _flip = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
  }

  @override
  void dispose() {
    _flip.dispose();
    super.dispose();
  }

  // 위치 칩 탭 → 칩 원형 축소 후 핀 플립 → 내 위치 인식 (서비스 음료와 동일 패턴).
  Future<void> _onLocationTap() async {
    if (_locLoading) return;
    // 홍대 좌표로 인식 → 검색 로딩 시작. (홈·주변 페이지 최초 로딩 좌표와 동일)
    debugPrint('위치 선택: 홍대 ($_kHongdaeLat, $_kHongdaeLng)');
    setState(() => _locLoading = true);

    await Future.delayed(_kShrinkDuration);
    if (!mounted) return;
    _flip.repeat();

    await Future.delayed(_kSearchDuration);
    if (!mounted) return;

    _flip.stop();
    _flip.reset();
    setState(() {
      _locLoading = false;
      _loc = '홍대';
    });
  }

  // source(실데이터) → 내 위치 기준 거리 재계산 → 지역 필터 → 정렬.
  List<_EntryClub> _filtered(List<_EntryClub> source) {
    final mapped = <_EntryClub>[];
    for (var i = 0; i < source.length; i++) {
      mapped.add(source[i].copyWithDist(_distFor(source[i], _loc, i)));
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

  @override
  Widget build(BuildContext context) {
    final top = MediaQuery.of(context).padding.top;
    final bottomPad = MediaQuery.of(context).padding.bottom + 100.h;
    final clubsAsync = ref.watch(freeEntryViewModelProvider);
    final source = clubsAsync.asData?.value.map(_fromClub).toList() ?? [];
    final list = _filtered(source);

    // 찜 상태 (스트림 + 낙관적 오버라이드 머지) — 다른 화면과 동일 로직.
    final uid = ref.watch(currentUidProvider);
    final streamFavIds = uid != null
        ? ref.watch(favoritedClubIdsProvider(uid)).asData?.value ?? <String>{}
        : <String>{};
    final optimistic = ref.watch(favoriteViewModelProvider);
    final favoritedIds = Set<String>.from(streamFavIds)
      ..addAll(optimistic.entries.where((e) => e.value).map((e) => e.key))
      ..removeAll(optimistic.entries.where((e) => !e.value).map((e) => e.key));

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
                _Intro(count: list.length, region: _region),
                _LocationBar(
                  loc: _loc,
                  sort: _sort,
                  locLoading: _locLoading,
                  flip: _flip,
                  onLocTap: _onLocationTap,
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
                        saved: favoritedIds.contains(c.id),
                        onSave: uid == null
                            ? null
                            : () => ref
                                .read(favoriteViewModelProvider.notifier)
                                .toggleFavorite(
                                  uid,
                                  c.id,
                                  favoritedIds.contains(c.id),
                                ),
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => ClubDetailScreen(clubId: c.id),
                          ),
                        ),
                      ),
                    )),
                if (clubsAsync.isLoading)
                  ...List.generate(
                    3,
                    (_) => Padding(
                      padding: EdgeInsets.fromLTRB(24.w, 0, 24.w, 14.h),
                      child: VybeSkel(height: 208.h, radius: 18),
                    ),
                  )
                else if (clubsAsync.hasError)
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 60.h, horizontal: 24.w),
                    child: Text(
                      '입장비 무료 클럽을 불러오지 못했어요',
                      textAlign: TextAlign.center,
                      style: VybeTypography.body4.copyWith(color: VybeColors.gray500),
                    ),
                  )
                else if (list.isEmpty)
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
    return const VybeGenreBackdrop(
      baseColors: [Color(0xFF17090F), Color(0xFF101013), Color(0xFF0D0A0C)],
      accent1: Color(0x6BFF4D8D),
      accent2: Color(0x4D7731FE),
    );
  }
}

// ── 인트로 ──
class _Intro extends StatelessWidget {
  final int count;
  // 헤드라인 접두사. '전체' → '내 주변', 그 외 → 지역명(예: '홍대').
  final String region;
  const _Intro({required this.count, required this.region});

  @override
  Widget build(BuildContext context) {
    final base = TextStyle(
      fontFamily: 'Pretendard',
      fontSize: 27.sp,
      height: 33 / 27,
      fontWeight: FontWeight.w700,
      color: Colors.white,
      letterSpacing: 27 * -0.025,
    );
    final prefix = region == '전체' ? '내 주변' : region;
    return Padding(
      padding: EdgeInsets.fromLTRB(24.w, 20.h, 24.w, 14.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 지역 변경 시 헤드라인 페이드+슬라이드 전환 (핫플레이스와 동일 패턴).
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 420),
            transitionBuilder: (child, anim) => FadeTransition(
              opacity: anim,
              child: SlideTransition(
                position: Tween(begin: const Offset(0, 0.3), end: Offset.zero)
                    .animate(anim),
                child: child,
              ),
            ),
            child: Text.rich(
              key: ValueKey(region),
              TextSpan(
                style: base,
                children: [
                  TextSpan(text: '$prefix '),
                  const TextSpan(
                      text: '입장비 무료', style: TextStyle(color: _entry)),
                  const TextSpan(text: '\n클럽 모아보기'),
                ],
              ),
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
                        text: prefix,
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
  final bool locLoading;
  final Animation<double> flip;
  final VoidCallback onLocTap;
  final ValueChanged<String> onSort;
  const _LocationBar({
    required this.loc,
    required this.sort,
    required this.locLoading,
    required this.flip,
    required this.onLocTap,
    required this.onSort,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(24.w, 4.h, 24.w, 10.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // 내 위치 — 탭하면 칩 원형 축소 + 핀 플립 후 내 위치 인식 (서비스 음료와 동일).
          GestureDetector(
            onTap: onLocTap,
            behavior: HitTestBehavior.opaque,
            child: AnimatedContainer(
              duration: _kShrinkDuration,
              curve: Curves.easeInOut,
              // 로딩 중엔 사방 동일 패딩 → 핀을 감싸는 원형.
              padding: locLoading
                  ? EdgeInsets.all(7.r)
                  : EdgeInsets.fromLTRB(10.w, 6.h, 12.w, 6.h),
              decoration: BoxDecoration(
                color: _entry.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(999.r),
                border: Border.all(color: _entry.withValues(alpha: 0.34)),
              ),
              child: AnimatedSize(
                duration: _kShrinkDuration,
                curve: Curves.easeInOut,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _PinFlip(animation: flip),
                    // 로딩 중엔 텍스트 제거 → 너비 축소.
                    if (!locLoading) ...[
                      SizedBox(width: 5.w),
                      Text(
                        loc,
                        style: VybeTypography.caption.copyWith(
                            height: 14 / 12,
                            fontWeight: FontWeight.w700,
                            color: Colors.white),
                      ),
                    ],
                  ],
                ),
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

// 지도 핀 3D 플립 — Y축 회전 (서비스 음료와 동일 패턴).
// 앞면 pink, 뒷면 보라.
class _PinFlip extends StatelessWidget {
  final Animation<double> animation;
  const _PinFlip({required this.animation});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, _) {
        final angle = animation.value * 2 * math.pi; // 0 → 360도 반복
        final isFront = math.cos(angle) >= 0;
        final color = isFront ? _entry : VybeColors.mainPurple500;

        return Transform(
          alignment: Alignment.center,
          // 원근감(3D) — setEntry(3,2,..)로 perspective 부여.
          transform: Matrix4.identity()
            ..setEntry(3, 2, 0.0015)
            ..rotateY(angle),
          child: Transform(
            // 뒷면일 때 좌우 반전 보정(아이콘 거울상 방지).
            alignment: Alignment.center,
            transform: Matrix4.identity()..rotateY(isFront ? 0 : math.pi),
            child: SvgPicture.asset(
              'assets/icons/home_screen/loaction_pin.svg',
              width: 13.r,
              height: 13.r,
              colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
            ),
          ),
        );
      },
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
                // '전체' 값은 필터 로직 유지, 표시만 '내 주변'.
                r == '전체' ? '내 주변' : r,
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
  final VoidCallback? onSave;
  final VoidCallback onTap;
  const _EntryCard({
    required this.club,
    required this.saved,
    required this.onSave,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: ClipRRect(
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
              // 클럽 썸네일 (없으면 gradient만).
              if (club.thumbnailUrl.isNotEmpty)
                Positioned.fill(
                  child: SkeletonImage(
                    url: club.thumbnailUrl,
                    fit: BoxFit.cover,
                    minSkeleton: const Duration(seconds: 1),
                  ),
                ),
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
              top: 12.h,
              left: 12.w,
              child: Container(
                height: 32.r,
                alignment: Alignment.center,
                padding: EdgeInsets.symmetric(horizontal: 11.w),
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
              top: 12.h,
              right: 52.w,
              child: Container(
                height: 32.r,
                alignment: Alignment.center,
                padding: EdgeInsets.symmetric(horizontal: 11.w),
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
                  // VYBE 추천 뱃지 (앱 전역 공통 디자인).
                  if (club.vybe) ...[
                    const VybeRecommendBadge(size: 12),
                    SizedBox(height: 7.h),
                  ],
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Text(
                        club.name,
                        style: VybeTypography.heading4
                            .copyWith(color: Colors.white, height: 1.0),
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
                  SizedBox(height: 6.h),
                  Row(
                    children: [
                      Icon(Icons.place_rounded,
                          size: 11.r, color: VybeColors.gray300),
                      SizedBox(width: 3.w),
                      Text(
                        '${club.area} · ${club.dist.toStringAsFixed(1)}km',
                        style: VybeTypography.caption.copyWith(
                            fontSize: 12.sp,
                            height: 1.0,
                            fontWeight: FontWeight.w600,
                            color: VybeColors.gray300),
                      ),
                      _dot(),
                      Text(
                        club.genre,
                        style: VybeTypography.caption.copyWith(
                            fontSize: 12.sp, height: 1.0, color: VybeColors.gray400),
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
