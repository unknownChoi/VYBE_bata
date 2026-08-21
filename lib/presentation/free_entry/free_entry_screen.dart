import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vybe/core/constants/app_geo.dart';
import 'package:vybe/core/providers/auth_providers.dart';
import 'package:vybe/core/utils/gradient_palette.dart';
import 'package:vybe/core/utils/number_format.dart';
import 'package:vybe/data/models/club_model.dart';
import 'package:vybe/design_system/colors.dart';
import 'package:vybe/design_system/typography.dart';
import 'package:vybe/presentation/clubs/club_detail_route.dart';
import 'package:vybe/presentation/clubs/viewmodels/favorite_viewmodel.dart';
import 'package:vybe/presentation/common/club_list_sorting.dart';
import 'package:vybe/presentation/common/free_entry_labels.dart';
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
import 'package:vybe/presentation/free_entry/viewmodels/free_entry_viewmodel.dart';

// 무료입장 클럽 모음 — clubs Firestore 실데이터(isFreeEntry=true).
// 상시 무료(always)와 시간대 무료(timed)를 한 목록에 담고, '지금 무료'인지는
// FreeEntryPolicy.statusAt 으로 화면에서 판정한다(서버는 요일×시:분을 못 가른다).
// 조건 코멘트는 clubs.freeEntry.condition — 비어 있으면 레거시 freeEntryCondition.
const _entry = Color(0xFFFF4D8D); // 무료입장 액센트 (hot pink)
const _entryInk = Color(0xFF2A0712); // pink 위 어두운 텍스트

const _regions = [kFilterAll, '홍대', '강남', '이태원', '압구정', '건대'];

/// 이 화면 전용 정렬 옵션 — 기본은 '지금 무료순'.
///
/// 공용 [kClubSorts] 에 넣지 않는 이유: 무료 시간대가 없는 화면(서비스 음료 등)에서는
/// 고를 수 없는 값이 된다.
const _sorts = [_kSortFreeNow, ...kClubSorts];
const _kSortFreeNow = '지금 무료순';

class _EntryClub implements ClubSortable {
  final String id;
  final String name;
  @override
  final String area;
  final String genre;
  @override
  final double dist;
  @override
  final double rating;

  /// 무료가 아닐 때 내는 값. 0이면 표시 안 함.
  /// 시간대 무료는 `entryFeeMin`, 상시 무료는 min이 0이라 `entryFeeMax`.
  final int cover;

  /// 무료입장 조건 (`freeEntry.condition`, 없으면 레거시 `freeEntryCondition`).
  final String cond;
  @override
  final bool open;
  final String thumbnailUrl;
  final List<Color> gradient;
  final bool vybe; // isVybeRecommended — VYBE 추천 뱃지 노출

  /// 시간대 무료(`freeEntry.type == 'timed'`)인지. false면 상시 무료.
  final bool timed;

  /// 지금 무료인지 — **영업 중일 때만** true.
  /// 문 닫은 클럽의 '지금 무료'는 거짓 정보다(홈 카드와 같은 규칙).
  final bool freeNow;

  /// `22:00 – 01:00`. 지금 무료면 진행 중인 창, 아니면 다음 창. 상시 무료면 빈 값.
  final String windowLabel;

  /// 지금 무료일 때 `38분 남음`. 아니면 null.
  final String? remainingLabel;

  /// 지금 무료가 아닐 때 `22:00부터` / `금 22:00부터`. 다음 창이 없으면 null.
  final String? startsLabel;

  /// '지금 무료순' 정렬 키 — 지금 무료면 끝나는 시각, 아니면 시작 시각.
  final DateTime? sortAt;

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
    required this.timed,
    required this.freeNow,
    required this.windowLabel,
    this.remainingLabel,
    this.startsLabel,
    this.sortAt,
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
    timed: timed,
    freeNow: freeNow,
    windowLabel: windowLabel,
    remainingLabel: remainingLabel,
    startsLabel: startsLabel,
    sortAt: sortAt,
  );
}

/// '지금 무료순' — ① 지금 무료 먼저 ② 시각(끝나는/시작하는) 이른 순 ③ 가까운 순.
///
/// 지금 무료인 카드끼리는 **곧 끝나는 것**을 앞에 둔다(놓치면 안 되는 순서).
/// 상시 무료는 [_EntryClub.sortAt] 이 null이라 같은 freeNow 그룹 안에서 거리순이 된다.
int _compareFreeNow(_EntryClub a, _EntryClub b) {
  if (a.freeNow != b.freeNow) return a.freeNow ? -1 : 1;
  final at = a.sortAt;
  final bt = b.sortAt;
  if (at != null && bt != null && at != bt) return at.compareTo(bt);
  if ((at == null) != (bt == null)) return at == null ? -1 : 1;
  return a.dist.compareTo(b.dist);
}

// 썸네일 없을 때 clubId 해시 기반 일관 그라데이션 fallback.
const _fallbackGradients = <List<Color>>[
  [Color(0xFF2B1655), Color(0xFFFF4D8D)],
  [Color(0xFF06FFA5), Color(0xFF3A86FF)],
  [VybeColors.accentBlue500, VybeColors.mainPurple500],
  [Color(0xFF3A0CA3), Color(0xFF4361EE)],
  [Color(0xFFFF006E), Color(0xFF8338EC)],
  [Color(0xFFF72585), Color(0xFFB5179E)],
  [Color(0xFF06FFA5), Color(0xFF1B9AAA)],
  [Color(0xFF6D4C91), Color(0xFF2A2D34)],
];

// ClubModel → 카드 뷰모델. dist는 화면에서 _loc 기준으로 재계산.
//
// [now] 는 목록 전체가 같은 값을 쓴다 — 카드마다 DateTime.now()를 다시 읽으면
// 같은 목록 안에서 기준 시각이 어긋나 정렬과 표기가 따로 논다.
_EntryClub _fromClub(ClubModel c, DateTime now) {
  final grad = gradientForKey(_fallbackGradients, c.clubId);
  final status = c.freeEntry.statusAt(now);
  final timed = c.freeEntry.isTimed;

  // 무료 창 판정과 **같은 now** 로 영업 여부를 묻는다. today.isCurrentlyOpen 은
  // 벽시계를 다시 읽어, 주입한 시각과 섞이면 '무료 창인데 영업 종료' 같은
  // 어긋난 답이 나온다.
  final openNow = c.operatingHours.dayAt(now).isOpenAt(now);

  final window = status.active ?? status.next;
  final cond = c.freeEntry.condition.isNotEmpty
      ? c.freeEntry.condition
      : (c.freeEntryCondition.isNotEmpty ? c.freeEntryCondition : '입장비 무료');

  return _EntryClub(
    id: c.clubId,
    name: c.name,
    area: c.area,
    genre: c.genre,
    dist: 0,
    rating: c.rating,
    // 시간대 무료는 무료가 끝나면 평상시 최소 요금을 받는다. 상시 무료는 min이
    // 0이라 비교값이 없어 entryFeeMax(상한)를 대신 쓴다 — 기존 표기 그대로.
    cover: c.entryFeeMin > 0 ? c.entryFeeMin : c.entryFeeMax,
    cond: cond,
    open: openNow,
    thumbnailUrl: c.thumbnailUrl,
    gradient: grad,
    vybe: c.isVybeRecommended,
    timed: timed,
    freeNow: status.isFreeNow && openNow,
    windowLabel: timed ? (window?.rangeLabel ?? '') : '',
    remainingLabel: status.isFreeNow && openNow
        ? freeEntryRemainingLabel(status.remainingFrom(now))
        : null,
    startsLabel: status.isFreeNow
        ? null
        : freeEntryStartsLabel(status.nextStartsAt, now),
    sortAt: status.isFreeNow ? status.activeEndsAt : status.nextStartsAt,
  );
}

class FreeEntryScreen extends ConsumerStatefulWidget {
  const FreeEntryScreen({super.key});

  @override
  ConsumerState<FreeEntryScreen> createState() => _FreeEntryScreenState();
}

class _FreeEntryScreenState extends ConsumerState<FreeEntryScreen>
    with SingleTickerProviderStateMixin, LocationFlipMixin {
  String _region = kFilterAll;
  String _loc = AppGeo.hongdaeLabel;
  // 기본은 '지금 무료순' — 이 화면에 온 이유가 "지금 들어갈 수 있는 곳"이라서.
  String _sort = _sorts.first;

  // 위치 칩 탭 → 칩 원형 축소 후 핀 플립 → 내 위치 인식 (서비스 음료와 동일 패턴).
  void _onLocationTap() {
    // 홍대 좌표로 인식 → 검색 로딩 시작. (홈·주변 페이지 최초 로딩 좌표와 동일)
    debugPrint(
      '위치 선택: ${AppGeo.hongdaeLabel} (${AppGeo.hongdaeLat}, ${AppGeo.hongdaeLng})',
    );
    runLocationFlip(onResolved: () => _loc = AppGeo.hongdaeLabel);
  }

  // source(실데이터) → 내 위치 기준 거리 재계산 → 지역 필터 → 정렬.
  //
  // '지금 무료순'은 공용 compareClubs가 모르는 값이라 여기서 다시 정렬한다.
  // (buildClubList에 넘기면 알 수 없는 값 → 거리순으로 조용히 떨어진다)
  List<_EntryClub> _filtered(List<_EntryClub> source) {
    final list = buildClubList(
      source,
      loc: _loc,
      sort: _sort,
      withDist: (c, d) => c.copyWithDist(d),
      keep: (c) => _region == kFilterAll || c.area == _region,
    );
    if (_sort == _kSortFreeNow) list.sort(_compareFreeNow);
    return list;
  }

  @override
  Widget build(BuildContext context) {
    final top = MediaQuery.paddingOf(context).top;
    final bottomPad = MediaQuery.paddingOf(context).bottom + 100.h;
    final clubsAsync = ref.watch(freeEntryViewModelProvider);
    // 목록 전체가 같은 시각으로 판정·정렬된다(카드마다 now를 다시 읽지 않는다).
    final now = DateTime.now();
    final source =
        clubsAsync.asData?.value.map((c) => _fromClub(c, now)).toList() ?? [];
    final list = _filtered(source);
    final freeNowCount = list.where((c) => c.freeNow).length;

    final uid = ref.watch(currentUidProvider);
    final favoritedIds = ref.watch(mergedFavoriteIdsProvider);

    return Scaffold(
      backgroundColor: VybeColors.background,
      body: SizedBox.expand(
        child: Stack(
          children: [
            // 핑크/보라 백드롭 — 화면 전체를 채운다(우하단 글로우까지).
            const Positioned.fill(child: IgnorePointer(child: _Backdrop())),
            // 카드 목록은 SliverList.builder로 화면에 보이는 만큼만 만든다
            // (ListView(children: [...])는 클럽 전부를 즉시 빌드해 진입이 무거워진다).
            CustomScrollView(
              slivers: [
                SliverPadding(
                  padding: EdgeInsets.only(top: top + 52.h),
                  sliver: SliverList.list(
                    children: [
                      _Intro(
                        count: list.length,
                        freeNowCount: freeNowCount,
                        region: _region,
                      ),
                      VybeLocationSortBar(
                        loc: _loc,
                        sort: _sort,
                        sorts: _sorts,
                        locLoading: locLoading,
                        flip: flip,
                        onLocTap: _onLocationTap,
                        onSort: (s) => setState(() => _sort = s),
                        accent: _entry,
                      ),
                      _RegionFilter(
                        active: _region,
                        onChange: (r) => setState(() => _region = r),
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
                      child: _EntryCard(
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
                          padding: EdgeInsets.symmetric(
                            vertical: 60.h,
                            horizontal: 24.w,
                          ),
                          child: Text(
                            '입장비 무료 클럽을 불러오지 못했어요',
                            textAlign: TextAlign.center,
                            style: VybeTypography.body4.copyWith(
                              color: VybeColors.gray500,
                            ),
                          ),
                        )
                      else if (list.isEmpty)
                        Padding(
                          padding: EdgeInsets.symmetric(
                            vertical: 60.h,
                            horizontal: 24.w,
                          ),
                          child: Text(
                            _region == kFilterAll
                                ? '입장비 무료 클럽이 아직 없어요'
                                : '$_region 지역에 입장비 무료 클럽이 없어요',
                            textAlign: TextAlign.center,
                            style: VybeTypography.body4.copyWith(
                              color: VybeColors.gray500,
                            ),
                          ),
                        ),
                      const VybeFooterNote(
                        icon: Icons.confirmation_number_rounded,
                        iconColor: _entry,
                        text: '입장 정책은 요일·시간대에 따라 달라질 수 있어요. 방문 전 확인해 주세요.',
                      ),
                    ],
                  ),
                ),
              ],
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
}

// ── 백드롭 ──
class _Backdrop extends StatelessWidget {
  const _Backdrop();
  @override
  Widget build(BuildContext context) {
    return const VybeAurora(
      accent1: _entry, // 좌상단 핑크
      accent2: VybeColors.mainPurple500, // 우상단 보라
      ink: Color(0xFF0D0A0C),
    );
  }
}

// ── 인트로 ──
class _Intro extends StatelessWidget {
  final int count;

  /// 이 중 지금 무료인 곳. 0이면 pill 문구를 '무료입장 정책'으로 낮춘다 —
  /// 한 곳도 무료가 아닌데 '지금 무료입장'이라 쓰면 거짓 정보다.
  final int freeNowCount;
  // 헤드라인 접두사. '전체' → '내 주변', 그 외 → 지역명(예: '홍대').
  final String region;
  const _Intro({
    required this.count,
    required this.freeNowCount,
    required this.region,
  });

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
    final prefix = region == kFilterAll ? '내 주변' : region;
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
                position: Tween(
                  begin: const Offset(0, 0.3),
                  end: Offset.zero,
                ).animate(anim),
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
                    text: '입장비 무료',
                    style: TextStyle(color: _entry),
                  ),
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
                      decoration: BoxDecoration(
                        color: freeNowCount > 0 ? _entry : VybeColors.gray500,
                        shape: BoxShape.circle,
                      ),
                    ),
                    SizedBox(width: 5.w),
                    Text(
                      freeNowCount > 0 ? '지금 무료 $freeNowCount곳' : '무료입장 정책',
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
              Text.rich(
                TextSpan(
                  style: VybeTypography.caption.copyWith(
                    color: VybeColors.gray400,
                  ),
                  children: [
                    TextSpan(
                      text: prefix,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const TextSpan(text: ' 근처 '),
                    TextSpan(
                      text: '$count곳',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
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
                r == kFilterAll ? '내 주변' : r,
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

// ── 무료입장 리본 ──
//
// 상태 셋 — ① 지금 무료(영업 중 + 무료 창 안) ② 시간대 무료인데 지금은 아님
// ③ 상시 무료. ②만 톤을 낮춘다(채운 핑크는 "지금 들어가면 공짜"라는 뜻으로 읽혀서).
class _FreeRibbon extends StatelessWidget {
  final _EntryClub club;
  const _FreeRibbon({required this.club});

  @override
  Widget build(BuildContext context) {
    final freeNow = club.freeNow;
    final pending = club.timed && !freeNow;

    // 상시 무료도 '지금 무료'이긴 하나 그렇게 쓰면 시간 제한이 있는 것처럼 읽힌다
    // → 종류(timed)를 먼저 보고 문구를 고른다.
    final label = switch ((club.timed, freeNow)) {
      (false, _) => '입장비 무료',
      (true, true) =>
        club.remainingLabel == null
            ? '지금 무료'
            : '지금 무료 · ${club.remainingLabel}',
      // 창을 못 읽은 데이터(빈 windows)는 시각 대신 종류만 말한다.
      (true, false) =>
        club.windowLabel.isEmpty ? '시간대 무료' : '${club.windowLabel} 무료',
    };

    return Container(
      height: 32.r,
      alignment: Alignment.center,
      padding: EdgeInsets.symmetric(horizontal: 11.w),
      decoration: BoxDecoration(
        color: pending ? const Color(0xCC141018) : _entry,
        borderRadius: BorderRadius.circular(12.r),
        border: pending
            ? Border.all(color: _entry.withValues(alpha: 0.5))
            : null,
        boxShadow: pending
            ? null
            : [
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
          Icon(
            pending
                ? Icons.schedule_rounded
                : Icons.confirmation_number_rounded,
            size: 15.r,
            color: pending ? _entry : _entryInk,
          ),
          SizedBox(width: 6.w),
          Text(
            label,
            style: VybeTypography.button2.copyWith(
              fontWeight: FontWeight.w800,
              color: pending ? _entry : _entryInk,
            ),
          ),
        ],
      ),
    );
  }
}

/// 카드 하단 요금 표기.
///
/// 무료가 **지금 유효할 때만** 취소선을 긋는다 — 무료 시간이 아닌 클럽에 취소선을
/// 그으면 지금 공짜로 들어갈 수 있다는 거짓말이 된다. 그때는 평상시 요금을
/// 그대로 보여 주고 언제부터 무료인지를 덧붙인다.
List<Widget> _feeTail(_EntryClub club) {
  // 상시 무료는 영업 여부와 무관하게 정책 자체가 무료 → 취소선 유지.
  final struck = !club.timed || club.freeNow;
  final fee = club.cover > 0 ? '${formatThousands(club.cover)}원' : '';

  return [
    if (fee.isNotEmpty)
      Text(
        fee,
        style: VybeTypography.caption.copyWith(
          fontSize: 11.sp,
          color: VybeColors.gray500,
          decoration: struck ? TextDecoration.lineThrough : null,
        ),
      ),
    if (fee.isNotEmpty) SizedBox(width: 5.w),
    Text(
      struck
          ? '무료'
          : (club.startsLabel == null ? '무료 시간 종료' : '${club.startsLabel} 무료'),
      style: VybeTypography.caption.copyWith(
        fontSize: 11.sp,
        fontWeight: FontWeight.w800,
        color: struck ? Colors.white : VybeColors.gray300,
      ),
    ),
  ];
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
      child: Container(
        height: 208.h,
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: club.gradient,
          ),
          borderRadius: BorderRadius.circular(18.r),
        ),
        // ⚠ 테두리는 자식 위(foregroundDecoration)에. decoration 에 두면 자식이
        // 바깥 라운드렉트로 클립되면서 코너 호에서 선을 덮어, 직선부만 남고
        // 모서리가 끊긴 것처럼 보인다. (CLAUDE.md '라운드 카드에 테두리' 참고)
        foregroundDecoration: BoxDecoration(
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
                  colors: [
                    Color(0xF50C0C0F),
                    Color(0x400C0C0F),
                    Colors.transparent,
                  ],
                  stops: [0.14, 0.56, 0.78],
                ),
              ),
            ),
            // 무료입장 리본 — 지금 무료 / 시간대 무료 / 상시 무료.
            Positioned(
              top: 12.h,
              left: 12.w,
              child: _FreeRibbon(club: club),
            ),
            // 영업 상태 pill.
            Positioned(
              top: 12.h,
              right: 52.w,
              child: VybeOpenNowPill(open: club.open),
            ),
            // 찜.
            Positioned(
              top: 12.h,
              right: 12.w,
              child: VybeSaveButton(saved: saved, onTap: onSave),
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
                      Flexible(
                        child: Text(
                          club.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: VybeTypography.heading4.copyWith(
                            color: Colors.white,
                            height: 1.0,
                          ),
                        ),
                      ),
                      // VYBE 추천 뱃지 — 클럽 이름 옆.
                      if (club.vybe) ...[
                        SizedBox(width: 6.w),
                        const VybeRecommendBadge(size: 10),
                      ],
                      SizedBox(width: 8.w),
                      Icon(
                        Icons.star_rounded,
                        size: 12.r,
                        color: VybeColors.mainLime500,
                      ),
                      SizedBox(width: 3.w),
                      Text(
                        club.rating.toStringAsFixed(2),
                        style: VybeTypography.caption.copyWith(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 6.h),
                  Row(
                    children: [
                      Icon(
                        Icons.place_rounded,
                        size: 11.r,
                        color: VybeColors.gray300,
                      ),
                      SizedBox(width: 3.w),
                      Text(
                        '${club.area} · ${club.dist.toStringAsFixed(1)}km',
                        style: VybeTypography.caption.copyWith(
                          fontSize: 12.sp,
                          height: 1.0,
                          fontWeight: FontWeight.w600,
                          color: VybeColors.gray300,
                        ),
                      ),
                      const VybeMetaDot(),
                      Text(
                        club.genre,
                        style: VybeTypography.caption.copyWith(
                          fontSize: 12.sp,
                          height: 1.0,
                          color: VybeColors.gray400,
                        ),
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
                            horizontal: 9.w,
                            vertical: 4.h,
                          ),
                          decoration: BoxDecoration(
                            color: _entry.withValues(alpha: 0.16),
                            borderRadius: BorderRadius.circular(8.r),
                            border: Border.all(
                              color: _entry.withValues(alpha: 0.34),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.confirmation_number_outlined,
                                size: 11.r,
                                color: _entry,
                              ),
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
                      ..._feeTail(club),
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
}
