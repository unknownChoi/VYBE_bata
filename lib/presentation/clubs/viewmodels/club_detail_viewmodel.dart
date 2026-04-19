import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:vybe/data/models/club_info_model.dart';
import 'package:vybe/data/models/club_model.dart';
import 'package:vybe/data/models/menu_model.dart';
import 'package:vybe/data/repositories/club_repository_impl.dart';

part 'club_detail_viewmodel.g.dart';

@riverpod
Future<ClubModel?> clubDetail(Ref ref, String clubId) {
  return ref.watch(clubRepositoryProvider).getClub(clubId);
}

@riverpod
Future<ClubInfoModel?> clubInfo(Ref ref, String clubId) {
  return ref.watch(clubRepositoryProvider).getClubInfo(clubId);
}

@riverpod
Future<List<MenuModel>> clubMenus(Ref ref, String clubId) {
  return ref.watch(clubRepositoryProvider).getMenus(clubId);
}
