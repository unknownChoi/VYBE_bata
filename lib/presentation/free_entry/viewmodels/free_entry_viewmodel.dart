import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:vybe/data/models/club_model.dart';
import 'package:vybe/data/repositories/club_repository_impl.dart';

part 'free_entry_viewmodel.g.dart';

/// 입장비 무료 클럽 목록.
/// clubs 중 entryFeeMin=0 인 활성 클럽. 지역/정렬 필터는 화면에서 처리.
@riverpod
class FreeEntryViewModel extends _$FreeEntryViewModel {
  @override
  Future<List<ClubModel>> build() {
    return ref.read(clubRepositoryProvider).getFreeEntryClubs();
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref.read(clubRepositoryProvider).getFreeEntryClubs(),
    );
  }
}
