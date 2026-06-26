import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:vybe/data/models/club_model.dart';
import 'package:vybe/data/repositories/club_repository_impl.dart';

part 'club_list_viewmodel.g.dart';

/// 활성 클럽 목록 실시간 스트림
@riverpod
Stream<List<ClubModel>> clubList(Ref ref) {
  return ref.watch(clubRepositoryProvider).watchActiveClubs();
}
