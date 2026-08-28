import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:vybe/data/models/club_model.dart';
import 'package:vybe/data/models/performance_model.dart';
import 'package:vybe/data/repositories/club_repository_impl.dart';
import 'package:vybe/data/repositories/performance_repository_impl.dart';

part 'edm_viewmodel.g.dart';

/// clubs.genre · performances.genre 에 들어가는 EDM 장르 값.
/// 두 쿼리가 같은 문자열을 봐야 해서 상수 하나로 둔다.
const kEdmGenre = 'EDM';

/// EDM 페이지 데이터 — 활성 EDM 클럽 + 오늘 EDM 공연 일정.
/// 타임테이블(공연 + 클럽 조인)·포스터 그리드는 화면에서 가공.
class EdmData {
  final List<ClubModel> clubs; // genre=EDM 활성 클럽
  final List<PerformanceModel> performances; // 오늘(KST) 공연, 시작시각 오름차순

  const EdmData({required this.clubs, required this.performances});

  /// clubId → 클럽. 타임테이블이 지역·거리·세부 장르를 조인할 때 쓴다.
  Map<String, ClubModel> get clubById => {for (final c in clubs) c.clubId: c};
}

/// EDM 클럽 + 오늘 공연 일정을 병렬 조회해 합친다.
@riverpod
class EdmViewModel extends _$EdmViewModel {
  Future<EdmData> _load() async {
    // 클럽은 필수. 오늘 공연(performances)은 인덱스 미생성/데이터 없음 시
    // 실패해도 클럽 그리드는 보여야 하므로 비치명적으로 처리.
    final clubsF = ref.read(clubRepositoryProvider).getClubsByGenre(kEdmGenre);
    final perfsF = ref
        .read(performanceRepositoryProvider)
        .getTodayPerformances(genre: kEdmGenre)
        .catchError((e, st) {
          debugPrint('[EDM] performances 조회 실패: $e');
          return <PerformanceModel>[];
        });
    final results = await (clubsF, perfsF).wait;
    return EdmData(clubs: results.$1, performances: results.$2);
  }

  @override
  Future<EdmData> build() => _load();

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(_load);
  }
}
