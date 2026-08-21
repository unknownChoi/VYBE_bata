import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vybe/core/constants/app_geo.dart';
import 'package:vybe/core/providers/auth_providers.dart';
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
import 'package:vybe/presentation/common/widgets/vybe_skeleton.dart';
import 'package:vybe/presentation/service_drinks/service_drinks_models.dart';
import 'package:vybe/presentation/service_drinks/service_drinks_style.dart';
import 'package:vybe/presentation/service_drinks/viewmodels/service_drinks_viewmodel.dart';
import 'package:vybe/presentation/service_drinks/widgets/service_drinks_card.dart';
import 'package:vybe/presentation/service_drinks/widgets/service_drinks_intro.dart';
import 'package:vybe/presentation/service_drinks/widgets/service_drinks_type_filter.dart';

/// 카드 목록이 비었을 때 안내 문구가 남기는 세로 여백.
const double _kEmptyGap = 60;

/// 서비스 음료(무료 음료) 제공 클럽 모음 — `clubs.serviceDrink` 실데이터.
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

  /// 위치 칩 탭 → 칩 원형 축소 후 핀 플립 → 내 위치 인식 (홈스크린과 동일 패턴).
  void _onLocationTap() =>
      runLocationFlip(onResolved: () => _loc = AppGeo.hongdaeLabel);

  /// 실데이터 → 내 위치 기준 거리 재계산 → 종류 필터 → 정렬.
  List<ServiceDrinkClub> _filtered(List<ServiceDrinkClub> source) =>
      buildClubList(
        source,
        loc: _loc,
        sort: _sort,
        withDist: (c, d) => c.copyWithDist(d),
        keep: (c) => _type == kFilterAll || c.drinks.contains(_type),
      );

  @override
  Widget build(BuildContext context) {
    final insets = MediaQuery.paddingOf(context);
    final clubsAsync = ref.watch(serviceDrinksViewModelProvider);
    final source =
        clubsAsync.asData?.value.map(ServiceDrinkClub.fromClub).toList() ?? [];
    final list = _filtered(source);

    return Scaffold(
      backgroundColor: VybeColors.background,
      body: SizedBox.expand(
        child: Stack(
          children: [
            // 시안/보라 백드롭 — 화면 전체를 채운다(우하단 글로우까지).
            const Positioned.fill(
              child: IgnorePointer(
                child: VybeAurora(
                  accent1: kDrinkAccent, // 좌상단 시안
                  accent2: VybeColors.mainPurple500, // 우상단 보라
                  ink: kDrinkBackdropInk,
                ),
              ),
            ),
            CustomScrollView(
              slivers: [
                SliverPadding(
                  padding: EdgeInsets.only(top: insets.top + 52.h),
                  sliver: SliverList.list(children: _headerSlivers(list.length)),
                ),
                // 카드 목록은 SliverList.builder로 보이는 만큼만 만든다
                // (ListView(children: [...])는 클럽 전부를 즉시 빌드해 진입이 무거워진다).
                _cardList(list),
                SliverPadding(
                  padding: EdgeInsets.only(bottom: insets.bottom + 100.h),
                  sliver: SliverList.list(
                    children: _footerSlivers(clubsAsync, list.isEmpty),
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

  List<Widget> _headerSlivers(int count) => [
    ServiceDrinksIntro(count: count, loc: _loc),
    VybeLocationSortBar(
      loc: _loc,
      sort: _sort,
      sorts: kClubSorts,
      locLoading: locLoading,
      flip: flip,
      onLocTap: _onLocationTap,
      onSort: (s) => setState(() => _sort = s),
      accent: kDrinkAccent,
    ),
    ServiceDrinksTypeFilter(
      active: _type,
      onChange: (t) => setState(() => _type = t),
    ),
    SizedBox(height: 4.h),
  ];

  Widget _cardList(List<ServiceDrinkClub> list) {
    final uid = ref.watch(currentUidProvider);
    final favoritedIds = ref.watch(mergedFavoriteIdsProvider);

    return SliverList.builder(
      itemCount: list.length,
      itemBuilder: (_, i) {
        final club = list[i];
        final saved = favoritedIds.contains(club.id);
        return _cardPadding(
          ServiceDrinksCard(
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

  /// 로딩 스켈레톤 / 오류 / 빈 목록 안내 + 하단 주의 문구.
  List<Widget> _footerSlivers(AsyncValue<Object?> clubsAsync, bool isEmpty) => [
    if (clubsAsync.isLoading)
      ...List.generate(
        3,
        (_) => _cardPadding(VybeSkel(height: kDrinkCardHeight.h, radius: 18)),
      )
    else if (clubsAsync.hasError)
      const _Note('서비스 음료 클럽을 불러오지 못했어요')
    else if (isEmpty)
      const _Note('해당 음료를 제공하는 클럽이 아직 없어요'),
    const VybeFooterNote(
      icon: Icons.local_bar_rounded,
      iconColor: kDrinkAccent,
      text: '서비스 음료는 매장 사정에 따라 변동될 수 있어요. 방문 전 확인해 주세요.',
    ),
  ];

  /// 카드·스켈레톤이 같은 여백을 쓰도록 한곳에서 준다
  /// (다르면 로딩→데이터 전환에 목록이 옆으로 튄다).
  Widget _cardPadding(Widget child) => Padding(
    padding: EdgeInsets.fromLTRB(24.w, 0, 24.w, 14.h),
    child: child,
  );
}

/// 목록 자리를 대신하는 회색 안내 한 줄.
class _Note extends StatelessWidget {
  final String text;
  const _Note(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(
        vertical: _kEmptyGap.h,
        horizontal: 24.w,
      ),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: VybeTypography.body4.copyWith(color: VybeColors.gray500),
      ),
    );
  }
}
