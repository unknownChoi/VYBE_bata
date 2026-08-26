import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vybe/core/constants/app_geo.dart';
import 'package:vybe/core/providers/auth_providers.dart';
import 'package:vybe/data/models/club_model.dart';
import 'package:vybe/presentation/clubs/club_detail_route.dart';
import 'package:vybe/presentation/clubs/viewmodels/favorite_viewmodel.dart';
import 'package:vybe/presentation/common/club_list_sorting.dart';
import 'package:vybe/presentation/common/location_flip_mixin.dart';
import 'package:vybe/presentation/common/widgets/vybe_aurora.dart';
import 'package:vybe/presentation/common/widgets/vybe_chip_filter_bar.dart';
import 'package:vybe/presentation/common/widgets/vybe_footer_note.dart';
import 'package:vybe/presentation/common/widgets/vybe_glass_header.dart';
import 'package:vybe/presentation/common/widgets/vybe_location_sort_bar.dart';
import 'package:vybe/presentation/free_entry/free_entry_models.dart';
import 'package:vybe/presentation/free_entry/free_entry_style.dart';
import 'package:vybe/presentation/free_entry/viewmodels/free_entry_viewmodel.dart';
import 'package:vybe/presentation/free_entry/widgets/free_entry_card.dart';
import 'package:vybe/presentation/free_entry/widgets/free_entry_hero.dart';
import 'package:vybe/presentation/free_entry/widgets/free_entry_states.dart';

/// 무료입장 클럽 모음 — clubs Firestore 실데이터(`isFreeEntry=true`).
///
/// 상시 무료(always)와 시간대 무료(timed)를 한 목록에 담고, '지금 무료'인지는
/// `FreeEntryPolicy.statusAt` 으로 화면에서 판정한다(서버는 요일×시:분을 못 가른다).
class FreeEntryScreen extends ConsumerStatefulWidget {
  const FreeEntryScreen({super.key});

  @override
  ConsumerState<FreeEntryScreen> createState() => _FreeEntryScreenState();
}

class _FreeEntryScreenState extends ConsumerState<FreeEntryScreen>
    with SingleTickerProviderStateMixin, LocationFlipMixin {
  String _region = kFilterAll;
  String _loc = AppGeo.hongdaeLabel;

  /// 기본은 '지금 무료순' — 이 화면에 온 이유가 "지금 들어갈 수 있는 곳"이라서.
  String _sort = kEntrySorts.first;

  // 위치 칩 탭 → 칩 원형 축소 후 핀 플립 → 내 위치 인식 (서비스 음료와 동일 패턴).
  void _onLocationTap() {
    // 홍대 좌표로 인식 → 검색 로딩 시작. (홈·주변 페이지 최초 로딩 좌표와 동일)
    debugPrint(
      '위치 선택: ${AppGeo.hongdaeLabel} (${AppGeo.hongdaeLat}, ${AppGeo.hongdaeLng})',
    );
    runLocationFlip(onResolved: () => _loc = AppGeo.hongdaeLabel);
  }

  /// source(실데이터) → 내 위치 기준 거리 재계산 → 지역 필터 → 정렬.
  ///
  /// '지금 무료순'은 공용 `compareClubs`가 모르는 값이라 여기서 다시 정렬한다
  /// (`buildClubList`에 넘기면 알 수 없는 값 → 거리순으로 조용히 떨어진다).
  List<FreeEntryClub> _filtered(List<FreeEntryClub> source) {
    final list = buildClubList(
      source,
      loc: _loc,
      sort: _sort,
      withDist: (c, d) => c.copyWithDist(d),
      keep: (c) => _region == kFilterAll || c.area == _region,
    );
    if (_sort == kSortFreeNow) list.sort(compareFreeNow);
    return list;
  }

  /// 목록 전체가 **같은 시각**으로 판정·정렬된다 (카드마다 now를 다시 읽지 않는다).
  List<FreeEntryClub> _cards(List<ClubModel>? clubs) {
    if (clubs == null) return const [];
    final now = DateTime.now();
    return clubs.map((c) => FreeEntryClub.fromClub(c, now)).toList();
  }

  @override
  Widget build(BuildContext context) {
    final clubsAsync = ref.watch(freeEntryViewModelProvider);
    final list = _filtered(_cards(clubsAsync.asData?.value));

    return Scaffold(
      backgroundColor: kVybeInk,
      body: SizedBox.expand(
        child: Stack(
          children: [
            // 배경 — 공용 리뉴얼 오로라 기본색(VYBE 추천 등 다른 전용 페이지와 동일).
            // 화면 전체를 채운다(우하단 글로우까지).
            const Positioned.fill(
              child: IgnorePointer(child: VybeAurora()),
            ),
            CustomScrollView(
              // ⚠ 튕김(오버스크롤) 금지 — 히어로가 상태바 뒤까지 올라가 있어서
              // 위로 당기면 이미지 위에 배경이 드러난다.
              physics: const ClampingScrollPhysics(),
              slivers: [
                _headerSliver(),
                _listSliver(list),
                _tailSliver(clubsAsync, list),
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

  /// 히어로 + 위치/정렬 바 + 지역 필터.
  ///
  /// 히어로가 상태바 뒤까지 채우므로 top 패딩을 두지 않는다.
  Widget _headerSliver() {
    return SliverList.list(
      children: [
        const FreeEntryHero(),
        SizedBox(height: 8.h),
        VybeLocationSortBar(
          loc: _loc,
          sort: _sort,
          sorts: kEntrySorts,
          locLoading: locLoading,
          flip: flip,
          onLocTap: _onLocationTap,
          onSort: (s) => setState(() => _sort = s),
          accent: kEntryAccent,
        ),
        VybeChipFilterBar(
          options: kEntryRegions,
          active: _region,
          onChange: (r) => setState(() => _region = r),
          accent: kEntryAccent,
          accentInk: kEntryInk,
          // '전체' 값은 필터 로직 유지, 표시만 '내 주변'.
          labelOf: (r) => r == kFilterAll ? '내 주변' : r,
          chipHPadding: 16,
        ),
        SizedBox(height: 4.h),
      ],
    );
  }

  /// 카드 목록. `SliverList.builder`라 화면에 보이는 만큼만 만든다
  /// (`ListView(children: [...])`는 클럽 전부를 즉시 빌드해 진입이 무거워진다).
  Widget _listSliver(List<FreeEntryClub> list) {
    final uid = ref.watch(currentUidProvider);
    final favoritedIds = ref.watch(mergedFavoriteIdsProvider);

    return SliverList.builder(
      itemCount: list.length,
      itemBuilder: (_, i) {
        final club = list[i];
        final saved = favoritedIds.contains(club.id);
        return Padding(
          padding: EdgeInsets.fromLTRB(24.w, 0, 24.w, 14.h),
          child: FreeEntryCard(
            club: club,
            saved: saved,
            onSave: uid == null
                ? null
                : () => ref
                      .read(favoriteViewModelProvider.notifier)
                      .toggleFavorite(uid, club.id, saved),
            onTap: () => openClubDetail(context, club.id),
          ),
        );
      },
    );
  }

  /// 로딩·에러·빈 목록 안내 + 하단 주의 문구.
  Widget _tailSliver(
    AsyncValue<List<ClubModel>> clubsAsync,
    List<FreeEntryClub> list,
  ) {
    return SliverPadding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.paddingOf(context).bottom + 100.h,
      ),
      sliver: SliverList.list(
        children: [
          if (clubsAsync.isLoading)
            const FreeEntryListSkeleton()
          else if (clubsAsync.hasError)
            const FreeEntryMessage.error()
          else if (list.isEmpty)
            FreeEntryMessage.empty(_region),
          const VybeFooterNote(
            icon: Icons.confirmation_number_rounded,
            iconColor: kEntryAccent,
            text: '입장 정책은 요일·시간대에 따라 달라질 수 있어요. 방문 전 확인해 주세요.',
          ),
        ],
      ),
    );
  }
}
