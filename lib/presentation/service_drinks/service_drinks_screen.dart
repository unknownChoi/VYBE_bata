import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vybe/core/constants/app_geo.dart';
import 'package:vybe/core/providers/auth_providers.dart';
import 'package:vybe/core/utils/gradient_palette.dart';
import 'package:vybe/data/models/club_model.dart';
import 'package:vybe/design_system/colors.dart';
import 'package:vybe/design_system/typography.dart';
import 'package:vybe/presentation/clubs/club_detail_route.dart';
import 'package:vybe/presentation/clubs/viewmodels/favorite_viewmodel.dart';
import 'package:vybe/presentation/common/club_list_sorting.dart';
import 'package:vybe/presentation/common/location_flip_mixin.dart';
import 'package:vybe/presentation/common/widgets/vybe_aurora.dart';
import 'package:vybe/presentation/common/widgets/vybe_footer_note.dart';
import 'package:vybe/presentation/common/widgets/vybe_glass_header.dart';
import 'package:vybe/presentation/common/widgets/vybe_location_sort_bar.dart';
import 'package:vybe/presentation/common/widgets/vybe_meta_dot.dart';
import 'package:vybe/presentation/common/widgets/vybe_open_now_pill.dart';
import 'package:vybe/presentation/common/widgets/vybe_recommend_badge.dart';
import 'package:vybe/presentation/common/widgets/vybe_save_button.dart';
import 'package:vybe/presentation/common/widgets/vybe_skeleton.dart';
import 'package:vybe/presentation/service_drinks/viewmodels/service_drinks_viewmodel.dart';

// 서비스 음료(무료 음료) 제공 클럽 모음 — clubs.serviceDrink 실데이터.
const _drink = Color(0xFF38D6EC); // 서비스음료 액센트 (cyan)
const _drinkInk = Color(0xFF042027); // cyan 위 어두운 텍스트

const _types = [kFilterAll, '양주', '샴페인', '칵테일', '맥주', '와인'];

class _DrinkClub implements ClubSortable {
  final String id;
  final String name;
  @override
  final String area;
  final String genre;
  @override
  final double dist;
  @override
  final double rating;
  final String perk;
  final List<String> drinks;
  @override
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
  [VybeColors.accentBlue500, VybeColors.mainPurple500],
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
  final grad = gradientForKey(_fallbackGradients, c.clubId);
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
    with SingleTickerProviderStateMixin, LocationFlipMixin {
  String _type = kFilterAll;
  String _loc = AppGeo.hongdaeLabel;
  String _sort = kClubSorts.first;

  // 위치 칩 탭 → 칩 원형 축소 후 핀 플립 → 내 위치 인식 (홈스크린과 동일 패턴).
  void _onLocationTap() =>
      runLocationFlip(onResolved: () => _loc = AppGeo.hongdaeLabel);

  // source(실데이터) → 내 위치 기준 거리 재계산 → 종류 필터 → 정렬.
  List<_DrinkClub> _filtered(List<_DrinkClub> source) => buildClubList(
        source,
        loc: _loc,
        sort: _sort,
        withDist: (c, d) => c.copyWithDist(d),
        keep: (c) => _type == kFilterAll || c.drinks.contains(_type),
      );

  @override
  Widget build(BuildContext context) {
    final top = MediaQuery.paddingOf(context).top;
    final bottomPad = MediaQuery.paddingOf(context).bottom + 100.h;
    final clubsAsync = ref.watch(serviceDrinksViewModelProvider);
    final source = clubsAsync.asData?.value.map(_fromClub).toList() ?? [];
    final list = _filtered(source);

    final uid = ref.watch(currentUidProvider);
    final favoritedIds = ref.watch(mergedFavoriteIdsProvider);

    return Scaffold(
      backgroundColor: VybeColors.background,
      body: SizedBox.expand(
        child: Stack(
          children: [
            // 시안/보라 백드롭 — 화면 전체를 채운다(우하단 글로우까지).
            const Positioned.fill(child: IgnorePointer(child: _Backdrop())),
            // 카드 목록은 SliverList.builder로 보이는 만큼만 만든다
            // (ListView(children: [...])는 클럽 전부를 즉시 빌드해 진입이 무거워진다).
            CustomScrollView(
              slivers: [
                SliverPadding(
                  padding: EdgeInsets.only(top: top + 52.h),
                  sliver: SliverList.list(
                    children: [
                      _Intro(count: list.length, loc: _loc),
                      VybeLocationSortBar(
                        loc: _loc,
                        sort: _sort,
                        sorts: kClubSorts,
                        locLoading: locLoading,
                        flip: flip,
                        onLocTap: _onLocationTap,
                        onSort: (s) => setState(() => _sort = s),
                        accent: _drink,
                      ),
                      _TypeFilter(
                        active: _type,
                        onChange: (t) => setState(() => _type = t),
                      ),
                      SizedBox(height: 4.h),
                    ],
                  ),
                ),
                SliverList.builder(
                  itemCount: list.length,
                  itemBuilder: (_, i) {
                    final c = list[i];
                    final saved = favoritedIds.contains(c.id);
                    return Padding(
                      padding: EdgeInsets.fromLTRB(24.w, 0, 24.w, 14.h),
                      child: _DrinkCard(
                        club: c,
                        saved: saved,
                        onSave: uid == null
                            ? null
                            : () => ref
                                .read(favoriteViewModelProvider.notifier)
                                .toggleFavorite(uid, c.id, saved),
                        onTap: () => openClubDetail(context, c.id),
                      ),
                    );
                  },
                ),
                SliverPadding(
                  padding: EdgeInsets.only(bottom: bottomPad),
                  sliver: SliverList.list(
                    children: [
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
                          padding:
                              EdgeInsets.symmetric(vertical: 60.h, horizontal: 24.w),
                          child: Text(
                            '서비스 음료 클럽을 불러오지 못했어요',
                            textAlign: TextAlign.center,
                            style: VybeTypography.body4
                                .copyWith(color: VybeColors.gray500),
                          ),
                        )
                      else if (list.isEmpty)
                        Padding(
                          padding:
                              EdgeInsets.symmetric(vertical: 60.h, horizontal: 24.w),
                          child: Text(
                            '해당 음료를 제공하는 클럽이 아직 없어요',
                            textAlign: TextAlign.center,
                            style: VybeTypography.body4
                                .copyWith(color: VybeColors.gray500),
                          ),
                        ),
                      const VybeFooterNote(
                        icon: Icons.local_bar_rounded,
                        iconColor: _drink,
                        text: '서비스 음료는 매장 사정에 따라 변동될 수 있어요. 방문 전 확인해 주세요.',
                      ),
                    ],
                  ),
                ),
              ],
            ),
            // 상단 헤더 (글래스 뒤로가기 + 글래스 공유).
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
}

// ── 백드롭 ──
class _Backdrop extends StatelessWidget {
  const _Backdrop();
  @override
  Widget build(BuildContext context) {
    return const VybeAurora(
      accent1: _drink, // 좌상단 시안
      accent2: VybeColors.mainPurple500, // 우상단 보라
      ink: Color(0xFF0A0E10),
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
          final isAll = t == kFilterAll;
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
                  VybeOpenNowPill(open: club.open, height: 32.h),
                ],
              ),
            ),
            // 찜.
            Positioned(
              top: 12.h,
              right: 12.w,
              child: VybeSaveButton(saved: saved, onTap: onSave),
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
                        // 이름·별점·평점은 텍스트 baseline 정렬 유지.
                        Row(
                        crossAxisAlignment: CrossAxisAlignment.baseline,
                        textBaseline: TextBaseline.alphabetic,
                        children: [
                          Flexible(
                            child: Text(
                              club.name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: VybeTypography.heading4
                                  .copyWith(color: Colors.white),
                            ),
                          ),
                          // VYBE 추천 뱃지 — 클럽 이름 옆.
                          if (club.isVybeRecommended) ...[
                            SizedBox(width: 6.w),
                            const VybeRecommendBadge(size: 10),
                          ],
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
                      const VybeMetaDot(),
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
}

