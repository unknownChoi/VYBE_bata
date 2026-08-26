import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vybe/design_system/colors.dart';
import 'package:vybe/design_system/typography.dart';
import 'package:vybe/presentation/common/widgets/vybe_aurora.dart';
import 'package:vybe/presentation/common/widgets/vybe_glass_header.dart';
import 'package:vybe/presentation/hot_places/hot_places_models.dart';
import 'package:vybe/presentation/hot_places/widgets/hot_places_header.dart';
import 'package:vybe/presentation/hot_places/widgets/hot_places_hero.dart';
import 'package:vybe/presentation/hot_places/widgets/hot_places_list_row.dart';
import 'package:vybe/presentation/hot_places/widgets/hot_places_podium.dart';
import 'package:vybe/presentation/hot_places/widgets/hot_places_skeleton.dart';

// 핫플레이스 — 실시간 방문자/혼잡도 기반 클럽 랭킹.
// claude.ai/design hot_places.html 디자인을 하드코딩 프론트로 구현.
// TODO: 추후 Firebase 실연동 (현재는 더미 데이터).

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
  List<HotClub> get _ranked {
    final all = [...kHotTopClubs, ...kHotListClubs];
    if (_area == '전체') return all;
    if (_area == '내 주변') {
      final near = all.where((c) => c.dist <= kHotNearRadiusKm).toList()
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
    final bottomPad = MediaQuery.paddingOf(context).bottom + 90.h;

    return Scaffold(
      backgroundColor: kVybeInk,
      // SizedBox.expand로 Stack을 화면 전체로 강제 → 백드롭이 다이나믹 아일랜드
      // (상태바) 영역까지 채워지고 본문이 그 밑으로 흐름. (vybe 추천 페이지와 동일)
      body: SizedBox.expand(
        child: Stack(
          children: [
            // 배경 — 공용 리뉴얼 오로라 기본색(VYBE 추천 등 다른 전용 페이지와 동일).
            // 화면 전체를 채운다(상태바 포함) — 부분 높이로 자르면 우하단
            // 글로우가 화면 중간에 맺히고 아래쪽에 색 경계가 생긴다.
            const Positioned.fill(
              child: IgnorePointer(child: VybeAurora()),
            ),
            Positioned.fill(
              child: _loading
                  ? const HotPlacesSkeleton()
                  : ListView(
                      controller: _scroll,
                      padding: EdgeInsets.only(bottom: bottomPad),
                      // ⚠ 튕김(오버스크롤) 금지 — 히어로가 상태바 뒤까지 올라가 있어서
                      // 위로 당기면 이미지 위에 배경이 드러난다.
                      physics: const ClampingScrollPhysics(),
                      children: [
                        const HotPlacesHero(),
                        SizedBox(height: 8.h),
                        HotPlacesAreaFilter(
                          active: _area,
                          scrolled: _scrolled,
                          onChange: (a) => setState(() => _area = a),
                        ),
                        if (_area == '전체')
                          HotPlacesPodium(
                            clubs: ranked.take(3).toList(),
                            saved: _saved,
                            onSave: _toggleSave,
                          ),
                        HotPlacesSectionHeader(area: _area, near: near, total: total),
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
                          ...list.map((c) => HotPlacesListRow(
                                club: c,
                                near: near,
                                saved: _saved.contains(c.id),
                                onSave: _toggleSave,
                              )),
                        // 하단 안내문은 뺐다 — 히어로 띠가 같은 말을 하고 있었고
                        // (게다가 '10분마다' vs '1시간마다'로 서로 어긋났다).
                        // 자리는 여백으로 남긴다.
                        SizedBox(height: 60.h),
                      ],
                    ),
            ),
            // 상단 투명 헤더 오버레이 (뒤로가기 버튼).
            const Positioned(top: 0, left: 0, right: 0, child: VybeGlassHeader()),
          ],
        ),
      ),
    );
  }
}
