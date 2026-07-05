import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:vybe/data/repositories/performance_repository_impl.dart';
import 'package:vybe/presentation/clubs/widgets/schedule_shared.dart';

part 'club_schedule_viewmodel.g.dart';

/// 클럽 상세 공연 일정 — performances 컬렉션에서 다가오는 공연을 조회해
/// 날짜별 카드 데이터(ScheduleDay)로 매핑. 섹션·전체 페이지 공용.
@riverpod
Future<List<ScheduleDay>> clubSchedule(Ref ref, String clubId) async {
  final perfs = await ref
      .read(performanceRepositoryProvider)
      .getUpcomingPerformancesByClub(clubId);
  return buildScheduleDays(perfs);
}
