import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:vybe/data/models/club_model.dart';
import 'package:vybe/data/models/performance_model.dart';
import 'package:vybe/data/repositories/club_repository_impl.dart';
import 'package:vybe/data/repositories/performance_repository_impl.dart';

part 'hip_hop_viewmodel.g.dart';

/// 힙합 페이지 데이터 — 활성 힙합 클럽 + 오늘 공연 일정.
/// hero(featured)·DJ rail(전체)·포스터 그리드(클럽+라인업 머지)는 화면에서 가공.
class HipHopData {
  final List<ClubModel> clubs; // genre=힙합 활성 클럽
  final List<PerformanceModel> performances; // 오늘(KST) 공연, 시작시각 오름차순

  const HipHopData({required this.clubs, required this.performances});

  /// clubId → 오늘 헤드라이너 공연(가장 이른 시각). 포스터 live/lineup 머지용.
  Map<String, PerformanceModel> get headlinerByClub {
    final map = <String, PerformanceModel>{};
    for (final p in performances) {
      // performances는 startAt 오름차순 → 클럽별 첫 건이 가장 이른 공연.
      map.putIfAbsent(p.clubId, () => p);
    }
    return map;
  }

  /// hero 캐러셀용 — isFeatured 공연만 (시작시각 순).
  List<PerformanceModel> get featured =>
      performances.where((p) => p.isFeatured).toList();
}

/// 힙합 클럽 + 오늘 공연 일정을 병렬 조회해 합친다.
@riverpod
class HipHopViewModel extends _$HipHopViewModel {
  Future<HipHopData> _load() async {
    // 클럽은 필수. 오늘 공연(performances)은 인덱스 미생성/데이터 없음 시
    // 실패해도 그리드(클럽 목록)는 보여야 하므로 비치명적으로 처리.
    final clubsF = ref.read(clubRepositoryProvider).getHipHopClubs();
    final perfsF = ref
        .read(performanceRepositoryProvider)
        .getTodayPerformances()
        .catchError((e, st) {
      debugPrint('[HipHop] performances 조회 실패: $e');
      return <PerformanceModel>[];
    });
    final results = await (clubsF, perfsF).wait;
    return HipHopData(clubs: results.$1, performances: results.$2);
  }

  @override
  Future<HipHopData> build() => _load();

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(_load);
  }
}
