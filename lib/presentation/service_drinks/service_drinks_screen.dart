import 'dart:math' as math;
import 'dart:ui' as ui;

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
import 'package:vybe/presentation/common/widgets/vybe_glass_button.dart';
import 'package:vybe/presentation/common/widgets/vybe_skeleton.dart';
import 'package:vybe/presentation/service_drinks/viewmodels/service_drinks_viewmodel.dart';

// 서비스 음료(무료 음료) 제공 클럽 모음 — mock UI.
// ClubModel에 perk/제공음료 필드가 없어 현재는 더미 데이터. 추후 스키마 확장 시 연동.
const _drink = Color(0xFF38D6EC); // 서비스음료 액센트 (cyan)
const _drinkInk = Color(0xFF042027); // cyan 위 어두운 텍스트

// 위치 칩 애니메이션 시간 — 홈(home_location_greeting)과 동일 패턴.
const _kShrinkDuration = Duration(milliseconds: 320); // 칩 원형 축소
const _kSearchDuration = Duration(milliseconds: 1600); // 핀 플립 노출 구간

const _types = ['전체', '양주', '샴페인', '칵테일', '맥주', '와인'];

// 정렬 옵션. 기본값 '거리순'. (내 위치는 탭 시 로딩 후 '홍대'로 인식)
const _sorts = ['거리순', '평점순', '추천순'];

// 내 위치별 → 클럽 지역까지 대략 거리(km).
const _areaDist = <String, Map<String, double>>{
  '홍대': {'홍대': 0.4, '강남': 11.2, '이태원': 7.1, '압구정': 9.3, '건대': 12.8},
  '강남': {'홍대': 11.0, '강남': 0.5, '이태원': 4.8, '압구정': 2.9, '건대': 7.9},
  '이태원': {'홍대': 7.0, '강남': 4.9, '이태원': 0.4, '압구정': 3.6, '건대': 8.8},
  '압구정': {'홍대': 9.1, '강남': 3.0, '이태원': 3.7, '압구정': 0.5, '건대': 6.2},
  '건대': {'홍대': 12.5, '강남': 7.8, '이태원': 8.7, '압구정': 6.1, '건대': 0.4},
};

// 내 위치 기준 클럽까지 거리(결정적 미세 편차 포함 → 안정 정렬).
double _distFor(_DrinkClub c, String loc, int idx) {
  final base = _areaDist[loc]?[c.area] ?? c.dist;
  return ((base + (idx % 5) * 0.16) * 10).round() / 10;
}

class _DrinkClub {
  final String id;
  final String name;
  final String area;
  final String genre;
  final double dist;
  final double rating;
  final String perk;
  final List<String> drinks;
  final bool open;
  final String hours;
  final String thumbnailUrl;
  final bool isVybeRecommended;
  final List<Color> gradient;

  const _DrinkClub({
    required this.id,
    required this.name,
    required this.area,
    required this.genre,
    required this.dist,
    required this.rating,
    required this.perk,
    required this.drinks,
    required this.open,
    required this.hours,
    required this.thumbnailUrl,
    required this.isVybeRecommended,
    required this.gradient,
  });

  _DrinkClub copyWithDist(double d) => _DrinkClub(
        id: id,
        name: name,
        area: area,
        genre: genre,
        dist: d,
        rating: rating,
        perk: perk,
        drinks: drinks,
        open: open,
        hours: hours,
        thumbnailUrl: thumbnailUrl,
        isVybeRecommended: isVybeRecommended,
        gradient: gradient,
      );
}

// 썸네일 없을 때 clubId 해시 기반 일관 그라데이션 fallback.
const _fallbackGradients = <List<Color>>[
  [Color(0xFF2B6BFF), Color(0xFF7731FE)],
  [Color(0xFFFF006E), Color(0xFF8338EC)],
  [Color(0xFFF72585), Color(0xFFB5179E)],
  [Color(0xFF3A0CA3), Color(0xFF4361EE)],
  [Color(0xFF2B1655), Color(0xFFFF4D8D)],
  [Color(0xFF06FFA5), Color(0xFF3A86FF)],
  [Color(0xFF06FFA5), Color(0xFF1B9AAA)],
  [Color(0xFF6D4C91), Color(0xFF2A2D34)],
];

// 오늘 영업시간 라벨 ('오늘 22:00 - 06:00' / '오늘 휴무').
String _hoursLabel(ClubModel c) {
  final d = c.operatingHours.today;
  if (d.isOpen && d.open != null && d.close != null) {
    return '오늘 ${d.open} - ${d.close}';
  }
  return '오늘 휴무';
}

// ClubModel → 카드 뷰모델. dist는 화면에서 _loc 기준으로 재계산.
_DrinkClub _fromClub(ClubModel c) {
  final grad = _fallbackGradients[c.clubId.hashCode.abs() % _fallbackGradients.length];
  return _DrinkClub(
    id: c.clubId,
    name: c.name,
    area: c.area,
    genre: c.genre,
    dist: 0,
    rating: c.rating,
    perk: c.serviceDrink.comment,
    drinks: c.serviceDrink.drinks,
    open: c.operatingHours.today.isCurrentlyOpen,
    hours: _hoursLabel(c),
    thumbnailUrl: c.thumbnailUrl,
    isVybeRecommended: c.isVybeRecommended,
    gradient: grad,
  );
}

class ServiceDrinksScreen extends ConsumerStatefulWidget {
  const ServiceDrinksScreen({super.key});

  @override
  ConsumerState<ServiceDrinksScreen> createState() =>
      _ServiceDrinksScreenState();
}

class _ServiceDrinksScreenState extends ConsumerState<ServiceDrinksScreen>
    with SingleTickerProviderStateMixin {
  String _type = '전체';
  String _loc = '홍대';
  String _sort = '거리순';
  bool _locLoading = false;

  // 지도 핀 3D 플립 컨트롤러 (Y축 회전 반복) — 홈과 동일.
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

  // 위치 칩 탭 → 칩 원형 축소 후 핀 플립 → 내 위치 인식 (홈스크린과 동일 패턴).
  Future<void> _onLocationTap() async {
    if (_locLoading) return;
    setState(() => _locLoading = true);

    // 칩이 원형으로 줄어드는 애니메이션 완료 후 핀 플립 시작.
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

  // source(실데이터) → 내 위치 기준 거리 재계산 → 종류 필터 → 정렬.
  List<_DrinkClub> _filtered(List<_DrinkClub> source) {
    final mapped = <_DrinkClub>[];
    for (var i = 0; i < source.length; i++) {
      mapped.add(source[i].copyWithDist(_distFor(source[i], _loc, i)));
    }
    final list = mapped
        .where((c) => _type == '전체' || c.drinks.contains(_type))
        .toList();
    list.sort((a, b) {
      if (_sort == '평점순') return b.rating.compareTo(a.rating);
      if (_sort == '추천순') {
        final o = (b.open ? 1 : 0) - (a.open ? 1 : 0);
        return o != 0 ? o : b.rating.compareTo(a.rating);
      }
      return a.dist.compareTo(b.dist); // 거리순
    });
    return list;
  }

  @override
  Widget build(BuildContext context) {
    final top = MediaQuery.of(context).padding.top;
    final bottomPad = MediaQuery.of(context).padding.bottom + 100.h;
    final clubsAsync = ref.watch(serviceDrinksViewModelProvider);
    final source = clubsAsync.asData?.value.map(_fromClub).toList() ?? [];
    final list = _filtered(source);
    final openCount = list.where((c) => c.open).length;

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
            // 상단 cyan/보라 백드롭.
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
                  locLoading: _locLoading,
                  flip: _flip,
                  onLocTap: _onLocationTap,
                  onSort: (s) => setState(() => _sort = s),
                ),
                _TypeFilter(
                  active: _type,
                  onChange: (t) => setState(() => _type = t),
                ),
                SizedBox(height: 4.h),
                ...list.map((c) => Padding(
                      padding: EdgeInsets.fromLTRB(24.w, 0, 24.w, 14.h),
                      child: _DrinkCard(
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
                      '서비스 음료 클럽을 불러오지 못했어요',
                      textAlign: TextAlign.center,
                      style: VybeTypography.body4.copyWith(color: VybeColors.gray500),
                    ),
                  )
                else if (list.isEmpty)
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 60.h, horizontal: 24.w),
                    child: Text(
                      '해당 음료를 제공하는 클럽이 아직 없어요',
                      textAlign: TextAlign.center,
                      style: VybeTypography.body4.copyWith(color: VybeColors.gray500),
                    ),
                  ),
                _FooterNote(),
              ],
            ),
            // 상단 헤더 (글래스 뒤로가기 + 타이틀 + 글래스 공유).
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
          colors: [Color(0xFF081417), Color(0xFF101013), Color(0xFF0A0E10)],
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
                  colors: [Color(0x7338D6EC), Color(0x00000000)],
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
                TextSpan(text: '내 주변에서 '),
                TextSpan(text: '무료 음료', style: TextStyle(color: _drink)),
                TextSpan(text: '\n주는 클럽'),
              ],
            ),
          ),
          SizedBox(height: 9.h),
          Row(
            children: [
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                decoration: BoxDecoration(
                  color: _drink.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(999.r),
                  border: Border.all(color: _drink.withValues(alpha: 0.4)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 7.r,
                      height: 7.r,
                      decoration: const BoxDecoration(
                          color: _drink, shape: BoxShape.circle),
                    ),
                    SizedBox(width: 5.w),
                    Text(
                      '지금 제공 중',
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
                            color: Colors.white,
                            fontWeight: FontWeight.w700)),
                    const TextSpan(text: ' 근처 '),
                    TextSpan(
                        text: '$count곳',
                        style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w700)),
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
          // 내 위치 — 탭하면 칩 원형 축소 + 핀 플립 후 내 위치 인식 (홈과 동일).
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
                color: _drink.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(999.r),
                border: Border.all(color: _drink.withValues(alpha: 0.34)),
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
          // 정렬 (gray).
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

// 지도 핀 3D 플립 — Y축 회전 (홈 home_location_greeting과 동일 패턴).
// 앞면 cyan, 뒷면 보라.
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
        final color = isFront ? _drink : VybeColors.mainPurple500;

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
                  color: on ? _drink : Colors.white,
                ),
              ),
              if (on) ...[
                SizedBox(width: 12.w),
                Icon(Icons.check_rounded, size: 14.r, color: _drink),
              ],
            ],
          ),
        );
      }).toList(),
      child: child,
    );
  }
}

// ── 종류 필터 ──
class _TypeFilter extends StatelessWidget {
  final String active;
  final ValueChanged<String> onChange;
  const _TypeFilter({required this.active, required this.onChange});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 50.h,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 8.h),
        itemCount: _types.length,
        separatorBuilder: (_, __) => SizedBox(width: 8.w),
        itemBuilder: (_, i) {
          final t = _types[i];
          final sel = t == active;
          final isAll = t == '전체';
          return GestureDetector(
            onTap: () => onChange(t),
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 14.w),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: sel ? _drink : VybeColors.gray900,
                borderRadius: BorderRadius.circular(999.r),
                border:
                    sel ? null : Border.all(color: VybeColors.gray800),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (!isAll) ...[
                    Icon(Icons.liquor_rounded,
                        size: 13.r, color: sel ? _drinkInk : _drink),
                    SizedBox(width: 4.w),
                  ],
                  Text(
                    t,
                    style: VybeTypography.button2.copyWith(
                      fontWeight: sel ? FontWeight.w700 : FontWeight.w500,
                      color: sel ? _drinkInk : VybeColors.gray300,
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

// ── 드링크 카드 ──
class _DrinkCard extends StatelessWidget {
  final _DrinkClub club;
  final bool saved;
  final VoidCallback? onSave;
  final VoidCallback onTap;
  const _DrinkCard({
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
            // 클럽 썸네일 (없으면 gradient만 노출).
            // SkeletonImage: 디코드 완료 후에도 1초간 shimmer 유지 후 reveal.
            if (club.thumbnailUrl.isNotEmpty)
              Positioned.fill(
                child: SkeletonImage(
                  url: club.thumbnailUrl,
                  fit: BoxFit.cover,
                  minSkeleton: const Duration(seconds: 1),
                ),
              ),
            // 하단 가독성 그라데이션.
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
            // perk 리본(좌) + 영업 pill(우) — 한 Row로 묶어 겹침 방지.
            // 찜 버튼 영역(우측 12~44w) 피하려 right: 52.w.
            Positioned(
              top: 14.h,
              left: 14.w,
              right: 52.w,
              child: Row(
                children: [
                  // perk 리본 — 길면 ellipsis로 줄어듦.
                  Flexible(
                    child: Container(
                      height: 32.h,
                      alignment: Alignment.center,
                      padding: EdgeInsets.symmetric(horizontal: 12.w),
                      decoration: BoxDecoration(
                        color: _drink,
                        borderRadius: BorderRadius.circular(12.r),
                        boxShadow: [
                          BoxShadow(
                            color: _drink.withValues(alpha: 0.32),
                            blurRadius: 18,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.liquor_rounded,
                              size: 14.r, color: _drinkInk),
                          SizedBox(width: 6.w),
                          Flexible(
                            child: Text(
                              club.perk,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: VybeTypography.button2.copyWith(
                                  fontWeight: FontWeight.w800,
                                  color: _drinkInk),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(width: 8.w),
                  // 영업 상태 pill (고정 크기).
                  Container(
                    height: 32.h,
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
                ],
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
            // 하단 정보 — 유체 글래스 바 (full bleed, 사진 위 블러로 가독성 확보).
            // 디자인(service_drinks.jsx): blur(18px) + 어두운 그라데이션 + 상단 1px 하이라이트.
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              // 상단 경계선 제거 + dstIn 마스크로 윗부분 페이드 → 사진과 자연스럽게 연결.
              child: ShaderMask(
                blendMode: BlendMode.dstIn,
                shaderCallback: (rect) => const LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  // 위 35%까지 투명 → 불투명 (블러·스크림 경계 feather).
                  colors: [Colors.transparent, Colors.white],
                  stops: [0.0, 0.35],
                ).createShader(rect),
                child: ClipRect(
                  child: BackdropFilter(
                    // CSS blur(18px) ≈ sigma 9.
                    filter: ui.ImageFilter.blur(sigmaX: 9, sigmaY: 9),
                    child: Container(
                      padding: EdgeInsets.fromLTRB(16.w, 34.h, 16.w, 22.h),
                      decoration: const BoxDecoration(
                        // rgba(16,16,21,0.82) → rgba(28,28,38,0) (bottom → top, 위로 투명).
                        gradient: LinearGradient(
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                          colors: [Color(0xD1101015), Color(0x001C1C26)],
                        ),
                      ),
                      child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                    // vybe 아이콘은 이름 텍스트와 세로 중앙 정렬.
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      if (club.isVybeRecommended) ...[
                        SvgPicture.asset(
                          'assets/icons/common/club_card/vybe_recommend.svg',
                          width: 15.r,
                          height: 15.r,
                        ),
                        SizedBox(width: 5.w),
                      ],
                      // 이름·별점·평점은 텍스트 baseline 정렬 유지.
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
                      ],
                    ),
                    ),
                    ),
                  ),
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
          Icon(Icons.local_bar_rounded, size: 15.r, color: _drink),
          SizedBox(width: 10.w),
          Expanded(
            child: Text(
              '서비스 음료는 매장 사정에 따라 변동될 수 있어요. 방문 전 확인해 주세요.',
              style: VybeTypography.caption.copyWith(
                  color: VybeColors.gray400, height: 17 / 12),
            ),
          ),
        ],
      ),
    );
  }
}
