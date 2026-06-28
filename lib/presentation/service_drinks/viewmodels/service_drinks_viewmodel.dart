import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:vybe/data/models/club_model.dart';
import 'package:vybe/data/repositories/club_repository_impl.dart';

part 'service_drinks_viewmodel.g.dart';

/// 서비스 음료(무료 제공) 클럽 목록.
/// clubs 중 serviceDrink.isOffered=true 인 활성 클럽. 종류/위치/정렬 필터는 화면에서 처리.
@riverpod
class ServiceDrinksViewModel extends _$ServiceDrinksViewModel {
  @override
  Future<List<ClubModel>> build() {
    return ref.read(clubRepositoryProvider).getServiceDrinkClubs();
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref.read(clubRepositoryProvider).getServiceDrinkClubs(),
    );
  }
}
