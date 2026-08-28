import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vybe/core/providers/location_providers.dart';
import 'package:vybe/data/models/club_model.dart';
import 'package:vybe/data/models/performance_model.dart';
import 'package:vybe/presentation/common/widgets/vybe_aurora.dart';
import 'package:vybe/presentation/common/widgets/vybe_glass_header.dart';
import 'package:vybe/presentation/edm/edm_models.dart';
import 'package:vybe/presentation/edm/viewmodels/edm_viewmodel.dart';
import 'package:vybe/presentation/edm/widgets/edm_club_grid.dart';
import 'package:vybe/presentation/edm/widgets/edm_hero.dart';
import 'package:vybe/presentation/edm/widgets/edm_timetable.dart';

/// EDM 장르 페이지 — 인트로 히어로 + DJ 타임테이블 + 주변 EDM 클럽 추천.
///
/// claude.ai/design `edm_renew.html` 디자인 기반. 수치는 디자인(393 기준) 값 그대로.
/// 데이터: 타임테이블은 오늘 performances(genre=EDM) + 클럽 조인,
/// 그리드는 clubs(genre=EDM).
class EdmScreen extends ConsumerStatefulWidget {
  const EdmScreen({super.key});

  @override
  ConsumerState<EdmScreen> createState() => _EdmScreenState();
}

class _EdmScreenState extends ConsumerState<EdmScreen> {
  final Set<Object> _saved = {};

  void _toggleSave(Object id) => setState(() {
    _saved.contains(id) ? _saved.remove(id) : _saved.add(id);
  });

  @override
  Widget build(BuildContext context) {
    // 플로팅 바텀 nav(MainScaffold) 가림 방지용 하단 여백.
    final bottomPad = MediaQuery.paddingOf(context).bottom + 90.h;

    final async = ref.watch(edmViewModelProvider);
    final data = async.asData?.value;
    final loading = async.isLoading && data == null;

    final clubs = data?.clubs ?? const <ClubModel>[];
    final perfs = data?.performances ?? const <PerformanceModel>[];
    final clubById = data?.clubById ?? const <String, ClubModel>{};

    // 거리 표시는 내 위치 기준.
    final me = ref.watch(userLocationProvider);
    final origin = (lat: me.lat, lng: me.lng);

    // ⚠ 판정 시각은 화면당 한 번만 읽는다 — 카드마다 DateTime.now()를 다시 읽으면
    // 같은 목록 안에서 기준이 어긋나 NOW 마커와 카드 상태가 따로 논다.
    final now = DateTime.now();

    final sets = [
      for (final p in perfs) edmSetFrom(p, clubById[p.clubId], origin: origin),
    ];
    final posters = [for (final c in clubs) edmClubFrom(c, origin: origin)];

    return Scaffold(
      backgroundColor: kVybeInk,
      // SizedBox.expand로 Stack을 화면 전체로 강제 → 백드롭이 상태바 영역까지 채워진다.
      body: SizedBox.expand(
        child: Stack(
          children: [
            // 배경 — 공용 리뉴얼 오로라 기본색(다른 카테고리 페이지와 동일).
            const Positioned.fill(child: IgnorePointer(child: VybeAurora())),
            Positioned.fill(
              child: ListView(
                // 히어로가 상태바 뒤까지 채우므로 top 패딩을 두지 않는다.
                padding: EdgeInsets.only(bottom: bottomPad),
                // ⚠ 튕김(오버스크롤) 금지 — 히어로가 상태바 뒤까지 올라가 있어서
                // 위로 당기면 이미지 위에 배경이 드러난다.
                physics: const ClampingScrollPhysics(),
                children: [
                  const EdmHero(),
                  SizedBox(height: 30.h),
                  EdmTimetable(
                    sets: sets,
                    loading: loading,
                    now: now,
                    saved: _saved,
                    onSave: _toggleSave,
                  ),
                  SizedBox(height: 46.h),
                  EdmClubGrid(
                    clubs: posters,
                    clubById: clubById,
                    loading: loading,
                    saved: _saved,
                    onSave: _toggleSave,
                  ),
                  SizedBox(height: 30.h),
                ],
              ),
            ),
            // 상단 투명 헤더 오버레이 (뒤로가기 · 공유).
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
